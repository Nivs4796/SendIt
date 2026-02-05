import { z } from 'zod'

export const achievementIdParamSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Achievement ID is required'),
  }),
})

export const applyReferralSchema = z.object({
  body: z.object({
    referralCode: z
      .string()
      .min(6, 'Referral code must be at least 6 characters')
      .max(20, 'Referral code must be at most 20 characters')
      .regex(/^[A-Z0-9]+$/i, 'Referral code must be alphanumeric'),
  }),
})
