import { z } from 'zod'

export const addMoneySchema = z.object({
  body: z.object({
    amount: z
      .number()
      .positive('Amount must be positive')
      .max(100000, 'Maximum amount is ₹100,000'),
  }),
})

export const checkBalanceSchema = z.object({
  body: z.object({
    amount: z.number().positive('Amount must be positive'),
  }),
})

export const addBonusSchema = z.object({
  body: z.object({
    userId: z.string().min(1, 'User ID is required'),
    amount: z
      .number()
      .positive('Amount must be positive')
      .max(10000, 'Maximum bonus is ₹10,000'),
    reason: z.string().min(1, 'Reason is required').max(200),
  }),
})

export const refundSchema = z.object({
  body: z.object({
    userId: z.string().min(1, 'User ID is required'),
    amount: z.number().positive('Amount must be positive'),
    bookingId: z.string().optional(),
    reason: z.string().max(200).optional(),
  }),
})
