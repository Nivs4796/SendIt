import { Request, Response, NextFunction } from 'express'
import * as pilotService from '../services/pilot.service'
import { formatResponse } from '../utils/helpers'
import { PilotStatus } from '@prisma/client'

export const registerPilot = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.registerPilot(req.body)
    res.status(201).json(formatResponse(true, 'Pilot registered successfully', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const getProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.getPilotById(req.user!.id)
    res.status(200).json(formatResponse(true, 'Profile retrieved', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const updateProfile = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.updatePilot(req.user!.id, req.body)
    res.status(200).json(formatResponse(true, 'Profile updated', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const updateLocation = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await pilotService.updateLocation(req.user!.id, req.body.lat, req.body.lng)
    res.status(200).json(formatResponse(true, 'Location updated'))
  } catch (error) {
    next(error)
  }
}

export const updateOnlineStatus = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.updateOnlineStatus(req.user!.id, req.body.isOnline)
    res.status(200).json(formatResponse(true, 'Status updated', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const getEarnings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const result = await pilotService.getPilotEarnings(req.user!.id, page, limit)
    res.status(200).json(formatResponse(true, 'Earnings retrieved', result, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getBookings = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const status = req.query.status as string | undefined
    const result = await pilotService.getPilotBookings(req.user!.id, page, limit, status)
    res.status(200).json(formatResponse(true, 'Bookings retrieved', { bookings: result.bookings }, result.meta))
  } catch (error) {
    next(error)
  }
}

// Admin endpoints
export const listPilots = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const status = req.query.status as PilotStatus | undefined
    const search = req.query.search as string | undefined
    const result = await pilotService.listPilots(page, limit, status, search)
    res.status(200).json(formatResponse(true, 'Pilots retrieved', { pilots: result.pilots }, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getPilotById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.getPilotById(req.params.id as string)
    res.status(200).json(formatResponse(true, 'Pilot retrieved', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const updatePilotStatus = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const pilot = await pilotService.updatePilotStatus(req.params.id as string, req.body.status)
    res.status(200).json(formatResponse(true, 'Pilot status updated', { pilot }))
  } catch (error) {
    next(error)
  }
}

export const getNearbyPilots = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { lat, lng, radius } = req.query
    const pilots = await pilotService.getNearbyPilots(
      parseFloat(lat as string),
      parseFloat(lng as string),
      parseFloat(radius as string) || 5
    )
    res.status(200).json(formatResponse(true, 'Nearby pilots retrieved', { pilots }))
  } catch (error) {
    next(error)
  }
}
