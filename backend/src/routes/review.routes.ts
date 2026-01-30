import { Router } from 'express'
import * as reviewController from '../controllers/review.controller'
import { authenticate, authorizeUser } from '../middleware/auth'
import { validate, createReviewSchema, pilotReviewsParamSchema } from '../validators'

const router = Router()

/**
 * @swagger
 * /reviews/booking/{bookingId}:
 *   post:
 *     summary: Submit a review for a booking
 *     tags: [Reviews]
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
 *               - rating
 *             properties:
 *               rating:
 *                 type: number
 *                 minimum: 1
 *                 maximum: 5
 *               comment:
 *                 type: string
 *     responses:
 *       201:
 *         description: Review submitted
 *       400:
 *         description: Cannot review this booking
 */
router.post('/booking/:bookingId', authenticate, authorizeUser, validate(createReviewSchema), reviewController.createReview)

/**
 * @swagger
 * /reviews/pilot/{pilotId}:
 *   get:
 *     summary: Get pilot reviews
 *     tags: [Reviews]
 *     parameters:
 *       - in: path
 *         name: pilotId
 *         required: true
 *         schema:
 *           type: string
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
 *         description: Reviews list
 */
router.get('/pilot/:pilotId', reviewController.getPilotReviews)

export default router
