import { z } from 'zod'

export const createCouponSchema = z.object({
  body: z.object({
    code: z
      .string()
      .min(3, 'Coupon code must be at least 3 characters')
      .max(20, 'Coupon code must be at most 20 characters')
      .regex(/^[A-Z0-9]+$/i, 'Coupon code must be alphanumeric'),
    description: z.string().max(500).optional(),
    discountType: z.enum(['PERCENTAGE', 'FIXED']).optional().default('PERCENTAGE'),
    discountValue: z
      .number()
      .positive('Discount value must be positive'),
    minOrderAmount: z.number().positive().optional(),
    maxDiscount: z.number().positive().optional(),
    usageLimit: z.number().int().positive().optional(),
    perUserLimit: z.number().int().positive().optional().default(1),
    vehicleTypeIds: z.array(z.string()).optional().default([]),
    startsAt: z.string().datetime().optional(),
    expiresAt: z.string().datetime().optional(),
  }).refine((data) => {
    // If discount type is PERCENTAGE, value should be <= 100
    if (data.discountType === 'PERCENTAGE' && data.discountValue > 100) {
      return false
    }
    return true
  }, {
    message: 'Percentage discount cannot exceed 100%',
    path: ['discountValue'],
  }),
})

export const updateCouponSchema = z.object({
  params: z.object({
    id: z.string(),
  }),
  body: z.object({
    description: z.string().max(500).optional(),
    discountType: z.enum(['PERCENTAGE', 'FIXED']).optional(),
    discountValue: z.number().positive().optional(),
    minOrderAmount: z.number().positive().nullable().optional(),
    maxDiscount: z.number().positive().nullable().optional(),
    usageLimit: z.number().int().positive().nullable().optional(),
    perUserLimit: z.number().int().positive().optional(),
    vehicleTypeIds: z.array(z.string()).optional(),
    isActive: z.boolean().optional(),
    startsAt: z.string().datetime().optional(),
    expiresAt: z.string().datetime().nullable().optional(),
  }),
})

export const validateCouponSchema = z.object({
  body: z.object({
    code: z.string().min(1, 'Coupon code is required'),
    orderAmount: z.number().positive('Order amount must be positive'),
    vehicleTypeId: z.string().min(1, 'Vehicle type is required'),
  }),
})
