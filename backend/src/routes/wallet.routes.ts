import { Router } from 'express'
import * as walletController from '../controllers/wallet.controller'
import { authenticate, authorize } from '../middleware/auth'
import { validate } from '../validators'
import { addMoneySchema, checkBalanceSchema, addBonusSchema, refundSchema } from '../validators/wallet.validator'

const router = Router()

// ============================================
// USER ROUTES
// ============================================

/**
 * @swagger
 * /wallet/balance:
 *   get:
 *     summary: Get wallet balance
 *     tags: [Wallet]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Wallet balance
 */
router.get(
  '/balance',
  authenticate,
  authorize('user'),
  walletController.getBalance
)

/**
 * @swagger
 * /wallet/add:
 *   post:
 *     summary: Add money to wallet
 *     tags: [Wallet]
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
 *                 minimum: 1
 *                 maximum: 100000
 *     responses:
 *       200:
 *         description: Money added
 */
router.post(
  '/add',
  authenticate,
  authorize('user'),
  validate(addMoneySchema),
  walletController.addMoney
)

/**
 * @swagger
 * /wallet/transactions:
 *   get:
 *     summary: Get transaction history
 *     tags: [Wallet]
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
 *         name: type
 *         schema:
 *           type: string
 *           enum: [CREDIT, DEBIT]
 *     responses:
 *       200:
 *         description: Transaction history
 */
router.get(
  '/transactions',
  authenticate,
  authorize('user'),
  walletController.getTransactions
)

/**
 * @swagger
 * /wallet/check:
 *   post:
 *     summary: Check if wallet has sufficient balance
 *     tags: [Wallet]
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
 *     responses:
 *       200:
 *         description: Balance check result
 */
router.post(
  '/check',
  authenticate,
  authorize('user'),
  validate(checkBalanceSchema),
  walletController.checkBalance
)

// ============================================
// ADMIN ROUTES
// ============================================

/**
 * @swagger
 * /wallet/admin/bonus:
 *   post:
 *     summary: Add bonus to user wallet (Admin)
 *     tags: [Wallet]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - amount
 *               - reason
 *             properties:
 *               userId:
 *                 type: string
 *               amount:
 *                 type: number
 *               reason:
 *                 type: string
 *     responses:
 *       200:
 *         description: Bonus added
 */
router.post(
  '/admin/bonus',
  authenticate,
  authorize('admin'),
  validate(addBonusSchema),
  walletController.addBonus
)

/**
 * @swagger
 * /wallet/admin/refund:
 *   post:
 *     summary: Refund to user wallet (Admin)
 *     tags: [Wallet]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - amount
 *             properties:
 *               userId:
 *                 type: string
 *               amount:
 *                 type: number
 *               bookingId:
 *                 type: string
 *               reason:
 *                 type: string
 *     responses:
 *       200:
 *         description: Refund processed
 */
router.post(
  '/admin/refund',
  authenticate,
  authorize('admin'),
  validate(refundSchema),
  walletController.refundToWallet
)

/**
 * @swagger
 * /wallet/admin/user/{userId}:
 *   get:
 *     summary: Get user wallet details (Admin)
 *     tags: [Wallet]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: userId
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
 *         description: User wallet details
 */
router.get(
  '/admin/user/:userId',
  authenticate,
  authorize('admin'),
  walletController.getUserWallet
)

export default router
