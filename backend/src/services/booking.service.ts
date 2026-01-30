import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import {
  calculateDistance,
  generateOTP,
  generateBookingNumber,
  getPaginationParams,
} from '../utils/helpers'
import { BookingStatus, PaymentMethod, PackageType } from '@prisma/client'

interface CreateBookingInput {
  userId: string
  vehicleTypeId: string
  pickupAddressId: string
  dropAddressId: string
  packageType?: PackageType
  packageWeight?: number
  packageDescription?: string
  scheduledAt?: Date
  paymentMethod?: PaymentMethod
}

interface BookingPricing {
  distance: number
  baseFare: number
  distanceFare: number
  taxes: number
  totalAmount: number
}

// Calculate pricing for a booking
export const calculateBookingPrice = async (
  vehicleTypeId: string,
  pickupAddressId: string,
  dropAddressId: string
): Promise<BookingPricing> => {
  // Get vehicle type pricing
  const vehicleType = await prisma.vehicleType.findUnique({
    where: { id: vehicleTypeId },
  })

  if (!vehicleType) {
    throw new AppError('Vehicle type not found', 404)
  }

  // Get addresses
  const [pickupAddress, dropAddress] = await Promise.all([
    prisma.address.findUnique({ where: { id: pickupAddressId } }),
    prisma.address.findUnique({ where: { id: dropAddressId } }),
  ])

  if (!pickupAddress || !dropAddress) {
    throw new AppError('Address not found', 404)
  }

  // Calculate distance
  const distance = calculateDistance(
    pickupAddress.lat,
    pickupAddress.lng,
    dropAddress.lat,
    dropAddress.lng
  )

  // Calculate pricing
  const baseFare = vehicleType.basePrice
  const distanceFare = distance * vehicleType.pricePerKm
  const subtotal = baseFare + distanceFare
  const taxes = subtotal * 0.05 // 5% GST
  const totalAmount = Math.round((subtotal + taxes) * 100) / 100

  return {
    distance: Math.round(distance * 100) / 100,
    baseFare,
    distanceFare: Math.round(distanceFare * 100) / 100,
    taxes: Math.round(taxes * 100) / 100,
    totalAmount,
  }
}

// Create a new booking
export const createBooking = async (input: CreateBookingInput) => {
  const {
    userId,
    vehicleTypeId,
    pickupAddressId,
    dropAddressId,
    packageType = 'PARCEL',
    packageWeight,
    packageDescription,
    scheduledAt,
    paymentMethod = 'CASH',
  } = input

  // Verify user exists
  const user = await prisma.user.findUnique({
    where: { id: userId },
  })

  if (!user) {
    throw new AppError('User not found', 404)
  }

  // Calculate pricing
  const pricing = await calculateBookingPrice(
    vehicleTypeId,
    pickupAddressId,
    dropAddressId
  )

  // Generate OTPs
  const pickupOtp = generateOTP(4)
  const deliveryOtp = generateOTP(4)

  // Create booking
  const booking = await prisma.booking.create({
    data: {
      bookingNumber: generateBookingNumber(),
      userId,
      vehicleTypeId,
      pickupAddressId,
      dropAddressId,
      packageType,
      packageWeight,
      packageDescription,
      distance: pricing.distance,
      baseFare: pricing.baseFare,
      distanceFare: pricing.distanceFare,
      taxes: pricing.taxes,
      totalAmount: pricing.totalAmount,
      paymentMethod,
      scheduledAt,
      pickupOtp,
      deliveryOtp,
      status: 'PENDING',
    },
    include: {
      user: {
        select: { id: true, name: true, phone: true },
      },
      vehicleType: true,
      pickupAddress: true,
      dropAddress: true,
    },
  })

  // Create initial tracking history
  await prisma.trackingHistory.create({
    data: {
      bookingId: booking.id,
      status: 'PENDING',
      note: 'Booking created',
    },
  })

  // TODO: Send notification to nearby pilots
  // TODO: Send confirmation to user

  return booking
}

// Get booking by ID
export const getBookingById = async (bookingId: string, userId?: string) => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: {
      user: {
        select: { id: true, name: true, phone: true },
      },
      pilot: {
        select: { id: true, name: true, phone: true, avatar: true, rating: true },
      },
      vehicleType: true,
      vehicle: true,
      pickupAddress: true,
      dropAddress: true,
      trackingHistory: {
        orderBy: { createdAt: 'desc' },
      },
      review: true,
    },
  })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  // If userId provided, verify ownership
  if (userId && booking.userId !== userId) {
    throw new AppError('Unauthorized access to booking', 403)
  }

  return booking
}

// Get user bookings
export const getUserBookings = async (
  userId: string,
  page: number = 1,
  limit: number = 10,
  status?: BookingStatus
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    userId,
    ...(status && { status }),
  }

  const [bookings, total] = await Promise.all([
    prisma.booking.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      include: {
        vehicleType: true,
        pickupAddress: true,
        dropAddress: true,
        pilot: {
          select: { id: true, name: true, phone: true, avatar: true },
        },
      },
    }),
    prisma.booking.count({ where }),
  ])

  return {
    bookings,
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

// Accept booking (for pilots)
export const acceptBooking = async (bookingId: string, pilotId: string) => {
  // Get pilot with active vehicle
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
    include: {
      vehicles: {
        where: { isActive: true, isVerified: true },
        take: 1,
      },
    },
  })

  if (!pilot || !pilot.isOnline) {
    throw new AppError('Pilot not available', 400)
  }

  if (pilot.vehicles.length === 0) {
    throw new AppError('No verified vehicle found', 400)
  }

  // Get booking
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
  })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  if (booking.status !== 'PENDING') {
    throw new AppError('Booking is no longer available', 400)
  }

  // Update booking
  const updatedBooking = await prisma.booking.update({
    where: { id: bookingId },
    data: {
      pilotId,
      vehicleId: pilot.vehicles[0].id,
      status: 'ACCEPTED',
      acceptedAt: new Date(),
    },
    include: {
      user: { select: { id: true, name: true, phone: true } },
      pilot: { select: { id: true, name: true, phone: true } },
      pickupAddress: true,
      dropAddress: true,
    },
  })

  // Add tracking history
  await prisma.trackingHistory.create({
    data: {
      bookingId,
      status: 'ACCEPTED',
      note: 'Booking accepted by pilot',
    },
  })

  // TODO: Send notification to user

  return updatedBooking
}

// Update booking status (for pilots)
export const updateBookingStatus = async (
  bookingId: string,
  pilotId: string,
  status: BookingStatus,
  lat?: number,
  lng?: number,
  note?: string
) => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
  })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  if (booking.pilotId !== pilotId) {
    throw new AppError('Unauthorized', 403)
  }

  // Validate status transitions
  const validTransitions: Record<BookingStatus, BookingStatus[]> = {
    PENDING: ['ACCEPTED', 'CANCELLED'],
    ACCEPTED: ['ARRIVED_PICKUP', 'CANCELLED'],
    ARRIVED_PICKUP: ['PICKED_UP', 'CANCELLED'],
    PICKED_UP: ['IN_TRANSIT'],
    IN_TRANSIT: ['ARRIVED_DROP'],
    ARRIVED_DROP: ['DELIVERED'],
    DELIVERED: [],
    CANCELLED: [],
  }

  if (!validTransitions[booking.status].includes(status)) {
    throw new AppError(`Cannot transition from ${booking.status} to ${status}`, 400)
  }

  // Prepare update data
  const updateData: Record<string, unknown> = { status }

  if (status === 'PICKED_UP') {
    updateData.pickedUpAt = new Date()
  } else if (status === 'DELIVERED') {
    updateData.deliveredAt = new Date()
  } else if (status === 'CANCELLED') {
    updateData.cancelledAt = new Date()
    updateData.cancelReason = note
  }

  if (lat && lng) {
    updateData.currentLat = lat
    updateData.currentLng = lng
  }

  // Update booking
  const updatedBooking = await prisma.booking.update({
    where: { id: bookingId },
    data: updateData,
    include: {
      user: { select: { id: true, name: true, phone: true } },
      pilot: { select: { id: true, name: true, phone: true } },
      pickupAddress: true,
      dropAddress: true,
    },
  })

  // Add tracking history
  await prisma.trackingHistory.create({
    data: {
      bookingId,
      status,
      lat,
      lng,
      note,
    },
  })

  // If delivered, update pilot stats
  if (status === 'DELIVERED') {
    await prisma.pilot.update({
      where: { id: pilotId },
      data: {
        totalDeliveries: { increment: 1 },
        totalEarnings: { increment: booking.totalAmount * 0.8 }, // 80% to pilot
      },
    })

    // Create earning record
    await prisma.earning.create({
      data: {
        pilotId,
        bookingId,
        amount: booking.totalAmount * 0.8,
        type: 'DELIVERY',
        status: 'PENDING',
      },
    })
  }

  return updatedBooking
}

// Cancel booking
export const cancelBooking = async (
  bookingId: string,
  userId: string,
  reason: string
) => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
  })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  if (booking.userId !== userId) {
    throw new AppError('Unauthorized', 403)
  }

  // Can only cancel pending or accepted bookings
  if (!['PENDING', 'ACCEPTED'].includes(booking.status)) {
    throw new AppError('Booking cannot be cancelled at this stage', 400)
  }

  const updatedBooking = await prisma.booking.update({
    where: { id: bookingId },
    data: {
      status: 'CANCELLED',
      cancelledAt: new Date(),
      cancelReason: reason,
    },
  })

  // Add tracking history
  await prisma.trackingHistory.create({
    data: {
      bookingId,
      status: 'CANCELLED',
      note: `Cancelled by user: ${reason}`,
    },
  })

  return updatedBooking
}
