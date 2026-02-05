import prisma from '../config/database'
import { AppError, NotFoundError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import logger from '../config/logger'
import crypto from 'crypto'

/**
 * Generate a unique referral code
 */
const generateReferralCode = (pilotId: string): string => {
  const prefix = 'SI'
  const hash = crypto
    .createHash('sha256')
    .update(pilotId + Date.now())
    .digest('hex')
    .substring(0, 6)
    .toUpperCase()
  return `${prefix}${hash}`
}

/**
 * Get or create referral code for a pilot
 */
export const getReferralInfo = async (pilotId: string) => {
  // Get pilot info
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
    select: { id: true, name: true },
  })

  if (!pilot) {
    throw new NotFoundError('Pilot')
  }

  // Find existing referral code or create new one
  let referral = await prisma.referral.findFirst({
    where: { referrerId: pilotId },
  })

  if (!referral) {
    // Create new referral entry for this pilot
    referral = await prisma.referral.create({
      data: {
        referrerId: pilotId,
        referralCode: generateReferralCode(pilotId),
        status: 'ACTIVE',
      },
    })
  }

  // Get referral stats
  const [totalReferrals, completedReferrals, totalEarnings] = await Promise.all([
    prisma.referral.count({
      where: { referrerId: pilotId, referredId: { not: null } },
    }),
    prisma.referral.count({
      where: { referrerId: pilotId, status: 'COMPLETED' },
    }),
    prisma.referral.aggregate({
      where: { referrerId: pilotId, status: 'COMPLETED' },
      _sum: { bonusAmount: true },
    }),
  ])

  return {
    referralCode: referral.referralCode,
    shareMessage: `Join SendIt as a delivery pilot and earn great rewards! Use my referral code: ${referral.referralCode}`,
    stats: {
      totalReferrals,
      completedReferrals,
      pendingReferrals: totalReferrals - completedReferrals,
      totalEarnings: totalEarnings._sum.bonusAmount || 0,
    },
    terms: [
      'Both you and your friend get ₹100 bonus after their first delivery',
      'Your friend must complete KYC verification',
      'Bonus is credited within 24 hours of first delivery',
    ],
  }
}

/**
 * Validate and apply referral code during signup
 */
export const applyReferralCode = async (
  referralCode: string,
  newPilotId: string
): Promise<{ valid: boolean; message: string }> => {
  const referral = await prisma.referral.findUnique({
    where: { referralCode: referralCode.toUpperCase() },
  })

  if (!referral) {
    return { valid: false, message: 'Invalid referral code' }
  }

  // Can't refer yourself
  if (referral.referrerId === newPilotId) {
    return { valid: false, message: 'Cannot use your own referral code' }
  }

  // Check if already referred
  const existingReferral = await prisma.referral.findFirst({
    where: { referredId: newPilotId },
  })

  if (existingReferral) {
    return { valid: false, message: 'You have already used a referral code' }
  }

  // Create referral record for the new pilot
  await prisma.referral.create({
    data: {
      referrerId: referral.referrerId,
      referredId: newPilotId,
      referralCode: generateReferralCode(newPilotId), // New code for the new pilot
      status: 'PENDING',
    },
  })

  logger.info(`Referral code applied: ${referralCode} for pilot ${newPilotId}`)
  return { valid: true, message: 'Referral code applied successfully' }
}

/**
 * Complete referral after first delivery (called internally)
 */
export const completeReferral = async (pilotId: string) => {
  const referral = await prisma.referral.findFirst({
    where: { referredId: pilotId, status: 'PENDING' },
  })

  if (!referral) {
    return null
  }

  const bonusAmount = 100 // ₹100 bonus

  // Update referral status
  await prisma.referral.update({
    where: { id: referral.id },
    data: {
      status: 'COMPLETED',
      bonusAmount,
      completedAt: new Date(),
    },
  })

  // Credit bonus to both pilots
  await prisma.$transaction([
    // Referrer bonus
    prisma.earning.create({
      data: {
        pilotId: referral.referrerId,
        amount: bonusAmount,
        type: 'REFERRAL',
        description: 'Referral bonus',
        status: 'PAID',
      },
    }),
    prisma.pilot.update({
      where: { id: referral.referrerId },
      data: { totalEarnings: { increment: bonusAmount } },
    }),
    // Referred pilot bonus
    prisma.earning.create({
      data: {
        pilotId: pilotId,
        amount: bonusAmount,
        type: 'REFERRAL',
        description: 'Welcome bonus (referral)',
        status: 'PAID',
      },
    }),
    prisma.pilot.update({
      where: { id: pilotId },
      data: { totalEarnings: { increment: bonusAmount } },
    }),
  ])

  logger.info(`Referral completed: ${referral.referrerId} -> ${pilotId}, Bonus: ₹${bonusAmount}`)
  return { success: true, bonus: bonusAmount }
}

/**
 * Get available rewards/achievements
 */
export const getAvailableRewards = async (pilotId: string) => {
  // Get all active achievements
  const achievements = await prisma.achievement.findMany({
    where: { isActive: true },
    orderBy: { rewardAmount: 'desc' },
  })

  // Get pilot's earned achievements
  const earnedAchievements = await prisma.pilotAchievement.findMany({
    where: { pilotId },
    select: { achievementId: true, claimed: true },
  })

  const earnedIds = new Set(earnedAchievements.map((a) => a.achievementId))
  const claimedIds = new Set(
    earnedAchievements.filter((a) => a.claimed).map((a) => a.achievementId)
  )

  // Categorize achievements
  const available = achievements
    .filter((a) => earnedIds.has(a.id) && !claimedIds.has(a.id))
    .map((a) => ({ ...a, status: 'CLAIMABLE' }))

  const earned = achievements
    .filter((a) => claimedIds.has(a.id))
    .map((a) => ({ ...a, status: 'CLAIMED' }))

  const locked = achievements
    .filter((a) => !earnedIds.has(a.id))
    .map((a) => ({ ...a, status: 'LOCKED' }))

  return {
    claimable: available,
    claimed: earned,
    locked,
    totalRewardsAvailable: available.reduce((sum, a) => sum + a.rewardAmount, 0),
  }
}

/**
 * Claim a reward
 */
export const claimReward = async (achievementId: string, pilotId: string) => {
  // Check if pilot has earned this achievement
  const pilotAchievement = await prisma.pilotAchievement.findUnique({
    where: { pilotId_achievementId: { pilotId, achievementId } },
  })

  if (!pilotAchievement) {
    throw new AppError('You have not earned this achievement', 400)
  }

  if (pilotAchievement.claimed) {
    throw new AppError('Reward already claimed', 400)
  }

  // Get achievement details
  const achievement = await prisma.achievement.findUnique({
    where: { id: achievementId },
  })

  if (!achievement || !achievement.isActive) {
    throw new NotFoundError('Achievement')
  }

  // Claim reward
  await prisma.$transaction([
    prisma.pilotAchievement.update({
      where: { id: pilotAchievement.id },
      data: { claimed: true, claimedAt: new Date() },
    }),
    prisma.earning.create({
      data: {
        pilotId,
        amount: achievement.rewardAmount,
        type: 'BONUS',
        description: `Achievement: ${achievement.name}`,
        status: 'PAID',
      },
    }),
    prisma.pilot.update({
      where: { id: pilotId },
      data: { totalEarnings: { increment: achievement.rewardAmount } },
    }),
  ])

  logger.info(`Reward claimed: Pilot ${pilotId}, Achievement: ${achievement.name}, Amount: ₹${achievement.rewardAmount}`)

  return {
    success: true,
    amount: achievement.rewardAmount,
    message: `₹${achievement.rewardAmount} has been credited to your earnings!`,
  }
}

/**
 * Get pilot achievements
 */
export const getPilotAchievements = async (pilotId: string) => {
  const pilotAchievements = await prisma.pilotAchievement.findMany({
    where: { pilotId },
    orderBy: { earnedAt: 'desc' },
  })

  const achievementIds = pilotAchievements.map((pa) => pa.achievementId)

  const achievements = await prisma.achievement.findMany({
    where: { id: { in: achievementIds } },
  })

  const achievementMap = new Map(achievements.map((a) => [a.id, a]))

  const result = pilotAchievements.map((pa) => ({
    ...pa,
    achievement: achievementMap.get(pa.achievementId),
  }))

  return result
}

/**
 * Check and award achievements (called internally after events)
 */
export const checkAndAwardAchievements = async (pilotId: string) => {
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
    select: { totalDeliveries: true, rating: true, totalEarnings: true },
  })

  if (!pilot) return

  const achievements = await prisma.achievement.findMany({
    where: { isActive: true },
  })

  const earnedAchievementIds = new Set(
    (
      await prisma.pilotAchievement.findMany({
        where: { pilotId },
        select: { achievementId: true },
      })
    ).map((pa) => pa.achievementId)
  )

  const newAchievements: string[] = []

  for (const achievement of achievements) {
    if (earnedAchievementIds.has(achievement.id)) continue

    const req = achievement.requirement as Record<string, number> | null
    if (!req) continue

    let earned = false

    // Check various achievement conditions
    if (req.deliveries && pilot.totalDeliveries >= req.deliveries) {
      earned = true
    }
    if (req.rating && pilot.rating >= req.rating) {
      earned = true
    }
    if (req.earnings && pilot.totalEarnings >= req.earnings) {
      earned = true
    }

    if (earned) {
      await prisma.pilotAchievement.create({
        data: { pilotId, achievementId: achievement.id },
      })
      newAchievements.push(achievement.name)
    }
  }

  if (newAchievements.length > 0) {
    logger.info(`New achievements for pilot ${pilotId}: ${newAchievements.join(', ')}`)
  }

  return newAchievements
}
