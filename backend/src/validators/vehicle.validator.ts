import { z } from 'zod'

export const createVehicleSchema = z.object({
  body: z.object({
    vehicleTypeId: z.string().cuid('Invalid vehicle type ID'),
    registrationNo: z.string().min(5, 'Registration number is required').optional(),
    model: z.string().min(2).optional(),
    color: z.string().min(2).optional(),
  }),
})

export const updateVehicleSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid vehicle ID'),
  }),
  body: z.object({
    registrationNo: z.string().min(5).optional(),
    model: z.string().min(2).optional(),
    color: z.string().min(2).optional(),
    isActive: z.boolean().optional(),
  }),
})

export const vehicleIdParamSchema = z.object({
  params: z.object({
    id: z.string().cuid('Invalid vehicle ID'),
  }),
})
