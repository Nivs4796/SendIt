import { Router } from 'express'
import * as matchingController from '../controllers/matching.controller'
import { authenticate, authorize } from '../middleware/auth'

const router = Router()

/**
 * @swagger
 * /matching/pilots/nearby:
 *   get:
 *     summary: Find nearby available pilots
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: lat
 *         required: true
 *         schema:
 *           type: number
 *         description: Pickup latitude
 *       - in: query
 *         name: lng
 *         required: true
 *         schema:
 *           type: number
 *         description: Pickup longitude
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
 *         description: Search radius in km
 *     responses:
 *       200:
 *         description: List of nearby pilots
 */
router.get(
  '/pilots/nearby',
  authenticate,
  authorize('admin'),
  matchingController.findNearbyPilots
)

/**
 * @swagger
 * /matching/bookings/{bookingId}/find-pilot:
 *   get:
 *     summary: Find best pilot for a booking
 *     tags: [Matching]
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
 *         description: Best available pilot found
 */
router.get(
  '/bookings/:bookingId/find-pilot',
  authenticate,
  authorize('admin'),
  matchingController.findPilots
)

/**
 * @swagger
 * /matching/bookings/{bookingId}/auto-assign:
 *   post:
 *     summary: Auto-assign booking to best pilot
 *     tags: [Matching]
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
 *         description: Job offer sent to pilot
 */
router.post(
  '/bookings/:bookingId/auto-assign',
  authenticate,
  authorize('admin'),
  matchingController.autoAssign
)

/**
 * @swagger
 * /matching/jobs/available:
 *   get:
 *     summary: Get available jobs for pilot
 *     tags: [Matching]
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
 *     responses:
 *       200:
 *         description: Available jobs list
 */
router.get(
  '/jobs/available',
  authenticate,
  authorize('pilot'),
  matchingController.getAvailableJobs
)

/**
 * @swagger
 * /matching/offers/pending:
 *   get:
 *     summary: Get pending job offers for pilot
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Pending offers list
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
 *     summary: Respond to job offer (accept/decline)
 *     tags: [Matching]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: offerId
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
 *               - accept
 *             properties:
 *               accept:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Response recorded
 */
router.post(
  '/offers/:offerId/respond',
  authenticate,
  authorize('pilot'),
  matchingController.respondToOffer
)

export default router
