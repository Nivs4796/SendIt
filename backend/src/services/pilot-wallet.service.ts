import prisma from '../config/database'
import { AppError, NotFoundError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { EarningType, EarningStatus } from '@prisma/client'
import logger from '../config/logger'

// Business Rules
const MIN_WITHDRAWAL_AMOUNT = 100 // ₹100 minimum

interface WithdrawalInput {
  pilotId: string
  bankAccountId: string
  amount: number
}

/**
 * Get pilot's earnings balance
 */
export const getPilotBalance = async (pilotId: string) => {
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
    select: {
      id: true,
      totalEarnings: true,
      name: true,
    },
  })

  if (!pilot) {
    throw new NotFoundError('Pilot')
  }

  // Calculate available balance (total earnings - withdrawn amount)
  const withdrawnAmount = await prisma.withdrawalRequest.aggregate({
    where: {
      pilotId,
      status: { in: ['PENDING', 'APPROVED', 'COMPLETED'] },
    },
    _sum: { amount: true },
  })

  const pendingWithdrawals = await prisma.withdrawalRequest.aggregate({
    where: { pilotId, status: 'PENDING' },
    _sum: { amount: true },
  })

  const totalEarnings = pilot.totalEarnings
  const totalWithdrawn = withdrawnAmount._sum.amount || 0
  const pendingAmount = pendingWithdrawals._sum.amount || 0
  const availableBalance = totalEarnings - totalWithdrawn

  return {
    totalEarnings,
    totalWithdrawn,
    pendingWithdrawals: pendingAmount,
    availableBalance,
    minWithdrawal: MIN_WITHDRAWAL_AMOUNT,
  }
}

/**
 * Get pilot earnings/transactions history
 */
export const getPilotTransactions = async (
  pilotId: string,
  page: number = 1,
  limit: number = 10,
  type?: EarningType
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    pilotId,
    ...(type && { type }),
  }

  const [earnings, total, stats] = await Promise.all([
    prisma.earning.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.earning.count({ where }),
    prisma.earning.groupBy({
      by: ['type'],
      where: { pilotId, status: 'PAID' },
      _sum: { amount: true },
    }),
  ])

  // Get withdrawal history
  const withdrawals = await prisma.withdrawalRequest.findMany({
    where: { pilotId },
    orderBy: { createdAt: 'desc' },
    take: 5,
    select: {
      id: true,
      amount: true,
      status: true,
      createdAt: true,
      processedAt: true,
    },
  })

  const summary = {
    deliveryEarnings: stats.find((s) => s.type === 'DELIVERY')?._sum.amount || 0,
    bonusEarnings: stats.find((s) => s.type === 'BONUS')?._sum.amount || 0,
    incentiveEarnings: stats.find((s) => s.type === 'INCENTIVE')?._sum.amount || 0,
    referralEarnings: stats.find((s) => s.type === 'REFERRAL')?._sum.amount || 0,
  }

  return {
    earnings,
    withdrawals,
    summary,
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

/**
 * Create withdrawal request
 */
export const createWithdrawalRequest = async (input: WithdrawalInput) => {
  const { pilotId, bankAccountId, amount } = input

  // Validate minimum amount
  if (amount < MIN_WITHDRAWAL_AMOUNT) {
    throw new AppError(
      `Minimum withdrawal amount is ₹${MIN_WITHDRAWAL_AMOUNT}`,
      400
    )
  }

  // Check available balance
  const balance = await getPilotBalance(pilotId)
  if (amount > balance.availableBalance) {
    throw new AppError('Insufficient balance for withdrawal', 400)
  }

  // Verify bank account exists and belongs to pilot
  const bankAccount = await prisma.bankAccount.findFirst({
    where: { id: bankAccountId, pilotId },
  })

  if (!bankAccount) {
    throw new AppError('Bank account not found', 404)
  }

  // Check for pending withdrawal
  const pendingRequest = await prisma.withdrawalRequest.findFirst({
    where: { pilotId, status: 'PENDING' },
  })

  if (pendingRequest) {
    throw new AppError('You already have a pending withdrawal request', 400)
  }

  // Create withdrawal request
  const withdrawal = await prisma.withdrawalRequest.create({
    data: {
      pilotId,
      bankAccountId,
      amount,
      status: 'PENDING',
    },
  })

  logger.info(
    `Withdrawal request created: Pilot ${pilotId}, Amount: ₹${amount}`
  )

  return {
    withdrawal,
    message: 'Withdrawal request submitted for approval',
    note: 'Withdrawals are processed within 2-3 business days after approval',
  }
}

/**
 * Get withdrawal requests for a pilot
 */
export const getWithdrawalHistory = async (
  pilotId: string,
  page: number = 1,
  limit: number = 10
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const [requests, total] = await Promise.all([
    prisma.withdrawalRequest.findMany({
      where: { pilotId },
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.withdrawalRequest.count({ where: { pilotId } }),
  ])

  return {
    requests,
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

/**
 * Cancel a pending withdrawal request
 */
export const cancelWithdrawalRequest = async (
  withdrawalId: string,
  pilotId: string
) => {
  const withdrawal = await prisma.withdrawalRequest.findFirst({
    where: { id: withdrawalId, pilotId },
  })

  if (!withdrawal) {
    throw new NotFoundError('Withdrawal request')
  }

  if (withdrawal.status !== 'PENDING') {
    throw new AppError('Only pending requests can be cancelled', 400)
  }

  await prisma.withdrawalRequest.update({
    where: { id: withdrawalId },
    data: { status: 'CANCELLED' },
  })

  logger.info(`Withdrawal cancelled: Pilot ${pilotId}, ID: ${withdrawalId}`)
  return { success: true, message: 'Withdrawal request cancelled' }
}
