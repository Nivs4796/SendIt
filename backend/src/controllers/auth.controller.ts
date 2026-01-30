import { Request, Response, NextFunction } from 'express'
import * as authService from '../services/auth.service'
import { formatResponse } from '../utils/helpers'

// Send OTP for User
export const sendUserOTP = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { phone } = req.body

    if (!phone) {
      res.status(400).json(formatResponse(false, 'Phone number is required'))
      return
    }

    const result = await authService.sendUserOTP(phone)
    res.status(200).json(formatResponse(true, result.message, { otp: result.otp }))
  } catch (error) {
    next(error)
  }
}

// Verify User OTP
export const verifyUserOTP = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { phone, otp } = req.body

    if (!phone || !otp) {
      res.status(400).json(formatResponse(false, 'Phone and OTP are required'))
      return
    }

    const result = await authService.verifyUserOTP(phone, otp)
    res.status(200).json(
      formatResponse(true, result.message, {
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        user: result.user,
        isNewUser: result.isNewUser,
      })
    )
  } catch (error) {
    next(error)
  }
}

// Send OTP for Pilot
export const sendPilotOTP = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { phone } = req.body

    if (!phone) {
      res.status(400).json(formatResponse(false, 'Phone number is required'))
      return
    }

    const result = await authService.sendPilotOTP(phone)
    res.status(200).json(formatResponse(true, result.message, { otp: result.otp }))
  } catch (error) {
    next(error)
  }
}

// Verify Pilot OTP
export const verifyPilotOTP = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { phone, otp } = req.body

    if (!phone || !otp) {
      res.status(400).json(formatResponse(false, 'Phone and OTP are required'))
      return
    }

    const result = await authService.verifyPilotOTP(phone, otp)
    res.status(200).json(
      formatResponse(true, result.message, {
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        pilot: result.user,
      })
    )
  } catch (error) {
    next(error)
  }
}

// Admin Login
export const adminLogin = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password } = req.body

    if (!email || !password) {
      res.status(400).json(formatResponse(false, 'Email and password are required'))
      return
    }

    const result = await authService.adminLogin(email, password)
    res.status(200).json(
      formatResponse(true, 'Login successful', {
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
        admin: result.admin,
      })
    )
  } catch (error) {
    next(error)
  }
}

// Create Admin (Initial Setup)
export const createAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { email, password, name, role } = req.body

    if (!email || !password || !name) {
      res.status(400).json(formatResponse(false, 'Email, password, and name are required'))
      return
    }

    const admin = await authService.createAdmin(email, password, name, role)
    res.status(201).json(formatResponse(true, 'Admin created successfully', { admin }))
  } catch (error) {
    next(error)
  }
}
