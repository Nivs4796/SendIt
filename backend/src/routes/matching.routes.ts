import { Router } from 'express'
import * as matchingController from '../controllers/matching.controller'
import { authenticate, authorize } from '../middleware/auth'
import { validate } from '../validators'
import {
  findNearbyPilotsSchema,
  findPilotForBookingSchema,
  autoAssignBookingSchema,
  getAvailableJobsSchema,
  respondToOfferSchema,
} from '../validators/matching.validator'

const router = Router()

/**
 * @swagger
 * /matching/pilots/nearby:
 *   get:
 *     summary: Find nearby available pilots
 *     description: Search for available pilots within a specified radius from given coordinates. Admin only.
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: lat
 *         required: true
 *         schema:
 *           type: number
 *           minimum: -90
 *           maximum: 90
 *         description: Pickup latitude (-90 to 90)
 *       - in: query
 *         name: lng
 *         required: true
 *         schema:
 *           type: number
 *           minimum: -180
 *           maximum: 180
 *         description: Pickup longitude (-180 to 180)
 *       - in: query
 *         name: vehicleTypeId
 *         required: true
 *         schema:
 *           type: string
 *         description: Required vehicle type ID
 *       - in: query
 *         name: radius
 *         schema:
 *           type: number
 *           default: 5
 *           maximum: 50
 *         description: Search radius in km (max 50km)
 *     responses:
 *       200:
 *         description: List of nearby pilots with scores
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     pilots:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: string
 *                           name:
 *                             type: string
 *                           distance:
 *                             type: number
 *                           rating:
 *                             type: number
 *                           score:
 *                             type: number
 *                     count:
 *                       type: integer
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin only
 */
router.get(
  '/pilots/nearby',
  authenticate,
  authorize('admin'),
  validate(findNearbyPilotsSchema),
  matchingController.findNearbyPilots
)

/**
 * @swagger
 * /matching/bookings/{bookingId}/find-pilot:
 *   get:
 *     summary: Find and assign best pilot for a booking
 *     description: Find the most suitable pilot for a booking based on distance, rating, and availability. Admin only.
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: string
 *         description: Booking ID to find pilot for
 *     responses:
 *       200:
 *         description: Best available pilot found and job offer created
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     pilot:
 *                       type: object
 *       400:
 *         description: Validation error or no pilots available
 *       404:
 *         description: Booking not found
 */
router.get(
  '/bookings/:bookingId/find-pilot',
  authenticate,
  authorize('admin'),
  validate(findPilotForBookingSchema),
  matchingController.findPilots
)

/**
 * @swagger
 * /matching/bookings/{bookingId}/auto-assign:
 *   post:
 *     summary: Auto-assign booking to best pilot
 *     description: Automatically find and assign the best available pilot to a booking. Admin only.
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: bookingId
 *         required: true
 *         schema:
 *           type: string
 *         description: Booking ID to auto-assign
 *     responses:
 *       200:
 *         description: Pilot auto-assigned successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     pilotId:
 *                       type: string
 *       400:
 *         description: No pilots available
 *       404:
 *         description: Booking not found
 */
router.post(
  '/bookings/:bookingId/auto-assign',
  authenticate,
  authorize('admin'),
  validate(autoAssignBookingSchema),
  matchingController.autoAssign
)

/**
 * @swagger
 * /matching/jobs/available:
 *   get:
 *     summary: Get available jobs for pilot
 *     description: Get list of available delivery jobs that the authenticated pilot can accept. Pilot only.
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *           minimum: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *           minimum: 1
 *           maximum: 100
 *         description: Items per page
 *     responses:
 *       200:
 *         description: List of available jobs
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
 *                     jobs:
 *                       type: array
 *                       items:
 *                         type: object
 *                 meta:
 *                   type: object
 *                   properties:
 *                     page:
 *                       type: integer
 *                     limit:
 *                       type: integer
 *                     total:
 *                       type: integer
 */
router.get(
  '/jobs/available',
  authenticate,
  authorize('pilot'),
  validate(getAvailableJobsSchema),
  matchingController.getAvailableJobs
)

/**
 * @swagger
 * /matching/offers/pending:
 *   get:
 *     summary: Get pending job offers for pilot
 *     description: Get list of job offers waiting for pilot's response. Pilot only.
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pending offers
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
 *                     offers:
 *                       type: array
 *                       items:
 *                         type: object
 *                         properties:
 *                           id:
 *                             type: string
 *                           booking:
 *                             type: object
 *                           expiresAt:
 *                             type: string
 *                             format: date-time
 */
router.get(
  '/offers/pending',
  authenticate,
  authorize('pilot'),
  matchingController.getPendingOffers
)

/**
 * @swagger
 * /matching/offers/{offerId}/respond:
 *   post:
 *     summary: Respond to job offer
 *     description: Accept or decline a pending job offer. Pilot only.
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: offerId
 *         required: true
 *         schema:
 *           type: string
 *         description: Job offer ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - accept
 *             properties:
 *               accept:
 *                 type: boolean
 *                 description: true to accept, false to decline
 *           example:
 *             accept: true
 *     responses:
 *       200:
 *         description: Response recorded successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *       400:
 *         description: Offer expired or already responded
 *       404:
 *         description: Offer not found
 */
router.post(
  '/offers/:offerId/respond',
  authenticate,
  authorize('pilot'),
  validate(respondToOfferSchema),
  matchingController.respondToOffer
)

export default router
