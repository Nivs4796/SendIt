import rateLimit from 'express-rate-limit'
import { config } from '../config'
import { ErrorCodes } from './errorHandler'

// General API rate limiter
export const apiLimiter = rateLimit({
  windowMs: config.rateLimitWindowMs, // 15 minutes
  max: config.rateLimitMax, // 100 requests per window
  message: {
    success: false,
    message: 'Too many requests, please try again later.',
    code: ErrorCodes.RATE_LIMIT_EXCEEDED,
  },
  standardHeaders: true,
  legacyHeaders: false,
})

// Strict rate limiter for auth endpoints
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // 10 requests per window
  message: {
    success: false,
    message: 'Too many authentication attempts, please try again later.',
    code: ErrorCodes.RATE_LIMIT_EXCEEDED,
  },
  standardHeaders: true,
  legacyHeaders: false,
})

// OTP rate limiter - stricter
export const otpLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 3, // 3 OTP requests per minute
  message: {
    success: false,
    message: 'Too many OTP requests, please wait before requesting again.',
    code: ErrorCodes.RATE_LIMIT_EXCEEDED,
  },
  standardHeaders: true,
  legacyHeaders: false,
})

// Booking creation rate limiter
export const bookingLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5, // 5 bookings per minute
  message: {
    success: false,
    message: 'Too many booking requests, please try again later.',
    code: ErrorCodes.RATE_LIMIT_EXCEEDED,
  },
  standardHeaders: true,
  legacyHeaders: false,
})

// Admin rate limiter - more generous
export const adminLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 200, // 200 requests per window
  message: {
    success: false,
    message: 'Too many admin requests, please try again later.',
    code: ErrorCodes.RATE_LIMIT_EXCEEDED,
  },
  standardHeaders: true,
  legacyHeaders: false,
})

// Payment verification - strict limit (5 attempts per 15 minutes)
export const paymentVerifyLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 verification attempts
  message: {
    success: false,
    message: 'Too many payment verification attempts. Please try again later.',
    code: ErrorCodes.RATE_LIMIT_EXCEEDED,
  },
  standardHeaders: true,
  legacyHeaders: false,
})

// Payment order creation - moderate limit (20 per hour)
export const paymentCreateLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20, // 20 payment orders per hour
  message: {
    success: false,
    message: 'Too many payment requests. Please try again later.',
    code: ErrorCodes.RATE_LIMIT_EXCEEDED,
  },
  standardHeaders: true,
  legacyHeaders: false,
})
