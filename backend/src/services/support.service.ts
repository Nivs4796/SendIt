import prisma from '../config/database'
import { AppError, NotFoundError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import logger from '../config/logger'

interface CreateTicketInput {
  pilotId?: string
  userId?: string
  subject: string
  description: string
  category?: string
  priority?: string
}

// Static contact information
const CONTACT_INFO = {
  email: 'support@sendit.in',
  phone: '+91 1800-XXX-XXXX',
  whatsapp: '+91 98765-43210',
  address: 'SendIt Technologies Pvt. Ltd.\nBengaluru, Karnataka, India',
  workingHours: 'Monday - Saturday, 9:00 AM - 6:00 PM IST',
  responseTime: 'We typically respond within 24 hours',
  socials: {
    twitter: '@SendItIndia',
    instagram: '@sendit.india',
    facebook: 'SendItIndia',
  },
}

// FAQ Categories
const FAQ_CATEGORIES = [
  'GENERAL',
  'PAYMENTS',
  'DELIVERIES',
  'ACCOUNT',
  'EARNINGS',
  'DOCUMENTS',
  'TECHNICAL',
]

/**
 * Get FAQs by category
 */
export const getFAQs = async (category?: string) => {
  const where = {
    isActive: true,
    ...(category && { category: category.toUpperCase() }),
  }

  const faqs = await prisma.fAQ.findMany({
    where,
    orderBy: [{ category: 'asc' }, { sortOrder: 'asc' }],
  })

  // Group by category if no specific category requested
  if (!category) {
    const grouped = faqs.reduce(
      (acc, faq) => {
        if (!acc[faq.category]) {
          acc[faq.category] = []
        }
        acc[faq.category].push(faq)
        return acc
      },
      {} as Record<string, typeof faqs>
    )

    return { faqs: grouped, categories: FAQ_CATEGORIES }
  }

  return { faqs, categories: FAQ_CATEGORIES }
}

/**
 * Create a support ticket
 */
export const createTicket = async (input: CreateTicketInput) => {
  const { pilotId, userId, subject, description, category, priority } = input

  if (!pilotId && !userId) {
    throw new AppError('Either pilotId or userId is required', 400)
  }

  const ticket = await prisma.supportTicket.create({
    data: {
      pilotId,
      userId,
      subject,
      description,
      category: category?.toUpperCase() || 'GENERAL',
      priority: priority?.toUpperCase() || 'MEDIUM',
      status: 'OPEN',
    },
  })

  logger.info(
    `Support ticket created: ${ticket.id} by ${pilotId ? 'Pilot' : 'User'} ${pilotId || userId}`
  )

  return {
    ticket,
    message: 'Your ticket has been submitted. We will respond within 24 hours.',
  }
}

/**
 * Get tickets for a pilot/user
 */
export const getMyTickets = async (
  pilotId?: string,
  userId?: string,
  page: number = 1,
  limit: number = 10
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    ...(pilotId && { pilotId }),
    ...(userId && { userId }),
  }

  const [tickets, total] = await Promise.all([
    prisma.supportTicket.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.supportTicket.count({ where }),
  ])

  return {
    tickets,
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

/**
 * Get a specific ticket
 */
export const getTicketById = async (
  ticketId: string,
  pilotId?: string,
  userId?: string
) => {
  const ticket = await prisma.supportTicket.findFirst({
    where: {
      id: ticketId,
      ...(pilotId && { pilotId }),
      ...(userId && { userId }),
    },
  })

  if (!ticket) {
    throw new NotFoundError('Support ticket')
  }

  return ticket
}

/**
 * Get contact information
 */
export const getContactInfo = () => {
  return CONTACT_INFO
}

/**
 * Search FAQs
 */
export const searchFAQs = async (query: string) => {
  const faqs = await prisma.fAQ.findMany({
    where: {
      isActive: true,
      OR: [
        { question: { contains: query, mode: 'insensitive' } },
        { answer: { contains: query, mode: 'insensitive' } },
      ],
    },
    orderBy: { sortOrder: 'asc' },
    take: 10,
  })

  return faqs
}

// Admin functions

/**
 * Update ticket status (Admin)
 */
export const updateTicketStatus = async (
  ticketId: string,
  status: string,
  adminNote?: string
) => {
  const ticket = await prisma.supportTicket.findUnique({
    where: { id: ticketId },
  })

  if (!ticket) {
    throw new NotFoundError('Support ticket')
  }

  const updated = await prisma.supportTicket.update({
    where: { id: ticketId },
    data: {
      status: status.toUpperCase(),
      ...(status.toUpperCase() === 'RESOLVED' && { resolvedAt: new Date() }),
    },
  })

  logger.info(`Ticket ${ticketId} status updated to ${status}`)
  return updated
}

/**
 * Create or update FAQ (Admin)
 */
export const upsertFAQ = async (
  id: string | null,
  question: string,
  answer: string,
  category: string,
  sortOrder?: number
) => {
  if (id) {
    return prisma.fAQ.update({
      where: { id },
      data: { question, answer, category: category.toUpperCase(), sortOrder },
    })
  }

  return prisma.fAQ.create({
    data: {
      question,
      answer,
      category: category.toUpperCase(),
      sortOrder: sortOrder || 0,
    },
  })
}
