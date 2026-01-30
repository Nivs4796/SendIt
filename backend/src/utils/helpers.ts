import jwt, { SignOptions } from 'jsonwebtoken'
import bcrypt from 'bcryptjs'
import { config } from '../config'

// Generate JWT Token
export const generateToken = (
  payload: { id: string; type: 'user' | 'pilot' | 'admin' },
  expiresIn: string = config.jwtExpiresIn
): string => {
  const options: SignOptions = { expiresIn: expiresIn as jwt.SignOptions['expiresIn'] }
  return jwt.sign(payload, config.jwtSecret, options)
}

// Generate Refresh Token
export const generateRefreshToken = (
  payload: { id: string; type: 'user' | 'pilot' | 'admin' }
): string => {
  const options: SignOptions = { expiresIn: config.jwtRefreshExpiresIn as jwt.SignOptions['expiresIn'] }
  return jwt.sign(payload, config.jwtRefreshSecret, options)
}

// Verify Refresh Token
export const verifyRefreshToken = (token: string): { id: string; type: 'user' | 'pilot' | 'admin' } | null => {
  try {
    return jwt.verify(token, config.jwtRefreshSecret) as { id: string; type: 'user' | 'pilot' | 'admin' }
  } catch {
    return null
  }
}

// Hash Password
export const hashPassword = async (password: string): Promise<string> => {
  const salt = await bcrypt.genSalt(10)
  return bcrypt.hash(password, salt)
}

// Compare Password
export const comparePassword = async (
  password: string,
  hashedPassword: string
): Promise<boolean> => {
  return bcrypt.compare(password, hashedPassword)
}

// Generate OTP
export const generateOTP = (length: number = 6): string => {
  const digits = '0123456789'
  let otp = ''
  for (let i = 0; i < length; i++) {
    otp += digits[Math.floor(Math.random() * 10)]
  }
  return otp
}

// Calculate OTP Expiry
export const getOTPExpiry = (): Date => {
  const expiry = new Date()
  expiry.setMinutes(expiry.getMinutes() + config.otpExpiryMinutes)
  return expiry
}

// Calculate Distance between two coordinates (Haversine formula)
export const calculateDistance = (
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number
): number => {
  const R = 6371 // Earth's radius in kilometers
  const dLat = toRad(lat2 - lat1)
  const dLng = toRad(lng2 - lng1)

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2)

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  return R * c // Distance in kilometers
}

const toRad = (value: number): number => {
  return (value * Math.PI) / 180
}

// Format phone number (add country code if missing)
export const formatPhoneNumber = (phone: string): string => {
  // Remove all non-digits
  const cleaned = phone.replace(/\D/g, '')

  // Add +91 if it's a 10 digit Indian number
  if (cleaned.length === 10) {
    return `+91${cleaned}`
  }

  // If already has country code
  if (cleaned.length === 12 && cleaned.startsWith('91')) {
    return `+${cleaned}`
  }

  return phone
}

// Generate unique booking number
export const generateBookingNumber = (): string => {
  const timestamp = Date.now().toString(36).toUpperCase()
  const random = Math.random().toString(36).substring(2, 6).toUpperCase()
  return `SI${timestamp}${random}`
}

// Pagination helper
export const getPaginationParams = (
  page: number = 1,
  limit: number = 10
): { skip: number; take: number } => {
  const take = Math.min(Math.max(1, limit), 100) // Limit between 1 and 100
  const skip = (Math.max(1, page) - 1) * take
  return { skip, take }
}

// Response formatter
export const formatResponse = <T>(
  success: boolean,
  message: string,
  data?: T,
  meta?: {
    page?: number
    limit?: number
    total?: number
    totalPages?: number
  }
) => {
  return {
    success,
    message,
    ...(data && { data }),
    ...(meta && { meta }),
  }
}
