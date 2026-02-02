import { z } from 'zod'

const phoneRegex = /^(\+91)?[6-9]\d{9}$/
const genders = ['MALE', 'FEMALE', 'OTHER'] as const

// Custom validator for avatar that accepts both full URLs and relative paths
const avatarSchema = z.string().refine(
  (val) => {
    // Accept relative paths starting with /uploads/
    if (val.startsWith('/uploads/')) return true
    // Accept full URLs
    try {
      new URL(val)
      return true
    } catch {
      return false
    }
  },
  { message: 'Invalid avatar URL or path' }
)

export const registerPilotSchema = z.object({
  body: z.object({
    phone: z.string().regex(phoneRegex, 'Invalid Indian phone number'),
    name: z.string().min(2, 'Name must be at least 2 characters'),
    email: z.string().email('Invalid email').optional(),
    dateOfBirth: z.string().datetime().optional(),
    gender: z.enum(genders).optional(),
  }),
})

export const updatePilotSchema = z.object({
  body: z.object({
    name: z.string().min(2).optional(),
    email: z.string().email().optional(),
    avatar: avatarSchema.optional(),
    dateOfBirth: z.string().datetime().optional(),
    gender: z.enum(genders).optional(),
    aadhaarNumber: z.string().regex(/^\d{12}$/, 'Aadhaar must be 12 digits').optional(),
    licenseNumber: z.string().min(5).optional(),
    panNumber: z.string().regex(/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/, 'Invalid PAN format').optional(),
  }),
})

export const updatePilotLocationSchema = z.object({
  body: z.object({
    lat: z.number().min(-90).max(90),
    lng: z.number().min(-180).max(180),
  }),
})

export const updatePilotOnlineStatusSchema = z.object({
  body: z.object({
    isOnline: z.boolean(),
  }),
})

export const pilotIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid pilot ID'),
  }),
})

export const updatePilotStatusSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid pilot ID'),
  }),
  body: z.object({
    status: z.enum(['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED']),
  }),
})
