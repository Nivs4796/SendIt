import { Router } from 'express'
import * as adminController from '../controllers/admin.controller'
import { authenticate, authorize } from '../middleware/auth'

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
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard statistics
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
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: active
 *         schema:
 *           type: boolean
 *     responses:
 *       200:
 *         description: List of users
 */
router.get('/users', adminController.listUsers)

/**
 * @swagger
 * /admin/users/{userId}:
 *   get:
 *     summary: Get user details
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
 */
router.get('/users/:userId', adminController.getUserDetails)

/**
 * @swagger
 * /admin/users/{userId}/status:
 *   put:
 *     summary: Update user status (activate/suspend)
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
 *     responses:
 *       200:
 *         description: User status updated
 */
router.put('/users/:userId/status', adminController.updateUserStatus)

// ============================================
// PILOT MANAGEMENT
// ============================================

/**
 * @swagger
 * /admin/pilots:
 *   get:
 *     summary: List all pilots
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
router.get('/pilots', adminController.listPilots)

/**
 * @swagger
 * /admin/pilots/{pilotId}:
 *   get:
 *     summary: Get pilot details
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
 */
router.get('/pilots/:pilotId', adminController.getPilotDetails)

/**
 * @swagger
 * /admin/pilots/{pilotId}/status:
 *   put:
 *     summary: Update pilot status (approve/reject/suspend)
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
 *     responses:
 *       200:
 *         description: Pilot status updated
 */
router.put('/pilots/:pilotId/status', adminController.updatePilotStatus)

/**
 * @swagger
 * /admin/documents/{documentId}/verify:
 *   put:
 *     summary: Verify pilot document
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
 *     responses:
 *       200:
 *         description: Document verification status updated
 */
router.put('/documents/:documentId/verify', adminController.verifyDocument)

// ============================================
// BOOKING MANAGEMENT
// ============================================

/**
 * @swagger
 * /admin/bookings:
 *   get:
 *     summary: List all bookings
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
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *       - in: query
 *         name: dateFrom
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: dateTo
 *         schema:
 *           type: string
 *           format: date
 *     responses:
 *       200:
 *         description: List of bookings
 */
router.get('/bookings', adminController.listBookings)

/**
 * @swagger
 * /admin/bookings/{bookingId}:
 *   get:
 *     summary: Get booking details
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
 */
router.get('/bookings/:bookingId', adminController.getBookingDetails)

/**
 * @swagger
 * /admin/bookings/{bookingId}/assign:
 *   post:
 *     summary: Assign pilot to booking
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
 *         description: Pilot assigned
 */
router.post('/bookings/:bookingId/assign', adminController.assignPilot)

/**
 * @swagger
 * /admin/bookings/{bookingId}/cancel:
 *   post:
 *     summary: Cancel booking
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
 *     responses:
 *       200:
 *         description: Booking cancelled
 */
router.post('/bookings/:bookingId/cancel', adminController.cancelBooking)

// ============================================
// SETTINGS
// ============================================

/**
 * @swagger
 * /admin/settings:
 *   get:
 *     summary: Get all settings
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Settings object
 */
router.get('/settings', adminController.getSettings)

/**
 * @swagger
 * /admin/settings:
 *   put:
 *     summary: Update a single setting
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
 *               value:
 *                 type: string
 *               description:
 *                 type: string
 *     responses:
 *       200:
 *         description: Setting updated
 */
router.put('/settings', adminController.updateSetting)

/**
 * @swagger
 * /admin/settings/bulk:
 *   put:
 *     summary: Update multiple settings
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
 *                 items:
 *                   type: object
 *                   properties:
 *                     key:
 *                       type: string
 *                     value:
 *                       type: string
 *     responses:
 *       200:
 *         description: Settings updated
 */
router.put('/settings/bulk', adminController.updateSettings)

// ============================================
// ANALYTICS
// ============================================

/**
 * @swagger
 * /admin/analytics/bookings:
 *   get:
 *     summary: Get booking analytics
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: days
 *         schema:
 *           type: integer
 *           default: 30
 *     responses:
 *       200:
 *         description: Booking analytics
 */
router.get('/analytics/bookings', adminController.getBookingAnalytics)

/**
 * @swagger
 * /admin/analytics/revenue:
 *   get:
 *     summary: Get revenue analytics
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: days
 *         schema:
 *           type: integer
 *           default: 30
 *     responses:
 *       200:
 *         description: Revenue analytics
 */
router.get('/analytics/revenue', adminController.getRevenueAnalytics)

export default router
