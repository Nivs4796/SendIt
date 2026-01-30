import { Router } from 'express'
import * as pilotController from '../controllers/pilot.controller'
import { authenticate, authorizePilot, authorizeAdmin } from '../middleware/auth'
import { validate, registerPilotSchema, updatePilotSchema, updatePilotLocationSchema, updatePilotOnlineStatusSchema, pilotIdParamSchema, updatePilotStatusSchema } from '../validators'

const router = Router()

/**
 * @swagger
 * /pilots/register:
 *   post:
 *     summary: Register as a pilot
 *     tags: [Pilots]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - name
 *             properties:
 *               phone:
 *                 type: string
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               dateOfBirth:
 *                 type: string
 *                 format: date-time
 *               gender:
 *                 type: string
 *                 enum: [MALE, FEMALE, OTHER]
 *     responses:
 *       201:
 *         description: Pilot registered
 */
router.post('/register', validate(registerPilotSchema), pilotController.registerPilot)

/**
 * @swagger
 * /pilots/profile:
 *   get:
 *     summary: Get pilot profile
 *     tags: [Pilots]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile retrieved
 */
router.get('/profile', authenticate, authorizePilot, pilotController.getProfile)

/**
 * @swagger
 * /pilots/profile:
 *   patch:
 *     summary: Update pilot profile
 *     tags: [Pilots]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               avatar:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profile updated
 */
router.patch('/profile', authenticate, authorizePilot, validate(updatePilotSchema), pilotController.updateProfile)

/**
 * @swagger
 * /pilots/location:
 *   patch:
 *     summary: Update pilot location
 *     tags: [Pilots]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - lat
 *               - lng
 *             properties:
 *               lat:
 *                 type: number
 *               lng:
 *                 type: number
 *     responses:
 *       200:
 *         description: Location updated
 */
router.patch('/location', authenticate, authorizePilot, validate(updatePilotLocationSchema), pilotController.updateLocation)

/**
 * @swagger
 * /pilots/status:
 *   patch:
 *     summary: Update pilot online status
 *     tags: [Pilots]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - isOnline
 *             properties:
 *               isOnline:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Status updated
 */
router.patch('/status', authenticate, authorizePilot, validate(updatePilotOnlineStatusSchema), pilotController.updateOnlineStatus)

/**
 * @swagger
 * /pilots/earnings:
 *   get:
 *     summary: Get pilot earnings
 *     tags: [Pilots]
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
 *     responses:
 *       200:
 *         description: Earnings list
 */
router.get('/earnings', authenticate, authorizePilot, pilotController.getEarnings)

/**
 * @swagger
 * /pilots/bookings:
 *   get:
 *     summary: Get pilot bookings
 *     tags: [Pilots]
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
 *     responses:
 *       200:
 *         description: Bookings list
 */
router.get('/bookings', authenticate, authorizePilot, pilotController.getBookings)

/**
 * @swagger
 * /pilots:
 *   get:
 *     summary: List all pilots (Admin only)
 *     tags: [Pilots]
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
 *     responses:
 *       200:
 *         description: Pilots list
 */
router.get('/', authenticate, authorizeAdmin, pilotController.listPilots)

/**
 * @swagger
 * /pilots/nearby:
 *   get:
 *     summary: Get nearby pilots
 *     tags: [Pilots]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: lat
 *         required: true
 *         schema:
 *           type: number
 *       - in: query
 *         name: lng
 *         required: true
 *         schema:
 *           type: number
 *       - in: query
 *         name: radius
 *         schema:
 *           type: number
 *     responses:
 *       200:
 *         description: Nearby pilots
 */
router.get('/nearby', authenticate, pilotController.getNearbyPilots)

/**
 * @swagger
 * /pilots/{id}:
 *   get:
 *     summary: Get pilot by ID (Admin only)
 *     tags: [Pilots]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Pilot details
 */
router.get('/:id', authenticate, authorizeAdmin, validate(pilotIdParamSchema), pilotController.getPilotById)

/**
 * @swagger
 * /pilots/{id}/status:
 *   patch:
 *     summary: Update pilot approval status (Admin only)
 *     tags: [Pilots]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
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
 *     responses:
 *       200:
 *         description: Status updated
 */
router.patch('/:id/status', authenticate, authorizeAdmin, validate(updatePilotStatusSchema), pilotController.updatePilotStatus)

export default router
