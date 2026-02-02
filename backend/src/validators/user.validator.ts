import { z } from 'zod'

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

export const updateUserSchema = z.object({
  body: z.object({
    name: z.string().min(2, 'Name must be at least 2 characters').optional(),
    email: z.string().email('Invalid email address').optional(),
    avatar: avatarSchema.optional(),
  }),
})

export const userIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid user ID'),
  }),
})
