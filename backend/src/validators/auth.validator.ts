import { z } from 'zod'

const phoneRegex = /^(\+91)?[6-9]\d{9}$/

export const sendOTPSchema = z.object({
  body: z.object({
    phone: z.string()
      .min(10, 'Phone number must be at least 10 digits')
      .regex(phoneRegex, 'Invalid Indian phone number'),
  }),
})

export const verifyOTPSchema = z.object({
  body: z.object({
    phone: z.string()
      .min(10, 'Phone number must be at least 10 digits')
      .regex(phoneRegex, 'Invalid Indian phone number'),
    otp: z.string()
      .length(6, 'OTP must be exactly 6 digits')
      .regex(/^\d{6}$/, 'OTP must contain only digits'),
  }),
})

export const adminLoginSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
  }),
})

export const createAdminSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(8, 'Password must be at least 8 characters'),
    name: z.string().min(2, 'Name must be at least 2 characters'),
    role: z.enum(['SUPER_ADMIN', 'ADMIN', 'SUPPORT']).optional(),
  }),
})

export const refreshTokenSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
  }),
})
