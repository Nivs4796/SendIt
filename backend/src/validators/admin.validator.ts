import { z } from 'zod'

// Common schemas
const uuidSchema = z.string().min(1, 'ID is required')

const paginationSchema = z.object({
  page: z
    .string()
    .optional()
    .default('1')
    .transform((val) => parseInt(val))
    .pipe(z.number().int().positive()),
  limit: z
    .string()
    .optional()
    .default('10')
    .transform((val) => parseInt(val))
    .pipe(z.number().int().positive().max(100)),
})

// ============================================
// USER MANAGEMENT
// ============================================

export const listUsersSchema = z.object({
  query: paginationSchema.extend({
    search: z.string().max(100).optional(),
    active: z.enum(['true', 'false']).optional(),
  }),
})

export const getUserDetailsSchema = z.object({
  params: z.object({
    userId: uuidSchema,
  }),
})

export const updateUserStatusSchema = z.object({
  params: z.object({
    userId: uuidSchema,
  }),
  body: z.object({
    isActive: z.boolean({ message: 'isActive must be a boolean' }),
  }),
})

export const adminUpdateUserSchema = z.object({
  params: z.object({
    userId: uuidSchema,
  }),
  body: z.object({
    name: z.string().min(2).max(100).optional(),
    email: z.string().email('Invalid email format').optional(),
    phone: z.string().min(10).max(15).optional(),
  }).refine((data) => {
    return data.name || data.email || data.phone
  }, {
    message: 'At least one field (name, email, or phone) must be provided',
  }),
})

// ============================================
// PILOT MANAGEMENT
// ============================================

export const listPilotsSchema = z.object({
  query: paginationSchema.extend({
    status: z.enum(['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED']).optional(),
    search: z.string().max(100).optional(),
    online: z.enum(['true', 'false']).optional(),
  }),
})

export const getPilotDetailsSchema = z.object({
  params: z.object({
    pilotId: uuidSchema,
  }),
})

export const adminUpdatePilotStatusSchema = z.object({
  params: z.object({
    pilotId: uuidSchema,
  }),
  body: z.object({
    status: z.enum(['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'], {
      message: 'Status must be one of: PENDING, APPROVED, REJECTED, SUSPENDED',
    }),
    reason: z.string().max(500).optional(),
  }),
})

export const verifyDocumentSchema = z.object({
  params: z.object({
    documentId: uuidSchema,
  }),
  body: z.object({
    status: z.enum(['APPROVED', 'REJECTED'], {
      message: 'Status must be either APPROVED or REJECTED',
    }),
    rejectedReason: z.string().max(500).optional(),
  }).refine((data) => {
    // If rejected, reason should be provided
    if (data.status === 'REJECTED' && !data.rejectedReason) {
      return false
    }
    return true
  }, {
    message: 'Rejection reason is required when rejecting a document',
    path: ['rejectedReason'],
  }),
})

// ============================================
// BOOKING MANAGEMENT
// ============================================

export const adminListBookingsSchema = z.object({
  query: paginationSchema.extend({
    status: z.enum([
      'PENDING',
      'SEARCHING',
      'CONFIRMED',
      'PILOT_ARRIVED',
      'PICKED_UP',
      'IN_TRANSIT',
      'DELIVERED',
      'CANCELLED',
    ]).optional(),
    search: z.string().max(100).optional(),
    dateFrom: z.string().datetime().optional(),
    dateTo: z.string().datetime().optional(),
  }),
})

export const getBookingDetailsSchema = z.object({
  params: z.object({
    bookingId: uuidSchema,
  }),
})

export const assignPilotSchema = z.object({
  params: z.object({
    bookingId: uuidSchema,
  }),
  body: z.object({
    pilotId: uuidSchema,
  }),
})

export const adminCancelBookingSchema = z.object({
  params: z.object({
    bookingId: uuidSchema,
  }),
  body: z.object({
    reason: z
      .string()
      .min(10, 'Cancellation reason must be at least 10 characters')
      .max(500, 'Cancellation reason must be at most 500 characters'),
  }),
})

// ============================================
// SETTINGS
// ============================================

export const updateSettingSchema = z.object({
  body: z.object({
    key: z
      .string()
      .min(1, 'Key is required')
      .max(50)
      .regex(/^[a-z_]+$/, 'Key must be lowercase with underscores only'),
    value: z.string().min(1, 'Value is required').max(500),
    description: z.string().max(200).optional(),
  }),
})

export const updateSettingsBulkSchema = z.object({
  body: z.object({
    settings: z
      .array(
        z.object({
          key: z.string().min(1).max(50),
          value: z.string().min(1).max(500),
        })
      )
      .min(1, 'At least one setting is required')
      .max(20, 'Maximum 20 settings per request'),
  }),
})

// ============================================
// ANALYTICS
// ============================================

export const analyticsQuerySchema = z.object({
  query: z.object({
    days: z
      .string()
      .optional()
      .default('30')
      .transform((val) => parseInt(val))
      .pipe(z.number().int().positive().max(365, 'Maximum 365 days')),
  }),
})

// ============================================
// PILOT EDIT
// ============================================

export const adminUpdatePilotSchema_Edit = z.object({
  params: z.object({
    pilotId: uuidSchema,
  }),
  body: z.object({
    name: z.string().min(2).max(100).optional(),
    email: z.string().email('Invalid email format').optional(),
    phone: z.string().min(10).max(15).optional(),
    dateOfBirth: z.string().datetime().optional(),
    gender: z.enum(['MALE', 'FEMALE', 'OTHER']).optional(),
  }).refine((data) => {
    return data.name || data.email || data.phone || data.dateOfBirth || data.gender
  }, {
    message: 'At least one field must be provided',
  }),
})

// ============================================
// VEHICLE MANAGEMENT
// ============================================

export const listVehiclesSchema = z.object({
  query: paginationSchema.extend({
    search: z.string().max(100).optional(),
    verified: z.enum(['true', 'false']).optional(),
    vehicleTypeId: z.string().optional(),
  }),
})

export const getVehicleDetailsSchema = z.object({
  params: z.object({
    vehicleId: uuidSchema,
  }),
})

export const verifyVehicleSchema = z.object({
  params: z.object({
    vehicleId: uuidSchema,
  }),
  body: z.object({
    isVerified: z.boolean({ message: 'isVerified must be a boolean' }),
    reason: z.string().max(500).optional(),
  }).refine((data) => {
    // If rejecting, reason should be provided
    if (!data.isVerified && !data.reason) {
      return false
    }
    return true
  }, {
    message: 'Reason is required when rejecting a vehicle',
    path: ['reason'],
  }),
})

// ============================================
// WALLET TRANSACTIONS
// ============================================

export const listWalletTransactionsSchema = z.object({
  query: paginationSchema.extend({
    userId: z.string().optional(),
    type: z.enum(['CREDIT', 'DEBIT']).optional(),
    dateFrom: z.string().datetime().optional(),
    dateTo: z.string().datetime().optional(),
  }),
})
