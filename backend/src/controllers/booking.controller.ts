import { Request, Response, NextFunction } from 'express'
import * as bookingService from '../services/booking.service'
import { formatResponse } from '../utils/helpers'
import { BookingStatus } from '@prisma/client'

// Helper to extract string param
const getParamAsString = (param: string | string[] | undefined): string => {
  if (Array.isArray(param)) return param[0]
  return param || ''
}

// Calculate booking price
export const calculatePrice = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const { vehicleTypeId, pickupAddressId, dropAddressId } = req.body

    if (!vehicleTypeId || !pickupAddressId || !dropAddressId) {
      res.status(400).json(formatResponse(false, 'All fields are required'))
      return
    }

    const pricing = await bookingService.calculateBookingPrice(
      vehicleTypeId,
      pickupAddressId,
      dropAddressId
    )

    res.status(200).json(formatResponse(true, 'Price calculated', pricing))
  } catch (error) {
    next(error)
  }
}

// Create booking
export const createBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id
    const {
      vehicleTypeId,
      pickupAddressId,
      dropAddressId,
      packageType,
      packageWeight,
      packageDescription,
      scheduledAt,
      paymentMethod,
    } = req.body

    if (!vehicleTypeId || !pickupAddressId || !dropAddressId) {
      res.status(400).json(formatResponse(false, 'Required fields are missing'))
      return
    }

    const booking = await bookingService.createBooking({
      userId,
      vehicleTypeId,
      pickupAddressId,
      dropAddressId,
      packageType,
      packageWeight,
      packageDescription,
      scheduledAt: scheduledAt ? new Date(scheduledAt) : undefined,
      paymentMethod,
    })

    res.status(201).json(formatResponse(true, 'Booking created successfully', { booking }))
  } catch (error) {
    next(error)
  }
}

// Get booking by ID
export const getBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = getParamAsString(req.params.id)
    const userId = req.user?.type === 'user' ? req.user.id : undefined

    const booking = await bookingService.getBookingById(id, userId)

    res.status(200).json(formatResponse(true, 'Booking retrieved', { booking }))
  } catch (error) {
    next(error)
  }
}

// Get user bookings
export const getUserBookings = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const userId = req.user!.id
    const page = parseInt(req.query.page as string) || 1
    const limit = parseInt(req.query.limit as string) || 10
    const status = req.query.status as BookingStatus | undefined

    const result = await bookingService.getUserBookings(userId, page, limit, status)

    res.status(200).json(
      formatResponse(true, 'Bookings retrieved', { bookings: result.bookings }, result.meta)
    )
  } catch (error) {
    next(error)
  }
}

// Accept booking (Pilot)
export const acceptBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = getParamAsString(req.params.id)
    const pilotId = req.user!.id

    const booking = await bookingService.acceptBooking(id, pilotId)

    res.status(200).json(formatResponse(true, 'Booking accepted', { booking }))
  } catch (error) {
    next(error)
  }
}

// Update booking status (Pilot)
export const updateBookingStatus = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = getParamAsString(req.params.id)
    const pilotId = req.user!.id
    const { status, lat, lng, note } = req.body

    if (!status) {
      res.status(400).json(formatResponse(false, 'Status is required'))
      return
    }

    const booking = await bookingService.updateBookingStatus(
      id,
      pilotId,
      status,
      lat,
      lng,
      note
    )

    res.status(200).json(formatResponse(true, 'Booking status updated', { booking }))
  } catch (error) {
    next(error)
  }
}

// Cancel booking (User)
export const cancelBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const id = getParamAsString(req.params.id)
    const userId = req.user!.id
    const { reason } = req.body

    const booking = await bookingService.cancelBooking(id, userId, reason || 'User cancelled')

    res.status(200).json(formatResponse(true, 'Booking cancelled', { booking }))
  } catch (error) {
    next(error)
  }
}
