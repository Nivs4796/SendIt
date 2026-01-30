import { z } from 'zod'

export const createAddressSchema = z.object({
  body: z.object({
    label: z.string().min(1, 'Label is required').max(50),
    address: z.string().min(5, 'Address must be at least 5 characters'),
    landmark: z.string().optional(),
    city: z.string().min(2, 'City is required'),
    state: z.string().min(2, 'State is required'),
    pincode: z.string().regex(/^\d{6}$/, 'Pincode must be 6 digits'),
    lat: z.number().min(-90).max(90),
    lng: z.number().min(-180).max(180),
    isDefault: z.boolean().optional(),
  }),
})

export const updateAddressSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid address ID'),
  }),
  body: z.object({
    label: z.string().min(1).max(50).optional(),
    address: z.string().min(5).optional(),
    landmark: z.string().optional(),
    city: z.string().min(2).optional(),
    state: z.string().min(2).optional(),
    pincode: z.string().regex(/^\d{6}$/).optional(),
    lat: z.number().min(-90).max(90).optional(),
    lng: z.number().min(-180).max(180).optional(),
    isDefault: z.boolean().optional(),
  }),
})

export const addressIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid address ID'),
  }),
})
