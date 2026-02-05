import { Router } from 'express'
import * as notificationsController from '../controllers/pilot-notifications.controller'
import { authenticate, authorizePilot } from '../middleware/auth'
import { validate } from '../validators'
import { notificationIdParamSchema, updateNotificationSettingsSchema } from '../validators/notifications.validator'

const router = Router()

/**
 * @swagger
 * /pilots/notifications:
 *   get:
 *     summary: Get pilot notifications
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *       - in: query
 *         name: unreadOnly
 *         schema:
 *           type: boolean
 *     responses:
 *       200:
 *         description: Notifications list
 */
router.get(
  '/',
  authenticate,
  authorizePilot,
  notificationsController.getNotifications
)

/**
 * @swagger
 * /pilots/notifications/{id}/read:
 *   patch:
 *     summary: Mark notification as read
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Notification marked as read
 */
router.patch(
  '/:id/read',
  authenticate,
  authorizePilot,
  validate(notificationIdParamSchema),
  notificationsController.markAsRead
)

/**
 * @swagger
 * /pilots/notifications/read-all:
 *   patch:
 *     summary: Mark all notifications as read
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: All notifications marked as read
 */
router.patch(
  '/read-all',
  authenticate,
  authorizePilot,
  notificationsController.markAllAsRead
)

/**
 * @swagger
 * /pilots/notifications/{id}:
 *   delete:
 *     summary: Delete a notification
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Notification deleted
 */
router.delete(
  '/:id',
  authenticate,
  authorizePilot,
  validate(notificationIdParamSchema),
  notificationsController.deleteNotification
)

/**
 * @swagger
 * /pilots/notifications/clear-read:
 *   delete:
 *     summary: Delete all read notifications
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Read notifications deleted
 */
router.delete(
  '/clear-read',
  authenticate,
  authorizePilot,
  notificationsController.deleteReadNotifications
)

/**
 * @swagger
 * /pilots/notification-settings:
 *   get:
 *     summary: Get notification settings
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Notification settings
 */
router.get(
  '/settings',
  authenticate,
  authorizePilot,
  notificationsController.getSettings
)

/**
 * @swagger
 * /pilots/notification-settings:
 *   patch:
 *     summary: Update notification settings
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               pushEnabled:
 *                 type: boolean
 *               emailEnabled:
 *                 type: boolean
 *               smsEnabled:
 *                 type: boolean
 *               jobAlerts:
 *                 type: boolean
 *               promotions:
 *                 type: boolean
 *               updates:
 *                 type: boolean
 *     responses:
 *       200:
 *         description: Settings updated
 */
router.patch(
  '/settings',
  authenticate,
  authorizePilot,
  validate(updateNotificationSettingsSchema),
  notificationsController.updateSettings
)

export default router
