import { Router, Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { authenticate, authorizeUser, authorizePilot } from '../middleware/auth';
import fcmService from '../services/fcm.service';

const router = Router();

// Validation middleware
const validate = (req: Request, res: Response, next: Function) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ success: false, errors: errors.array() });
  }
  next();
};

// =============================================
// USER FCM TOKEN ROUTES
// =============================================

/**
 * Register FCM token for user
 * POST /api/v1/fcm/user/register
 */
router.post(
  '/user/register',
  authenticate,
  authorizeUser,
  [
    body('fcmToken').notEmpty().withMessage('FCM token is required'),
  ],
  validate,
  async (req: Request, res: Response) => {
    try {
      const { fcmToken } = req.body;
      const userId = req.user!.id;

      await fcmService.registerUserToken(userId, fcmToken);

      res.json({
        success: true,
        message: 'FCM token registered successfully',
      });
    } catch (error) {
      console.error('FCM register error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to register FCM token',
      });
    }
  }
);

/**
 * Clear FCM token for user (logout)
 * DELETE /api/v1/fcm/user/token
 */
router.delete(
  '/user/token',
  authenticate,
  authorizeUser,
  async (req: Request, res: Response) => {
    try {
      const userId = req.user!.id;
      await fcmService.clearUserToken(userId);

      res.json({
        success: true,
        message: 'FCM token cleared',
      });
    } catch (error) {
      console.error('FCM clear error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to clear FCM token',
      });
    }
  }
);

// =============================================
// PILOT FCM TOKEN ROUTES
// =============================================

/**
 * Register FCM token for pilot
 * POST /api/v1/fcm/pilot/register
 */
router.post(
  '/pilot/register',
  authenticate,
  authorizePilot,
  [
    body('fcmToken').notEmpty().withMessage('FCM token is required'),
  ],
  validate,
  async (req: Request, res: Response) => {
    try {
      const { fcmToken } = req.body;
      const pilotId = req.user!.id;

      await fcmService.registerPilotToken(pilotId, fcmToken);

      res.json({
        success: true,
        message: 'FCM token registered successfully',
      });
    } catch (error) {
      console.error('FCM register error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to register FCM token',
      });
    }
  }
);

/**
 * Clear FCM token for pilot (logout)
 * DELETE /api/v1/fcm/pilot/token
 */
router.delete(
  '/pilot/token',
  authenticate,
  authorizePilot,
  async (req: Request, res: Response) => {
    try {
      const pilotId = req.user!.id;
      await fcmService.clearPilotToken(pilotId);

      res.json({
        success: true,
        message: 'FCM token cleared',
      });
    } catch (error) {
      console.error('FCM clear error:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to clear FCM token',
      });
    }
  }
);

export default router;
