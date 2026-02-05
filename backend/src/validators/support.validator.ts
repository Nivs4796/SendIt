import { z } from 'zod'

const CategoryEnum = z.enum([
  'GENERAL',
  'PAYMENTS',
  'DELIVERIES',
  'ACCOUNT',
  'EARNINGS',
  'DOCUMENTS',
  'TECHNICAL',
])

const PriorityEnum = z.enum(['LOW', 'MEDIUM', 'HIGH', 'URGENT'])

export const createTicketSchema = z.object({
  body: z.object({
    subject: z
      .string()
      .min(5, 'Subject must be at least 5 characters')
      .max(200, 'Subject must be at most 200 characters'),
    description: z
      .string()
      .min(10, 'Description must be at least 10 characters')
      .max(2000, 'Description must be at most 2000 characters'),
    category: CategoryEnum.optional(),
    priority: PriorityEnum.optional(),
  }),
})

export const ticketIdParamSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Ticket ID is required'),
  }),
})

export const faqQuerySchema = z.object({
  query: z.object({
    category: CategoryEnum.optional(),
    search: z.string().max(100).optional(),
  }),
})
