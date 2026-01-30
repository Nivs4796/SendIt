import { Request, Response, NextFunction } from 'express'
import { config } from '../config'

export class AppError extends Error {
  statusCode: number
  isOperational: boolean

  constructor(message: string, statusCode: number) {
    super(message)
    this.statusCode = statusCode
    this.isOperational = true

    Error.captureStackTrace(this, this.constructor)
  }
}

export const errorHandler = (
  err: Error | AppError,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  let statusCode = 500
  let message = 'Internal Server Error'
  let stack: string | undefined

  if (err instanceof AppError) {
    statusCode = err.statusCode
    message = err.message
  } else if (err instanceof Error) {
    message = err.message
  }

  // Include stack trace in development
  if (config.nodeEnv === 'development') {
    stack = err.stack
  }

  // Log error
  console.error(`[ERROR] ${statusCode} - ${message}`)
  if (config.nodeEnv === 'development' && stack) {
    console.error(stack)
  }

  res.status(statusCode).json({
    success: false,
    message,
    ...(config.nodeEnv === 'development' && { stack }),
  })
}

export const notFoundHandler = (
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  res.status(404).json({
    success: false,
    message: `Route ${req.method} ${req.originalUrl} not found`,
  })
}
