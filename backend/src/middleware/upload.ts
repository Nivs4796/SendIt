import multer, { FileFilterCallback } from 'multer'
import path from 'path'
import fs from 'fs'
import { Request } from 'express'
import { ValidationError } from './errorHandler'

// Ensure upload directories exist
const uploadDirs = ['uploads/documents', 'uploads/avatars', 'uploads/delivery-photos']
uploadDirs.forEach((dir) => {
  const fullPath = path.join(process.cwd(), dir)
  if (!fs.existsSync(fullPath)) {
    fs.mkdirSync(fullPath, { recursive: true })
  }
})

// File type configurations
const ALLOWED_IMAGE_TYPES = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
const ALLOWED_DOCUMENT_TYPES = [...ALLOWED_IMAGE_TYPES, 'application/pdf']

// File size limits (in bytes)
const MAX_FILE_SIZE = {
  avatar: 5 * 1024 * 1024, // 5MB
  document: 10 * 1024 * 1024, // 10MB
  deliveryPhoto: 5 * 1024 * 1024, // 5MB
}

// Generate unique filename
const generateFilename = (file: Express.Multer.File): string => {
  const uniqueSuffix = `${Date.now()}-${Math.round(Math.random() * 1e9)}`
  const ext = path.extname(file.originalname).toLowerCase()
  return `${uniqueSuffix}${ext}`
}

// Storage configuration for documents
const documentStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(process.cwd(), 'uploads/documents'))
  },
  filename: (req, file, cb) => {
    cb(null, generateFilename(file))
  },
})

// Storage configuration for avatars
const avatarStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(process.cwd(), 'uploads/avatars'))
  },
  filename: (req, file, cb) => {
    cb(null, generateFilename(file))
  },
})

// Storage configuration for delivery photos
const deliveryPhotoStorage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(process.cwd(), 'uploads/delivery-photos'))
  },
  filename: (req, file, cb) => {
    cb(null, generateFilename(file))
  },
})

// File filter for images
const imageFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: FileFilterCallback
): void => {
  if (ALLOWED_IMAGE_TYPES.includes(file.mimetype)) {
    cb(null, true)
  } else {
    cb(new ValidationError('Only JPEG, PNG, and WebP images are allowed'))
  }
}

// File filter for documents (images + PDF)
const documentFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: FileFilterCallback
): void => {
  if (ALLOWED_DOCUMENT_TYPES.includes(file.mimetype)) {
    cb(null, true)
  } else {
    cb(new ValidationError('Only JPEG, PNG, WebP images and PDF files are allowed'))
  }
}

// Multer instances
export const uploadDocument = multer({
  storage: documentStorage,
  fileFilter: documentFilter,
  limits: {
    fileSize: MAX_FILE_SIZE.document,
  },
})

export const uploadAvatar = multer({
  storage: avatarStorage,
  fileFilter: imageFilter,
  limits: {
    fileSize: MAX_FILE_SIZE.avatar,
  },
})

export const uploadDeliveryPhoto = multer({
  storage: deliveryPhotoStorage,
  fileFilter: imageFilter,
  limits: {
    fileSize: MAX_FILE_SIZE.deliveryPhoto,
  },
})

// Field configurations for pilot documents
export const pilotDocumentFields = uploadDocument.fields([
  { name: 'idProof', maxCount: 1 },
  { name: 'drivingLicense', maxCount: 1 },
  { name: 'vehicleRC', maxCount: 1 },
  { name: 'insurance', maxCount: 1 },
  { name: 'pollutionCertificate', maxCount: 1 },
  { name: 'parentalConsent', maxCount: 1 },
  { name: 'bankProof', maxCount: 1 },
])

// Helper to get file URL
export const getFileUrl = (filename: string, folder: string): string => {
  return `/uploads/${folder}/${filename}`
}

// Helper to delete file
export const deleteFile = (filePath: string): void => {
  const fullPath = path.join(process.cwd(), filePath)
  if (fs.existsSync(fullPath)) {
    fs.unlinkSync(fullPath)
  }
}

export default {
  uploadDocument,
  uploadAvatar,
  uploadDeliveryPhoto,
  pilotDocumentFields,
  getFileUrl,
  deleteFile,
}
