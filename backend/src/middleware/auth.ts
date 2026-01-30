import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import { config } from '../config'
import prisma from '../config/database'

interface JwtPayload {
  id: string
  type: 'user' | 'pilot' | 'admin'
}

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string
        type: 'user' | 'pilot' | 'admin'
      }
    }
  }
}

export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({
        success: false,
        message: 'Access token is required',
      })
      return
    }

    const token = authHeader.split(' ')[1]

    const decoded = jwt.verify(token, config.jwtSecret) as JwtPayload

    req.user = {
      id: decoded.id,
      type: decoded.type,
    }

    next()
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Invalid or expired token',
    })
  }
}

export const authorizeUser = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  if (!req.user || req.user.type !== 'user') {
    res.status(403).json({
      success: false,
      message: 'Access denied. User access required.',
    })
    return
  }

  // Verify user exists and is active
  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
    select: { id: true, isActive: true },
  })

  if (!user || !user.isActive) {
    res.status(403).json({
      success: false,
      message: 'User account not found or inactive',
    })
    return
  }

  next()
}

export const authorizePilot = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  if (!req.user || req.user.type !== 'pilot') {
    res.status(403).json({
      success: false,
      message: 'Access denied. Pilot access required.',
    })
    return
  }

  // Verify pilot exists, is active and approved
  const pilot = await prisma.pilot.findUnique({
    where: { id: req.user.id },
    select: { id: true, isActive: true, status: true },
  })

  if (!pilot || !pilot.isActive || pilot.status !== 'APPROVED') {
    res.status(403).json({
      success: false,
      message: 'Pilot account not found, inactive, or not approved',
    })
    return
  }

  next()
}

export const authorizeAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  if (!req.user || req.user.type !== 'admin') {
    res.status(403).json({
      success: false,
      message: 'Access denied. Admin access required.',
    })
    return
  }

  // Verify admin exists and is active
  const admin = await prisma.admin.findUnique({
    where: { id: req.user.id },
    select: { id: true, isActive: true, role: true },
  })

  if (!admin || !admin.isActive) {
    res.status(403).json({
      success: false,
      message: 'Admin account not found or inactive',
    })
    return
  }

  next()
}

export const authorizeSuperAdmin = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  if (!req.user || req.user.type !== 'admin') {
    res.status(403).json({
      success: false,
      message: 'Access denied. Super Admin access required.',
    })
    return
  }

  const admin = await prisma.admin.findUnique({
    where: { id: req.user.id },
    select: { id: true, isActive: true, role: true },
  })

  if (!admin || !admin.isActive || admin.role !== 'SUPER_ADMIN') {
    res.status(403).json({
      success: false,
      message: 'Super Admin access required',
    })
    return
  }

  next()
}

// Generic authorize function
export const authorize = (...roles: Array<'user' | 'pilot' | 'admin'>) => {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    if (!req.user) {
      res.status(401).json({
        success: false,
        message: 'Authentication required',
      })
      return
    }

    if (!roles.includes(req.user.type)) {
      res.status(403).json({
        success: false,
        message: `Access denied. Required role: ${roles.join(' or ')}`,
      })
      return
    }

    // Verify entity exists and is active based on type
    if (req.user.type === 'user') {
      const user = await prisma.user.findUnique({
        where: { id: req.user.id },
        select: { id: true, isActive: true },
      })
      if (!user || !user.isActive) {
        res.status(403).json({
          success: false,
          message: 'User account not found or inactive',
        })
        return
      }
    } else if (req.user.type === 'pilot') {
      const pilot = await prisma.pilot.findUnique({
        where: { id: req.user.id },
        select: { id: true, isActive: true, status: true },
      })
      if (!pilot || !pilot.isActive) {
        res.status(403).json({
          success: false,
          message: 'Pilot account not found or inactive',
        })
        return
      }
    } else if (req.user.type === 'admin') {
      const admin = await prisma.admin.findUnique({
        where: { id: req.user.id },
        select: { id: true, isActive: true },
      })
      if (!admin || !admin.isActive) {
        res.status(403).json({
          success: false,
          message: 'Admin account not found or inactive',
        })
        return
      }
    }

    next()
  }
}
