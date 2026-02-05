import { Request, Response, NextFunction } from 'express'
import * as supportService from '../services/support.service'
import { formatResponse } from '../utils/helpers'

/**
 * Get FAQs
 */
export const getFAQs = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { category, search } = req.query

    if (search && typeof search === 'string') {
      const faqs = await supportService.searchFAQs(search)
      res.json(formatResponse(true, 'FAQs retrieved', { faqs }))
      return
    }

    const result = await supportService.getFAQs(category as string | undefined)

    res.json(formatResponse(true, 'FAQs retrieved', result))
  } catch (error) {
    next(error)
  }
}

/**
 * Create support ticket
 */
export const createTicket = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const userType = req.user!.type
    const { subject, description, category, priority } = req.body

    const result = await supportService.createTicket({
      pilotId: userType === 'pilot' ? userId : undefined,
      userId: userType === 'user' ? userId : undefined,
      subject,
      description,
      category,
      priority,
    })

    res.status(201).json(formatResponse(true, result.message, { ticket: result.ticket }))
  } catch (error) {
    next(error)
  }
}

/**
 * Get my tickets
 */
export const getMyTickets = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const userType = req.user!.type
    const { page = '1', limit = '10' } = req.query

    const result = await supportService.getMyTickets(
      userType === 'pilot' ? userId : undefined,
      userType === 'user' ? userId : undefined,
      parseInt(page as string),
      parseInt(limit as string)
    )

    res.json(formatResponse(true, 'Tickets retrieved', result.tickets, result.meta))
  } catch (error) {
    next(error)
  }
}

/**
 * Get ticket by ID
 */
export const getTicketById = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const userType = req.user!.type
    const id = req.params.id as string

    const ticket = await supportService.getTicketById(
      id,
      userType === 'pilot' ? userId : undefined,
      userType === 'user' ? userId : undefined
    )

    res.json(formatResponse(true, 'Ticket retrieved', ticket))
  } catch (error) {
    next(error)
  }
}

/**
 * Get contact information
 */
export const getContactInfo = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const contact = supportService.getContactInfo()

    res.json(formatResponse(true, 'Contact information retrieved', contact))
  } catch (error) {
    next(error)
  }
}
