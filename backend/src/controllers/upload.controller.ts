import { Request, Response, NextFunction } from 'express'
import path from 'path'
import { ValidationError, ForbiddenError, NotFoundError, ErrorCodes } from '../middleware/errorHandler'
import { getFileUrl, deleteFile } from '../middleware/upload'
import { prisma } from '../config/database'
import logger from '../config/logger'
import { DocumentType } from '@prisma/client'

// ============================================
// PATH VALIDATION HELPERS (Security)
// ============================================
const ALLOWED_UPLOAD_FOLDERS = ['documents', 'avatars', 'delivery-photos', 'vehicles', 'pilots', 'users']

const isValidFilename = (filename: string): boolean => {
  // Only allow alphanumeric, dash, underscore, and dot
  // Filename must be at least 10 chars (includes extension)
  return /^[a-zA-Z0-9._-]{10,}$/.test(filename)
}

const isValidFolder = (folder: string): boolean => {
  return ALLOWED_UPLOAD_FOLDERS.includes(folder)
}

interface AuthenticatedRequest extends Request {
  user?: {
    id: string
    type: 'user' | 'pilot' | 'admin'
  }
}

interface MulterFiles {
  [fieldname: string]: Express.Multer.File[]
}

/**
 * Upload single file (document)
 */
export const uploadSingleFile = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (!req.file) {
      throw new ValidationError('No file uploaded')
    }

    const folder = (req.params.folder as string) || 'documents'
    const fileUrl = getFileUrl(req.file.filename, folder)

    logger.info(`File uploaded: ${fileUrl} by ${req.user?.type}:${req.user?.id}`)

    res.status(200).json({
      success: true,
      data: {
        filename: req.file.filename,
        originalName: req.file.originalname,
        mimetype: req.file.mimetype,
        size: req.file.size,
        url: fileUrl,
      },
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Upload multiple pilot documents
 */
export const uploadPilotDocuments = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const pilotId = req.user?.id
    if (!pilotId || req.user?.type !== 'pilot') {
      throw new ForbiddenError('Access denied')
    }

    const files = req.files as MulterFiles
    if (!files || Object.keys(files).length === 0) {
      throw new ValidationError('No files uploaded')
    }

    const uploadedDocs: Record<string, string> = {}
    const documentRecords: Array<{
      pilotId: string
      type: DocumentType
      url: string
      filename: string
    }> = []

    // Map field names to document types
    const typeMap: Record<string, DocumentType> = {
      idProof: 'ID_PROOF',
      drivingLicense: 'DRIVING_LICENSE',
      vehicleRC: 'VEHICLE_RC',
      insurance: 'INSURANCE',
      pollutionCertificate: 'POLLUTION_CERTIFICATE',
      parentalConsent: 'PARENTAL_CONSENT',
      bankProof: 'BANK_PROOF',
    }

    // Process each uploaded file
    for (const [fieldName, fileArray] of Object.entries(files)) {
      if (fileArray && fileArray.length > 0) {
        const file = fileArray[0]
        const fileUrl = getFileUrl(file.filename, 'documents')
        uploadedDocs[fieldName] = fileUrl

        const docType = typeMap[fieldName]
        if (docType) {
          documentRecords.push({
            pilotId,
            type: docType,
            url: fileUrl,
            filename: file.filename,
          })
        }
      }
    }

    // Save document records to database
    if (documentRecords.length > 0) {
      for (const doc of documentRecords) {
        // Upsert document - update if exists, create if not
        await prisma.document.upsert({
          where: {
            pilotId_type: {
              pilotId: doc.pilotId,
              type: doc.type,
            },
          },
          update: {
            url: doc.url,
            filename: doc.filename,
            status: 'PENDING',
            isVerified: false,
            updatedAt: new Date(),
          },
          create: {
            pilotId: doc.pilotId,
            type: doc.type,
            url: doc.url,
            filename: doc.filename,
            status: 'PENDING',
            isVerified: false,
          },
        })
      }
    }

    logger.info(`Pilot ${pilotId} uploaded ${documentRecords.length} documents`)

    res.status(200).json({
      success: true,
      data: {
        uploaded: uploadedDocs,
        count: documentRecords.length,
      },
      message: 'Documents uploaded successfully',
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Upload user avatar
 */
export const uploadUserAvatar = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user?.id
    if (!userId || req.user?.type !== 'user') {
      throw new ForbiddenError('Access denied')
    }

    if (!req.file) {
      throw new ValidationError('No file uploaded')
    }

    const fileUrl = getFileUrl(req.file.filename, 'avatars')

    // Get old avatar to delete
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { avatar: true },
    })

    // Update user avatar
    await prisma.user.update({
      where: { id: userId },
      data: { avatar: fileUrl },
    })

    // Delete old avatar if exists
    if (user?.avatar && user.avatar.startsWith('/uploads/')) {
      deleteFile(user.avatar)
    }

    logger.info(`User ${userId} updated avatar`)

    res.status(200).json({
      success: true,
      data: {
        avatar: fileUrl,
      },
      message: 'Avatar updated successfully',
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Upload pilot avatar
 */
export const uploadPilotAvatar = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const pilotId = req.user?.id
    if (!pilotId || req.user?.type !== 'pilot') {
      throw new ForbiddenError('Access denied')
    }

    if (!req.file) {
      throw new ValidationError('No file uploaded')
    }

    const fileUrl = getFileUrl(req.file.filename, 'avatars')

    // Get old avatar to delete
    const pilot = await prisma.pilot.findUnique({
      where: { id: pilotId },
      select: { avatar: true },
    })

    // Update pilot avatar
    await prisma.pilot.update({
      where: { id: pilotId },
      data: { avatar: fileUrl },
    })

    // Delete old avatar if exists
    if (pilot?.avatar && pilot.avatar.startsWith('/uploads/')) {
      deleteFile(pilot.avatar)
    }

    logger.info(`Pilot ${pilotId} updated avatar`)

    res.status(200).json({
      success: true,
      data: {
        avatar: fileUrl,
      },
      message: 'Avatar updated successfully',
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Upload delivery photo (for pilot completing delivery)
 */
export const uploadDeliveryPhoto = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const pilotId = req.user?.id
    if (!pilotId || req.user?.type !== 'pilot') {
      throw new ForbiddenError('Access denied')
    }

    const bookingId = req.params.bookingId as string
    if (!bookingId) {
      throw new ValidationError('Booking ID is required')
    }

    if (!req.file) {
      throw new ValidationError('No file uploaded')
    }

    // Verify booking belongs to this pilot
    const booking = await prisma.booking.findFirst({
      where: {
        id: bookingId,
        pilotId: pilotId,
      },
    })

    if (!booking) {
      throw new NotFoundError('Booking', ErrorCodes.BOOKING_NOT_FOUND)
    }

    const fileUrl = getFileUrl(req.file.filename, 'delivery-photos')

    // Update booking with delivery photo
    await prisma.booking.update({
      where: { id: bookingId },
      data: { deliveryPhoto: fileUrl },
    })

    logger.info(`Pilot ${pilotId} uploaded delivery photo for booking ${bookingId}`)

    res.status(200).json({
      success: true,
      data: {
        deliveryPhoto: fileUrl,
        bookingId,
      },
      message: 'Delivery photo uploaded successfully',
    })
  } catch (error) {
    next(error)
  }
}

/**
 * Delete a file (admin only)
 */
export const deleteUploadedFile = async (
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    if (req.user?.type !== 'admin') {
      throw new ForbiddenError('Access denied')
    }

    const folder = req.params.folder as string
    const filename = req.params.filename as string

    if (!folder || !filename) {
      throw new ValidationError('Folder and filename are required')
    }

    // ============================================
    // SECURITY: Path Traversal Prevention
    // ============================================

    // Validate folder is in allowed list
    if (!isValidFolder(folder)) {
      throw new ValidationError('Invalid upload folder')
    }

    // Validate filename format (prevent path traversal)
    if (!isValidFilename(filename)) {
      throw new ValidationError('Invalid filename format')
    }

    // Ensure no path traversal attempts
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
      throw new ValidationError('Invalid filename')
    }

    // Build and validate the full path
    const uploadsDir = path.join(process.cwd(), 'uploads')
    const filePath = path.join(uploadsDir, folder, filename)

    // Verify the resolved path is still within uploads directory
    const resolvedPath = path.resolve(filePath)
    if (!resolvedPath.startsWith(uploadsDir)) {
      throw new ValidationError('Invalid file path')
    }

    deleteFile(`/uploads/${folder}/${filename}`)

    logger.info(`Admin deleted file: /uploads/${folder}/${filename}`)

    res.status(200).json({
      success: true,
      message: 'File deleted successfully',
    })
  } catch (error) {
    next(error)
  }
}
