import { Request, Response, NextFunction } from 'express'
import * as matchingService from '../services/matching.service'
import { formatResponse } from '../utils/helpers'

/**
 * Find available pilots for a booking
 */
export const findPilots = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { bookingId } = req.params

    const result = await matchingService.findAndAssignPilot(bookingId)

    res.json(formatResponse(result.success, result.message, result.pilot ? { pilot: result.pilot } : undefined))
  } catch (error) {
    next(error)
  }
}

/**
 * Get available jobs for a pilot
 */
export const getAvailableJobs = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { page = '1', limit = '10' } = req.query

    const result = await matchingService.getAvailableJobsForPilot(
      pilotId,
      parseInt(page as string),
      parseInt(limit as string)
    )

    res.json(formatResponse(true, 'Available jobs retrieved', { jobs: result.jobs }, result.meta))
  } catch (error) {
    next(error)
  }
}

/**
 * Get pending job offers for a pilot
 */
export const getPendingOffers = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id

    const offers = await matchingService.getPendingOffersForPilot(pilotId)

    res.json(formatResponse(true, 'Pending offers retrieved', { offers }))
  } catch (error) {
    next(error)
  }
}

/**
 * Respond to a job offer (accept/decline)
 */
export const respondToOffer = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { offerId } = req.params
    const { accept } = req.body

    const result = await matchingService.respondToJobOffer(offerId, pilotId, accept)

    res.json(formatResponse(result.success, result.message))
  } catch (error) {
    next(error)
  }
}

/**
 * Auto-assign a booking to the best pilot
 */
export const autoAssign = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { bookingId } = req.params

    const result = await matchingService.autoAssignBooking(bookingId)

    res.json(formatResponse(result.success, result.message, result.pilotId ? { pilotId: result.pilotId } : undefined))
  } catch (error) {
    next(error)
  }
}

/**
 * Find nearby pilots (for testing/admin)
 */
export const findNearbyPilots = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { lat, lng, vehicleTypeId, radius = '5' } = req.query

    if (!lat || !lng || !vehicleTypeId) {
      res.status(400).json(formatResponse(false, 'lat, lng, and vehicleTypeId are required'))
      return
    }

    const pilots = await matchingService.findAvailablePilots(
      parseFloat(lat as string),
      parseFloat(lng as string),
      vehicleTypeId as string,
      parseFloat(radius as string)
    )

    res.json(formatResponse(true, 'Nearby pilots found', { pilots, count: pilots.length }))
  } catch (error) {
    next(error)
  }
}
