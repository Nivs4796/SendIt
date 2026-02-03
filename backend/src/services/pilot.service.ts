import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { Gender, PilotStatus, DocumentType } from '@prisma/client'

interface RegisterPilotInput {
  phone: string
  name: string
  email?: string
  date_of_birth?: string
  dateOfBirth?: Date
  gender?: Gender
  // Extra fields from app (stored in pilot record where possible)
  address?: string
  city?: string
  state?: string
  pincode?: string
  // Related data
  vehicle?: {
    type: string
    category: string
    number: string
    model?: string
  }
  documents?: {
    id_proof?: string
    driving_license?: string
    vehicle_rc?: string
    insurance?: string
    parental_consent?: string
  }
  bankDetails?: {
    account_holder: string
    bank_name: string
    account_number: string
    ifsc: string
  }
}

interface UpdatePilotInput {
  name?: string
  email?: string
  avatar?: string
  dateOfBirth?: Date
  gender?: Gender
  aadhaarNumber?: string
  licenseNumber?: string
  panNumber?: string
}

export const registerPilot = async (input: RegisterPilotInput) => {
  const existing = await prisma.pilot.findUnique({ where: { phone: input.phone } })
  if (existing) {
    throw new AppError('Pilot with this phone already exists', 400)
  }

  // Parse date_of_birth string to Date
  let dob: Date | undefined
  if (input.date_of_birth) {
    dob = new Date(input.date_of_birth)
  } else if (input.dateOfBirth) {
    dob = input.dateOfBirth
  }

  // Create pilot with transaction to handle related records
  const pilot = await prisma.$transaction(async (tx) => {
    // 1. Create pilot
    const newPilot = await tx.pilot.create({
      data: {
        phone: input.phone,
        name: input.name,
        email: input.email,
        dateOfBirth: dob,
      },
    })

    // 2. Create vehicle if provided
    if (input.vehicle) {
      // Map vehicle type string to vehicleTypeId
      const vehicleTypeMap: Record<string, string> = {
        'cycle': 'Cycle',
        'ev_cycle': 'EV Cycle', 
        '2_wheeler': '2 Wheeler',
        '3_wheeler': '3 Wheeler',
        'truck': 'Truck',
      }
      const typeName = vehicleTypeMap[input.vehicle.type] || input.vehicle.type

      const vehicleType = await tx.vehicleType.findFirst({
        where: { name: { contains: typeName, mode: 'insensitive' } },
      })

      if (vehicleType) {
        await tx.vehicle.create({
          data: {
            pilotId: newPilot.id,
            vehicleTypeId: vehicleType.id,
            registrationNo: input.vehicle.number,
            model: input.vehicle.model,
          },
        })
      }
    }

    // 3. Create documents if provided
    if (input.documents) {
      const docTypeMap: Record<string, DocumentType> = {
        'id_proof': 'ID_PROOF',
        'driving_license': 'DRIVING_LICENSE',
        'vehicle_rc': 'VEHICLE_RC',
        'insurance': 'INSURANCE',
        'parental_consent': 'OTHER',
      }

      const docsToCreate = Object.entries(input.documents)
        .filter(([_, url]) => url)
        .map(([type, url]) => ({
          pilotId: newPilot.id,
          type: docTypeMap[type] || 'OTHER',
          url: url as string,
          filename: (url as string).split('/').pop() || 'document',
        }))

      if (docsToCreate.length > 0) {
        await tx.document.createMany({ data: docsToCreate })
      }
    }

    // 4. Create bank account if provided
    if (input.bankDetails) {
      await tx.bankAccount.create({
        data: {
          pilotId: newPilot.id,
          accountName: input.bankDetails.account_holder,
          accountNumber: input.bankDetails.account_number,
          ifscCode: input.bankDetails.ifsc,
          bankName: input.bankDetails.bank_name,
        },
      })
    }

    return newPilot
  })

  return {
    id: pilot.id,
    phone: pilot.phone,
    name: pilot.name,
    email: pilot.email,
    status: pilot.status,
    createdAt: pilot.createdAt,
  }
}

export const getPilotById = async (id: string) => {
  const pilot = await prisma.pilot.findUnique({
    where: { id },
    include: {
      vehicles: { include: { vehicleType: true } },
      bankAccount: true,
      documents: true,
      _count: { select: { bookings: true, reviews: true } },
    },
  })

  if (!pilot) {
    throw new AppError('Pilot not found', 404)
  }

  return pilot
}

export const updatePilot = async (id: string, data: UpdatePilotInput) => {
  const pilot = await prisma.pilot.update({
    where: { id },
    data,
    select: {
      id: true,
      phone: true,
      name: true,
      email: true,
      avatar: true,
      status: true,
      isVerified: true,
      updatedAt: true,
    },
  })

  return pilot
}

export const updateLocation = async (id: string, lat: number, lng: number) => {
  await prisma.pilot.update({
    where: { id },
    data: { currentLat: lat, currentLng: lng, lastLocationAt: new Date() },
  })
}

export const updateOnlineStatus = async (id: string, isOnline: boolean) => {
  const pilot = await prisma.pilot.update({
    where: { id },
    data: { isOnline },
    select: { id: true, isOnline: true },
  })
  return pilot
}

export const getPilotEarnings = async (id: string, page: number = 1, limit: number = 10) => {
  const { skip, take } = getPaginationParams(page, limit)

  const [earnings, total, stats] = await Promise.all([
    prisma.earning.findMany({
      where: { pilotId: id },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.earning.count({ where: { pilotId: id } }),
    prisma.earning.aggregate({
      where: { pilotId: id },
      _sum: { amount: true },
    }),
  ])

  return {
    earnings,
    totalEarnings: stats._sum.amount || 0,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const getPilotBookings = async (id: string, page: number = 1, limit: number = 10) => {
  const { skip, take } = getPaginationParams(page, limit)

  const [bookings, total] = await Promise.all([
    prisma.booking.findMany({
      where: { pilotId: id },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, name: true, phone: true } },
        pickupAddress: true,
        dropAddress: true,
        vehicleType: true,
      },
    }),
    prisma.booking.count({ where: { pilotId: id } }),
  ])

  return {
    bookings,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const listPilots = async (
  page: number = 1,
  limit: number = 10,
  status?: PilotStatus,
  search?: string
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    ...(status && { status }),
    ...(search && {
      OR: [
        { name: { contains: search, mode: 'insensitive' as const } },
        { phone: { contains: search } },
      ],
    }),
  }

  const [pilots, total] = await Promise.all([
    prisma.pilot.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        phone: true,
        name: true,
        avatar: true,
        status: true,
        isOnline: true,
        rating: true,
        totalDeliveries: true,
        createdAt: true,
      },
    }),
    prisma.pilot.count({ where }),
  ])

  return {
    pilots,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const updatePilotStatus = async (id: string, status: PilotStatus) => {
  const pilot = await prisma.pilot.update({
    where: { id },
    data: { status, isVerified: status === 'APPROVED' },
  })
  return pilot
}

export const getNearbyPilots = async (lat: number, lng: number, radiusKm: number = 5) => {
  // Simple box-based query for nearby pilots
  const latDelta = radiusKm / 111 // 1 degree ~ 111km
  const lngDelta = radiusKm / (111 * Math.cos(lat * Math.PI / 180))

  const pilots = await prisma.pilot.findMany({
    where: {
      isOnline: true,
      status: 'APPROVED',
      currentLat: { gte: lat - latDelta, lte: lat + latDelta },
      currentLng: { gte: lng - lngDelta, lte: lng + lngDelta },
    },
    include: {
      vehicles: { where: { isActive: true, isVerified: true }, include: { vehicleType: true } },
    },
  })

  return pilots
}
