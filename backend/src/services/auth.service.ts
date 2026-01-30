import prisma from '../config/database'
import { config } from '../config'
import {
  generateToken,
  generateRefreshToken,
  generateOTP,
  getOTPExpiry,
  hashPassword,
  comparePassword,
} from '../utils/helpers'
import { AppError } from '../middleware/errorHandler'
import { OTPPurpose } from '@prisma/client'

interface SendOTPResult {
  success: boolean
  message: string
  // In development, return OTP for testing
  otp?: string
}

interface VerifyOTPResult {
  success: boolean
  message: string
  accessToken?: string
  refreshToken?: string
  user?: {
    id: string
    phone: string
    name: string | null
    email: string | null
    isVerified: boolean
  }
  isNewUser?: boolean
}

// Send OTP for User Login/Signup
export const sendUserOTP = async (
  phone: string,
  purpose: OTPPurpose = 'LOGIN'
): Promise<SendOTPResult> => {
  // Generate OTP
  const otp = generateOTP(6)
  const expiresAt = getOTPExpiry()

  // Check if user exists
  let user = await prisma.user.findUnique({
    where: { phone },
  })

  // Create user if doesn't exist (for signup flow)
  if (!user) {
    user = await prisma.user.create({
      data: { phone },
    })
  }

  // Save OTP to database
  await prisma.oTP.create({
    data: {
      phone,
      otp,
      purpose,
      userId: user.id,
      expiresAt,
    },
  })

  // TODO: Send OTP via SMS service
  // await sendSMS(phone, `Your SendIt OTP is: ${otp}`)

  return {
    success: true,
    message: 'OTP sent successfully',
    // Return OTP in development for testing
    ...(config.nodeEnv === 'development' && { otp }),
  }
}

// Verify User OTP
export const verifyUserOTP = async (
  phone: string,
  otp: string
): Promise<VerifyOTPResult> => {
  // Find the latest OTP for this phone
  const otpRecord = await prisma.oTP.findFirst({
    where: {
      phone,
      otp,
      isUsed: false,
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: 'desc' },
  })

  if (!otpRecord) {
    throw new AppError('Invalid or expired OTP', 400)
  }

  // Mark OTP as used
  await prisma.oTP.update({
    where: { id: otpRecord.id },
    data: { isUsed: true },
  })

  // Get or create user
  let user = await prisma.user.findUnique({
    where: { phone },
  })

  const isNewUser = !user?.name

  if (!user) {
    user = await prisma.user.create({
      data: { phone, isVerified: true },
    })
  } else {
    // Update user as verified
    user = await prisma.user.update({
      where: { id: user.id },
      data: { isVerified: true },
    })
  }

  // Generate tokens
  const accessToken = generateToken({ id: user.id, type: 'user' })
  const refreshToken = generateRefreshToken({ id: user.id, type: 'user' })

  return {
    success: true,
    message: 'OTP verified successfully',
    accessToken,
    refreshToken,
    user: {
      id: user.id,
      phone: user.phone,
      name: user.name,
      email: user.email,
      isVerified: user.isVerified,
    },
    isNewUser,
  }
}

// Send OTP for Pilot Login/Signup
export const sendPilotOTP = async (
  phone: string,
  purpose: OTPPurpose = 'LOGIN'
): Promise<SendOTPResult> => {
  const otp = generateOTP(6)
  const expiresAt = getOTPExpiry()

  let pilot = await prisma.pilot.findUnique({
    where: { phone },
  })

  if (!pilot && purpose === 'LOGIN') {
    throw new AppError('Pilot not registered. Please sign up first.', 404)
  }

  // Save OTP
  await prisma.oTP.create({
    data: {
      phone,
      otp,
      purpose,
      pilotId: pilot?.id,
      expiresAt,
    },
  })

  return {
    success: true,
    message: 'OTP sent successfully',
    ...(config.nodeEnv === 'development' && { otp }),
  }
}

// Verify Pilot OTP
export const verifyPilotOTP = async (
  phone: string,
  otp: string
): Promise<VerifyOTPResult> => {
  const otpRecord = await prisma.oTP.findFirst({
    where: {
      phone,
      otp,
      isUsed: false,
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: 'desc' },
  })

  if (!otpRecord) {
    throw new AppError('Invalid or expired OTP', 400)
  }

  await prisma.oTP.update({
    where: { id: otpRecord.id },
    data: { isUsed: true },
  })

  const pilot = await prisma.pilot.findUnique({
    where: { phone },
  })

  if (!pilot) {
    throw new AppError('Pilot not found', 404)
  }

  // Update pilot as verified
  await prisma.pilot.update({
    where: { id: pilot.id },
    data: { isVerified: true },
  })

  const accessToken = generateToken({ id: pilot.id, type: 'pilot' })
  const refreshToken = generateRefreshToken({ id: pilot.id, type: 'pilot' })

  return {
    success: true,
    message: 'OTP verified successfully',
    accessToken,
    refreshToken,
    user: {
      id: pilot.id,
      phone: pilot.phone,
      name: pilot.name,
      email: pilot.email,
      isVerified: pilot.isVerified,
    },
  }
}

// Admin Login
export const adminLogin = async (
  email: string,
  password: string
): Promise<{ accessToken: string; refreshToken: string; admin: object }> => {
  const admin = await prisma.admin.findUnique({
    where: { email },
  })

  if (!admin) {
    throw new AppError('Invalid email or password', 401)
  }

  const isPasswordValid = await comparePassword(password, admin.password)

  if (!isPasswordValid) {
    throw new AppError('Invalid email or password', 401)
  }

  if (!admin.isActive) {
    throw new AppError('Account is deactivated', 403)
  }

  const accessToken = generateToken({ id: admin.id, type: 'admin' })
  const refreshToken = generateRefreshToken({ id: admin.id, type: 'admin' })

  return {
    accessToken,
    refreshToken,
    admin: {
      id: admin.id,
      email: admin.email,
      name: admin.name,
      role: admin.role,
    },
  }
}

// Create Admin (for initial setup)
export const createAdmin = async (
  email: string,
  password: string,
  name: string,
  role: 'SUPER_ADMIN' | 'ADMIN' | 'SUPPORT' = 'ADMIN'
) => {
  const existingAdmin = await prisma.admin.findUnique({
    where: { email },
  })

  if (existingAdmin) {
    throw new AppError('Admin with this email already exists', 400)
  }

  const hashedPassword = await hashPassword(password)

  const admin = await prisma.admin.create({
    data: {
      email,
      password: hashedPassword,
      name,
      role,
    },
    select: {
      id: true,
      email: true,
      name: true,
      role: true,
      createdAt: true,
    },
  })

  return admin
}
