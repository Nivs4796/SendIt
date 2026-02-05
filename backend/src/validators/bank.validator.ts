import { z } from 'zod'

export const addBankAccountSchema = z.object({
  body: z.object({
    accountName: z
      .string()
      .min(3, 'Account name must be at least 3 characters')
      .max(100, 'Account name must be at most 100 characters'),
    accountNumber: z
      .string()
      .regex(/^\d{9,18}$/, 'Account number must be 9-18 digits'),
    ifscCode: z
      .string()
      .regex(/^[A-Za-z]{4}0[A-Za-z0-9]{6}$/, 'Invalid IFSC code format'),
    bankName: z
      .string()
      .min(2, 'Bank name is required')
      .max(100, 'Bank name must be at most 100 characters'),
    branchName: z
      .string()
      .max(100, 'Branch name must be at most 100 characters')
      .optional(),
  }),
})

export const bankAccountIdParamSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Bank account ID is required'),
  }),
})

export const ifscLookupSchema = z.object({
  query: z.object({
    ifsc: z
      .string()
      .regex(/^[A-Za-z]{4}0[A-Za-z0-9]{6}$/, 'Invalid IFSC code format'),
  }),
})

export const validateBankSchema = z.object({
  body: z.object({
    accountNumber: z
      .string()
      .regex(/^\d{9,18}$/, 'Account number must be 9-18 digits'),
    ifscCode: z
      .string()
      .regex(/^[A-Za-z]{4}0[A-Za-z0-9]{6}$/, 'Invalid IFSC code format'),
  }),
})
