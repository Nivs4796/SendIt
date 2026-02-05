import { z } from 'zod'

export const notificationIdParamSchema = z.object({
  params: z.object({
    id: z.string().min(1, 'Notification ID is required'),
  }),
})

export const updateNotificationSettingsSchema = z.object({
  body: z.object({
    pushEnabled: z.boolean().optional(),
    emailEnabled: z.boolean().optional(),
    smsEnabled: z.boolean().optional(),
    jobAlerts: z.boolean().optional(),
    promotions: z.boolean().optional(),
    updates: z.boolean().optional(),
  }),
})
