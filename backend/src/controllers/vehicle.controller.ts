import { Request, Response, NextFunction } from 'express'
import * as vehicleService from '../services/vehicle.service'
import { formatResponse } from '../utils/helpers'

export const createVehicle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const vehicle = await vehicleService.createVehicle({ ...req.body, pilotId: req.user!.id })
    res.status(201).json(formatResponse(true, 'Vehicle added', { vehicle }))
  } catch (error) {
    next(error)
  }
}

export const getVehicles = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const vehicles = await vehicleService.getPilotVehicles(req.user!.id)
    res.status(200).json(formatResponse(true, 'Vehicles retrieved', { vehicles }))
  } catch (error) {
    next(error)
  }
}

export const getVehicle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const vehicle = await vehicleService.getVehicleById(req.params.id as string, req.user!.id)
    res.status(200).json(formatResponse(true, 'Vehicle retrieved', { vehicle }))
  } catch (error) {
    next(error)
  }
}

export const updateVehicle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const vehicle = await vehicleService.updateVehicle(req.params.id as string, req.user!.id, req.body)
    res.status(200).json(formatResponse(true, 'Vehicle updated', { vehicle }))
  } catch (error) {
    next(error)
  }
}

export const deleteVehicle = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await vehicleService.deleteVehicle(req.params.id as string, req.user!.id)
    res.status(200).json(formatResponse(true, 'Vehicle deleted'))
  } catch (error) {
    next(error)
  }
}

export const getVehicleTypes = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const types = await vehicleService.getVehicleTypes()
    res.status(200).json(formatResponse(true, 'Vehicle types retrieved', { types }))
  } catch (error) {
    next(error)
  }
}
