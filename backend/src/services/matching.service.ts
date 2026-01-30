import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { calculateDistance } from '../utils/helpers'
import { BookingStatus } from '@prisma/client'
import logger from '../config/logger'

// Configuration for matching algorithm
const MATCHING_CONFIG = {
  DEFAULT_RADIUS_KM: 5,
  MAX_RADIUS_KM: 15,
  RADIUS_INCREMENT_KM: 2,
  JOB_OFFER_TIMEOUT_SECONDS: 30,
  MAX_OFFER_ATTEMPTS: 5,
  WEIGHT_DISTANCE: 0.4,
  WEIGHT_RATING: 0.3,
  WEIGHT_DELIVERIES: 0.2,
  WEIGHT_ACCEPTANCE_RATE: 0.1,
}

interface PilotWithScore {
  id: string
  name: string
  phone: string
  avatar: string | null
  rating: number
  totalDeliveries: number
  currentLat: number
  currentLng: number
  distanceKm: number
  score: number
  vehicleId: string
  vehicleType: string
  vehicleRegistration: string | null
}

interface JobOffer {
  id: string
  bookingId: string
  pilotId: string
  status: 'PENDING' | 'ACCEPTED' | 'DECLINED' | 'EXPIRED'
  offeredAt: Date
  expiresAt: Date
  respondedAt?: Date
}

// In-memory store for active job offers (in production, use Redis)
const activeJobOffers = new Map<string, JobOffer>()

/**
 * Find available pilots near pickup location with matching vehicle type
 */
export const findAvailablePilots = async (
  pickupLat: number,
  pickupLng: number,
  vehicleTypeId: string,
  radiusKm: number = MATCHING_CONFIG.DEFAULT_RADIUS_KM
): Promise<PilotWithScore[]> => {
  // Calculate bounding box for initial filter
  const latDelta = radiusKm / 111
  const lngDelta = radiusKm / (111 * Math.cos(pickupLat * Math.PI / 180))

  // Find pilots who are online, approved, and have the right vehicle type
  const pilots = await prisma.pilot.findMany({
    where: {
      isOnline: true,
      isActive: true,
      status: 'APPROVED',
      currentLat: {
        gte: pickupLat - latDelta,
        lte: pickupLat + latDelta,
      },
      currentLng: {
        gte: pickupLng - lngDelta,
        lte: pickupLng + lngDelta,
      },
      vehicles: {
        some: {
          vehicleTypeId,
          isActive: true,
          isVerified: true,
        },
      },
      // Exclude pilots who are currently on an active delivery
      bookings: {
        none: {
          status: {
            in: ['ACCEPTED', 'ARRIVED_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_DROP'],
          },
        },
      },
    },
    include: {
      vehicles: {
        where: {
          vehicleTypeId,
          isActive: true,
          isVerified: true,
        },
        include: {
          vehicleType: true,
        },
        take: 1,
      },
      _count: {
        select: {
          bookings: {
            where: { status: 'DELIVERED' },
          },
        },
      },
    },
  })

  // Calculate distance and score for each pilot
  const pilotsWithScores: PilotWithScore[] = pilots
    .map((pilot) => {
      const distanceKm = calculateDistance(
        pickupLat,
        pickupLng,
        pilot.currentLat!,
        pilot.currentLng!
      )

      // Only include pilots within the actual radius (circle, not square)
      if (distanceKm > radiusKm) {
        return null
      }

      const vehicle = pilot.vehicles[0]
      if (!vehicle) return null

      // Calculate composite score
      const score = calculatePilotScore(
        distanceKm,
        pilot.rating,
        pilot.totalDeliveries,
        radiusKm
      )

      return {
        id: pilot.id,
        name: pilot.name,
        phone: pilot.phone,
        avatar: pilot.avatar,
        rating: pilot.rating,
        totalDeliveries: pilot.totalDeliveries,
        currentLat: pilot.currentLat!,
        currentLng: pilot.currentLng!,
        distanceKm: Math.round(distanceKm * 100) / 100,
        score,
        vehicleId: vehicle.id,
        vehicleType: vehicle.vehicleType.name,
        vehicleRegistration: vehicle.registrationNo,
      }
    })
    .filter((p): p is PilotWithScore => p !== null)
    .sort((a, b) => b.score - a.score) // Sort by score descending

  return pilotsWithScores
}

/**
 * Calculate pilot score based on multiple factors
 */
const calculatePilotScore = (
  distanceKm: number,
  rating: number,
  totalDeliveries: number,
  maxRadiusKm: number
): number => {
  // Normalize distance (closer = higher score)
  const distanceScore = 1 - (distanceKm / maxRadiusKm)

  // Normalize rating (0-5 scale)
  const ratingScore = rating / 5

  // Normalize deliveries (log scale to prevent extreme values)
  const deliveryScore = Math.min(Math.log10(totalDeliveries + 1) / 3, 1)

  // Weighted composite score
  const score =
    MATCHING_CONFIG.WEIGHT_DISTANCE * distanceScore +
    MATCHING_CONFIG.WEIGHT_RATING * ratingScore +
    MATCHING_CONFIG.WEIGHT_DELIVERIES * deliveryScore

  return Math.round(score * 100) / 100
}

/**
 * Find and assign best pilot for a booking
 */
export const findAndAssignPilot = async (bookingId: string): Promise<{
  success: boolean
  pilot?: PilotWithScore
  message: string
}> => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: {
      pickupAddress: true,
      vehicleType: true,
    },
  })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  if (booking.status !== 'PENDING') {
    throw new AppError('Booking is no longer available for assignment', 400)
  }

  const { lat: pickupLat, lng: pickupLng } = booking.pickupAddress
  let currentRadius = MATCHING_CONFIG.DEFAULT_RADIUS_KM
  let pilots: PilotWithScore[] = []

  // Expand search radius until we find pilots or hit max
  while (currentRadius <= MATCHING_CONFIG.MAX_RADIUS_KM && pilots.length === 0) {
    pilots = await findAvailablePilots(
      pickupLat,
      pickupLng,
      booking.vehicleTypeId,
      currentRadius
    )

    if (pilots.length === 0) {
      currentRadius += MATCHING_CONFIG.RADIUS_INCREMENT_KM
      logger.info(`No pilots found in ${currentRadius - MATCHING_CONFIG.RADIUS_INCREMENT_KM}km, expanding to ${currentRadius}km`)
    }
  }

  if (pilots.length === 0) {
    logger.warn(`No available pilots found for booking ${bookingId} within ${MATCHING_CONFIG.MAX_RADIUS_KM}km`)
    return {
      success: false,
      message: `No available pilots found within ${MATCHING_CONFIG.MAX_RADIUS_KM}km radius`,
    }
  }

  logger.info(`Found ${pilots.length} available pilots for booking ${bookingId}`)

  // Return the best pilot (for manual or automatic assignment)
  return {
    success: true,
    pilot: pilots[0],
    message: `Found ${pilots.length} available pilot(s)`,
  }
}

/**
 * Create a job offer for a pilot
 */
export const createJobOffer = async (
  bookingId: string,
  pilotId: string
): Promise<JobOffer> => {
  // Check if booking is still pending
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
  })

  if (!booking || booking.status !== 'PENDING') {
    throw new AppError('Booking is no longer available', 400)
  }

  // Check if pilot is still available
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
  })

  if (!pilot || !pilot.isOnline || pilot.status !== 'APPROVED') {
    throw new AppError('Pilot is not available', 400)
  }

  const now = new Date()
  const expiresAt = new Date(now.getTime() + MATCHING_CONFIG.JOB_OFFER_TIMEOUT_SECONDS * 1000)

  const offer: JobOffer = {
    id: `offer_${bookingId}_${pilotId}_${now.getTime()}`,
    bookingId,
    pilotId,
    status: 'PENDING',
    offeredAt: now,
    expiresAt,
  }

  activeJobOffers.set(offer.id, offer)

  // Store offer in database for persistence
  await prisma.notification.create({
    data: {
      pilotId,
      title: 'New Delivery Request',
      body: `New delivery job available - ${MATCHING_CONFIG.JOB_OFFER_TIMEOUT_SECONDS}s to accept`,
      type: 'BOOKING',
      data: {
        offerId: offer.id,
        bookingId,
        expiresAt: expiresAt.toISOString(),
      },
    },
  })

  logger.info(`Job offer created: ${offer.id} for pilot ${pilotId}`)

  return offer
}

/**
 * Respond to a job offer (accept/decline)
 */
export const respondToJobOffer = async (
  offerId: string,
  pilotId: string,
  accept: boolean
): Promise<{ success: boolean; message: string }> => {
  const offer = activeJobOffers.get(offerId)

  if (!offer) {
    throw new AppError('Job offer not found or expired', 404)
  }

  if (offer.pilotId !== pilotId) {
    throw new AppError('Unauthorized', 403)
  }

  if (offer.status !== 'PENDING') {
    throw new AppError('Job offer already responded to', 400)
  }

  const now = new Date()

  // Check if offer has expired
  if (now > offer.expiresAt) {
    offer.status = 'EXPIRED'
    activeJobOffers.set(offerId, offer)
    throw new AppError('Job offer has expired', 400)
  }

  offer.respondedAt = now

  if (accept) {
    // Try to accept the booking
    const booking = await prisma.booking.findUnique({
      where: { id: offer.bookingId },
    })

    if (!booking || booking.status !== 'PENDING') {
      offer.status = 'EXPIRED'
      activeJobOffers.set(offerId, offer)
      throw new AppError('Booking is no longer available', 400)
    }

    // Get pilot's active vehicle
    const pilot = await prisma.pilot.findUnique({
      where: { id: pilotId },
      include: {
        vehicles: {
          where: {
            vehicleTypeId: booking.vehicleTypeId,
            isActive: true,
            isVerified: true,
          },
          take: 1,
        },
      },
    })

    if (!pilot || pilot.vehicles.length === 0) {
      throw new AppError('No suitable vehicle found', 400)
    }

    // Accept the booking
    await prisma.booking.update({
      where: { id: offer.bookingId },
      data: {
        pilotId,
        vehicleId: pilot.vehicles[0].id,
        status: 'ACCEPTED',
        acceptedAt: now,
      },
    })

    // Add tracking history
    await prisma.trackingHistory.create({
      data: {
        bookingId: offer.bookingId,
        status: 'ACCEPTED',
        lat: pilot.currentLat,
        lng: pilot.currentLng,
        note: 'Job accepted by pilot',
      },
    })

    offer.status = 'ACCEPTED'
    activeJobOffers.set(offerId, offer)

    logger.info(`Job offer ${offerId} accepted by pilot ${pilotId}`)

    return {
      success: true,
      message: 'Job accepted successfully',
    }
  } else {
    offer.status = 'DECLINED'
    activeJobOffers.set(offerId, offer)

    logger.info(`Job offer ${offerId} declined by pilot ${pilotId}`)

    return {
      success: true,
      message: 'Job declined',
    }
  }
}

/**
 * Get pending job offers for a pilot
 */
export const getPendingOffersForPilot = async (pilotId: string): Promise<JobOffer[]> => {
  const now = new Date()
  const pendingOffers: JobOffer[] = []

  for (const [_, offer] of activeJobOffers) {
    if (
      offer.pilotId === pilotId &&
      offer.status === 'PENDING' &&
      now < offer.expiresAt
    ) {
      pendingOffers.push(offer)
    }
  }

  return pendingOffers
}

/**
 * Get available jobs for a pilot (bookings near their location)
 */
export const getAvailableJobsForPilot = async (
  pilotId: string,
  page: number = 1,
  limit: number = 10
): Promise<{
  jobs: Array<{
    id: string
    bookingNumber: string
    pickupAddress: object
    dropAddress: object
    distance: number
    totalAmount: number
    vehicleType: object
    packageType: string
    distanceFromPilot: number
    createdAt: Date
  }>
  meta: { page: number; limit: number; total: number; totalPages: number }
}> => {
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
    include: {
      vehicles: {
        where: { isActive: true, isVerified: true },
        select: { vehicleTypeId: true },
      },
    },
  })

  if (!pilot || !pilot.currentLat || !pilot.currentLng) {
    throw new AppError('Pilot location not available', 400)
  }

  const vehicleTypeIds = pilot.vehicles.map((v) => v.vehicleTypeId)

  if (vehicleTypeIds.length === 0) {
    return {
      jobs: [],
      meta: { page, limit, total: 0, totalPages: 0 },
    }
  }

  // Find pending bookings within radius
  const radiusKm = MATCHING_CONFIG.DEFAULT_RADIUS_KM
  const latDelta = radiusKm / 111
  const lngDelta = radiusKm / (111 * Math.cos(pilot.currentLat * Math.PI / 180))

  const pendingBookings = await prisma.booking.findMany({
    where: {
      status: 'PENDING',
      vehicleTypeId: { in: vehicleTypeIds },
      pickupAddress: {
        lat: {
          gte: pilot.currentLat - latDelta,
          lte: pilot.currentLat + latDelta,
        },
        lng: {
          gte: pilot.currentLng - lngDelta,
          lte: pilot.currentLng + lngDelta,
        },
      },
    },
    include: {
      pickupAddress: true,
      dropAddress: true,
      vehicleType: true,
    },
    orderBy: { createdAt: 'desc' },
  })

  // Calculate distance from pilot and filter
  const jobsWithDistance = pendingBookings
    .map((booking) => {
      const distanceFromPilot = calculateDistance(
        pilot.currentLat!,
        pilot.currentLng!,
        booking.pickupAddress.lat,
        booking.pickupAddress.lng
      )

      if (distanceFromPilot > radiusKm) {
        return null
      }

      return {
        id: booking.id,
        bookingNumber: booking.bookingNumber,
        pickupAddress: booking.pickupAddress,
        dropAddress: booking.dropAddress,
        distance: booking.distance,
        totalAmount: booking.totalAmount,
        vehicleType: booking.vehicleType,
        packageType: booking.packageType,
        distanceFromPilot: Math.round(distanceFromPilot * 100) / 100,
        createdAt: booking.createdAt,
      }
    })
    .filter((j) => j !== null)
    .sort((a, b) => a!.distanceFromPilot - b!.distanceFromPilot)

  // Apply pagination
  const total = jobsWithDistance.length
  const skip = (page - 1) * limit
  const paginatedJobs = jobsWithDistance.slice(skip, skip + limit)

  return {
    jobs: paginatedJobs as Array<{
      id: string
      bookingNumber: string
      pickupAddress: object
      dropAddress: object
      distance: number
      totalAmount: number
      vehicleType: object
      packageType: string
      distanceFromPilot: number
      createdAt: Date
    }>,
    meta: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  }
}

/**
 * Auto-assign booking to best available pilot
 */
export const autoAssignBooking = async (bookingId: string): Promise<{
  success: boolean
  pilotId?: string
  message: string
}> => {
  const result = await findAndAssignPilot(bookingId)

  if (!result.success || !result.pilot) {
    return {
      success: false,
      message: result.message,
    }
  }

  // Create job offer for the best pilot
  const offer = await createJobOffer(bookingId, result.pilot.id)

  return {
    success: true,
    pilotId: result.pilot.id,
    message: `Job offered to pilot ${result.pilot.name}. Waiting for response.`,
  }
}

/**
 * Clean up expired job offers
 */
export const cleanupExpiredOffers = (): void => {
  const now = new Date()

  for (const [id, offer] of activeJobOffers) {
    if (offer.status === 'PENDING' && now > offer.expiresAt) {
      offer.status = 'EXPIRED'
      activeJobOffers.set(id, offer)
      logger.info(`Job offer ${id} expired`)
    }

    // Remove old offers (older than 1 hour)
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000)
    if (offer.offeredAt < oneHourAgo) {
      activeJobOffers.delete(id)
    }
  }
}

// Run cleanup every minute
setInterval(cleanupExpiredOffers, 60 * 1000)
