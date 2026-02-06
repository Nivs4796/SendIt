import { Request, Response, NextFunction } from 'express'
import * as adminService from '../services/admin.service'
import { formatResponse } from '../utils/helpers'

// ============================================
// DASHBOARD
// ============================================

export const getDashboard = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const stats = await adminService.getDashboardStats()
    res.json(formatResponse(true, 'Dashboard stats retrieved', stats))
  } catch (error) {
    next(error)
  }
}

// ============================================
// USER MANAGEMENT
// ============================================

export const listUsers = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page = '1', limit = '10', search, active } = req.query
    const isActive = active === 'true' ? true : active === 'false' ? false : undefined

    const result = await adminService.listUsers(
      parseInt(page as string),
      parseInt(limit as string),
      search as string | undefined,
      isActive
    )

    res.json(formatResponse(true, 'Users retrieved', { users: result.users }, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getUserDetails = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.params.userId as string
    const result = await adminService.getUserDetails(userId)
    res.json(formatResponse(true, 'User details retrieved', result))
  } catch (error) {
    next(error)
  }
}

export const updateUserStatus = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.params.userId as string
    const { isActive } = req.body

    const user = await adminService.updateUserStatus(userId, isActive)
    res.json(formatResponse(true, `User ${isActive ? 'activated' : 'suspended'}`, { user }))
  } catch (error) {
    next(error)
  }
}

export const updateUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.params.userId as string
    const { name, email, phone } = req.body

    const user = await adminService.updateUser(userId, { name, email, phone })
    res.json(formatResponse(true, 'User updated successfully', { user }))
  } catch (error) {
    next(error)
  }
}

// ============================================
// PILOT MANAGEMENT
// ============================================

export const listPilots = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page = '1', limit = '10', status, search, online } = req.query
    const isOnline = online === 'true' ? true : online === 'false' ? false : undefined

    const result = await adminService.listPilots(
      parseInt(page as string),
      parseInt(limit as string),
      status as 'PENDING' | 'APPROVED' | 'REJECTED' | 'SUSPENDED' | undefined,
      search as string | undefined,
      isOnline
    )

    res.json(formatResponse(true, 'Pilots retrieved', { pilots: result.pilots }, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getPilotDetails = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.params.pilotId as string
    const result = await adminService.getPilotDetails(pilotId)
    res.json(formatResponse(true, 'Pilot details retrieved', result))
  } catch (error) {
    next(error)
  }
}

export const updatePilotStatus = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.params.pilotId as string
    const { status, reason } = req.body

    const pilot = await adminService.updatePilotStatus(pilotId, status, reason)
    res.json(formatResponse(true, `Pilot status updated to ${status}`, { pilot }))
  } catch (error) {
    next(error)
  }
}

export const verifyDocument = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const documentId = req.params.documentId as string
    const { status, rejectedReason } = req.body

    const document = await adminService.verifyPilotDocument(documentId, status, rejectedReason)
    res.json(formatResponse(true, `Document ${status}`, { document }))
  } catch (error) {
    next(error)
  }
}

export const updatePilot = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.params.pilotId as string
    const { name, email, phone, dateOfBirth, gender } = req.body

    const pilot = await adminService.updatePilot(pilotId, { name, email, phone, dateOfBirth, gender })
    res.json(formatResponse(true, 'Pilot updated successfully', { pilot }))
  } catch (error) {
    next(error)
  }
}

// ============================================
// BOOKING MANAGEMENT
// ============================================

export const listBookings = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page = '1', limit = '10', status, search, dateFrom, dateTo, pilotId } = req.query

    const result = await adminService.listBookings(
      parseInt(page as string),
      parseInt(limit as string),
      status as any,
      search as string | undefined,
      dateFrom ? new Date(dateFrom as string) : undefined,
      dateTo ? new Date(dateTo as string) : undefined,
      pilotId as string | undefined
    )

    res.json(formatResponse(true, 'Bookings retrieved', { bookings: result.bookings }, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getBookingDetails = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const bookingId = req.params.bookingId as string
    const booking = await adminService.getBookingDetails(bookingId)
    res.json(formatResponse(true, 'Booking details retrieved', { booking }))
  } catch (error) {
    next(error)
  }
}

export const assignPilot = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const bookingId = req.params.bookingId as string
    const { pilotId } = req.body

    const booking = await adminService.assignPilotToBooking(bookingId, pilotId)
    res.json(formatResponse(true, 'Pilot assigned to booking', { booking }))
  } catch (error) {
    next(error)
  }
}

export const cancelBooking = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const bookingId = req.params.bookingId as string
    const { reason } = req.body

    const booking = await adminService.cancelBookingByAdmin(bookingId, reason)
    res.json(formatResponse(true, 'Booking cancelled', { booking }))
  } catch (error) {
    next(error)
  }
}

export const updateBookingStatus = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const bookingId = req.params.bookingId as string
    const { status, note } = req.body

    const booking = await adminService.updateBookingStatusByAdmin(bookingId, status, note)
    res.json(formatResponse(true, `Booking status updated to ${status}`, { booking }))
  } catch (error) {
    next(error)
  }
}

// ============================================
// SETTINGS
// ============================================

export const getSettings = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const settings = await adminService.getSettings()
    res.json(formatResponse(true, 'Settings retrieved', { settings }))
  } catch (error) {
    next(error)
  }
}

export const updateSetting = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { key, value, description } = req.body
    const setting = await adminService.updateSetting(key, value, description)
    res.json(formatResponse(true, 'Setting updated', { setting }))
  } catch (error) {
    next(error)
  }
}

export const updateSettings = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { settings } = req.body
    const results = await adminService.updateMultipleSettings(settings)
    res.json(formatResponse(true, 'Settings updated', { settings: results }))
  } catch (error) {
    next(error)
  }
}

// ============================================
// ANALYTICS
// ============================================

export const getBookingAnalytics = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { days = '30' } = req.query
    const analytics = await adminService.getBookingAnalytics(parseInt(days as string))
    res.json(formatResponse(true, 'Booking analytics retrieved', analytics))
  } catch (error) {
    next(error)
  }
}

export const getRevenueAnalytics = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { days = '30' } = req.query
    const analytics = await adminService.getRevenueAnalytics(parseInt(days as string))
    res.json(formatResponse(true, 'Revenue analytics retrieved', analytics))
  } catch (error) {
    next(error)
  }
}

// ============================================
// VEHICLE MANAGEMENT
// ============================================

export const listVehicles = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page = '1', limit = '10', search, verified, vehicleTypeId } = req.query
    const isVerified = verified === 'true' ? true : verified === 'false' ? false : undefined

    const result = await adminService.listAllVehicles(
      parseInt(page as string),
      parseInt(limit as string),
      search as string | undefined,
      isVerified,
      vehicleTypeId as string | undefined
    )

    res.json(formatResponse(true, 'Vehicles retrieved', { vehicles: result.vehicles }, result.meta))
  } catch (error) {
    next(error)
  }
}

export const getVehicleDetails = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const vehicleId = req.params.vehicleId as string
    const vehicle = await adminService.getVehicleDetails(vehicleId)
    res.json(formatResponse(true, 'Vehicle details retrieved', { vehicle }))
  } catch (error) {
    next(error)
  }
}

export const verifyVehicle = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const vehicleId = req.params.vehicleId as string
    const { isVerified, reason } = req.body

    const vehicle = await adminService.verifyVehicle(vehicleId, isVerified, reason)
    res.json(formatResponse(true, `Vehicle ${isVerified ? 'verified' : 'rejected'}`, { vehicle }))
  } catch (error) {
    next(error)
  }
}

// ============================================
// WALLET TRANSACTIONS
// ============================================

export const listWalletTransactions = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page = '1', limit = '10', userId, type, dateFrom, dateTo } = req.query

    const result = await adminService.listWalletTransactions(
      parseInt(page as string),
      parseInt(limit as string),
      userId as string | undefined,
      type as 'CREDIT' | 'DEBIT' | undefined,
      dateFrom ? new Date(dateFrom as string) : undefined,
      dateTo ? new Date(dateTo as string) : undefined
    )

    res.json(formatResponse(true, 'Wallet transactions retrieved', { transactions: result.transactions }, result.meta))
  } catch (error) {
    next(error)
  }
}
