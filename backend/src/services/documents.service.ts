import prisma from '../config/database'
import { AppError, NotFoundError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { DocumentType, DocumentStatus } from '@prisma/client'
import { deleteFile } from '../middleware/upload'
import logger from '../config/logger'

interface CreateDocumentInput {
  pilotId: string
  type: DocumentType
  url: string
  filename?: string
}

interface UpdateDocumentInput {
  url?: string
  filename?: string
  status?: DocumentStatus
  rejectedReason?: string
}

/**
 * Get all documents for a pilot
 */
export const getPilotDocuments = async (
  pilotId: string,
  page: number = 1,
  limit: number = 20
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const [documents, total] = await Promise.all([
    prisma.document.findMany({
      where: { pilotId },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.document.count({ where: { pilotId } }),
  ])

  return {
    documents,
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

/**
 * Get a specific document by ID
 */
export const getDocumentById = async (documentId: string, pilotId: string) => {
  const document = await prisma.document.findFirst({
    where: { id: documentId, pilotId },
  })

  if (!document) {
    throw new NotFoundError('Document')
  }

  return document
}

/**
 * Create/upload a new document
 */
export const createDocument = async (input: CreateDocumentInput) => {
  const { pilotId, type, url, filename } = input

  // Check if document of this type already exists
  const existingDoc = await prisma.document.findFirst({
    where: { pilotId, type },
  })

  if (existingDoc) {
    // Update existing document (re-upload)
    const updatedDoc = await prisma.document.update({
      where: { id: existingDoc.id },
      data: {
        url,
        filename,
        status: 'PENDING',
        isVerified: false,
        rejectedReason: null,
        verifiedAt: null,
      },
    })

    // Delete old file
    if (existingDoc.url) {
      try {
        deleteFile(existingDoc.url)
      } catch (err) {
        logger.warn(`Failed to delete old document: ${existingDoc.url}`)
      }
    }

    logger.info(`Document re-uploaded: Pilot ${pilotId}, Type: ${type}`)
    return updatedDoc
  }

  // Create new document
  const document = await prisma.document.create({
    data: {
      pilotId,
      type,
      url,
      filename,
      status: 'PENDING',
    },
  })

  logger.info(`Document uploaded: Pilot ${pilotId}, Type: ${type}`)
  return document
}

/**
 * Update a document
 */
export const updateDocument = async (
  documentId: string,
  pilotId: string,
  input: UpdateDocumentInput
) => {
  const document = await getDocumentById(documentId, pilotId)

  const updatedDocument = await prisma.document.update({
    where: { id: documentId },
    data: {
      ...input,
      // Reset verification if URL changed
      ...(input.url && {
        status: 'PENDING',
        isVerified: false,
        rejectedReason: null,
        verifiedAt: null,
      }),
    },
  })

  // Delete old file if URL changed
  if (input.url && document.url && document.url !== input.url) {
    try {
      deleteFile(document.url)
    } catch (err) {
      logger.warn(`Failed to delete old document: ${document.url}`)
    }
  }

  return updatedDocument
}

/**
 * Delete a document
 */
export const deleteDocument = async (documentId: string, pilotId: string) => {
  const document = await getDocumentById(documentId, pilotId)

  // Delete file from storage
  if (document.url) {
    try {
      deleteFile(document.url)
    } catch (err) {
      logger.warn(`Failed to delete document file: ${document.url}`)
    }
  }

  await prisma.document.delete({
    where: { id: documentId },
  })

  logger.info(`Document deleted: Pilot ${pilotId}, ID: ${documentId}`)
  return { success: true }
}

/**
 * Get document verification status summary for a pilot
 */
export const getDocumentSummary = async (pilotId: string) => {
  const documents = await prisma.document.findMany({
    where: { pilotId },
    select: {
      type: true,
      status: true,
      isVerified: true,
    },
  })

  const requiredDocs: DocumentType[] = [
    'AADHAAR_FRONT',
    'AADHAAR_BACK',
    'PROFILE_PHOTO',
  ]

  const summary = {
    total: documents.length,
    pending: documents.filter((d) => d.status === 'PENDING').length,
    approved: documents.filter((d) => d.status === 'APPROVED').length,
    rejected: documents.filter((d) => d.status === 'REJECTED').length,
    verified: documents.filter((d) => d.isVerified).length,
    documents: documents.reduce(
      (acc, doc) => {
        acc[doc.type] = {
          status: doc.status,
          isVerified: doc.isVerified,
        }
        return acc
      },
      {} as Record<string, { status: string; isVerified: boolean }>
    ),
    missingRequired: requiredDocs.filter(
      (type) => !documents.some((d) => d.type === type)
    ),
  }

  return summary
}
