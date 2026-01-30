import { Router } from 'express'
import * as adminController from '../controllers/admin.controller'
import { authenticate, authorize } from '../middleware/auth'
import { validate } from '../validators'
import {
  listUsersSchema,
  getUserDetailsSchema,
  updateUserStatusSchema,
  listPilotsSchema,
  getPilotDetailsSchema,
  adminUpdatePilotStatusSchema,
  verifyDocumentSchema,
  adminListBookingsSchema,
  getBookingDetailsSchema,
  assignPilotSchema,
  adminCancelBookingSchema,
  updateSettingSchema,
  updateSettingsBulkSchema,
  analyticsQuerySchema,
} from '../validators/admin.validator'

const router = Router()

// All admin routes require admin authentication
router.use(authenticate)
router.use(authorize('admin'))

// ============================================
// DASHBOARD
// ============================================

/**
 * @swagger
 * /admin/dashboard:
 *   get:
 *     summary: Get dashboard statistics
 *     description: Get overview statistics for the admin dashboard including user counts, booking stats, and revenue.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     totalUsers:
 *                       type: integer
 *                     totalPilots:
 *                       type: integer
 *                     totalBookings:
 *                       type: integer
 *                     totalRevenue:
 *                       type: number
 *                     pendingPilots:
 *                       type: integer
 *                     activeBookings:
 *                       type: integer
 */
router.get('/dashboard', adminController.getDashboard)

// ============================================
// USER MANAGEMENT
// ============================================

/**
 * @swagger
 * /admin/users:
 *   get:
 *     summary: List all users
 *     description: Get paginated list of all users with optional filtering.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *           minimum: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *           minimum: 1
 *           maximum: 100
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *           maxLength: 100
 *         description: Search by name, phone, or email
 *       - in: query
 *         name: active
 *         schema:
 *           type: boolean
 *         description: Filter by active status
 *     responses:
 *       200:
 *         description: List of users with pagination
 */
router.get('/users', validate(listUsersSchema), adminController.listUsers)

/**
 * @swagger
 * /admin/users/{userId}:
 *   get:
 *     summary: Get user details
 *     description: Get detailed information about a specific user including their bookings and addresses.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: User details
 *       404:
 *         description: User not found
 */
router.get('/users/:userId', validate(getUserDetailsSchema), adminController.getUserDetails)

/**
 * @swagger
 * /admin/users/{userId}/status:
 *   put:
 *     summary: Update user status
 *     description: Activate or suspend a user account.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - isActive
 *             properties:
 *               isActive:
 *                 type: boolean
 *                 description: true to activate, false to suspend
 *           example:
 *             isActive: false
 *     responses:
 *       200:
 *         description: User status updated
 *       404:
 *         description: User not found
 */
router.put('/users/:userId/status', validate(updateUserStatusSchema), adminController.updateUserStatus)

// ============================================
// PILOT MANAGEMENT
// ============================================

/**
 * @swagger
 * /admin/pilots:
 *   get:
 *     summary: List all pilots
 *     description: Get paginated list of all pilots with optional filtering by status and online state.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [PENDING, APPROVED, REJECTED, SUSPENDED]
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: online
 *         schema:
 *           type: boolean
 *     responses:
 *       200:
 *         description: List of pilots
 */
router.get('/pilots', validate(listPilotsSchema), adminController.listPilots)

/**
 * @swagger
 * /admin/pilots/{pilotId}:
 *   get:
 *     summary: Get pilot details
 *     description: Get detailed information about a pilot including documents, vehicles, and earnings.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: pilotId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Pilot details
 *       404:
 *         description: Pilot not found
 */
router.get('/pilots/:pilotId', validate(getPilotDetailsSchema), adminController.getPilotDetails)

/**
 * @swagger
 * /admin/pilots/{pilotId}/status:
 *   put:
 *     summary: Update pilot status
 *     description: Approve, reject, or suspend a pilot.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: pilotId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [PENDING, APPROVED, REJECTED, SUSPENDED]
 *               reason:
 *                 type: string
 *                 maxLength: 500
 *                 description: Required when rejecting or suspending
 *           example:
 *             status: "APPROVED"
 *     responses:
 *       200:
 *         description: Pilot status updated
 *       404:
 *         description: Pilot not found
 */
router.put('/pilots/:pilotId/status', validate(adminUpdatePilotStatusSchema), adminController.updatePilotStatus)

/**
 * @swagger
 * /admin/documents/{documentId}/verify:
 *   put:
 *     summary: Verify pilot document
 *     description: Approve or reject a pilot's uploaded document.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: documentId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [APPROVED, REJECTED]
 *               rejectedReason:
 *                 type: string
 *                 description: Required when status is REJECTED
 *           example:
 *             status: "APPROVED"
 *     responses:
 *       200:
 *         description: Document verification status updated
 *       400:
 *         description: Rejection reason required when rejecting
 *       404:
 *         description: Document not found
 */
router.put('/documents/:documentId/verify', validate(verifyDocumentSchema), adminController.verifyDocument)

// ============================================
// BOOKING MANAGEMENT
// ============================================

/**
 * @swagger
 * /admin/bookings:
 *   get:
 *     summary: List all bookings
 *     description: Get paginated list of all bookings with optional filtering.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [PENDING, SEARCHING, CONFIRMED, PILOT_ARRIVED, PICKED_UP, IN_TRANSIT, DELIVERED, CANCELLED]
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: dateFrom
 *         schema:
 *           type: string
 *           format: date-time
 *       - in: query
 *         name: dateTo
 *         schema:
 *           type: string
 *           format: date-time
 *     responses:
 *       200:
 *         description: List of bookings
 */
router.get('/bookings', validate(adminListBookingsSchema), adminController.listBookings)

/**
 * @swagger
 * /admin/bookings/{bookingId}:
 *   get:
 *     summary: Get booking details
 *     description: Get detailed information about a specific booking.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Booking details
 *       404:
 *         description: Booking not found
 */
router.get('/bookings/:bookingId', validate(getBookingDetailsSchema), adminController.getBookingDetails)

/**
 * @swagger
 * /admin/bookings/{bookingId}/assign:
 *   post:
 *     summary: Assign pilot to booking
 *     description: Manually assign a specific pilot to a booking.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - pilotId
 *             properties:
 *               pilotId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Pilot assigned successfully
 *       400:
 *         description: Pilot not available
 *       404:
 *         description: Booking or pilot not found
 */
router.post('/bookings/:bookingId/assign', validate(assignPilotSchema), adminController.assignPilot)

/**
 * @swagger
 * /admin/bookings/{bookingId}/cancel:
 *   post:
 *     summary: Cancel booking
 *     description: Cancel a booking with a reason.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - reason
 *             properties:
 *               reason:
 *                 type: string
 *                 minLength: 10
 *                 maxLength: 500
 *                 description: Cancellation reason (10-500 characters)
 *           example:
 *             reason: "Customer requested cancellation due to change in plans"
 *     responses:
 *       200:
 *         description: Booking cancelled
 *       400:
 *         description: Booking cannot be cancelled
 *       404:
 *         description: Booking not found
 */
router.post('/bookings/:bookingId/cancel', validate(adminCancelBookingSchema), adminController.cancelBooking)

// ============================================
// SETTINGS
// ============================================

/**
 * @swagger
 * /admin/settings:
 *   get:
 *     summary: Get all settings
 *     description: Get all system settings.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Settings object with all key-value pairs
 */
router.get('/settings', adminController.getSettings)

/**
 * @swagger
 * /admin/settings:
 *   put:
 *     summary: Update a single setting
 *     description: Update a system setting by key.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - key
 *               - value
 *             properties:
 *               key:
 *                 type: string
 *                 pattern: "^[a-z_]+$"
 *                 description: Setting key (lowercase with underscores)
 *               value:
 *                 type: string
 *               description:
 *                 type: string
 *           example:
 *             key: "base_fare"
 *             value: "25"
 *             description: "Base fare for all rides"
 *     responses:
 *       200:
 *         description: Setting updated
 */
router.put('/settings', validate(updateSettingSchema), adminController.updateSetting)

/**
 * @swagger
 * /admin/settings/bulk:
 *   put:
 *     summary: Update multiple settings
 *     description: Update multiple settings at once.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - settings
 *             properties:
 *               settings:
 *                 type: array
 *                 minItems: 1
 *                 maxItems: 20
 *                 items:
 *                   type: object
 *                   required:
 *                     - key
 *                     - value
 *                   properties:
 *                     key:
 *                       type: string
 *                     value:
 *                       type: string
 *           example:
 *             settings:
 *               - key: "base_fare"
 *                 value: "25"
 *               - key: "per_km_rate"
 *                 value: "12"
 *     responses:
 *       200:
 *         description: Settings updated
 */
router.put('/settings/bulk', validate(updateSettingsBulkSchema), adminController.updateSettings)

// ============================================
// ANALYTICS
// ============================================

/**
 * @swagger
 * /admin/analytics/bookings:
 *   get:
 *     summary: Get booking analytics
 *     description: Get booking statistics and trends.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: days
 *         schema:
 *           type: integer
 *           default: 30
 *           minimum: 1
 *           maximum: 365
 *         description: Number of days to analyze
 *     responses:
 *       200:
 *         description: Booking analytics data
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     totalBookings:
 *                       type: integer
 *                     bookingsByStatus:
 *                       type: object
 *                     dailyBookings:
 *                       type: array
 */
router.get('/analytics/bookings', validate(analyticsQuerySchema), adminController.getBookingAnalytics)

/**
 * @swagger
 * /admin/analytics/revenue:
 *   get:
 *     summary: Get revenue analytics
 *     description: Get revenue statistics and trends.
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: days
 *         schema:
 *           type: integer
 *           default: 30
 *           minimum: 1
 *           maximum: 365
 *         description: Number of days to analyze
 *     responses:
 *       200:
 *         description: Revenue analytics data
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     totalRevenue:
 *                       type: number
 *                     dailyRevenue:
 *                       type: array
 */
router.get('/analytics/revenue', validate(analyticsQuerySchema), adminController.getRevenueAnalytics)

export default router
