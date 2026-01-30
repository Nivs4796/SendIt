import { z } from 'zod'

export const updateUserSchema = z.object({
  body: z.object({
    name: z.string().min(2, 'Name must be at least 2 characters').optional(),
    email: z.string().email('Invalid email address').optional(),
    avatar: z.string().url('Invalid avatar URL').optional(),
  }),
})

export const userIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid user ID'),
  }),
})
