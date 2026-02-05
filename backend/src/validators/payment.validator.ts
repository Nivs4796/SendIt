import { z } from 'zod'

export const createOrderSchema = z.object({
  body: z.object({
    bookingId: z.string().min(1, 'Booking ID is required'),
    amount: z.number().positive('Amount must be positive'),
  }),
})

export const verifyPaymentSchema = z.object({
  body: z.object({
    orderId: z.string().min(1, 'Order ID is required'),
    paymentId: z.string().min(1, 'Payment ID is required'),
    signature: z.string().min(1, 'Signature is required'),
    bookingId: z.string().optional(),
  }),
})

export const walletTopupSchema = z.object({
  body: z.object({
    amount: z
      .number()
      .min(10, 'Minimum topup is ₹10')
      .max(10000, 'Maximum topup is ₹10,000'),
  }),
})

export const verifyWalletSchema = z.object({
  body: z.object({
    orderId: z.string().min(1, 'Order ID is required'),
    paymentId: z.string().min(1, 'Payment ID is required'),
    signature: z.string().min(1, 'Signature is required'),
    amount: z.number().positive('Amount must be positive'),
  }),
})
