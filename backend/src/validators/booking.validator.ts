import { z } from 'zod'

const packageTypes = ['DOCUMENT', 'PARCEL', 'FOOD', 'GROCERY', 'MEDICINE', 'FRAGILE', 'OTHER'] as const
const paymentMethods = ['CASH', 'UPI', 'CARD', 'WALLET', 'NETBANKING'] as const
const bookingStatuses = ['PENDING', 'ACCEPTED', 'ARRIVED_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_DROP', 'DELIVERED', 'CANCELLED'] as const

export const calculatePriceSchema = z.object({
  body: z.object({
    vehicleTypeId: z.string().cuid('Invalid vehicle type ID'),
    pickupAddressId: z.string().cuid('Invalid pickup address ID'),
    dropAddressId: z.string().cuid('Invalid drop address ID'),
  }),
})

export const createBookingSchema = z.object({
  body: z.object({
    vehicleTypeId: z.string().cuid('Invalid vehicle type ID'),
    pickupAddressId: z.string().cuid('Invalid pickup address ID'),
    dropAddressId: z.string().cuid('Invalid drop address ID'),
    packageType: z.enum(packageTypes).optional(),
    packageWeight: z.number().positive('Weight must be positive').optional(),
    packageDescription: z.string().max(500).optional(),
    scheduledAt: z.string().datetime().optional(),
    paymentMethod: z.enum(paymentMethods).optional(),
  }),
})

export const bookingIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid booking ID'),
  }),
})

export const updateBookingStatusSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid booking ID'),
  }),
  body: z.object({
    status: z.enum(bookingStatuses),
    lat: z.number().min(-90).max(90).optional(),
    lng: z.number().min(-180).max(180).optional(),
    note: z.string().max(500).optional(),
  }),
})

export const cancelBookingSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid booking ID'),
  }),
  body: z.object({
    reason: z.string().min(5, 'Reason must be at least 5 characters').max(500),
  }),
})

export const listBookingsSchema = z.object({
  query: z.object({
    page: z.string().regex(/^\d+$/).transform(Number).optional(),
    limit: z.string().regex(/^\d+$/).transform(Number).optional(),
    status: z.enum(bookingStatuses).optional(),
  }),
})
