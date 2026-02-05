import { Router } from 'express'
import * as paymentController from '../controllers/payment.controller'
import { authenticate, authorize } from '../middleware/auth'
import { validate } from '../validators'
import { createOrderSchema, verifyPaymentSchema } from '../validators/payment.validator'
import { paymentVerifyLimiter, paymentCreateLimiter } from '../middleware/rateLimiter'

const router = Router()

/**
 * @swagger
 * /payments/create-order:
 *   post:
 *     summary: Create Razorpay order for booking payment
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - bookingId
 *               - amount
 *             properties:
 *               bookingId:
 *                 type: string
 *               amount:
 *                 type: number
 *                 description: Amount in INR (will be converted to paise)
 *     responses:
 *       200:
 *         description: Razorpay order created
 */
router.post(
  '/create-order',
  authenticate,
  authorize('user'),
  paymentCreateLimiter,
  validate(createOrderSchema),
  paymentController.createOrder
)

/**
 * @swagger
 * /payments/verify:
 *   post:
 *     summary: Verify Razorpay payment signature
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - orderId
 *               - paymentId
 *               - signature
 *             properties:
 *               orderId:
 *                 type: string
 *               paymentId:
 *                 type: string
 *               signature:
 *                 type: string
 *               bookingId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Payment verified
 */
router.post(
  '/verify',
  authenticate,
  authorize('user'),
  paymentVerifyLimiter,
  validate(verifyPaymentSchema),
  paymentController.verifyPayment
)

/**
 * @swagger
 * /payments/wallet/add:
 *   post:
 *     summary: Create order for adding money to wallet
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - amount
 *             properties:
 *               amount:
 *                 type: number
 *                 minimum: 10
 *                 maximum: 10000
 *     responses:
 *       200:
 *         description: Razorpay order for wallet topup
 */
router.post(
  '/wallet/add',
  authenticate,
  authorize('user'),
  paymentCreateLimiter,
  paymentController.createWalletOrder
)

/**
 * @swagger
 * /payments/wallet/verify:
 *   post:
 *     summary: Verify wallet topup payment
 *     tags: [Payments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - orderId
 *               - paymentId
 *               - signature
 *               - amount
 *             properties:
 *               orderId:
 *                 type: string
 *               paymentId:
 *                 type: string
 *               signature:
 *                 type: string
 *               amount:
 *                 type: number
 *     responses:
 *       200:
 *         description: Wallet credited
 */
router.post(
  '/wallet/verify',
  authenticate,
  authorize('user'),
  paymentVerifyLimiter,
  paymentController.verifyWalletPayment
)

export default router
