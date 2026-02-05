import { Request, Response, NextFunction } from 'express'
import * as notificationsService from '../services/pilot-notifications.service'
import { formatResponse } from '../utils/helpers'

// Helper to extract string param
const getParamAsString = (param: string | string[] | undefined): string => {
  if (Array.isArray(param)) return param[0]
  return param || ''
}

/**
 * Get pilot notifications
 */
export const getNotifications = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { page = '1', limit = '20', unreadOnly = 'false' } = req.query

    const result = await notificationsService.getPilotNotifications(
      pilotId,
      parseInt(page as string),
      parseInt(limit as string),
      unreadOnly === 'true'
    )

    res.json(formatResponse(true, 'Notifications retrieved', {
      notifications: result.notifications,
      unreadCount: result.unreadCount,
    }, result.meta))
  } catch (error) {
    next(error)
  }
}

/**
 * Mark notification as read
 */
export const markAsRead = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const id = getParamAsString(req.params.id)

    const notification = await notificationsService.markAsRead(id, pilotId)

    res.json(formatResponse(true, 'Notification marked as read', notification))
  } catch (error) {
    next(error)
  }
}

/**
 * Mark all notifications as read
 */
export const markAllAsRead = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id

    const result = await notificationsService.markAllAsRead(pilotId)

    res.json(formatResponse(true, `${result.count} notifications marked as read`))
  } catch (error) {
    next(error)
  }
}

/**
 * Delete a notification
 */
export const deleteNotification = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const id = getParamAsString(req.params.id)

    await notificationsService.deleteNotification(id, pilotId)

    res.json(formatResponse(true, 'Notification deleted'))
  } catch (error) {
    next(error)
  }
}

/**
 * Delete all read notifications
 */
export const deleteReadNotifications = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id

    const result = await notificationsService.deleteReadNotifications(pilotId)

    res.json(formatResponse(true, `${result.count} notifications deleted`))
  } catch (error) {
    next(error)
  }
}

/**
 * Get notification settings
 */
export const getSettings = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id

    const settings = await notificationsService.getNotificationSettings(pilotId)

    res.json(formatResponse(true, 'Notification settings retrieved', settings))
  } catch (error) {
    next(error)
  }
}

/**
 * Update notification settings
 */
export const updateSettings = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const updates = req.body

    const settings = await notificationsService.updateNotificationSettings(pilotId, updates)

    res.json(formatResponse(true, 'Notification settings updated', settings))
  } catch (error) {
    next(error)
  }
}
