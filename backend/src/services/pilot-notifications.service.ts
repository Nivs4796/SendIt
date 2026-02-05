import prisma from '../config/database'
import { AppError, NotFoundError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { NotificationType } from '@prisma/client'
import logger from '../config/logger'

interface UpdateNotificationSettingsInput {
  pushEnabled?: boolean
  emailEnabled?: boolean
  smsEnabled?: boolean
  jobAlerts?: boolean
  promotions?: boolean
  updates?: boolean
}

/**
 * Get pilot notifications
 */
export const getPilotNotifications = async (
  pilotId: string,
  page: number = 1,
  limit: number = 20,
  unreadOnly: boolean = false
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    pilotId,
    ...(unreadOnly && { isRead: false }),
  }

  const [notifications, total, unreadCount] = await Promise.all([
    prisma.notification.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.notification.count({ where }),
    prisma.notification.count({ where: { pilotId, isRead: false } }),
  ])

  return {
    notifications,
    unreadCount,
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

/**
 * Mark a notification as read
 */
export const markAsRead = async (notificationId: string, pilotId: string) => {
  const notification = await prisma.notification.findFirst({
    where: { id: notificationId, pilotId },
  })

  if (!notification) {
    throw new NotFoundError('Notification')
  }

  if (notification.isRead) {
    return notification
  }

  const updated = await prisma.notification.update({
    where: { id: notificationId },
    data: { isRead: true },
  })

  return updated
}

/**
 * Mark all notifications as read
 */
export const markAllAsRead = async (pilotId: string) => {
  const result = await prisma.notification.updateMany({
    where: { pilotId, isRead: false },
    data: { isRead: true },
  })

  logger.info(`Marked ${result.count} notifications as read for pilot ${pilotId}`)
  return { count: result.count }
}

/**
 * Delete a notification
 */
export const deleteNotification = async (notificationId: string, pilotId: string) => {
  const notification = await prisma.notification.findFirst({
    where: { id: notificationId, pilotId },
  })

  if (!notification) {
    throw new NotFoundError('Notification')
  }

  await prisma.notification.delete({
    where: { id: notificationId },
  })

  return { success: true }
}

/**
 * Delete all read notifications
 */
export const deleteReadNotifications = async (pilotId: string) => {
  const result = await prisma.notification.deleteMany({
    where: { pilotId, isRead: true },
  })

  logger.info(`Deleted ${result.count} read notifications for pilot ${pilotId}`)
  return { count: result.count }
}

/**
 * Get notification settings for a pilot
 */
export const getNotificationSettings = async (pilotId: string) => {
  let settings = await prisma.notificationSetting.findUnique({
    where: { pilotId },
  })

  // Create default settings if not exists
  if (!settings) {
    settings = await prisma.notificationSetting.create({
      data: {
        pilotId,
        pushEnabled: true,
        emailEnabled: false,
        smsEnabled: false,
        jobAlerts: true,
        promotions: true,
        updates: true,
      },
    })
  }

  return settings
}

/**
 * Update notification settings
 */
export const updateNotificationSettings = async (
  pilotId: string,
  input: UpdateNotificationSettingsInput
) => {
  // Ensure settings exist
  await getNotificationSettings(pilotId)

  const settings = await prisma.notificationSetting.update({
    where: { pilotId },
    data: input,
  })

  logger.info(`Notification settings updated for pilot ${pilotId}`)
  return settings
}

/**
 * Create a notification for a pilot
 */
export const createPilotNotification = async (
  pilotId: string,
  title: string,
  body: string,
  type: NotificationType,
  data?: object
) => {
  const notification = await prisma.notification.create({
    data: {
      pilotId,
      title,
      body,
      type,
      data: data as any,
    },
  })

  return notification
}

/**
 * Create bulk notifications for multiple pilots
 */
export const createBulkNotifications = async (
  pilotIds: string[],
  title: string,
  body: string,
  type: NotificationType,
  data?: object
) => {
  const notifications = await prisma.notification.createMany({
    data: pilotIds.map((pilotId) => ({
      pilotId,
      title,
      body,
      type,
      data: data as any,
    })),
  })

  logger.info(`Created ${notifications.count} bulk notifications`)
  return { count: notifications.count }
}
