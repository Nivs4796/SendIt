import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { DiscountType } from '@prisma/client'

interface CreateCouponInput {
  code: string
  description?: string
  discountType?: DiscountType
  discountValue: number
  minOrderAmount?: number
  maxDiscount?: number
  usageLimit?: number
  perUserLimit?: number
  vehicleTypeIds?: string[]
  startsAt?: Date
  expiresAt?: Date
}

interface UpdateCouponInput {
  description?: string
  discountType?: DiscountType
  discountValue?: number
  minOrderAmount?: number
  maxDiscount?: number
  usageLimit?: number
  perUserLimit?: number
  vehicleTypeIds?: string[]
  isActive?: boolean
  startsAt?: Date
  expiresAt?: Date
}

/**
 * Create a new coupon
 */
export const createCoupon = async (input: CreateCouponInput) => {
  const { code, ...data } = input

  // Check if code already exists
  const existing = await prisma.coupon.findUnique({
    where: { code: code.toUpperCase() },
  })

  if (existing) {
    throw new AppError('Coupon code already exists', 400)
  }

  const coupon = await prisma.coupon.create({
    data: {
      ...data,
      code: code.toUpperCase(),
    },
  })

  return coupon
}

/**
 * Get coupon by ID
 */
export const getCouponById = async (id: string) => {
  const coupon = await prisma.coupon.findUnique({
    where: { id },
    include: {
      _count: {
        select: { usages: true },
      },
    },
  })

  if (!coupon) {
    throw new AppError('Coupon not found', 404)
  }

  return coupon
}

/**
 * Get coupon by code
 */
export const getCouponByCode = async (code: string) => {
  const coupon = await prisma.coupon.findUnique({
    where: { code: code.toUpperCase() },
  })

  if (!coupon) {
    throw new AppError('Coupon not found', 404)
  }

  return coupon
}

/**
 * Update a coupon
 */
export const updateCoupon = async (id: string, data: UpdateCouponInput) => {
  const coupon = await prisma.coupon.update({
    where: { id },
    data,
  })

  return coupon
}

/**
 * Delete a coupon
 */
export const deleteCoupon = async (id: string) => {
  // Check if coupon has been used
  const usageCount = await prisma.couponUsage.count({
    where: { couponId: id },
  })

  if (usageCount > 0) {
    // Soft delete - just deactivate
    await prisma.coupon.update({
      where: { id },
      data: { isActive: false },
    })
  } else {
    // Hard delete
    await prisma.coupon.delete({
      where: { id },
    })
  }
}

/**
 * List all coupons
 */
export const listCoupons = async (
  page: number = 1,
  limit: number = 10,
  isActive?: boolean
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = isActive !== undefined ? { isActive } : {}

  const [coupons, total] = await Promise.all([
    prisma.coupon.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: { usages: true },
        },
      },
    }),
    prisma.coupon.count({ where }),
  ])

  return {
    coupons,
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

/**
 * Validate and calculate discount for a coupon
 */
export const validateCoupon = async (
  code: string,
  userId: string,
  orderAmount: number,
  vehicleTypeId: string
): Promise<{
  valid: boolean
  coupon?: typeof coupon
  discount?: number
  message: string
}> => {
  const coupon = await prisma.coupon.findUnique({
    where: { code: code.toUpperCase() },
  })

  if (!coupon) {
    return { valid: false, message: 'Invalid coupon code' }
  }

  // Check if coupon is active
  if (!coupon.isActive) {
    return { valid: false, message: 'Coupon is no longer active' }
  }

  // Check date validity
  const now = new Date()
  if (coupon.startsAt > now) {
    return { valid: false, message: 'Coupon is not yet valid' }
  }

  if (coupon.expiresAt && coupon.expiresAt < now) {
    return { valid: false, message: 'Coupon has expired' }
  }

  // Check usage limit
  if (coupon.usageLimit && coupon.usageCount >= coupon.usageLimit) {
    return { valid: false, message: 'Coupon usage limit reached' }
  }

  // Check per-user limit
  const userUsageCount = await prisma.couponUsage.count({
    where: {
      couponId: coupon.id,
      userId,
    },
  })

  if (userUsageCount >= coupon.perUserLimit) {
    return { valid: false, message: 'You have already used this coupon' }
  }

  // Check minimum order amount
  if (coupon.minOrderAmount && orderAmount < coupon.minOrderAmount) {
    return {
      valid: false,
      message: `Minimum order amount is ₹${coupon.minOrderAmount}`,
    }
  }

  // Check vehicle type restriction
  if (coupon.vehicleTypeIds.length > 0 && !coupon.vehicleTypeIds.includes(vehicleTypeId)) {
    return { valid: false, message: 'Coupon not valid for this vehicle type' }
  }

  // Calculate discount
  let discount: number

  if (coupon.discountType === 'PERCENTAGE') {
    discount = (orderAmount * coupon.discountValue) / 100
    // Apply max discount cap
    if (coupon.maxDiscount && discount > coupon.maxDiscount) {
      discount = coupon.maxDiscount
    }
  } else {
    // Fixed discount
    discount = coupon.discountValue
    // Don't exceed order amount
    if (discount > orderAmount) {
      discount = orderAmount
    }
  }

  discount = Math.round(discount * 100) / 100

  return {
    valid: true,
    coupon,
    discount,
    message: `Coupon applied! You save ₹${discount}`,
  }
}

/**
 * Apply coupon to a booking
 */
export const applyCoupon = async (
  couponId: string,
  userId: string,
  bookingId: string,
  discount: number
) => {
  // Record usage
  await prisma.couponUsage.create({
    data: {
      couponId,
      userId,
      bookingId,
      discount,
    },
  })

  // Increment usage count
  await prisma.coupon.update({
    where: { id: couponId },
    data: {
      usageCount: { increment: 1 },
    },
  })
}

/**
 * Get user's coupon usage history
 */
export const getUserCouponHistory = async (userId: string, page: number = 1, limit: number = 10) => {
  const { skip, take } = getPaginationParams(page, limit)

  const [usages, total] = await Promise.all([
    prisma.couponUsage.findMany({
      where: { userId },
      skip,
      take,
      orderBy: { usedAt: 'desc' },
      include: {
        coupon: {
          select: {
            code: true,
            description: true,
            discountType: true,
            discountValue: true,
          },
        },
      },
    }),
    prisma.couponUsage.count({ where: { userId } }),
  ])

  return {
    usages,
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

/**
 * Get available coupons for a user
 */
export const getAvailableCoupons = async (
  userId: string,
  orderAmount?: number,
  vehicleTypeId?: string
) => {
  const now = new Date()

  // Get all active coupons that haven't expired
  // Handle both null startsAt (legacy) and valid startsAt dates
  const coupons = await prisma.coupon.findMany({
    where: {
      isActive: true,
      AND: [
        // startsAt: either null (legacy) or <= now
        {
          OR: [
            { startsAt: { lte: now } },
          ],
        },
        // expiresAt: either null (no expiry) or > now
        {
          OR: [
            { expiresAt: null },
            { expiresAt: { gt: now } },
          ],
        },
      ],
    },
    orderBy: { discountValue: 'desc' },
  })

  // Filter and check availability for this user
  const availableCoupons = []

  for (const coupon of coupons) {
    // Check usage limit
    if (coupon.usageLimit && coupon.usageCount >= coupon.usageLimit) {
      continue
    }

    // Check per-user limit
    const userUsageCount = await prisma.couponUsage.count({
      where: {
        couponId: coupon.id,
        userId,
      },
    })

    if (userUsageCount >= coupon.perUserLimit) {
      continue
    }

    // Check vehicle type if provided
    if (vehicleTypeId && coupon.vehicleTypeIds.length > 0) {
      if (!coupon.vehicleTypeIds.includes(vehicleTypeId)) {
        continue
      }
    }

    // Calculate potential discount
    let potentialDiscount: number | null = null
    let isApplicable = true

    if (orderAmount) {
      if (coupon.minOrderAmount && orderAmount < coupon.minOrderAmount) {
        isApplicable = false
      } else {
        if (coupon.discountType === 'PERCENTAGE') {
          potentialDiscount = (orderAmount * coupon.discountValue) / 100
          if (coupon.maxDiscount && potentialDiscount > coupon.maxDiscount) {
            potentialDiscount = coupon.maxDiscount
          }
        } else {
          potentialDiscount = Math.min(coupon.discountValue, orderAmount)
        }
        potentialDiscount = Math.round(potentialDiscount * 100) / 100
      }
    }

    availableCoupons.push({
      ...coupon,
      potentialDiscount,
      isApplicable,
    })
  }

  return availableCoupons
}

/**
 * Get coupon statistics for admin dashboard
 */
export const getCouponStats = async () => {
  const [totalCoupons, activeCoupons, usageStats] = await Promise.all([
    prisma.coupon.count(),
    prisma.coupon.count({
      where: {
        isActive: true,
        OR: [
          { expiresAt: null },
          { expiresAt: { gte: new Date() } },
        ],
      },
    }),
    prisma.couponUsage.aggregate({
      _count: { id: true },
      _sum: { discount: true },
    }),
  ])

  return {
    totalCoupons,
    activeCoupons,
    totalRedemptions: usageStats._count.id,
    totalDiscountGiven: usageStats._sum.discount || 0,
  }
}
