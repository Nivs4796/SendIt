import { Request, Response, NextFunction } from 'express'
import * as pilotWalletService from '../services/pilot-wallet.service'
import { formatResponse } from '../utils/helpers'

// Helper to extract string param
const getParamAsString = (param: string | string[] | undefined): string => {
  if (Array.isArray(param)) return param[0]
  return param || ''
}

/**
 * Get pilot earnings balance
 */
export const getPilotBalance = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const balance = await pilotWalletService.getPilotBalance(pilotId)

    res.json(formatResponse(true, 'Balance retrieved', balance))
  } catch (error) {
    next(error)
  }
}

/**
 * Get pilot transactions/earnings history
 */
export const getPilotTransactions = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { page = '1', limit = '10', type } = req.query

    const result = await pilotWalletService.getPilotTransactions(
      pilotId,
      parseInt(page as string),
      parseInt(limit as string),
      type as any
    )

    res.json(formatResponse(true, 'Transactions retrieved', {
      earnings: result.earnings,
      withdrawals: result.withdrawals,
      summary: result.summary,
    }, result.meta))
  } catch (error) {
    next(error)
  }
}

/**
 * Create withdrawal request
 */
export const createWithdrawal = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { bankAccountId, amount } = req.body

    const result = await pilotWalletService.createWithdrawalRequest({
      pilotId,
      bankAccountId,
      amount,
    })

    res.status(201).json(formatResponse(true, result.message, {
      withdrawal: result.withdrawal,
      note: result.note,
    }))
  } catch (error) {
    next(error)
  }
}

/**
 * Get withdrawal history
 */
export const getWithdrawalHistory = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { page = '1', limit = '10' } = req.query

    const result = await pilotWalletService.getWithdrawalHistory(
      pilotId,
      parseInt(page as string),
      parseInt(limit as string)
    )

    res.json(formatResponse(true, 'Withdrawal history retrieved', result.requests, result.meta))
  } catch (error) {
    next(error)
  }
}

/**
 * Cancel a pending withdrawal
 */
export const cancelWithdrawal = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const id = getParamAsString(req.params.id)

    const result = await pilotWalletService.cancelWithdrawalRequest(id, pilotId)

    res.json(formatResponse(true, result.message))
  } catch (error) {
    next(error)
  }
}
