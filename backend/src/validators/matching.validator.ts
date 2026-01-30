import { z } from 'zod'

// Latitude validation (-90 to 90)
const latitudeSchema = z
  .string()
  .transform((val) => parseFloat(val))
  .pipe(z.number().min(-90).max(90))

// Longitude validation (-180 to 180)
const longitudeSchema = z
  .string()
  .transform((val) => parseFloat(val))
  .pipe(z.number().min(-180).max(180))

// UUID validation
const uuidSchema = z.string().min(1, 'ID is required')

// Pagination schema
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

/**
 * Find nearby pilots query validation
 */
export const findNearbyPilotsSchema = z.object({
  query: z.object({
    lat: latitudeSchema,
    lng: longitudeSchema,
    vehicleTypeId: uuidSchema,
    radius: z
      .string()
      .optional()
      .default('5')
      .transform((val) => parseFloat(val))
      .pipe(z.number().positive().max(50, 'Maximum radius is 50km')),
  }),
})

/**
 * Find pilot for booking params validation
 */
export const findPilotForBookingSchema = z.object({
  params: z.object({
    bookingId: uuidSchema,
  }),
})

/**
 * Auto-assign booking params validation
 */
export const autoAssignBookingSchema = z.object({
  params: z.object({
    bookingId: uuidSchema,
  }),
})

/**
 * Get available jobs query validation
 */
export const getAvailableJobsSchema = z.object({
  query: paginationSchema,
})

/**
 * Respond to job offer validation
 */
export const respondToOfferSchema = z.object({
  params: z.object({
    offerId: uuidSchema,
  }),
  body: z.object({
    accept: z.boolean({ message: 'Accept must be a boolean' }),
  }),
})
