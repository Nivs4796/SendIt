import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { Gender, PilotStatus } from '@prisma/client'

interface RegisterPilotInput {
  phone: string
  name: string
  email?: string
  dateOfBirth?: Date
  gender?: Gender
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

  const pilot = await prisma.pilot.create({
    data: input,
    select: {
      id: true,
      phone: true,
      name: true,
      email: true,
      status: true,
      createdAt: true,
    },
  })

  return pilot
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
