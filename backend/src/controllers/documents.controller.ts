import { Request, Response, NextFunction } from 'express'
import * as documentsService from '../services/documents.service'
import { formatResponse } from '../utils/helpers'
import { getFileUrl } from '../middleware/upload'
import { DocumentType } from '@prisma/client'

// Helper to extract string param
const getParamAsString = (param: string | string[] | undefined): string => {
  if (Array.isArray(param)) return param[0]
  return param || ''
}

/**
 * Get pilot's documents
 */
export const getDocuments = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { page = '1', limit = '20' } = req.query

    const result = await documentsService.getPilotDocuments(
      pilotId,
      parseInt(page as string),
      parseInt(limit as string)
    )

    res.json(formatResponse(true, 'Documents retrieved', result.documents, result.meta))
  } catch (error) {
    next(error)
  }
}

/**
 * Get document summary/status
 */
export const getDocumentSummary = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const summary = await documentsService.getDocumentSummary(pilotId)

    res.json(formatResponse(true, 'Document summary retrieved', summary))
  } catch (error) {
    next(error)
  }
}

/**
 * Upload a document
 */
export const uploadDocument = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { type } = req.body
    const file = req.file

    if (!file) {
      res.status(400).json(formatResponse(false, 'No file uploaded'))
      return
    }

    if (!type || !Object.values(DocumentType).includes(type)) {
      res.status(400).json(formatResponse(false, 'Invalid document type'))
      return
    }

    const url = getFileUrl(file.filename, 'documents')

    const document = await documentsService.createDocument({
      pilotId,
      type: type as DocumentType,
      url,
      filename: file.originalname,
    })

    res.status(201).json(formatResponse(true, 'Document uploaded successfully', document))
  } catch (error) {
    next(error)
  }
}

/**
 * Update/re-upload a document
 */
export const updateDocument = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const id = getParamAsString(req.params.id)
    const file = req.file

    let updateData: { url?: string; filename?: string } = {}

    if (file) {
      updateData = {
        url: getFileUrl(file.filename, 'documents'),
        filename: file.originalname,
      }
    }

    const document = await documentsService.updateDocument(id, pilotId, updateData)

    res.json(formatResponse(true, 'Document updated successfully', document))
  } catch (error) {
    next(error)
  }
}

/**
 * Delete a document
 */
export const deleteDocument = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const id = getParamAsString(req.params.id)

    await documentsService.deleteDocument(id, pilotId)

    res.json(formatResponse(true, 'Document deleted successfully'))
  } catch (error) {
    next(error)
  }
}
