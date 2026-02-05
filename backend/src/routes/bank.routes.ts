import { Router } from 'express'
import * as bankController from '../controllers/bank.controller'
import { authenticate, authorizePilot } from '../middleware/auth'
import { validate } from '../validators'
import { addBankAccountSchema, bankAccountIdParamSchema, ifscLookupSchema, validateBankSchema } from '../validators/bank.validator'

const router = Router()

// ============================================
// PILOT BANK ACCOUNT ROUTES
// ============================================

/**
 * @swagger
 * /pilots/bank-accounts:
 *   get:
 *     summary: Get pilot's bank accounts
 *     tags: [Bank]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Bank accounts list
 */
router.get(
  '/',
  authenticate,
  authorizePilot,
  bankController.getBankAccounts
)

/**
 * @swagger
 * /pilots/bank-accounts:
 *   post:
 *     summary: Add a new bank account
 *     tags: [Bank]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - accountName
 *               - accountNumber
 *               - ifscCode
 *               - bankName
 *             properties:
 *               accountName:
 *                 type: string
 *                 description: Name on the bank account
 *               accountNumber:
 *                 type: string
 *                 description: Bank account number
 *               ifscCode:
 *                 type: string
 *                 description: IFSC code
 *               bankName:
 *                 type: string
 *                 description: Bank name
 *               branchName:
 *                 type: string
 *                 description: Branch name (optional)
 *     responses:
 *       201:
 *         description: Bank account added
 *       400:
 *         description: Invalid data or duplicate account
 */
router.post(
  '/',
  authenticate,
  authorizePilot,
  validate(addBankAccountSchema),
  bankController.addBankAccount
)

/**
 * @swagger
 * /pilots/bank-accounts/{id}:
 *   delete:
 *     summary: Delete a bank account
 *     tags: [Bank]
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
 *         description: Bank account deleted
 *       400:
 *         description: Cannot delete (has pending withdrawals)
 */
router.delete(
  '/:id',
  authenticate,
  authorizePilot,
  validate(bankAccountIdParamSchema),
  bankController.deleteBankAccount
)

/**
 * @swagger
 * /pilots/bank-accounts/{id}/primary:
 *   patch:
 *     summary: Set bank account as primary
 *     tags: [Bank]
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
 *         description: Primary account updated
 */
router.patch(
  '/:id/primary',
  authenticate,
  authorizePilot,
  validate(bankAccountIdParamSchema),
  bankController.setPrimaryAccount
)

// ============================================
// UTILITY ROUTES (No auth required for IFSC lookup)
// ============================================

/**
 * @swagger
 * /utils/ifsc:
 *   get:
 *     summary: Lookup IFSC code details
 *     tags: [Utils]
 *     parameters:
 *       - in: query
 *         name: ifsc
 *         required: true
 *         schema:
 *           type: string
 *         description: IFSC code to lookup
 *     responses:
 *       200:
 *         description: Bank details for IFSC
 *       404:
 *         description: IFSC code not found
 */
router.get(
  '/ifsc-lookup',
  validate(ifscLookupSchema),
  bankController.lookupIFSC
)

/**
 * @swagger
 * /utils/validate-bank:
 *   post:
 *     summary: Validate bank account details
 *     tags: [Utils]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - accountNumber
 *               - ifscCode
 *             properties:
 *               accountNumber:
 *                 type: string
 *               ifscCode:
 *                 type: string
 *     responses:
 *       200:
 *         description: Validation result
 */
router.post(
  '/validate',
  validate(validateBankSchema),
  bankController.validateBankDetails
)

export default router
