import { Request, Response, NextFunction } from 'express'
import { z, ZodError, ZodType } from 'zod'

export const validate = (schema: ZodType) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      })
      next()
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.issues.map((issue) => ({
          field: issue.path.join('.'),
          message: issue.message,
        }))
        res.status(400).json({
          success: false,
          message: 'Validation failed',
          errors,
        })
        return
      }
      next(error)
    }
  }
}

export * from './auth.validator'
export * from './user.validator'
export * from './address.validator'
export * from './booking.validator'
export * from './pilot.validator'
export * from './vehicle.validator'
export * from './review.validator'
