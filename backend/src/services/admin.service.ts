import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { PilotStatus, BookingStatus } from '@prisma/client'
import logger from '../config/logger'

// ============================================
// DASHBOARD STATISTICS
// ============================================

export const getDashboardStats = async () => {
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const [
    totalUsers,
    totalPilots,
    activePilots,
    onlinePilots,
    pendingPilots,
    totalBookings,
    todayBookings,
    completedBookings,
    pendingBookings,
    cancelledBookings,
    totalRevenue,
    todayRevenue,
  ] = await Promise.all([
    prisma.user.count(),
    prisma.pilot.count(),
    prisma.pilot.count({ where: { status: 'APPROVED', isActive: true } }),
    prisma.pilot.count({ where: { isOnline: true } }),
    prisma.pilot.count({ where: { status: 'PENDING' } }),
    prisma.booking.count(),
    prisma.booking.count({ where: { createdAt: { gte: today } } }),
    prisma.booking.count({ where: { status: 'DELIVERED' } }),
    prisma.booking.count({ where: { status: 'PENDING' } }),
    prisma.booking.count({ where: { status: 'CANCELLED' } }),
    prisma.booking.aggregate({
      where: { status: 'DELIVERED' },
      _sum: { totalAmount: true },
    }),
    prisma.booking.aggregate({
      where: { status: 'DELIVERED', deliveredAt: { gte: today } },
      _sum: { totalAmount: true },
    }),
  ])

  return {
    users: {
      total: totalUsers,
    },
    pilots: {
      total: totalPilots,
      active: activePilots,
      online: onlinePilots,
      pending: pendingPilots,
    },
    bookings: {
      total: totalBookings,
      today: todayBookings,
      completed: completedBookings,
      pending: pendingBookings,
      cancelled: cancelledBookings,
    },
    revenue: {
      total: totalRevenue._sum.totalAmount || 0,
      today: todayRevenue._sum.totalAmount || 0,
    },
  }
}

// ============================================
// USER MANAGEMENT
// ============================================

export const listUsers = async (
  page: number = 1,
  limit: number = 10,
  search?: string,
  isActive?: boolean
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    ...(isActive !== undefined && { isActive }),
    ...(search && {
      OR: [
        { name: { contains: search, mode: 'insensitive' as const } },
        { phone: { contains: search } },
        { email: { contains: search, mode: 'insensitive' as const } },
      ],
    }),
  }

  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        phone: true,
        email: true,
        name: true,
        avatar: true,
        walletBalance: true,
        isVerified: true,
        isActive: true,
        createdAt: true,
        _count: {
          select: { bookings: true },
        },
      },
    }),
    prisma.user.count({ where }),
  ])

  return {
    users,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const getUserDetails = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    include: {
      addresses: true,
      bookings: {
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: {
          vehicleType: true,
          pilot: { select: { name: true, phone: true } },
        },
      },
      _count: {
        select: { bookings: true, reviews: true, addresses: true },
      },
    },
  })

  if (!user) {
    throw new AppError('User not found', 404)
  }

  // Get booking stats
  const bookingStats = await prisma.booking.groupBy({
    by: ['status'],
    where: { userId },
    _count: true,
  })

  return { user, bookingStats }
}

export const updateUserStatus = async (userId: string, isActive: boolean) => {
  const user = await prisma.user.update({
    where: { id: userId },
    data: { isActive },
    select: { id: true, name: true, phone: true, isActive: true },
  })

  logger.info(`User ${userId} status updated to ${isActive ? 'active' : 'suspended'}`)
  return user
}

export const updateUser = async (
  userId: string,
  data: { name?: string; email?: string; phone?: string }
) => {
  // Check if user exists
  const existingUser = await prisma.user.findUnique({ where: { id: userId } })
  if (!existingUser) {
    throw new AppError('User not found', 404)
  }

  // Check for unique constraints if updating email or phone
  if (data.email && data.email !== existingUser.email) {
    const emailExists = await prisma.user.findUnique({ where: { email: data.email } })
    if (emailExists) {
      throw new AppError('Email already in use', 400)
    }
  }

  if (data.phone && data.phone !== existingUser.phone) {
    const phoneExists = await prisma.user.findUnique({ where: { phone: data.phone } })
    if (phoneExists) {
      throw new AppError('Phone already in use', 400)
    }
  }

  const user = await prisma.user.update({
    where: { id: userId },
    data,
    select: {
      id: true,
      name: true,
      email: true,
      phone: true,
      avatar: true,
      walletBalance: true,
      isVerified: true,
      isActive: true,
      createdAt: true,
      updatedAt: true,
    },
  })

  logger.info(`User ${userId} profile updated by admin`)
  return user
}

// ============================================
// PILOT MANAGEMENT
// ============================================

export const listPilots = async (
  page: number = 1,
  limit: number = 10,
  status?: PilotStatus,
  search?: string,
  isOnline?: boolean
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    ...(status && { status }),
    ...(isOnline !== undefined && { isOnline }),
    ...(search && {
      OR: [
        { name: { contains: search, mode: 'insensitive' as const } },
        { phone: { contains: search } },
        { email: { contains: search, mode: 'insensitive' as const } },
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
        email: true,
        name: true,
        avatar: true,
        status: true,
        isOnline: true,
        isVerified: true,
        rating: true,
        totalDeliveries: true,
        totalEarnings: true,
        createdAt: true,
        _count: {
          select: { vehicles: true },
        },
      },
    }),
    prisma.pilot.count({ where }),
  ])

  return {
    pilots,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const getPilotDetails = async (pilotId: string) => {
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
    include: {
      vehicles: { include: { vehicleType: true } },
      documents: true,
      bankAccounts: true,
      bookings: {
        take: 10,
        orderBy: { createdAt: 'desc' },
        include: {
          user: { select: { name: true, phone: true } },
          pickupAddress: true,
          dropAddress: true,
        },
      },
      _count: {
        select: { bookings: true, reviews: true },
      },
    },
  })

  if (!pilot) {
    throw new AppError('Pilot not found', 404)
  }

  // Get booking stats
  const bookingStats = await prisma.booking.groupBy({
    by: ['status'],
    where: { pilotId },
    _count: true,
  })

  // Get earnings summary
  const earningsSummary = await prisma.earning.aggregate({
    where: { pilotId },
    _sum: { amount: true },
  })

  return { pilot, bookingStats, totalEarnings: earningsSummary._sum.amount || 0 }
}

export const updatePilotStatus = async (
  pilotId: string,
  status: PilotStatus,
  reason?: string
) => {
  const pilot = await prisma.pilot.update({
    where: { id: pilotId },
    data: {
      status,
      isVerified: status === 'APPROVED',
      isActive: status !== 'SUSPENDED',
    },
    select: { id: true, name: true, phone: true, status: true },
  })

  // Create notification for pilot
  await prisma.notification.create({
    data: {
      pilotId,
      title: `Account ${status}`,
      body: reason || `Your account status has been updated to ${status}`,
      type: 'SYSTEM',
    },
  })

  logger.info(`Pilot ${pilotId} status updated to ${status}`)
  return pilot
}

export const verifyPilotDocument = async (
  documentId: string,
  status: 'APPROVED' | 'REJECTED',
  rejectedReason?: string
) => {
  const document = await prisma.document.update({
    where: { id: documentId },
    data: {
      status,
      rejectedReason: status === 'REJECTED' ? rejectedReason : null,
      verifiedAt: status === 'APPROVED' ? new Date() : null,
    },
  })

  logger.info(`Document ${documentId} ${status}`)
  return document
}

export const updatePilot = async (
  pilotId: string,
  data: { name?: string; email?: string; phone?: string; dateOfBirth?: Date; gender?: 'MALE' | 'FEMALE' | 'OTHER' }
) => {
  const existingPilot = await prisma.pilot.findUnique({ where: { id: pilotId } })
  if (!existingPilot) {
    throw new AppError('Pilot not found', 404)
  }

  // Check for unique constraints
  if (data.email && data.email !== existingPilot.email) {
    const emailExists = await prisma.pilot.findUnique({ where: { email: data.email } })
    if (emailExists) {
      throw new AppError('Email already in use', 400)
    }
  }

  if (data.phone && data.phone !== existingPilot.phone) {
    const phoneExists = await prisma.pilot.findUnique({ where: { phone: data.phone } })
    if (phoneExists) {
      throw new AppError('Phone already in use', 400)
    }
  }

  const pilot = await prisma.pilot.update({
    where: { id: pilotId },
    data,
    select: {
      id: true,
      name: true,
      email: true,
      phone: true,
      avatar: true,
      dateOfBirth: true,
      gender: true,
      status: true,
      isOnline: true,
      isVerified: true,
      isActive: true,
      rating: true,
      totalDeliveries: true,
      totalEarnings: true,
      createdAt: true,
      updatedAt: true,
    },
  })

  logger.info(`Pilot ${pilotId} profile updated by admin`)
  return pilot
}

// ============================================
// BOOKING MANAGEMENT
// ============================================

export const listBookings = async (
  page: number = 1,
  limit: number = 10,
  status?: BookingStatus,
  search?: string,
  dateFrom?: Date,
  dateTo?: Date,
  pilotId?: string
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    ...(status && { status }),
    ...(pilotId && { pilotId }),
    ...(search && {
      OR: [
        { bookingNumber: { contains: search, mode: 'insensitive' as const } },
        { user: { phone: { contains: search } } },
        { pilot: { phone: { contains: search } } },
      ],
    }),
    ...(dateFrom && { createdAt: { gte: dateFrom } }),
    ...(dateTo && { createdAt: { lte: dateTo } }),
  }

  const [bookings, total] = await Promise.all([
    prisma.booking.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, name: true, phone: true } },
        pilot: { select: { id: true, name: true, phone: true } },
        vehicleType: true,
        pickupAddress: true,
        dropAddress: true,
      },
    }),
    prisma.booking.count({ where }),
  ])

  return {
    bookings,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const getBookingDetails = async (bookingId: string) => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: {
      user: true,
      pilot: true,
      vehicle: { include: { vehicleType: true } },
      vehicleType: true,
      pickupAddress: true,
      dropAddress: true,
      trackingHistory: { orderBy: { createdAt: 'asc' } },
      payment: true,
      review: true,
    },
  })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  return booking
}

export const assignPilotToBooking = async (bookingId: string, pilotId: string) => {
  const [booking, pilot] = await Promise.all([
    prisma.booking.findUnique({ where: { id: bookingId } }),
    prisma.pilot.findUnique({
      where: { id: pilotId },
      include: {
        vehicles: {
          where: { isActive: true, isVerified: true },
          take: 1,
        },
      },
    }),
  ])

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  if (booking.status !== 'PENDING') {
    throw new AppError('Booking cannot be assigned', 400)
  }

  if (!pilot || pilot.status !== 'APPROVED' || pilot.vehicles.length === 0) {
    throw new AppError('Pilot not available or no verified vehicle', 400)
  }

  const updatedBooking = await prisma.booking.update({
    where: { id: bookingId },
    data: {
      pilotId,
      vehicleId: pilot.vehicles[0].id,
      status: 'ACCEPTED',
      acceptedAt: new Date(),
    },
    include: {
      user: { select: { name: true, phone: true } },
      pilot: { select: { name: true, phone: true } },
    },
  })

  await prisma.trackingHistory.create({
    data: {
      bookingId,
      status: 'ACCEPTED',
      note: 'Assigned by admin',
    },
  })

  logger.info(`Booking ${bookingId} assigned to pilot ${pilotId} by admin`)
  return updatedBooking
}

export const cancelBookingByAdmin = async (bookingId: string, reason: string) => {
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
  })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  if (['DELIVERED', 'CANCELLED'].includes(booking.status)) {
    throw new AppError('Booking cannot be cancelled', 400)
  }

  const updatedBooking = await prisma.booking.update({
    where: { id: bookingId },
    data: {
      status: 'CANCELLED',
      cancelledAt: new Date(),
      cancelReason: `Admin: ${reason}`,
    },
  })

  await prisma.trackingHistory.create({
    data: {
      bookingId,
      status: 'CANCELLED',
      note: `Cancelled by admin: ${reason}`,
    },
  })

  logger.info(`Booking ${bookingId} cancelled by admin: ${reason}`)
  return updatedBooking
}

export const updateBookingStatusByAdmin = async (
  bookingId: string,
  status: BookingStatus,
  note?: string
) => {
  const booking = await prisma.booking.findUnique({ where: { id: bookingId } })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  if (['DELIVERED', 'CANCELLED'].includes(booking.status)) {
    throw new AppError('Cannot update status of completed or cancelled booking', 400)
  }

  // Build timestamp updates based on status
  // Note: Prisma Booking model only has acceptedAt, pickedUpAt, deliveredAt, cancelledAt
  const timestampUpdates: Record<string, Date> = {}
  if (status === 'ACCEPTED') timestampUpdates.acceptedAt = new Date()
  if (status === 'PICKED_UP') timestampUpdates.pickedUpAt = new Date()
  if (status === 'DELIVERED') timestampUpdates.deliveredAt = new Date()

  const updatedBooking = await prisma.booking.update({
    where: { id: bookingId },
    data: {
      status,
      ...timestampUpdates,
    },
    include: {
      user: { select: { name: true, phone: true } },
      pilot: { select: { name: true, phone: true } },
      pickupAddress: true,
      dropAddress: true,
    },
  })

  // Create tracking history entry
  await prisma.trackingHistory.create({
    data: {
      bookingId,
      status,
      note: note ? `Admin override: ${note}` : 'Status updated by admin',
    },
  })

  logger.info(`Booking ${bookingId} status updated to ${status} by admin`)
  return updatedBooking
}

// ============================================
// SETTINGS MANAGEMENT
// ============================================

export const getSettings = async () => {
  const settings = await prisma.setting.findMany({
    orderBy: { key: 'asc' },
  })

  // Convert to key-value object
  const settingsObj: Record<string, string> = {}
  settings.forEach((s) => {
    settingsObj[s.key] = s.value
  })

  return settingsObj
}

export const updateSetting = async (key: string, value: string, description?: string) => {
  const setting = await prisma.setting.upsert({
    where: { key },
    update: { value, description },
    create: { key, value, description },
  })

  logger.info(`Setting ${key} updated to ${value}`)
  return setting
}

export const updateMultipleSettings = async (settings: Array<{ key: string; value: string; description?: string }>) => {
  const results = await Promise.all(
    settings.map((s) => updateSetting(s.key, s.value, s.description))
  )
  return results
}

// ============================================
// ANALYTICS
// ============================================

export const getBookingAnalytics = async (days: number = 30) => {
  const startDate = new Date()
  startDate.setDate(startDate.getDate() - days)

  // Daily bookings
  const dailyBookings = await prisma.$queryRaw`
    SELECT
      DATE("createdAt") as date,
      COUNT(*) as total,
      COUNT(CASE WHEN status = 'DELIVERED' THEN 1 END) as completed,
      COUNT(CASE WHEN status = 'CANCELLED' THEN 1 END) as cancelled,
      SUM(CASE WHEN status = 'DELIVERED' THEN "totalAmount" ELSE 0 END) as revenue
    FROM bookings
    WHERE "createdAt" >= ${startDate}
    GROUP BY DATE("createdAt")
    ORDER BY date DESC
  ` as Array<{ date: Date; total: bigint; completed: bigint; cancelled: bigint; revenue: number }>

  // Status distribution
  const statusDistribution = await prisma.booking.groupBy({
    by: ['status'],
    where: { createdAt: { gte: startDate } },
    _count: true,
  })

  // Vehicle type distribution
  const vehicleDistribution = await prisma.booking.groupBy({
    by: ['vehicleTypeId'],
    where: { createdAt: { gte: startDate } },
    _count: true,
  })

  return {
    dailyBookings: dailyBookings.map((d) => ({
      date: d.date,
      total: Number(d.total),
      completed: Number(d.completed),
      cancelled: Number(d.cancelled),
      revenue: d.revenue || 0,
    })),
    statusDistribution,
    vehicleDistribution,
  }
}

export const getRevenueAnalytics = async (days: number = 30) => {
  const startDate = new Date()
  startDate.setDate(startDate.getDate() - days)

  const revenueData = await prisma.$queryRaw`
    SELECT
      DATE("deliveredAt") as date,
      SUM("totalAmount") as revenue,
      COUNT(*) as orders
    FROM bookings
    WHERE status = 'DELIVERED' AND "deliveredAt" >= ${startDate}
    GROUP BY DATE("deliveredAt")
    ORDER BY date DESC
  ` as Array<{ date: Date; revenue: number; orders: bigint }>

  const totalRevenue = await prisma.booking.aggregate({
    where: { status: 'DELIVERED', deliveredAt: { gte: startDate } },
    _sum: { totalAmount: true },
    _count: true,
  })

  return {
    daily: revenueData.map((d) => ({
      date: d.date,
      revenue: d.revenue || 0,
      orders: Number(d.orders),
    })),
    total: totalRevenue._sum.totalAmount || 0,
    totalOrders: totalRevenue._count,
  }
}

// ============================================
// VEHICLE MANAGEMENT
// ============================================

export const listAllVehicles = async (
  page: number = 1,
  limit: number = 10,
  search?: string,
  isVerified?: boolean,
  vehicleTypeId?: string
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    ...(isVerified !== undefined && { isVerified }),
    ...(vehicleTypeId && { vehicleTypeId }),
    ...(search && {
      OR: [
        { registrationNo: { contains: search, mode: 'insensitive' as const } },
        { model: { contains: search, mode: 'insensitive' as const } },
        { pilot: { name: { contains: search, mode: 'insensitive' as const } } },
        { pilot: { phone: { contains: search } } },
      ],
    }),
  }

  const [vehicles, total] = await Promise.all([
    prisma.vehicle.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      include: {
        pilot: { select: { id: true, name: true, phone: true, status: true } },
        vehicleType: true,
      },
    }),
    prisma.vehicle.count({ where }),
  ])

  return {
    vehicles,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const getVehicleDetails = async (vehicleId: string) => {
  const vehicle = await prisma.vehicle.findUnique({
    where: { id: vehicleId },
    include: {
      pilot: {
        select: {
          id: true,
          name: true,
          phone: true,
          email: true,
          status: true,
          rating: true,
        },
      },
      vehicleType: true,
      bookings: {
        take: 5,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          bookingNumber: true,
          status: true,
          createdAt: true,
        },
      },
    },
  })

  if (!vehicle) {
    throw new AppError('Vehicle not found', 404)
  }

  return vehicle
}

export const verifyVehicle = async (
  vehicleId: string,
  isVerified: boolean,
  reason?: string
) => {
  const vehicle = await prisma.vehicle.update({
    where: { id: vehicleId },
    data: { isVerified },
    include: {
      pilot: { select: { id: true, name: true } },
      vehicleType: true,
    },
  })

  // Notify pilot
  await prisma.notification.create({
    data: {
      pilotId: vehicle.pilotId,
      title: `Vehicle ${isVerified ? 'Verified' : 'Rejected'}`,
      body: reason || `Your vehicle ${vehicle.registrationNo || ''} has been ${isVerified ? 'verified' : 'rejected'}`,
      type: 'SYSTEM',
    },
  })

  logger.info(`Vehicle ${vehicleId} ${isVerified ? 'verified' : 'rejected'} by admin`)
  return vehicle
}

// ============================================
// WALLET TRANSACTIONS
// ============================================

export const listWalletTransactions = async (
  page: number = 1,
  limit: number = 10,
  userId?: string,
  type?: 'CREDIT' | 'DEBIT',
  dateFrom?: Date,
  dateTo?: Date
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    ...(userId && { userId }),
    ...(type && { type }),
    ...(dateFrom && { createdAt: { gte: dateFrom } }),
    ...(dateTo && { createdAt: { lte: dateTo } }),
  }

  const [transactions, total] = await Promise.all([
    prisma.walletTransaction.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.walletTransaction.count({ where }),
  ])

  // Get user details for transactions
  const userIds = [...new Set(transactions.map((t) => t.userId))]
  const users = await prisma.user.findMany({
    where: { id: { in: userIds } },
    select: { id: true, name: true, phone: true },
  })
  const userMap = new Map(users.map((u) => [u.id, u]))

  const transactionsWithUsers = transactions.map((t) => ({
    ...t,
    user: userMap.get(t.userId),
  }))

  return {
    transactions: transactionsWithUsers,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}
