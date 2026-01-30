import { Request, Response, NextFunction } from 'express'
import * as reviewService from '../services/review.service'
import { formatResponse } from '../utils/helpers'

export const createReview = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const review = await reviewService.createReview({
      bookingId: req.params.bookingId as string,
      userId: req.user!.id,
      rating: req.body.rating,
      comment: req.body.comment,
    })
    res.status(201).json(formatResponse(true, 'Review submitted', { review }))
  } catch (error) {
    next(error)
  }
}

export const getPilotReviews = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const result = await reviewService.getPilotReviews(req.params.pilotId as string, page, limit)
    res.status(200).json(formatResponse(true, 'Reviews retrieved', { reviews: result.reviews }, result.meta))
  } catch (error) {
    next(error)
  }
}
