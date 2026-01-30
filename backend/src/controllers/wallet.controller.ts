import { Request, Response, NextFunction } from 'express'
import * as walletService from '../services/wallet.service'
import { formatResponse } from '../utils/helpers'

/**
 * Get wallet balance
 */
export const getBalance = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const balance = await walletService.getWalletBalance(userId)

    res.json(formatResponse(true, 'Wallet balance retrieved', { balance }))
  } catch (error) {
    next(error)
  }
}

/**
 * Add money to wallet (simulated - in production would integrate with payment gateway)
 */
export const addMoney = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { amount } = req.body

    // In production, this would be called after payment gateway confirmation
    const result = await walletService.addMoney({
      userId,
      amount,
      description: 'Added via app',
      referenceType: 'TOPUP',
    })

    res.json(formatResponse(true, 'Money added to wallet', {
      balance: result.balance,
      transaction: result.transaction,
    }))
  } catch (error) {
    next(error)
  }
}

/**
 * Get transaction history
 */
export const getTransactions = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { page = '1', limit = '10', type } = req.query

    const result = await walletService.getTransactionHistory(
      userId,
      parseInt(page as string),
      parseInt(limit as string),
      type as 'CREDIT' | 'DEBIT' | undefined
    )

    res.json(formatResponse(true, 'Transactions retrieved', {
      transactions: result.transactions,
      summary: result.summary,
    }, result.meta))
  } catch (error) {
    next(error)
  }
}

/**
 * Check wallet balance for payment
 */
export const checkBalance = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { amount } = req.body

    const hasSufficient = await walletService.hasSufficientBalance(userId, amount)
    const balance = await walletService.getWalletBalance(userId)

    res.json(formatResponse(true, 'Balance check complete', {
      hasSufficientBalance: hasSufficient,
      currentBalance: balance,
      requiredAmount: amount,
      shortfall: hasSufficient ? 0 : amount - balance,
    }))
  } catch (error) {
    next(error)
  }
}

// ============================================
// ADMIN ROUTES
// ============================================

/**
 * Add bonus to user wallet (Admin)
 */
export const addBonus = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { userId, amount, reason } = req.body

    const result = await walletService.addBonus(userId, amount, reason)

    res.json(formatResponse(true, 'Bonus added to wallet', {
      balance: result.balance,
      transaction: result.transaction,
    }))
  } catch (error) {
    next(error)
  }
}

/**
 * Refund to user wallet (Admin)
 */
export const refundToWallet = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { userId, amount, bookingId, reason } = req.body

    const result = await walletService.refundToWallet(userId, amount, bookingId, reason)

    res.json(formatResponse(true, 'Refund added to wallet', {
      balance: result.balance,
      transaction: result.transaction,
    }))
  } catch (error) {
    next(error)
  }
}

/**
 * Get user wallet details (Admin)
 */
export const getUserWallet = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { userId } = req.params
    const { page = '1', limit = '10' } = req.query

    const [balance, history] = await Promise.all([
      walletService.getWalletBalance(userId),
      walletService.getTransactionHistory(
        userId,
        parseInt(page as string),
        parseInt(limit as string)
      ),
    ])

    res.json(formatResponse(true, 'User wallet retrieved', {
      balance,
      transactions: history.transactions,
      summary: history.summary,
    }, history.meta))
  } catch (error) {
    next(error)
  }
}
