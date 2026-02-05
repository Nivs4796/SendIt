import { Router } from 'express'
import authRoutes from './auth.routes'
import bookingRoutes from './booking.routes'
import userRoutes from './user.routes'
import addressRoutes from './address.routes'
import pilotRoutes from './pilot.routes'
import vehicleRoutes from './vehicle.routes'
import reviewRoutes from './review.routes'
import matchingRoutes from './matching.routes'
import couponRoutes from './coupon.routes'
import walletRoutes from './wallet.routes'
import adminRoutes from './admin.routes'
import uploadRoutes from './upload.routes'
import documentsRoutes from './documents.routes'
import bankRoutes from './bank.routes'
import notificationsRoutes from './notifications.routes'
import supportRoutes from './support.routes'
import rewardsRoutes from './rewards.routes'
import paymentRoutes from './payment.routes'
import fcmRoutes from './fcm.routes'

const router = Router()

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health check endpoint
 *     tags: [System]
 *     responses:
 *       200:
 *         description: API is running
 */
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'SendIt API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  })
})

// Mount routes
router.use('/auth', authRoutes)
router.use('/users', userRoutes)
router.use('/addresses', addressRoutes)
router.use('/pilots', pilotRoutes)
router.use('/vehicles', vehicleRoutes)
router.use('/bookings', bookingRoutes)
router.use('/reviews', reviewRoutes)
router.use('/matching', matchingRoutes)
router.use('/coupons', couponRoutes)
router.use('/wallet', walletRoutes)
router.use('/admin', adminRoutes)
router.use('/upload', uploadRoutes)

// New routes
router.use('/pilots/documents', documentsRoutes)
router.use('/pilots/bank-accounts', bankRoutes)
router.use('/pilots/notifications', notificationsRoutes)
router.use('/support', supportRoutes)
router.use('/pilots', rewardsRoutes) // Mounts /pilots/referral, /pilots/rewards, /pilots/achievements

// Utility routes (IFSC lookup)
router.use('/utils', bankRoutes)

// Payment routes (Razorpay)
router.use('/payments', paymentRoutes)

// FCM push notification token routes
router.use('/fcm', fcmRoutes)

export default router
