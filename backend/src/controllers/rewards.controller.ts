import { Request, Response, NextFunction } from 'express'
import * as rewardsService from '../services/rewards.service'
import { formatResponse } from '../utils/helpers'

// Helper to extract string param
const getParamAsString = (param: string | string[] | undefined): string => {
  if (Array.isArray(param)) return param[0]
  return param || ''
}

/**
 * Get referral info and code
 */
export const getReferralInfo = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id

    const info = await rewardsService.getReferralInfo(pilotId)

    res.json(formatResponse(true, 'Referral info retrieved', info))
  } catch (error) {
    next(error)
  }
}

/**
 * Get available rewards
 */
export const getAvailableRewards = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id

    const rewards = await rewardsService.getAvailableRewards(pilotId)

    res.json(formatResponse(true, 'Rewards retrieved', rewards))
  } catch (error) {
    next(error)
  }
}

/**
 * Claim a reward
 */
export const claimReward = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const id = getParamAsString(req.params.id)

    const result = await rewardsService.claimReward(id, pilotId)

    res.json(formatResponse(true, result.message, {
      amount: result.amount,
    }))
  } catch (error) {
    next(error)
  }
}

/**
 * Get pilot achievements
 */
export const getAchievements = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id

    const achievements = await rewardsService.getPilotAchievements(pilotId)

    res.json(formatResponse(true, 'Achievements retrieved', { achievements }))
  } catch (error) {
    next(error)
  }
}

/**
 * Apply referral code (during signup/onboarding)
 */
export const applyReferralCode = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { referralCode } = req.body

    const result = await rewardsService.applyReferralCode(referralCode, pilotId)

    if (!result.valid) {
      res.status(400).json(formatResponse(false, result.message))
      return
    }

    res.json(formatResponse(true, result.message))
  } catch (error) {
    next(error)
  }
}
