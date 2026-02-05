import { Router } from 'express'
import * as supportController from '../controllers/support.controller'
import { authenticate, authorize } from '../middleware/auth'
import { validate } from '../validators'
import { createTicketSchema, ticketIdParamSchema } from '../validators/support.validator'

const router = Router()

/**
 * @swagger
 * /support/faqs:
 *   get:
 *     summary: Get FAQs
 *     tags: [Support]
 *     parameters:
 *       - in: query
 *         name: category
 *         schema:
 *           type: string
 *           enum: [GENERAL, PAYMENTS, DELIVERIES, ACCOUNT, EARNINGS, DOCUMENTS, TECHNICAL]
 *         description: Filter by category
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search in questions and answers
 *     responses:
 *       200:
 *         description: FAQs list
 */
router.get('/faqs', supportController.getFAQs)

/**
 * @swagger
 * /support/contact:
 *   get:
 *     summary: Get contact information
 *     tags: [Support]
 *     responses:
 *       200:
 *         description: Contact information
 */
router.get('/contact', supportController.getContactInfo)

/**
 * @swagger
 * /support/tickets:
 *   post:
 *     summary: Create a support ticket
 *     tags: [Support]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - subject
 *               - description
 *             properties:
 *               subject:
 *                 type: string
 *                 minLength: 5
 *                 maxLength: 200
 *               description:
 *                 type: string
 *                 minLength: 10
 *                 maxLength: 2000
 *               category:
 *                 type: string
 *                 enum: [GENERAL, PAYMENTS, DELIVERIES, ACCOUNT, EARNINGS, DOCUMENTS, TECHNICAL]
 *               priority:
 *                 type: string
 *                 enum: [LOW, MEDIUM, HIGH, URGENT]
 *     responses:
 *       201:
 *         description: Ticket created
 */
router.post(
  '/tickets',
  authenticate,
  authorize('user', 'pilot'),
  validate(createTicketSchema),
  supportController.createTicket
)

/**
 * @swagger
 * /support/tickets:
 *   get:
 *     summary: Get my support tickets
 *     tags: [Support]
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
 *         description: Tickets list
 */
router.get(
  '/tickets',
  authenticate,
  authorize('user', 'pilot'),
  supportController.getMyTickets
)

/**
 * @swagger
 * /support/tickets/{id}:
 *   get:
 *     summary: Get a specific ticket
 *     tags: [Support]
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
 *         description: Ticket details
 */
router.get(
  '/tickets/:id',
  authenticate,
  authorize('user', 'pilot'),
  validate(ticketIdParamSchema),
  supportController.getTicketById
)

export default router
