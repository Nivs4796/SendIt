import { z } from 'zod'

const DocumentTypeEnum = z.enum([
  'AADHAAR_FRONT',
  'AADHAAR_BACK',
  'LICENSE_FRONT',
  'LICENSE_BACK',
  'PAN_CARD',
  'VEHICLE_RC',
  'VEHICLE_INSURANCE',
  'PROFILE_PHOTO',
  'VEHICLE_PHOTO',
  'ID_PROOF',
  'DRIVING_LICENSE',
  'INSURANCE',
  'POLLUTION_CERTIFICATE',
  'PARENTAL_CONSENT',
  'BANK_PROOF',
])

export const uploadDocumentSchema = z.object({
  body: z.object({
    type: DocumentTypeEnum,
  }),
})

export const documentIdParamSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Document ID is required'),
  }),
})
