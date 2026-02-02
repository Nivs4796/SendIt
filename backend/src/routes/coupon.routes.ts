import { Router } from 'express'
import * as couponController from '../controllers/coupon.controller'
import { authenticate, authorize } from '../middleware/auth'
import { validate } from '../validators'
import { createCouponSchema, updateCouponSchema, validateCouponSchema } from '../validators/coupon.validator'

const router = Router()

// ============================================
// ADMIN ROUTES
// ============================================

/**
 * @swagger
 * /coupons:
 *   post:
 *     summary: Create a new coupon
 *     tags: [Coupons]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - code
 *               - discountValue
 *             properties:
 *               code:
 *                 type: string
 *                 example: "WELCOME50"
 *               description:
 *                 type: string
 *               discountType:
 *                 type: string
 *                 enum: [PERCENTAGE, FIXED]
 *               discountValue:
 *                 type: number
 *               minOrderAmount:
 *                 type: number
 *               maxDiscount:
 *                 type: number
 *               usageLimit:
 *                 type: integer
 *               perUserLimit:
 *                 type: integer
 *               vehicleTypeIds:
 *                 type: array
 *                 items:
 *                   type: string
 *               expiresAt:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       201:
 *         description: Coupon created
 */
router.post(
  '/',
  authenticate,
  authorize('admin'),
  validate(createCouponSchema),
  couponController.createCoupon
)

/**
 * @swagger
 * /coupons:
 *   get:
 *     summary: List all coupons (Admin)
 *     tags: [Coupons]
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
 *         name: active
 *         schema:
 *           type: boolean
 *     responses:
 *       200:
 *         description: List of coupons
 */
router.get(
  '/',
  authenticate,
  authorize('admin'),
  couponController.listCoupons
)

/**
 * @swagger
 * /coupons/{id}:
 *   get:
 *     summary: Get coupon by ID
 *     tags: [Coupons]
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
 *         description: Coupon details
 */
router.get(
  '/:id',
  authenticate,
  authorize('admin'),
  couponController.getCoupon
)

/**
 * @swagger
 * /coupons/{id}:
 *   put:
 *     summary: Update a coupon
 *     tags: [Coupons]
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
 *     responses:
 *       200:
 *         description: Coupon updated
 */
router.put(
  '/:id',
  authenticate,
  authorize('admin'),
  validate(updateCouponSchema),
  couponController.updateCoupon
)

/**
 * @swagger
 * /coupons/{id}:
 *   delete:
 *     summary: Delete a coupon
 *     tags: [Coupons]
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
 *         description: Coupon deleted
 */
router.delete(
  '/:id',
  authenticate,
  authorize('admin'),
  couponController.deleteCoupon
)

/**
 * @swagger
 * /coupons/stats:
 *   get:
 *     summary: Get coupon statistics
 *     tags: [Coupons]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Coupon statistics
 */
router.get(
  '/stats',
  authenticate,
  authorize('admin'),
  couponController.getCouponStats
)

// ============================================
// USER ROUTES
// ============================================

/**
 * @swagger
 * /coupons/validate:
 *   post:
 *     summary: Validate a coupon code
 *     tags: [Coupons]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - code
 *               - orderAmount
 *               - vehicleTypeId
 *             properties:
 *               code:
 *                 type: string
 *               orderAmount:
 *                 type: number
 *               vehicleTypeId:
 *                 type: string
 *     responses:
 *       200:
 *         description: Coupon validation result
 */
router.post(
  '/validate',
  authenticate,
  authorize('user'),
  validate(validateCouponSchema),
  couponController.validateCoupon
)

/**
 * @swagger
 * /coupons/available:
 *   get:
 *     summary: Get available coupons for user
 *     tags: [Coupons]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: orderAmount
 *         schema:
 *           type: number
 *       - in: query
 *         name: vehicleTypeId
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Available coupons
 */
router.get(
  '/available',
  authenticate,
  authorize('user'),
  couponController.getAvailableCoupons
)

/**
 * @swagger
 * /coupons/history:
 *   get:
 *     summary: Get user's coupon usage history
 *     tags: [Coupons]
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
 *         description: Coupon usage history
 */
router.get(
  '/history',
  authenticate,
  authorize('user'),
  couponController.getCouponHistory
)

export default router
