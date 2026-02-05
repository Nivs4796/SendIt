import { Router } from 'express'
import * as rewardsController from '../controllers/rewards.controller'
import { authenticate, authorizePilot } from '../middleware/auth'
import { validate } from '../validators'
import { achievementIdParamSchema, applyReferralSchema } from '../validators/rewards.validator'

const router = Router()

/**
 * @swagger
 * /pilots/referral:
 *   get:
 *     summary: Get referral code and stats
 *     tags: [Rewards]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Referral information
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 referralCode:
 *                   type: string
 *                 shareMessage:
 *                   type: string
 *                 stats:
 *                   type: object
 *                   properties:
 *                     totalReferrals:
 *                       type: integer
 *                     completedReferrals:
 *                       type: integer
 *                     pendingReferrals:
 *                       type: integer
 *                     totalEarnings:
 *                       type: number
 *                 terms:
 *                   type: array
 *                   items:
 *                     type: string
 */
router.get(
  '/referral',
  authenticate,
  authorizePilot,
  rewardsController.getReferralInfo
)

/**
 * @swagger
 * /pilots/referral/apply:
 *   post:
 *     summary: Apply a referral code
 *     tags: [Rewards]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - referralCode
 *             properties:
 *               referralCode:
 *                 type: string
 *     responses:
 *       200:
 *         description: Referral code applied
 *       400:
 *         description: Invalid or already used
 */
router.post(
  '/referral/apply',
  authenticate,
  authorizePilot,
  validate(applyReferralSchema),
  rewardsController.applyReferralCode
)

/**
 * @swagger
 * /pilots/rewards:
 *   get:
 *     summary: Get available rewards
 *     tags: [Rewards]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Available rewards
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 claimable:
 *                   type: array
 *                   description: Rewards ready to claim
 *                 claimed:
 *                   type: array
 *                   description: Already claimed rewards
 *                 locked:
 *                   type: array
 *                   description: Not yet earned
 *                 totalRewardsAvailable:
 *                   type: number
 */
router.get(
  '/rewards',
  authenticate,
  authorizePilot,
  rewardsController.getAvailableRewards
)

/**
 * @swagger
 * /pilots/rewards/{id}/claim:
 *   post:
 *     summary: Claim a reward
 *     tags: [Rewards]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Achievement ID
 *     responses:
 *       200:
 *         description: Reward claimed
 *       400:
 *         description: Not earned or already claimed
 */
router.post(
  '/rewards/:id/claim',
  authenticate,
  authorizePilot,
  validate(achievementIdParamSchema),
  rewardsController.claimReward
)

/**
 * @swagger
 * /pilots/achievements:
 *   get:
 *     summary: Get pilot's earned achievements
 *     tags: [Rewards]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Achievements list
 */
router.get(
  '/achievements',
  authenticate,
  authorizePilot,
  rewardsController.getAchievements
)

export default router
