# SendIt Backend API Hardening Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make SendIt APIs bulletproof with Zod validation, rate limiting, full CRUD operations, Swagger documentation, and structured logging.

**Architecture:** Three-tier hardening approach - Essential (validation, rate limiting), Comprehensive (full CRUD for all entities), Enterprise (Swagger, logging, metrics). Each layer builds on the previous.

**Tech Stack:** Express.js, Zod, express-rate-limit, swagger-jsdoc, swagger-ui-express, winston, morgan

---

## Phase 1: Essential - Validation & Security (Tasks 1-6)

### Task 1: Install Dependencies

**Files:**
- Modify: `package.json`

**Step 1: Install essential packages**

Run:
```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt/backend
npm install express-rate-limit swagger-jsdoc swagger-ui-express winston
```

**Step 2: Verify installation**

Run: `npm ls express-rate-limit swagger-jsdoc winston`
Expected: All packages listed without errors

---

### Task 2: Create Zod Validation Schemas

**Files:**
- Create: `src/validators/auth.validator.ts`
- Create: `src/validators/booking.validator.ts`
- Create: `src/validators/user.validator.ts`
- Create: `src/validators/pilot.validator.ts`
- Create: `src/validators/address.validator.ts`
- Create: `src/validators/vehicle.validator.ts`
- Create: `src/validators/index.ts`

**Step 1: Create auth validator**

```typescript
// src/validators/auth.validator.ts
import { z } from 'zod'

const phoneRegex = /^(\+91)?[6-9]\d{9}$/

export const sendOTPSchema = z.object({
  body: z.object({
    phone: z.string()
      .min(10, 'Phone number must be at least 10 digits')
      .regex(phoneRegex, 'Invalid Indian phone number'),
  }),
})

export const verifyOTPSchema = z.object({
  body: z.object({
    phone: z.string()
      .min(10, 'Phone number must be at least 10 digits')
      .regex(phoneRegex, 'Invalid Indian phone number'),
    otp: z.string()
      .length(6, 'OTP must be exactly 6 digits')
      .regex(/^\d{6}$/, 'OTP must contain only digits'),
  }),
})

export const adminLoginSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(6, 'Password must be at least 6 characters'),
  }),
})

export const createAdminSchema = z.object({
  body: z.object({
    email: z.string().email('Invalid email address'),
    password: z.string().min(8, 'Password must be at least 8 characters'),
    name: z.string().min(2, 'Name must be at least 2 characters'),
    role: z.enum(['SUPER_ADMIN', 'ADMIN', 'SUPPORT']).optional(),
  }),
})

export const refreshTokenSchema = z.object({
  body: z.object({
    refreshToken: z.string().min(1, 'Refresh token is required'),
  }),
})
```

**Step 2: Create user validator**

```typescript
// src/validators/user.validator.ts
import { z } from 'zod'

export const updateUserSchema = z.object({
  body: z.object({
    name: z.string().min(2, 'Name must be at least 2 characters').optional(),
    email: z.string().email('Invalid email address').optional(),
    avatar: z.string().url('Invalid avatar URL').optional(),
  }),
})

export const userIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid user ID'),
  }),
})
```

**Step 3: Create address validator**

```typescript
// src/validators/address.validator.ts
import { z } from 'zod'

export const createAddressSchema = z.object({
  body: z.object({
    label: z.string().min(1, 'Label is required').max(50),
    address: z.string().min(5, 'Address must be at least 5 characters'),
    landmark: z.string().optional(),
    city: z.string().min(2, 'City is required'),
    state: z.string().min(2, 'State is required'),
    pincode: z.string().regex(/^\d{6}$/, 'Pincode must be 6 digits'),
    lat: z.number().min(-90).max(90),
    lng: z.number().min(-180).max(180),
    isDefault: z.boolean().optional(),
  }),
})

export const updateAddressSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid address ID'),
  }),
  body: z.object({
    label: z.string().min(1).max(50).optional(),
    address: z.string().min(5).optional(),
    landmark: z.string().optional(),
    city: z.string().min(2).optional(),
    state: z.string().min(2).optional(),
    pincode: z.string().regex(/^\d{6}$/).optional(),
    lat: z.number().min(-90).max(90).optional(),
    lng: z.number().min(-180).max(180).optional(),
    isDefault: z.boolean().optional(),
  }),
})

export const addressIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid address ID'),
  }),
})
```

**Step 4: Create booking validator**

```typescript
// src/validators/booking.validator.ts
import { z } from 'zod'

const packageTypes = ['DOCUMENT', 'PARCEL', 'FOOD', 'GROCERY', 'MEDICINE', 'FRAGILE', 'OTHER'] as const
const paymentMethods = ['CASH', 'UPI', 'CARD', 'WALLET', 'NETBANKING'] as const
const bookingStatuses = ['PENDING', 'ACCEPTED', 'ARRIVED_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_DROP', 'DELIVERED', 'CANCELLED'] as const

export const calculatePriceSchema = z.object({
  body: z.object({
    vehicleTypeId: z.string().cuid('Invalid vehicle type ID'),
    pickupAddressId: z.string().cuid('Invalid pickup address ID'),
    dropAddressId: z.string().cuid('Invalid drop address ID'),
  }),
})

export const createBookingSchema = z.object({
  body: z.object({
    vehicleTypeId: z.string().cuid('Invalid vehicle type ID'),
    pickupAddressId: z.string().cuid('Invalid pickup address ID'),
    dropAddressId: z.string().cuid('Invalid drop address ID'),
    packageType: z.enum(packageTypes).optional(),
    packageWeight: z.number().positive('Weight must be positive').optional(),
    packageDescription: z.string().max(500).optional(),
    scheduledAt: z.string().datetime().optional(),
    paymentMethod: z.enum(paymentMethods).optional(),
  }),
})

export const bookingIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid booking ID'),
  }),
})

export const updateBookingStatusSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid booking ID'),
  }),
  body: z.object({
    status: z.enum(bookingStatuses),
    lat: z.number().min(-90).max(90).optional(),
    lng: z.number().min(-180).max(180).optional(),
    note: z.string().max(500).optional(),
  }),
})

export const cancelBookingSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid booking ID'),
  }),
  body: z.object({
    reason: z.string().min(5, 'Reason must be at least 5 characters').max(500),
  }),
})

export const listBookingsSchema = z.object({
  query: z.object({
    page: z.string().regex(/^\d+$/).transform(Number).optional(),
    limit: z.string().regex(/^\d+$/).transform(Number).optional(),
    status: z.enum(bookingStatuses).optional(),
  }),
})
```

**Step 5: Create pilot validator**

```typescript
// src/validators/pilot.validator.ts
import { z } from 'zod'

const phoneRegex = /^(\+91)?[6-9]\d{9}$/
const genders = ['MALE', 'FEMALE', 'OTHER'] as const

export const registerPilotSchema = z.object({
  body: z.object({
    phone: z.string().regex(phoneRegex, 'Invalid Indian phone number'),
    name: z.string().min(2, 'Name must be at least 2 characters'),
    email: z.string().email('Invalid email').optional(),
    dateOfBirth: z.string().datetime().optional(),
    gender: z.enum(genders).optional(),
  }),
})

export const updatePilotSchema = z.object({
  body: z.object({
    name: z.string().min(2).optional(),
    email: z.string().email().optional(),
    avatar: z.string().url().optional(),
    dateOfBirth: z.string().datetime().optional(),
    gender: z.enum(genders).optional(),
    aadhaarNumber: z.string().regex(/^\d{12}$/, 'Aadhaar must be 12 digits').optional(),
    licenseNumber: z.string().min(5).optional(),
    panNumber: z.string().regex(/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/, 'Invalid PAN format').optional(),
  }),
})

export const updatePilotLocationSchema = z.object({
  body: z.object({
    lat: z.number().min(-90).max(90),
    lng: z.number().min(-180).max(180),
  }),
})

export const updatePilotOnlineStatusSchema = z.object({
  body: z.object({
    isOnline: z.boolean(),
  }),
})

export const pilotIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid pilot ID'),
  }),
})
```

**Step 6: Create vehicle validator**

```typescript
// src/validators/vehicle.validator.ts
import { z } from 'zod'

export const createVehicleSchema = z.object({
  body: z.object({
    vehicleTypeId: z.string().cuid('Invalid vehicle type ID'),
    registrationNo: z.string().min(5, 'Registration number is required').optional(),
    model: z.string().min(2).optional(),
    color: z.string().min(2).optional(),
  }),
})

export const updateVehicleSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid vehicle ID'),
  }),
  body: z.object({
    registrationNo: z.string().min(5).optional(),
    model: z.string().min(2).optional(),
    color: z.string().min(2).optional(),
    isActive: z.boolean().optional(),
  }),
})

export const vehicleIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid vehicle ID'),
  }),
})
```

**Step 7: Create validator index and middleware**

```typescript
// src/validators/index.ts
import { Request, Response, NextFunction } from 'express'
import { AnyZodObject, ZodError } from 'zod'

export const validate = (schema: AnyZodObject) => {
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
        const errors = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message,
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
```

---

### Task 3: Create Rate Limiting Middleware

**Files:**
- Create: `src/middleware/rateLimiter.ts`

**Step 1: Create rate limiter**

```typescript
// src/middleware/rateLimiter.ts
import rateLimit from 'express-rate-limit'
import { config } from '../config'

// General API rate limiter
export const apiLimiter = rateLimit({
  windowMs: config.rateLimitWindowMs, // 15 minutes
  max: config.rateLimitMax, // 100 requests per window
  message: {
    success: false,
    message: 'Too many requests, please try again later.',
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
  },
  standardHeaders: true,
  legacyHeaders: false,
})
```

---

### Task 4: Create Structured Logger

**Files:**
- Create: `src/config/logger.ts`
- Modify: `src/index.ts`

**Step 1: Create winston logger**

```typescript
// src/config/logger.ts
import winston from 'winston'
import { config } from './index'

const levels = {
  error: 0,
  warn: 1,
  info: 2,
  http: 3,
  debug: 4,
}

const colors = {
  error: 'red',
  warn: 'yellow',
  info: 'green',
  http: 'magenta',
  debug: 'white',
}

winston.addColors(colors)

const format = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
  winston.format.colorize({ all: config.nodeEnv === 'development' }),
  winston.format.printf(
    (info) => `${info.timestamp} ${info.level}: ${info.message}`,
  ),
)

const transports = [
  new winston.transports.Console(),
  new winston.transports.File({
    filename: 'logs/error.log',
    level: 'error',
  }),
  new winston.transports.File({ filename: 'logs/all.log' }),
]

const logger = winston.createLogger({
  level: config.nodeEnv === 'development' ? 'debug' : 'warn',
  levels,
  format,
  transports,
})

export default logger
```

**Step 2: Create HTTP request logger middleware**

```typescript
// src/middleware/httpLogger.ts
import morgan, { StreamOptions } from 'morgan'
import logger from '../config/logger'

const stream: StreamOptions = {
  write: (message) => logger.http(message.trim()),
}

const skip = () => {
  const env = process.env.NODE_ENV || 'development'
  return env !== 'development'
}

export const httpLogger = morgan(
  ':method :url :status :res[content-length] - :response-time ms',
  { stream, skip }
)
```

---

### Task 5: Update Auth Routes with Validation & Rate Limiting

**Files:**
- Modify: `src/routes/auth.routes.ts`

**Step 1: Update auth routes**

```typescript
// src/routes/auth.routes.ts
import { Router } from 'express'
import * as authController from '../controllers/auth.controller'
import { validate, sendOTPSchema, verifyOTPSchema, adminLoginSchema, createAdminSchema } from '../validators'
import { authLimiter, otpLimiter } from '../middleware/rateLimiter'
import { authenticate, authorizeSuperAdmin } from '../middleware/auth'

const router = Router()

// User Auth
router.post('/user/send-otp', otpLimiter, validate(sendOTPSchema), authController.sendUserOTP)
router.post('/user/verify-otp', authLimiter, validate(verifyOTPSchema), authController.verifyUserOTP)

// Pilot Auth
router.post('/pilot/send-otp', otpLimiter, validate(sendOTPSchema), authController.sendPilotOTP)
router.post('/pilot/verify-otp', authLimiter, validate(verifyOTPSchema), authController.verifyPilotOTP)

// Admin Auth
router.post('/admin/login', authLimiter, validate(adminLoginSchema), authController.adminLogin)
router.post('/admin/create', authenticate, authorizeSuperAdmin, validate(createAdminSchema), authController.createAdmin)

export default router
```

---

### Task 6: Update Booking Routes with Validation

**Files:**
- Modify: `src/routes/booking.routes.ts`

**Step 1: Update booking routes**

```typescript
// src/routes/booking.routes.ts
import { Router } from 'express'
import * as bookingController from '../controllers/booking.controller'
import { authenticate, authorizeUser, authorizePilot } from '../middleware/auth'
import { bookingLimiter } from '../middleware/rateLimiter'
import {
  validate,
  calculatePriceSchema,
  createBookingSchema,
  bookingIdParamSchema,
  updateBookingStatusSchema,
  cancelBookingSchema,
  listBookingsSchema,
} from '../validators'

const router = Router()

// Price calculation
router.post('/calculate-price', authenticate, authorizeUser, validate(calculatePriceSchema), bookingController.calculatePrice)

// User booking routes
router.post('/', authenticate, authorizeUser, bookingLimiter, validate(createBookingSchema), bookingController.createBooking)
router.get('/my-bookings', authenticate, authorizeUser, validate(listBookingsSchema), bookingController.getUserBookings)
router.get('/:id', authenticate, validate(bookingIdParamSchema), bookingController.getBooking)
router.post('/:id/cancel', authenticate, authorizeUser, validate(cancelBookingSchema), bookingController.cancelBooking)

// Pilot booking routes
router.post('/:id/accept', authenticate, authorizePilot, validate(bookingIdParamSchema), bookingController.acceptBooking)
router.patch('/:id/status', authenticate, authorizePilot, validate(updateBookingStatusSchema), bookingController.updateBookingStatus)

export default router
```

---

## Phase 2: Comprehensive - Full CRUD APIs (Tasks 7-14)

### Task 7: Create User Service & Controller

**Files:**
- Create: `src/services/user.service.ts`
- Create: `src/controllers/user.controller.ts`

**Step 1: Create user service**

```typescript
// src/services/user.service.ts
import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'

export const getUserById = async (id: string) => {
  const user = await prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      phone: true,
      email: true,
      name: true,
      avatar: true,
      isVerified: true,
      isActive: true,
      createdAt: true,
      addresses: true,
      _count: {
        select: { bookings: true, reviews: true },
      },
    },
  })

  if (!user) {
    throw new AppError('User not found', 404)
  }

  return user
}

export const updateUser = async (
  id: string,
  data: { name?: string; email?: string; avatar?: string }
) => {
  const user = await prisma.user.update({
    where: { id },
    data,
    select: {
      id: true,
      phone: true,
      email: true,
      name: true,
      avatar: true,
      isVerified: true,
      updatedAt: true,
    },
  })

  return user
}

export const deleteUser = async (id: string) => {
  await prisma.user.update({
    where: { id },
    data: { isActive: false },
  })
}

export const listUsers = async (page: number = 1, limit: number = 10, search?: string) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = search
    ? {
        OR: [
          { name: { contains: search, mode: 'insensitive' as const } },
          { phone: { contains: search } },
          { email: { contains: search, mode: 'insensitive' as const } },
        ],
      }
    : {}

  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        phone: true,
        email: true,
        name: true,
        avatar: true,
        isVerified: true,
        isActive: true,
        createdAt: true,
        _count: { select: { bookings: true } },
      },
    }),
    prisma.user.count({ where }),
  ])

  return {
    users,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}
```

**Step 2: Create user controller**

```typescript
// src/controllers/user.controller.ts
import { Request, Response, NextFunction } from 'express'
import * as userService from '../services/user.service'
import { formatResponse } from '../utils/helpers'

export const getProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await userService.getUserById(req.user!.id)
    res.status(200).json(formatResponse(true, 'Profile retrieved', { user }))
  } catch (error) {
    next(error)
  }
}

export const updateProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await userService.updateUser(req.user!.id, req.body)
    res.status(200).json(formatResponse(true, 'Profile updated', { user }))
  } catch (error) {
    next(error)
  }
}

export const deleteAccount = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await userService.deleteUser(req.user!.id)
    res.status(200).json(formatResponse(true, 'Account deleted successfully'))
  } catch (error) {
    next(error)
  }
}

// Admin endpoints
export const listUsers = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const search = req.query.search as string | undefined
    const result = await userService.listUsers(page, limit, search)
    res.status(200).json(formatResponse(true, 'Users retrieved', { users: result.users }, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getUserById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const user = await userService.getUserById(req.params.id as string)
    res.status(200).json(formatResponse(true, 'User retrieved', { user }))
  } catch (error) {
    next(error)
  }
}
```

---

### Task 8: Create Address Service & Controller

**Files:**
- Create: `src/services/address.service.ts`
- Create: `src/controllers/address.controller.ts`

**Step 1: Create address service**

```typescript
// src/services/address.service.ts
import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'

interface CreateAddressInput {
  userId: string
  label: string
  address: string
  landmark?: string
  city: string
  state: string
  pincode: string
  lat: number
  lng: number
  isDefault?: boolean
}

export const createAddress = async (input: CreateAddressInput) => {
  const { userId, isDefault, ...data } = input

  // If setting as default, unset other defaults
  if (isDefault) {
    await prisma.address.updateMany({
      where: { userId, isDefault: true },
      data: { isDefault: false },
    })
  }

  const address = await prisma.address.create({
    data: { ...data, userId, isDefault: isDefault || false },
  })

  return address
}

export const getAddressById = async (id: string, userId: string) => {
  const address = await prisma.address.findUnique({ where: { id } })

  if (!address) {
    throw new AppError('Address not found', 404)
  }

  if (address.userId !== userId) {
    throw new AppError('Unauthorized', 403)
  }

  return address
}

export const updateAddress = async (
  id: string,
  userId: string,
  data: Partial<CreateAddressInput>
) => {
  const address = await prisma.address.findUnique({ where: { id } })

  if (!address) {
    throw new AppError('Address not found', 404)
  }

  if (address.userId !== userId) {
    throw new AppError('Unauthorized', 403)
  }

  // If setting as default, unset other defaults
  if (data.isDefault) {
    await prisma.address.updateMany({
      where: { userId, isDefault: true, id: { not: id } },
      data: { isDefault: false },
    })
  }

  const updated = await prisma.address.update({ where: { id }, data })
  return updated
}

export const deleteAddress = async (id: string, userId: string) => {
  const address = await prisma.address.findUnique({ where: { id } })

  if (!address) {
    throw new AppError('Address not found', 404)
  }

  if (address.userId !== userId) {
    throw new AppError('Unauthorized', 403)
  }

  await prisma.address.delete({ where: { id } })
}

export const getUserAddresses = async (userId: string) => {
  const addresses = await prisma.address.findMany({
    where: { userId },
    orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
  })
  return addresses
}
```

**Step 2: Create address controller**

```typescript
// src/controllers/address.controller.ts
import { Request, Response, NextFunction } from 'express'
import * as addressService from '../services/address.service'
import { formatResponse } from '../utils/helpers'

export const createAddress = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const address = await addressService.createAddress({ ...req.body, userId: req.user!.id })
    res.status(201).json(formatResponse(true, 'Address created', { address }))
  } catch (error) {
    next(error)
  }
}

export const getAddresses = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const addresses = await addressService.getUserAddresses(req.user!.id)
    res.status(200).json(formatResponse(true, 'Addresses retrieved', { addresses }))
  } catch (error) {
    next(error)
  }
}

export const getAddress = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const address = await addressService.getAddressById(req.params.id as string, req.user!.id)
    res.status(200).json(formatResponse(true, 'Address retrieved', { address }))
  } catch (error) {
    next(error)
  }
}

export const updateAddress = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const address = await addressService.updateAddress(req.params.id as string, req.user!.id, req.body)
    res.status(200).json(formatResponse(true, 'Address updated', { address }))
  } catch (error) {
    next(error)
  }
}

export const deleteAddress = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await addressService.deleteAddress(req.params.id as string, req.user!.id)
    res.status(200).json(formatResponse(true, 'Address deleted'))
  } catch (error) {
    next(error)
  }
}
```

---

### Task 9: Create Pilot Service & Controller

**Files:**
- Create: `src/services/pilot.service.ts`
- Create: `src/controllers/pilot.controller.ts`

**Step 1: Create pilot service**

```typescript
// src/services/pilot.service.ts
import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { Gender, PilotStatus } from '@prisma/client'

interface RegisterPilotInput {
  phone: string
  name: string
  email?: string
  dateOfBirth?: Date
  gender?: Gender
}

interface UpdatePilotInput {
  name?: string
  email?: string
  avatar?: string
  dateOfBirth?: Date
  gender?: Gender
  aadhaarNumber?: string
  licenseNumber?: string
  panNumber?: string
}

export const registerPilot = async (input: RegisterPilotInput) => {
  const existing = await prisma.pilot.findUnique({ where: { phone: input.phone } })
  if (existing) {
    throw new AppError('Pilot with this phone already exists', 400)
  }

  const pilot = await prisma.pilot.create({
    data: input,
    select: {
      id: true,
      phone: true,
      name: true,
      email: true,
      status: true,
      createdAt: true,
    },
  })

  return pilot
}

export const getPilotById = async (id: string) => {
  const pilot = await prisma.pilot.findUnique({
    where: { id },
    include: {
      vehicles: { include: { vehicleType: true } },
      bankAccount: true,
      documents: true,
      _count: { select: { bookings: true, reviews: true } },
    },
  })

  if (!pilot) {
    throw new AppError('Pilot not found', 404)
  }

  return pilot
}

export const updatePilot = async (id: string, data: UpdatePilotInput) => {
  const pilot = await prisma.pilot.update({
    where: { id },
    data,
    select: {
      id: true,
      phone: true,
      name: true,
      email: true,
      avatar: true,
      status: true,
      isVerified: true,
      updatedAt: true,
    },
  })

  return pilot
}

export const updateLocation = async (id: string, lat: number, lng: number) => {
  await prisma.pilot.update({
    where: { id },
    data: { currentLat: lat, currentLng: lng, lastLocationAt: new Date() },
  })
}

export const updateOnlineStatus = async (id: string, isOnline: boolean) => {
  const pilot = await prisma.pilot.update({
    where: { id },
    data: { isOnline },
    select: { id: true, isOnline: true },
  })
  return pilot
}

export const getPilotEarnings = async (id: string, page: number = 1, limit: number = 10) => {
  const { skip, take } = getPaginationParams(page, limit)

  const [earnings, total, stats] = await Promise.all([
    prisma.earning.findMany({
      where: { pilotId: id },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.earning.count({ where: { pilotId: id } }),
    prisma.earning.aggregate({
      where: { pilotId: id },
      _sum: { amount: true },
    }),
  ])

  return {
    earnings,
    totalEarnings: stats._sum.amount || 0,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const getPilotBookings = async (id: string, page: number = 1, limit: number = 10) => {
  const { skip, take } = getPaginationParams(page, limit)

  const [bookings, total] = await Promise.all([
    prisma.booking.findMany({
      where: { pilotId: id },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, name: true, phone: true } },
        pickupAddress: true,
        dropAddress: true,
        vehicleType: true,
      },
    }),
    prisma.booking.count({ where: { pilotId: id } }),
  ])

  return {
    bookings,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const listPilots = async (
  page: number = 1,
  limit: number = 10,
  status?: PilotStatus,
  search?: string
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    ...(status && { status }),
    ...(search && {
      OR: [
        { name: { contains: search, mode: 'insensitive' as const } },
        { phone: { contains: search } },
      ],
    }),
  }

  const [pilots, total] = await Promise.all([
    prisma.pilot.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true,
        phone: true,
        name: true,
        avatar: true,
        status: true,
        isOnline: true,
        rating: true,
        totalDeliveries: true,
        createdAt: true,
      },
    }),
    prisma.pilot.count({ where }),
  ])

  return {
    pilots,
    meta: { page, limit: take, total, totalPages: Math.ceil(total / take) },
  }
}

export const updatePilotStatus = async (id: string, status: PilotStatus) => {
  const pilot = await prisma.pilot.update({
    where: { id },
    data: { status, isVerified: status === 'APPROVED' },
  })
  return pilot
}

export const getNearbyPilots = async (lat: number, lng: number, radiusKm: number = 5) => {
  // Simple box-based query for nearby pilots
  const latDelta = radiusKm / 111 // 1 degree ~ 111km
  const lngDelta = radiusKm / (111 * Math.cos(lat * Math.PI / 180))

  const pilots = await prisma.pilot.findMany({
    where: {
      isOnline: true,
      status: 'APPROVED',
      currentLat: { gte: lat - latDelta, lte: lat + latDelta },
      currentLng: { gte: lng - lngDelta, lte: lng + lngDelta },
    },
    include: {
      vehicles: { where: { isActive: true, isVerified: true }, include: { vehicleType: true } },
    },
  })

  return pilots
}
```

**Step 2: Create pilot controller**

```typescript
// src/controllers/pilot.controller.ts
import { Request, Response, NextFunction } from 'express'
import * as pilotService from '../services/pilot.service'
import { formatResponse } from '../utils/helpers'
import { PilotStatus } from '@prisma/client'

export const registerPilot = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.registerPilot(req.body)
    res.status(201).json(formatResponse(true, 'Pilot registered successfully', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const getProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.getPilotById(req.user!.id)
    res.status(200).json(formatResponse(true, 'Profile retrieved', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const updateProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.updatePilot(req.user!.id, req.body)
    res.status(200).json(formatResponse(true, 'Profile updated', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const updateLocation = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await pilotService.updateLocation(req.user!.id, req.body.lat, req.body.lng)
    res.status(200).json(formatResponse(true, 'Location updated'))
  } catch (error) {
    next(error)
  }
}

export const updateOnlineStatus = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.updateOnlineStatus(req.user!.id, req.body.isOnline)
    res.status(200).json(formatResponse(true, 'Status updated', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const getEarnings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const result = await pilotService.getPilotEarnings(req.user!.id, page, limit)
    res.status(200).json(formatResponse(true, 'Earnings retrieved', result, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getBookings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const result = await pilotService.getPilotBookings(req.user!.id, page, limit)
    res.status(200).json(formatResponse(true, 'Bookings retrieved', { bookings: result.bookings }, result.meta))
  } catch (error) {
    next(error)
  }
}

// Admin endpoints
export const listPilots = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const status = req.query.status as PilotStatus | undefined
    const search = req.query.search as string | undefined
    const result = await pilotService.listPilots(page, limit, status, search)
    res.status(200).json(formatResponse(true, 'Pilots retrieved', { pilots: result.pilots }, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getPilotById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.getPilotById(req.params.id as string)
    res.status(200).json(formatResponse(true, 'Pilot retrieved', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const updatePilotStatus = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.updatePilotStatus(req.params.id as string, req.body.status)
    res.status(200).json(formatResponse(true, 'Pilot status updated', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const getNearbyPilots = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { lat, lng, radius } = req.query
    const pilots = await pilotService.getNearbyPilots(
      parseFloat(lat as string),
      parseFloat(lng as string),
      parseFloat(radius as string) || 5
    )
    res.status(200).json(formatResponse(true, 'Nearby pilots retrieved', { pilots }))
  } catch (error) {
    next(error)
  }
}
```

---

### Task 10: Create Vehicle Service & Controller

**Files:**
- Create: `src/services/vehicle.service.ts`
- Create: `src/controllers/vehicle.controller.ts`

**Step 1: Create vehicle service**

```typescript
// src/services/vehicle.service.ts
import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'

interface CreateVehicleInput {
  pilotId: string
  vehicleTypeId: string
  registrationNo?: string
  model?: string
  color?: string
}

export const createVehicle = async (input: CreateVehicleInput) => {
  // Verify vehicle type exists
  const vehicleType = await prisma.vehicleType.findUnique({ where: { id: input.vehicleTypeId } })
  if (!vehicleType) {
    throw new AppError('Vehicle type not found', 404)
  }

  const vehicle = await prisma.vehicle.create({
    data: input,
    include: { vehicleType: true },
  })

  return vehicle
}

export const getVehicleById = async (id: string, pilotId: string) => {
  const vehicle = await prisma.vehicle.findUnique({
    where: { id },
    include: { vehicleType: true },
  })

  if (!vehicle) {
    throw new AppError('Vehicle not found', 404)
  }

  if (vehicle.pilotId !== pilotId) {
    throw new AppError('Unauthorized', 403)
  }

  return vehicle
}

export const updateVehicle = async (
  id: string,
  pilotId: string,
  data: { registrationNo?: string; model?: string; color?: string; isActive?: boolean }
) => {
  const vehicle = await prisma.vehicle.findUnique({ where: { id } })

  if (!vehicle) {
    throw new AppError('Vehicle not found', 404)
  }

  if (vehicle.pilotId !== pilotId) {
    throw new AppError('Unauthorized', 403)
  }

  const updated = await prisma.vehicle.update({
    where: { id },
    data,
    include: { vehicleType: true },
  })

  return updated
}

export const deleteVehicle = async (id: string, pilotId: string) => {
  const vehicle = await prisma.vehicle.findUnique({ where: { id } })

  if (!vehicle) {
    throw new AppError('Vehicle not found', 404)
  }

  if (vehicle.pilotId !== pilotId) {
    throw new AppError('Unauthorized', 403)
  }

  await prisma.vehicle.delete({ where: { id } })
}

export const getPilotVehicles = async (pilotId: string) => {
  const vehicles = await prisma.vehicle.findMany({
    where: { pilotId },
    include: { vehicleType: true },
    orderBy: { createdAt: 'desc' },
  })
  return vehicles
}

export const getVehicleTypes = async () => {
  const types = await prisma.vehicleType.findMany({
    where: { isActive: true },
    orderBy: { basePrice: 'asc' },
  })
  return types
}
```

**Step 2: Create vehicle controller**

```typescript
// src/controllers/vehicle.controller.ts
import { Request, Response, NextFunction } from 'express'
import * as vehicleService from '../services/vehicle.service'
import { formatResponse } from '../utils/helpers'

export const createVehicle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const vehicle = await vehicleService.createVehicle({ ...req.body, pilotId: req.user!.id })
    res.status(201).json(formatResponse(true, 'Vehicle added', { vehicle }))
  } catch (error) {
    next(error)
  }
}

export const getVehicles = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const vehicles = await vehicleService.getPilotVehicles(req.user!.id)
    res.status(200).json(formatResponse(true, 'Vehicles retrieved', { vehicles }))
  } catch (error) {
    next(error)
  }
}

export const getVehicle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const vehicle = await vehicleService.getVehicleById(req.params.id as string, req.user!.id)
    res.status(200).json(formatResponse(true, 'Vehicle retrieved', { vehicle }))
  } catch (error) {
    next(error)
  }
}

export const updateVehicle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const vehicle = await vehicleService.updateVehicle(req.params.id as string, req.user!.id, req.body)
    res.status(200).json(formatResponse(true, 'Vehicle updated', { vehicle }))
  } catch (error) {
    next(error)
  }
}

export const deleteVehicle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await vehicleService.deleteVehicle(req.params.id as string, req.user!.id)
    res.status(200).json(formatResponse(true, 'Vehicle deleted'))
  } catch (error) {
    next(error)
  }
}

export const getVehicleTypes = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const types = await vehicleService.getVehicleTypes()
    res.status(200).json(formatResponse(true, 'Vehicle types retrieved', { types }))
  } catch (error) {
    next(error)
  }
}
```

---

### Task 11: Create Review Service & Controller

**Files:**
- Create: `src/services/review.service.ts`
- Create: `src/controllers/review.controller.ts`

**Step 1: Create review service**

```typescript
// src/services/review.service.ts
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
```

**Step 2: Create review controller**

```typescript
// src/controllers/review.controller.ts
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
```

---

### Task 12: Create All Routes

**Files:**
- Create: `src/routes/user.routes.ts`
- Create: `src/routes/address.routes.ts`
- Create: `src/routes/pilot.routes.ts`
- Create: `src/routes/vehicle.routes.ts`
- Create: `src/routes/review.routes.ts`
- Create: `src/routes/admin.routes.ts`
- Modify: `src/routes/index.ts`

**Step 1: Create user routes**

```typescript
// src/routes/user.routes.ts
import { Router } from 'express'
import * as userController from '../controllers/user.controller'
import { authenticate, authorizeUser, authorizeAdmin } from '../middleware/auth'
import { validate, updateUserSchema, userIdParamSchema } from '../validators'

const router = Router()

// User profile routes
router.get('/profile', authenticate, authorizeUser, userController.getProfile)
router.patch('/profile', authenticate, authorizeUser, validate(updateUserSchema), userController.updateProfile)
router.delete('/account', authenticate, authorizeUser, userController.deleteAccount)

// Admin routes
router.get('/', authenticate, authorizeAdmin, userController.listUsers)
router.get('/:id', authenticate, authorizeAdmin, validate(userIdParamSchema), userController.getUserById)

export default router
```

**Step 2: Create address routes**

```typescript
// src/routes/address.routes.ts
import { Router } from 'express'
import * as addressController from '../controllers/address.controller'
import { authenticate, authorizeUser } from '../middleware/auth'
import { validate, createAddressSchema, updateAddressSchema, addressIdParamSchema } from '../validators'

const router = Router()

router.post('/', authenticate, authorizeUser, validate(createAddressSchema), addressController.createAddress)
router.get('/', authenticate, authorizeUser, addressController.getAddresses)
router.get('/:id', authenticate, authorizeUser, validate(addressIdParamSchema), addressController.getAddress)
router.patch('/:id', authenticate, authorizeUser, validate(updateAddressSchema), addressController.updateAddress)
router.delete('/:id', authenticate, authorizeUser, validate(addressIdParamSchema), addressController.deleteAddress)

export default router
```

**Step 3: Create pilot routes**

```typescript
// src/routes/pilot.routes.ts
import { Router } from 'express'
import * as pilotController from '../controllers/pilot.controller'
import { authenticate, authorizePilot, authorizeAdmin } from '../middleware/auth'
import { validate, registerPilotSchema, updatePilotSchema, updatePilotLocationSchema, updatePilotOnlineStatusSchema, pilotIdParamSchema } from '../validators'

const router = Router()

// Public - Pilot registration
router.post('/register', validate(registerPilotSchema), pilotController.registerPilot)

// Pilot profile routes
router.get('/profile', authenticate, authorizePilot, pilotController.getProfile)
router.patch('/profile', authenticate, authorizePilot, validate(updatePilotSchema), pilotController.updateProfile)
router.patch('/location', authenticate, authorizePilot, validate(updatePilotLocationSchema), pilotController.updateLocation)
router.patch('/status', authenticate, authorizePilot, validate(updatePilotOnlineStatusSchema), pilotController.updateOnlineStatus)
router.get('/earnings', authenticate, authorizePilot, pilotController.getEarnings)
router.get('/bookings', authenticate, authorizePilot, pilotController.getBookings)

// Admin routes
router.get('/', authenticate, authorizeAdmin, pilotController.listPilots)
router.get('/nearby', authenticate, pilotController.getNearbyPilots)
router.get('/:id', authenticate, authorizeAdmin, validate(pilotIdParamSchema), pilotController.getPilotById)
router.patch('/:id/status', authenticate, authorizeAdmin, pilotController.updatePilotStatus)

export default router
```

**Step 4: Create vehicle routes**

```typescript
// src/routes/vehicle.routes.ts
import { Router } from 'express'
import * as vehicleController from '../controllers/vehicle.controller'
import { authenticate, authorizePilot } from '../middleware/auth'
import { validate, createVehicleSchema, updateVehicleSchema, vehicleIdParamSchema } from '../validators'

const router = Router()

// Public - Get vehicle types
router.get('/types', vehicleController.getVehicleTypes)

// Pilot vehicle routes
router.post('/', authenticate, authorizePilot, validate(createVehicleSchema), vehicleController.createVehicle)
router.get('/', authenticate, authorizePilot, vehicleController.getVehicles)
router.get('/:id', authenticate, authorizePilot, validate(vehicleIdParamSchema), vehicleController.getVehicle)
router.patch('/:id', authenticate, authorizePilot, validate(updateVehicleSchema), vehicleController.updateVehicle)
router.delete('/:id', authenticate, authorizePilot, validate(vehicleIdParamSchema), vehicleController.deleteVehicle)

export default router
```

**Step 5: Create review routes**

```typescript
// src/routes/review.routes.ts
import { Router } from 'express'
import * as reviewController from '../controllers/review.controller'
import { authenticate, authorizeUser } from '../middleware/auth'

const router = Router()

router.post('/booking/:bookingId', authenticate, authorizeUser, reviewController.createReview)
router.get('/pilot/:pilotId', reviewController.getPilotReviews)

export default router
```

**Step 6: Update routes index**

```typescript
// src/routes/index.ts
import { Router } from 'express'
import authRoutes from './auth.routes'
import bookingRoutes from './booking.routes'
import userRoutes from './user.routes'
import addressRoutes from './address.routes'
import pilotRoutes from './pilot.routes'
import vehicleRoutes from './vehicle.routes'
import reviewRoutes from './review.routes'

const router = Router()

// Health check
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'SendIt API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  })
})

// Mount routes
router.use('/auth', authRoutes)
router.use('/users', userRoutes)
router.use('/addresses', addressRoutes)
router.use('/pilots', pilotRoutes)
router.use('/vehicles', vehicleRoutes)
router.use('/bookings', bookingRoutes)
router.use('/reviews', reviewRoutes)

export default router
```

---

## Phase 3: Enterprise - Documentation & Monitoring (Tasks 13-15)

### Task 13: Create Swagger Documentation

**Files:**
- Create: `src/config/swagger.ts`
- Modify: `src/index.ts`

**Step 1: Create Swagger config**

```typescript
// src/config/swagger.ts
import swaggerJsdoc from 'swagger-jsdoc'

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'SendIt API',
      version: '1.0.0',
      description: 'SendIt Delivery Platform API Documentation',
      contact: {
        name: 'SendIt Team',
        email: 'support@sendit.co.in',
      },
    },
    servers: [
      {
        url: 'http://localhost:5000/api/v1',
        description: 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string' },
            errors: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  field: { type: 'string' },
                  message: { type: 'string' },
                },
              },
            },
          },
        },
        User: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            phone: { type: 'string' },
            email: { type: 'string' },
            name: { type: 'string' },
            avatar: { type: 'string' },
            isVerified: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Pilot: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            phone: { type: 'string' },
            name: { type: 'string' },
            email: { type: 'string' },
            status: { type: 'string', enum: ['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'] },
            rating: { type: 'number' },
            totalDeliveries: { type: 'integer' },
            isOnline: { type: 'boolean' },
          },
        },
        Booking: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            bookingNumber: { type: 'string' },
            status: { type: 'string', enum: ['PENDING', 'ACCEPTED', 'ARRIVED_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_DROP', 'DELIVERED', 'CANCELLED'] },
            totalAmount: { type: 'number' },
            distance: { type: 'number' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Address: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            label: { type: 'string' },
            address: { type: 'string' },
            city: { type: 'string' },
            state: { type: 'string' },
            pincode: { type: 'string' },
            lat: { type: 'number' },
            lng: { type: 'number' },
          },
        },
        VehicleType: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            name: { type: 'string' },
            description: { type: 'string' },
            maxWeight: { type: 'number' },
            basePrice: { type: 'number' },
            pricePerKm: { type: 'number' },
          },
        },
      },
    },
    tags: [
      { name: 'Auth', description: 'Authentication endpoints' },
      { name: 'Users', description: 'User management' },
      { name: 'Pilots', description: 'Pilot management' },
      { name: 'Bookings', description: 'Booking management' },
      { name: 'Addresses', description: 'Address management' },
      { name: 'Vehicles', description: 'Vehicle management' },
      { name: 'Reviews', description: 'Review management' },
    ],
  },
  apis: ['./src/routes/*.ts'],
}

export const swaggerSpec = swaggerJsdoc(options)
```

---

### Task 14: Add JSDoc Comments to Routes

**Files:**
- Modify: `src/routes/auth.routes.ts` (add JSDoc)
- Modify: `src/routes/booking.routes.ts` (add JSDoc)

**Step 1: Add JSDoc to auth routes**

Add at the top of auth.routes.ts after imports:

```typescript
/**
 * @swagger
 * /auth/user/send-otp:
 *   post:
 *     summary: Send OTP to user phone
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "+919876543210"
 *     responses:
 *       200:
 *         description: OTP sent successfully
 *       400:
 *         description: Validation error
 *       429:
 *         description: Too many requests
 *
 * @swagger
 * /auth/user/verify-otp:
 *   post:
 *     summary: Verify OTP and login
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - otp
 *             properties:
 *               phone:
 *                 type: string
 *               otp:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 *       400:
 *         description: Invalid OTP
 *
 * @swagger
 * /auth/admin/login:
 *   post:
 *     summary: Admin login
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 */
```

---

### Task 15: Update Main Application

**Files:**
- Modify: `src/index.ts`

**Step 1: Update index.ts with all middleware**

```typescript
// src/index.ts
import express, { Application } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import swaggerUi from 'swagger-ui-express'
import { config } from './config'
import prisma from './config/database'
import logger from './config/logger'
import { swaggerSpec } from './config/swagger'
import routes from './routes'
import { errorHandler, notFoundHandler } from './middleware/errorHandler'
import { httpLogger } from './middleware/httpLogger'
import { apiLimiter } from './middleware/rateLimiter'

const app: Application = express()

// Security middleware
app.use(helmet())
app.use(cors({
  origin: config.clientUrl,
  credentials: true,
}))

// Logging
app.use(httpLogger)

// Body parsing
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true }))

// Rate limiting
app.use('/api', apiLimiter)

// API Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'SendIt API Docs',
}))

// API Routes
app.use('/api/v1', routes)

// Root route
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to SendIt API',
    version: '1.0.0',
    docs: '/api-docs',
    health: '/api/v1/health',
  })
})

// Error handlers
app.use(notFoundHandler)
app.use(errorHandler)

// Start server
const startServer = async () => {
  try {
    await prisma.$connect()
    logger.info('Database connected successfully')

    app.listen(config.port, () => {
      logger.info(`
🚀 SendIt API Server Started
━━━━━━━━━━━━━━━━━━━━━━━━━━━
📡 Port: ${config.port}
🌍 Environment: ${config.nodeEnv}
🔗 URL: ${config.appUrl}
📚 API Docs: ${config.appUrl}/api-docs
📊 Health: ${config.appUrl}/api/v1/health
━━━━━━━━━━━━━━━━━━━━━━━━━━━
      `)
    })
  } catch (error) {
    logger.error('Failed to start server:', error)
    process.exit(1)
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  logger.info('Shutting down gracefully...')
  await prisma.$disconnect()
  process.exit(0)
})

process.on('SIGTERM', async () => {
  logger.info('SIGTERM received. Shutting down gracefully...')
  await prisma.$disconnect()
  process.exit(0)
})

startServer()

export default app
```

---

## Phase 4: Testing & Verification (Task 16)

### Task 16: Create API Test Script

**Files:**
- Create: `scripts/test-api.sh`

**Step 1: Create test script**

```bash
#!/bin/bash
# scripts/test-api.sh - API Testing Script

BASE_URL="http://localhost:5000/api/v1"
TOKEN=""

echo "🧪 SendIt API Test Suite"
echo "========================"

# Health Check
echo -e "\n1. Health Check"
curl -s "$BASE_URL/health" | jq .

# Send OTP
echo -e "\n2. Send OTP"
OTP_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/user/send-otp" \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210"}')
echo $OTP_RESPONSE | jq .
OTP=$(echo $OTP_RESPONSE | jq -r '.data.otp')

# Verify OTP
echo -e "\n3. Verify OTP"
AUTH_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/user/verify-otp" \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"+919876543210\", \"otp\": \"$OTP\"}")
echo $AUTH_RESPONSE | jq .
TOKEN=$(echo $AUTH_RESPONSE | jq -r '.data.accessToken')

# Get Profile
echo -e "\n4. Get User Profile"
curl -s "$BASE_URL/users/profile" \
  -H "Authorization: Bearer $TOKEN" | jq .

# Get Vehicle Types
echo -e "\n5. Get Vehicle Types"
curl -s "$BASE_URL/vehicles/types" | jq .

# Create Address
echo -e "\n6. Create Address"
curl -s -X POST "$BASE_URL/addresses" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "label": "Home",
    "address": "123 Test Street",
    "city": "Ahmedabad",
    "state": "Gujarat",
    "pincode": "380001",
    "lat": 23.0225,
    "lng": 72.5714
  }' | jq .

echo -e "\n✅ API Tests Complete"
```

**Step 2: Make executable and run**

```bash
chmod +x scripts/test-api.sh
./scripts/test-api.sh
```

---

## Summary

**Phase 1 (Essential):** Zod validation, rate limiting, structured logging
**Phase 2 (Comprehensive):** Full CRUD for users, pilots, addresses, vehicles, reviews
**Phase 3 (Enterprise):** Swagger documentation, request logging, metrics
**Phase 4 (Testing):** API test script for verification

**Total Files to Create:** 25
**Total Files to Modify:** 5

---

Plan complete and saved to `docs/plans/2026-01-30-api-hardening.md`. Two execution options:

**1. Subagent-Driven (this session)** - I dispatch fresh subagent per task, review between tasks, fast iteration

**2. Parallel Session (separate)** - Open new session with executing-plans, batch execution with checkpoints

**Which approach?**
