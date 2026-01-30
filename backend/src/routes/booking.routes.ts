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

/**
 * @swagger
 * /bookings/calculate-price:
 *   post:
 *     summary: Calculate delivery price
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - vehicleTypeId
 *               - pickupAddressId
 *               - dropAddressId
 *             properties:
 *               vehicleTypeId:
 *                 type: string
 *               pickupAddressId:
 *                 type: string
 *               dropAddressId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Price calculated
 *       400:
 *         description: Validation error
 */
router.post('/calculate-price', authenticate, authorizeUser, validate(calculatePriceSchema), bookingController.calculatePrice)

/**
 * @swagger
 * /bookings:
 *   post:
 *     summary: Create a new booking
 *     tags: [Bookings]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - vehicleTypeId
 *               - pickupAddressId
 *               - dropAddressId
 *             properties:
 *               vehicleTypeId:
 *                 type: string
 *               pickupAddressId:
 *                 type: string
 *               dropAddressId:
 *                 type: string
 *               packageType:
 *                 type: string
 *                 enum: [DOCUMENT, PARCEL, FOOD, GROCERY, MEDICINE, FRAGILE, OTHER]
 *               packageWeight:
 *                 type: number
 *               packageDescription:
 *                 type: string
 *               scheduledAt:
 *                 type: string
 *                 format: date-time
 *               paymentMethod:
 *                 type: string
 *                 enum: [CASH, UPI, CARD, WALLET, NETBANKING]
 *     responses:
 *       201:
 *         description: Booking created
 *       400:
 *         description: Validation error
 *       429:
 *         description: Too many bookings
 */
router.post('/', authenticate, authorizeUser, bookingLimiter, validate(createBookingSchema), bookingController.createBooking)

/**
 * @swagger
 * /bookings/my-bookings:
 *   get:
 *     summary: Get user's bookings
 *     tags: [Bookings]
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
 *           enum: [PENDING, ACCEPTED, ARRIVED_PICKUP, PICKED_UP, IN_TRANSIT, ARRIVED_DROP, DELIVERED, CANCELLED]
 *     responses:
 *       200:
 *         description: Bookings list
 */
router.get('/my-bookings', authenticate, authorizeUser, validate(listBookingsSchema), bookingController.getUserBookings)

/**
 * @swagger
 * /bookings/{id}:
 *   get:
 *     summary: Get booking details
 *     tags: [Bookings]
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
 *         description: Booking details
 *       404:
 *         description: Booking not found
 */
router.get('/:id', authenticate, validate(bookingIdParamSchema), bookingController.getBooking)

/**
 * @swagger
 * /bookings/{id}/cancel:
 *   post:
 *     summary: Cancel a booking
 *     tags: [Bookings]
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
 *               - reason
 *             properties:
 *               reason:
 *                 type: string
 *     responses:
 *       200:
 *         description: Booking cancelled
 *       400:
 *         description: Cannot cancel booking
 */
router.post('/:id/cancel', authenticate, authorizeUser, validate(cancelBookingSchema), bookingController.cancelBooking)

/**
 * @swagger
 * /bookings/{id}/accept:
 *   post:
 *     summary: Pilot accepts a booking
 *     tags: [Bookings]
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
 *         description: Booking accepted
 *       400:
 *         description: Cannot accept booking
 */
router.post('/:id/accept', authenticate, authorizePilot, validate(bookingIdParamSchema), bookingController.acceptBooking)

/**
 * @swagger
 * /bookings/{id}/status:
 *   patch:
 *     summary: Update booking status (Pilot only)
 *     tags: [Bookings]
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
 *                 enum: [PENDING, ACCEPTED, ARRIVED_PICKUP, PICKED_UP, IN_TRANSIT, ARRIVED_DROP, DELIVERED, CANCELLED]
 *               lat:
 *                 type: number
 *               lng:
 *                 type: number
 *               note:
 *                 type: string
 *     responses:
 *       200:
 *         description: Status updated
 */
router.patch('/:id/status', authenticate, authorizePilot, validate(updateBookingStatusSchema), bookingController.updateBookingStatus)

export default router
