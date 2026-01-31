import { Router } from 'express'
import * as uploadController from '../controllers/upload.controller'
import { authenticate, authorizeUser, authorizePilot, authorizeAdmin } from '../middleware/auth'
import { uploadDocument, uploadAvatar, uploadDeliveryPhoto, pilotDocumentFields } from '../middleware/upload'

const router = Router()

/**
 * @swagger
 * /upload/document:
 *   post:
 *     summary: Upload a single document
 *     tags: [Upload]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
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
 *         description: File uploaded successfully
 *       400:
 *         description: Invalid file or no file uploaded
 */
router.post(
  '/document',
  authenticate,
  uploadDocument.single('file'),
  uploadController.uploadSingleFile
)

/**
 * @swagger
 * /upload/pilot/documents:
 *   post:
 *     summary: Upload pilot verification documents
 *     tags: [Upload]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               idProof:
 *                 type: string
 *                 format: binary
 *                 description: Aadhaar/PAN/Passport
 *               drivingLicense:
 *                 type: string
 *                 format: binary
 *                 description: Driving License (for motorized vehicles)
 *               vehicleRC:
 *                 type: string
 *                 format: binary
 *                 description: Vehicle Registration Certificate
 *               insurance:
 *                 type: string
 *                 format: binary
 *                 description: Vehicle Insurance
 *               pollutionCertificate:
 *                 type: string
 *                 format: binary
 *                 description: Pollution Under Control Certificate
 *               parentalConsent:
 *                 type: string
 *                 format: binary
 *                 description: Parental Consent (for 16-18 age pilots)
 *               bankProof:
 *                 type: string
 *                 format: binary
 *                 description: Cancelled Cheque/Passbook
 *     responses:
 *       200:
 *         description: Documents uploaded successfully
 *       400:
 *         description: Invalid files or no files uploaded
 *       403:
 *         description: Access denied
 */
router.post(
  '/pilot/documents',
  authenticate,
  authorizePilot,
  pilotDocumentFields,
  uploadController.uploadPilotDocuments
)

/**
 * @swagger
 * /upload/pilot/avatar:
 *   post:
 *     summary: Upload pilot avatar/profile picture
 *     tags: [Upload]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               avatar:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Avatar uploaded successfully
 *       400:
 *         description: Invalid file or no file uploaded
 */
router.post(
  '/pilot/avatar',
  authenticate,
  authorizePilot,
  uploadAvatar.single('avatar'),
  uploadController.uploadPilotAvatar
)

/**
 * @swagger
 * /upload/user/avatar:
 *   post:
 *     summary: Upload user avatar/profile picture
 *     tags: [Upload]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               avatar:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Avatar uploaded successfully
 *       400:
 *         description: Invalid file or no file uploaded
 */
router.post(
  '/user/avatar',
  authenticate,
  authorizeUser,
  uploadAvatar.single('avatar'),
  uploadController.uploadUserAvatar
)

/**
 * @swagger
 * /upload/delivery-photo/{bookingId}:
 *   post:
 *     summary: Upload delivery completion photo
 *     tags: [Upload]
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
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               photo:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Photo uploaded successfully
 *       400:
 *         description: Invalid file or no file uploaded
 *       404:
 *         description: Booking not found
 */
router.post(
  '/delivery-photo/:bookingId',
  authenticate,
  authorizePilot,
  uploadDeliveryPhoto.single('photo'),
  uploadController.uploadDeliveryPhoto
)

/**
 * @swagger
 * /upload/{folder}/{filename}:
 *   delete:
 *     summary: Delete an uploaded file (Admin only)
 *     tags: [Upload]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: folder
 *         required: true
 *         schema:
 *           type: string
 *           enum: [documents, avatars, delivery-photos]
 *       - in: path
 *         name: filename
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: File deleted successfully
 *       403:
 *         description: Access denied
 */
router.delete(
  '/:folder/:filename',
  authenticate,
  authorizeAdmin,
  uploadController.deleteUploadedFile
)

export default router
