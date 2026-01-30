import { Request, Response, NextFunction } from 'express'
import { ZodError } from 'zod'
import { Prisma } from '@prisma/client'
import { config } from '../config'

// ============================================
// ERROR CODES
// ============================================

export const ErrorCodes = {
  // General errors (1000-1099)
  INTERNAL_ERROR: 'ERR_1000',
  VALIDATION_ERROR: 'ERR_1001',
  NOT_FOUND: 'ERR_1002',
  RATE_LIMIT_EXCEEDED: 'ERR_1003',
  SERVICE_UNAVAILABLE: 'ERR_1004',

  // Authentication errors (1100-1199)
  AUTHENTICATION_REQUIRED: 'ERR_1100',
  INVALID_CREDENTIALS: 'ERR_1101',
  TOKEN_EXPIRED: 'ERR_1102',
  TOKEN_INVALID: 'ERR_1103',
  REFRESH_TOKEN_EXPIRED: 'ERR_1104',

  // Authorization errors (1200-1299)
  FORBIDDEN: 'ERR_1200',
  INSUFFICIENT_PERMISSIONS: 'ERR_1201',
  ROLE_REQUIRED: 'ERR_1202',
  ACCOUNT_SUSPENDED: 'ERR_1203',
  ACCOUNT_NOT_VERIFIED: 'ERR_1204',

  // Resource errors (1300-1399)
  USER_NOT_FOUND: 'ERR_1300',
  PILOT_NOT_FOUND: 'ERR_1301',
  BOOKING_NOT_FOUND: 'ERR_1302',
  VEHICLE_NOT_FOUND: 'ERR_1303',
  ADDRESS_NOT_FOUND: 'ERR_1304',
  COUPON_NOT_FOUND: 'ERR_1305',
  WALLET_NOT_FOUND: 'ERR_1306',
  DOCUMENT_NOT_FOUND: 'ERR_1307',
  OFFER_NOT_FOUND: 'ERR_1308',

  // Business logic errors (1400-1499)
  BOOKING_ALREADY_CANCELLED: 'ERR_1400',
  BOOKING_CANNOT_BE_CANCELLED: 'ERR_1401',
  PILOT_NOT_AVAILABLE: 'ERR_1402',
  PILOT_NOT_APPROVED: 'ERR_1403',
  COUPON_EXPIRED: 'ERR_1404',
  COUPON_USAGE_LIMIT_REACHED: 'ERR_1405',
  INSUFFICIENT_WALLET_BALANCE: 'ERR_1406',
  OFFER_EXPIRED: 'ERR_1407',
  OFFER_ALREADY_RESPONDED: 'ERR_1408',
  NO_PILOTS_AVAILABLE: 'ERR_1409',
  INVALID_BOOKING_STATUS: 'ERR_1410',
  DUPLICATE_ENTRY: 'ERR_1411',

  // Database errors (1500-1599)
  DATABASE_ERROR: 'ERR_1500',
  UNIQUE_CONSTRAINT_VIOLATION: 'ERR_1501',
  FOREIGN_KEY_VIOLATION: 'ERR_1502',
  RECORD_NOT_FOUND: 'ERR_1503',
} as const

export type ErrorCode = (typeof ErrorCodes)[keyof typeof ErrorCodes]

// ============================================
// BASE ERROR CLASS
// ============================================

export class AppError extends Error {
  public readonly statusCode: number
  public readonly code: ErrorCode
  public readonly isOperational: boolean
  public readonly details?: Record<string, unknown>

  constructor(
    message: string,
    statusCode: number,
    code: ErrorCode = ErrorCodes.INTERNAL_ERROR,
    details?: Record<string, unknown>
  ) {
    super(message)
    this.statusCode = statusCode
    this.code = code
    this.isOperational = true
    this.details = details

    Object.setPrototypeOf(this, new.target.prototype)
    Error.captureStackTrace(this, this.constructor)
  }
}

// ============================================
// SPECIFIC ERROR CLASSES
// ============================================

/**
 * 400 Bad Request - Validation errors
 */
export class ValidationError extends AppError {
  public readonly errors: Array<{ field: string; message: string }>

  constructor(
    message: string = 'Validation failed',
    errors: Array<{ field: string; message: string }> = []
  ) {
    super(message, 400, ErrorCodes.VALIDATION_ERROR, { errors })
    this.errors = errors
  }

  static fromZodError(error: ZodError): ValidationError {
    const errors = error.issues.map((issue) => ({
      field: issue.path.join('.'),
      message: issue.message,
    }))
    return new ValidationError('Validation failed', errors)
  }
}

/**
 * 401 Unauthorized - Authentication errors
 */
export class AuthenticationError extends AppError {
  constructor(
    message: string = 'Authentication required',
    code: ErrorCode = ErrorCodes.AUTHENTICATION_REQUIRED
  ) {
    super(message, 401, code)
  }
}

export class InvalidCredentialsError extends AuthenticationError {
  constructor(message: string = 'Invalid email or password') {
    super(message, ErrorCodes.INVALID_CREDENTIALS)
  }
}

export class TokenExpiredError extends AuthenticationError {
  constructor(message: string = 'Token has expired') {
    super(message, ErrorCodes.TOKEN_EXPIRED)
  }
}

export class TokenInvalidError extends AuthenticationError {
  constructor(message: string = 'Token is invalid') {
    super(message, ErrorCodes.TOKEN_INVALID)
  }
}

/**
 * 403 Forbidden - Authorization errors
 */
export class ForbiddenError extends AppError {
  constructor(
    message: string = 'Access forbidden',
    code: ErrorCode = ErrorCodes.FORBIDDEN
  ) {
    super(message, 403, code)
  }
}

export class InsufficientPermissionsError extends ForbiddenError {
  constructor(message: string = 'Insufficient permissions') {
    super(message, ErrorCodes.INSUFFICIENT_PERMISSIONS)
  }
}

export class AccountSuspendedError extends ForbiddenError {
  constructor(message: string = 'Account has been suspended') {
    super(message, ErrorCodes.ACCOUNT_SUSPENDED)
  }
}

/**
 * 404 Not Found - Resource errors
 */
export class NotFoundError extends AppError {
  constructor(
    resource: string = 'Resource',
    code: ErrorCode = ErrorCodes.NOT_FOUND
  ) {
    super(`${resource} not found`, 404, code)
  }
}

export class UserNotFoundError extends NotFoundError {
  constructor(message: string = 'User') {
    super(message, ErrorCodes.USER_NOT_FOUND)
  }
}

export class PilotNotFoundError extends NotFoundError {
  constructor(message: string = 'Pilot') {
    super(message, ErrorCodes.PILOT_NOT_FOUND)
  }
}

export class BookingNotFoundError extends NotFoundError {
  constructor(message: string = 'Booking') {
    super(message, ErrorCodes.BOOKING_NOT_FOUND)
  }
}

export class VehicleNotFoundError extends NotFoundError {
  constructor(message: string = 'Vehicle') {
    super(message, ErrorCodes.VEHICLE_NOT_FOUND)
  }
}

export class AddressNotFoundError extends NotFoundError {
  constructor(message: string = 'Address') {
    super(message, ErrorCodes.ADDRESS_NOT_FOUND)
  }
}

export class CouponNotFoundError extends NotFoundError {
  constructor(message: string = 'Coupon') {
    super(message, ErrorCodes.COUPON_NOT_FOUND)
  }
}

export class DocumentNotFoundError extends NotFoundError {
  constructor(message: string = 'Document') {
    super(message, ErrorCodes.DOCUMENT_NOT_FOUND)
  }
}

export class OfferNotFoundError extends NotFoundError {
  constructor(message: string = 'Job offer') {
    super(message, ErrorCodes.OFFER_NOT_FOUND)
  }
}

/**
 * 409 Conflict - Business logic errors
 */
export class ConflictError extends AppError {
  constructor(
    message: string,
    code: ErrorCode = ErrorCodes.DUPLICATE_ENTRY
  ) {
    super(message, 409, code)
  }
}

export class DuplicateEntryError extends ConflictError {
  constructor(field: string) {
    super(`${field} already exists`, ErrorCodes.DUPLICATE_ENTRY)
  }
}

/**
 * 422 Unprocessable Entity - Business rule violations
 */
export class BusinessRuleError extends AppError {
  constructor(message: string, code: ErrorCode) {
    super(message, 422, code)
  }
}

export class BookingAlreadyCancelledError extends BusinessRuleError {
  constructor() {
    super('Booking has already been cancelled', ErrorCodes.BOOKING_ALREADY_CANCELLED)
  }
}

export class BookingCannotBeCancelledError extends BusinessRuleError {
  constructor(reason: string = 'Booking cannot be cancelled at this stage') {
    super(reason, ErrorCodes.BOOKING_CANNOT_BE_CANCELLED)
  }
}

export class PilotNotAvailableError extends BusinessRuleError {
  constructor() {
    super('Pilot is not available', ErrorCodes.PILOT_NOT_AVAILABLE)
  }
}

export class PilotNotApprovedError extends BusinessRuleError {
  constructor() {
    super('Pilot is not approved', ErrorCodes.PILOT_NOT_APPROVED)
  }
}

export class CouponExpiredError extends BusinessRuleError {
  constructor() {
    super('Coupon has expired', ErrorCodes.COUPON_EXPIRED)
  }
}

export class CouponUsageLimitError extends BusinessRuleError {
  constructor() {
    super('Coupon usage limit has been reached', ErrorCodes.COUPON_USAGE_LIMIT_REACHED)
  }
}

export class InsufficientBalanceError extends BusinessRuleError {
  constructor() {
    super('Insufficient wallet balance', ErrorCodes.INSUFFICIENT_WALLET_BALANCE)
  }
}

export class OfferExpiredError extends BusinessRuleError {
  constructor() {
    super('Job offer has expired', ErrorCodes.OFFER_EXPIRED)
  }
}

export class OfferAlreadyRespondedError extends BusinessRuleError {
  constructor() {
    super('Job offer has already been responded to', ErrorCodes.OFFER_ALREADY_RESPONDED)
  }
}

export class NoPilotsAvailableError extends BusinessRuleError {
  constructor() {
    super('No pilots available in your area', ErrorCodes.NO_PILOTS_AVAILABLE)
  }
}

export class InvalidBookingStatusError extends BusinessRuleError {
  constructor(currentStatus: string, requiredStatus: string) {
    super(
      `Invalid booking status. Current: ${currentStatus}, Required: ${requiredStatus}`,
      ErrorCodes.INVALID_BOOKING_STATUS
    )
  }
}

/**
 * 429 Too Many Requests - Rate limiting
 */
export class RateLimitError extends AppError {
  constructor(message: string = 'Too many requests, please try again later') {
    super(message, 429, ErrorCodes.RATE_LIMIT_EXCEEDED)
  }
}

/**
 * 500 Internal Server Error
 */
export class InternalError extends AppError {
  constructor(message: string = 'Internal server error') {
    super(message, 500, ErrorCodes.INTERNAL_ERROR)
  }
}

/**
 * 503 Service Unavailable
 */
export class ServiceUnavailableError extends AppError {
  constructor(message: string = 'Service temporarily unavailable') {
    super(message, 503, ErrorCodes.SERVICE_UNAVAILABLE)
  }
}

/**
 * Database Error
 */
export class DatabaseError extends AppError {
  constructor(message: string = 'Database operation failed') {
    super(message, 500, ErrorCodes.DATABASE_ERROR)
  }
}

// ============================================
// ERROR HANDLER MIDDLEWARE
// ============================================

interface ErrorResponse {
  success: false
  message: string
  code: ErrorCode
  errors?: Array<{ field: string; message: string }>
  details?: Record<string, unknown>
  stack?: string
}

/**
 * Convert Prisma errors to AppError
 */
function handlePrismaError(error: Prisma.PrismaClientKnownRequestError): AppError {
  switch (error.code) {
    case 'P2002': {
      const target = (error.meta?.target as string[])?.join(', ') || 'field'
      return new ConflictError(
        `Duplicate value for ${target}`,
        ErrorCodes.UNIQUE_CONSTRAINT_VIOLATION
      )
    }
    case 'P2003':
      return new AppError(
        'Related record not found',
        400,
        ErrorCodes.FOREIGN_KEY_VIOLATION
      )
    case 'P2025':
      return new NotFoundError('Record', ErrorCodes.RECORD_NOT_FOUND)
    default:
      return new DatabaseError(`Database error: ${error.message}`)
  }
}

/**
 * Global error handler middleware
 */
export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  let error: AppError

  // Handle different error types
  if (err instanceof AppError) {
    error = err
  } else if (err instanceof ZodError) {
    error = ValidationError.fromZodError(err)
  } else if (err instanceof Prisma.PrismaClientKnownRequestError) {
    error = handlePrismaError(err)
  } else if (err instanceof Prisma.PrismaClientValidationError) {
    error = new ValidationError('Invalid data provided')
  } else {
    // Unknown error - treat as internal server error
    error = new InternalError(
      config.nodeEnv === 'production' ? 'Internal server error' : err.message
    )
  }

  // Build response
  const response: ErrorResponse = {
    success: false,
    message: error.message,
    code: error.code,
  }

  // Add validation errors if present
  if (error instanceof ValidationError && error.errors.length > 0) {
    response.errors = error.errors
  }

  // Add details if present
  if (error.details && config.nodeEnv !== 'production') {
    response.details = error.details
  }

  // Add stack trace in development
  if (config.nodeEnv === 'development') {
    response.stack = err.stack
  }

  // Log error
  const logMessage = `[${error.code}] ${error.statusCode} - ${error.message}`
  if (error.statusCode >= 500) {
    console.error(logMessage)
    if (config.nodeEnv === 'development') {
      console.error(err.stack)
    }
  } else if (config.nodeEnv === 'development') {
    console.warn(logMessage)
  }

  res.status(error.statusCode).json(response)
}

/**
 * 404 Not Found handler for undefined routes
 */
export const notFoundHandler = (
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  const response: ErrorResponse = {
    success: false,
    message: `Route ${req.method} ${req.originalUrl} not found`,
    code: ErrorCodes.NOT_FOUND,
  }
  res.status(404).json(response)
}

/**
 * Async handler wrapper to catch errors in async route handlers
 */
export const asyncHandler = <T>(
  fn: (req: Request, res: Response, next: NextFunction) => Promise<T>
) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}
