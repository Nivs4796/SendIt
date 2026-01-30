import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'

interface CreateReviewInput {
  bookingId: string
  userId: string
  rating: number
  comment?: string
}

export const createReview = async (input: CreateReviewInput) => {
  const { bookingId, userId, rating, comment } = input

  // Verify booking exists and belongs to user
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    select: { id: true, userId: true, pilotId: true, status: true },
  })

  if (!booking) {
    throw new AppError('Booking not found', 404)
  }

  if (booking.userId !== userId) {
    throw new AppError('Unauthorized', 403)
  }

  if (booking.status !== 'DELIVERED') {
    throw new AppError('Can only review delivered bookings', 400)
  }

  if (!booking.pilotId) {
    throw new AppError('No pilot assigned to this booking', 400)
  }

  // Check if review already exists
  const existingReview = await prisma.review.findUnique({ where: { bookingId } })
  if (existingReview) {
    throw new AppError('Review already exists for this booking', 400)
  }

  // Create review
  const review = await prisma.review.create({
    data: {
      bookingId,
      userId,
      pilotId: booking.pilotId,
      rating,
      comment,
    },
  })

  // Update pilot's average rating
  const pilotReviews = await prisma.review.aggregate({
    where: { pilotId: booking.pilotId },
    _avg: { rating: true },
  })

  await prisma.pilot.update({
    where: { id: booking.pilotId },
    data: { rating: pilotReviews._avg.rating || 0 },
  })

  return review
}

export const getPilotReviews = async (pilotId: string, page: number = 1, limit: number = 10) => {
  const skip = (page - 1) * limit

  const [reviews, total] = await Promise.all([
    prisma.review.findMany({
      where: { pilotId },
      skip,
      take: limit,
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, name: true, avatar: true } },
        booking: { select: { id: true, bookingNumber: true } },
      },
    }),
    prisma.review.count({ where: { pilotId } }),
  ])

  return {
    reviews,
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  }
}
