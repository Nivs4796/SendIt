import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'

interface CreateVehicleInput {
  pilotId: string
  vehicleTypeId: string
  registrationNo?: string
  model?: string
  color?: string
}

export const createVehicle = async (input: CreateVehicleInput) => {
  // Verify vehicle type exists
  const vehicleType = await prisma.vehicleType.findUnique({ where: { id: input.vehicleTypeId } })
  if (!vehicleType) {
    throw new AppError('Vehicle type not found', 404)
  }

  const vehicle = await prisma.vehicle.create({
    data: input,
    include: { vehicleType: true },
  })

  return vehicle
}

export const getVehicleById = async (id: string, pilotId: string) => {
  const vehicle = await prisma.vehicle.findUnique({
    where: { id },
    include: { vehicleType: true },
  })

  if (!vehicle) {
    throw new AppError('Vehicle not found', 404)
  }

  if (vehicle.pilotId !== pilotId) {
    throw new AppError('Unauthorized', 403)
  }

  return vehicle
}

export const updateVehicle = async (
  id: string,
  pilotId: string,
  data: { registrationNo?: string; model?: string; color?: string; isActive?: boolean }
) => {
  const vehicle = await prisma.vehicle.findUnique({ where: { id } })

  if (!vehicle) {
    throw new AppError('Vehicle not found', 404)
  }

  if (vehicle.pilotId !== pilotId) {
    throw new AppError('Unauthorized', 403)
  }

  const updated = await prisma.vehicle.update({
    where: { id },
    data,
    include: { vehicleType: true },
  })

  return updated
}

export const deleteVehicle = async (id: string, pilotId: string) => {
  const vehicle = await prisma.vehicle.findUnique({ where: { id } })

  if (!vehicle) {
    throw new AppError('Vehicle not found', 404)
  }

  if (vehicle.pilotId !== pilotId) {
    throw new AppError('Unauthorized', 403)
  }

  await prisma.vehicle.delete({ where: { id } })
}

export const getPilotVehicles = async (pilotId: string) => {
  const vehicles = await prisma.vehicle.findMany({
    where: { pilotId },
    include: { vehicleType: true },
    orderBy: { createdAt: 'desc' },
  })
  return vehicles
}

export const getVehicleTypes = async () => {
  const types = await prisma.vehicleType.findMany({
    where: { isActive: true },
    orderBy: { basePrice: 'asc' },
  })
  return types
}
