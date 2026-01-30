import { Router } from 'express'
import * as authController from '../controllers/auth.controller'
import { validate, sendOTPSchema, verifyOTPSchema, adminLoginSchema, createAdminSchema } from '../validators'
import { authLimiter, otpLimiter } from '../middleware/rateLimiter'
import { authenticate, authorizeSuperAdmin } from '../middleware/auth'

const router = Router()

/**
 * @swagger
 * /auth/user/send-otp:
 *   post:
 *     summary: Send OTP to user phone
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "+919876543210"
 *     responses:
 *       200:
 *         description: OTP sent successfully
 *       400:
 *         description: Validation error
 *       429:
 *         description: Too many requests
 */
router.post('/user/send-otp', otpLimiter, validate(sendOTPSchema), authController.sendUserOTP)

/**
 * @swagger
 * /auth/user/verify-otp:
 *   post:
 *     summary: Verify OTP and login user
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - otp
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "+919876543210"
 *               otp:
 *                 type: string
 *                 example: "123456"
 *     responses:
 *       200:
 *         description: Login successful
 *       400:
 *         description: Invalid OTP
 *       429:
 *         description: Too many attempts
 */
router.post('/user/verify-otp', authLimiter, validate(verifyOTPSchema), authController.verifyUserOTP)

/**
 * @swagger
 * /auth/pilot/send-otp:
 *   post:
 *     summary: Send OTP to pilot phone
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *             properties:
 *               phone:
 *                 type: string
 *                 example: "+919876543210"
 *     responses:
 *       200:
 *         description: OTP sent successfully
 *       400:
 *         description: Validation error
 *       429:
 *         description: Too many requests
 */
router.post('/pilot/send-otp', otpLimiter, validate(sendOTPSchema), authController.sendPilotOTP)

/**
 * @swagger
 * /auth/pilot/verify-otp:
 *   post:
 *     summary: Verify OTP and login pilot
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phone
 *               - otp
 *             properties:
 *               phone:
 *                 type: string
 *               otp:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 *       400:
 *         description: Invalid OTP
 */
router.post('/pilot/verify-otp', authLimiter, validate(verifyOTPSchema), authController.verifyPilotOTP)

/**
 * @swagger
 * /auth/admin/login:
 *   post:
 *     summary: Admin login with email and password
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 example: "admin@sendit.co.in"
 *               password:
 *                 type: string
 *                 example: "admin123"
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 */
router.post('/admin/login', authLimiter, validate(adminLoginSchema), authController.adminLogin)

/**
 * @swagger
 * /auth/admin/create:
 *   post:
 *     summary: Create new admin (Super Admin only)
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - name
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               name:
 *                 type: string
 *               role:
 *                 type: string
 *                 enum: [SUPER_ADMIN, ADMIN, SUPPORT]
 *     responses:
 *       201:
 *         description: Admin created successfully
 *       403:
 *         description: Access denied
 */
router.post('/admin/create', authenticate, authorizeSuperAdmin, validate(createAdminSchema), authController.createAdmin)

export default router
