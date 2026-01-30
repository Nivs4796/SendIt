import { z } from 'zod'

export const createReviewSchema = z.object({
  params: z.object({
    bookingId: z.string().cuid('Invalid booking ID'),
  }),
  body: z.object({
    rating: z.number().min(1, 'Rating must be at least 1').max(5, 'Rating cannot exceed 5'),
    comment: z.string().max(500, 'Comment too long').optional(),
  }),
})

export const pilotReviewsParamSchema = z.object({
  params: z.object({
    pilotId: z.string().cuid('Invalid pilot ID'),
  }),
  query: z.object({
    page: z.string().regex(/^\d+$/).transform(Number).optional(),
    limit: z.string().regex(/^\d+$/).transform(Number).optional(),
  }).optional(),
})
