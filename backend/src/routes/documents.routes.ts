import { Router } from 'express'
import * as documentsController from '../controllers/documents.controller'
import { authenticate, authorizePilot } from '../middleware/auth'
import { uploadDocument } from '../middleware/upload'
import { validate } from '../validators'
import { uploadDocumentSchema, documentIdParamSchema } from '../validators/documents.validator'

const router = Router()

/**
 * @swagger
 * /pilots/documents:
 *   get:
 *     summary: Get pilot's documents
 *     tags: [Documents]
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
 *         description: Documents list
 */
router.get(
  '/',
  authenticate,
  authorizePilot,
  documentsController.getDocuments
)

/**
 * @swagger
 * /pilots/documents/summary:
 *   get:
 *     summary: Get document verification summary
 *     tags: [Documents]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Document summary
 */
router.get(
  '/summary',
  authenticate,
  authorizePilot,
  documentsController.getDocumentSummary
)

/**
 * @swagger
 * /pilots/documents:
 *   post:
 *     summary: Upload a document
 *     tags: [Documents]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - type
 *               - file
 *             properties:
 *               type:
 *                 type: string
 *                 enum: [AADHAAR_FRONT, AADHAAR_BACK, LICENSE_FRONT, LICENSE_BACK, PAN_CARD, VEHICLE_RC, VEHICLE_INSURANCE, PROFILE_PHOTO, VEHICLE_PHOTO, ID_PROOF, DRIVING_LICENSE, INSURANCE, POLLUTION_CERTIFICATE, PARENTAL_CONSENT, BANK_PROOF]
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       201:
 *         description: Document uploaded
 *       400:
 *         description: Invalid file or type
 */
router.post(
  '/',
  authenticate,
  authorizePilot,
  uploadDocument.single('file'),
  validate(uploadDocumentSchema),
  documentsController.uploadDocument
)

/**
 * @swagger
 * /pilots/documents/{id}:
 *   put:
 *     summary: Update/re-upload a document
 *     tags: [Documents]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Document updated
 */
router.put(
  '/:id',
  authenticate,
  authorizePilot,
  uploadDocument.single('file'),
  validate(documentIdParamSchema),
  documentsController.updateDocument
)

/**
 * @swagger
 * /pilots/documents/{id}:
 *   delete:
 *     summary: Delete a document
 *     tags: [Documents]
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
 *         description: Document deleted
 */
router.delete(
  '/:id',
  authenticate,
  authorizePilot,
  validate(documentIdParamSchema),
  documentsController.deleteDocument
)

export default router
