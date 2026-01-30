import prisma from '../config/database'
import { AppError } from '../middleware/errorHandler'
import { getPaginationParams } from '../utils/helpers'
import { WalletTxnType, WalletTxnStatus } from '@prisma/client'
import logger from '../config/logger'

interface AddMoneyInput {
  userId: string
  amount: number
  description?: string
  referenceId?: string
  referenceType?: string
}

interface DeductMoneyInput {
  userId: string
  amount: number
  description?: string
  referenceId?: string
  referenceType?: string
}

/**
 * Get user's wallet balance
 */
export const getWalletBalance = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { id: true, walletBalance: true },
  })

  if (!user) {
    throw new AppError('User not found', 404)
  }

  return user.walletBalance
}

/**
 * Add money to wallet
 */
export const addMoney = async (input: AddMoneyInput) => {
  const { userId, amount, description, referenceId, referenceType } = input

  if (amount <= 0) {
    throw new AppError('Amount must be positive', 400)
  }

  // Get current balance
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { walletBalance: true },
  })

  if (!user) {
    throw new AppError('User not found', 404)
  }

  const balanceBefore = user.walletBalance
  const balanceAfter = balanceBefore + amount

  // Update balance and create transaction in a transaction
  const [updatedUser, transaction] = await prisma.$transaction([
    prisma.user.update({
      where: { id: userId },
      data: { walletBalance: balanceAfter },
      select: { id: true, walletBalance: true },
    }),
    prisma.walletTransaction.create({
      data: {
        userId,
        type: 'CREDIT',
        amount,
        balanceBefore,
        balanceAfter,
        description: description || 'Added money to wallet',
        referenceId,
        referenceType,
        status: 'COMPLETED',
      },
    }),
  ])

  logger.info(`Wallet credit: User ${userId}, Amount: ₹${amount}, New Balance: ₹${balanceAfter}`)

  return {
    balance: updatedUser.walletBalance,
    transaction,
  }
}

/**
 * Deduct money from wallet
 */
export const deductMoney = async (input: DeductMoneyInput) => {
  const { userId, amount, description, referenceId, referenceType } = input

  if (amount <= 0) {
    throw new AppError('Amount must be positive', 400)
  }

  // Get current balance
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { walletBalance: true },
  })

  if (!user) {
    throw new AppError('User not found', 404)
  }

  if (user.walletBalance < amount) {
    throw new AppError('Insufficient wallet balance', 400)
  }

  const balanceBefore = user.walletBalance
  const balanceAfter = balanceBefore - amount

  // Update balance and create transaction
  const [updatedUser, transaction] = await prisma.$transaction([
    prisma.user.update({
      where: { id: userId },
      data: { walletBalance: balanceAfter },
      select: { id: true, walletBalance: true },
    }),
    prisma.walletTransaction.create({
      data: {
        userId,
        type: 'DEBIT',
        amount,
        balanceBefore,
        balanceAfter,
        description: description || 'Payment from wallet',
        referenceId,
        referenceType,
        status: 'COMPLETED',
      },
    }),
  ])

  logger.info(`Wallet debit: User ${userId}, Amount: ₹${amount}, New Balance: ₹${balanceAfter}`)

  return {
    balance: updatedUser.walletBalance,
    transaction,
  }
}

/**
 * Process wallet payment for booking
 */
export const processWalletPayment = async (
  userId: string,
  bookingId: string,
  amount: number
): Promise<{ success: boolean; paidAmount: number; remainingAmount: number }> => {
  const balance = await getWalletBalance(userId)

  if (balance <= 0) {
    return {
      success: false,
      paidAmount: 0,
      remainingAmount: amount,
    }
  }

  // Pay as much as possible from wallet
  const payableAmount = Math.min(balance, amount)
  const remainingAmount = amount - payableAmount

  await deductMoney({
    userId,
    amount: payableAmount,
    description: `Payment for booking`,
    referenceId: bookingId,
    referenceType: 'BOOKING',
  })

  return {
    success: true,
    paidAmount: payableAmount,
    remainingAmount,
  }
}

/**
 * Refund to wallet
 */
export const refundToWallet = async (
  userId: string,
  amount: number,
  bookingId?: string,
  reason?: string
) => {
  return await addMoney({
    userId,
    amount,
    description: reason || 'Refund to wallet',
    referenceId: bookingId,
    referenceType: 'REFUND',
  })
}

/**
 * Get wallet transaction history
 */
export const getTransactionHistory = async (
  userId: string,
  page: number = 1,
  limit: number = 10,
  type?: WalletTxnType
) => {
  const { skip, take } = getPaginationParams(page, limit)

  const where = {
    userId,
    ...(type && { type }),
  }

  const [transactions, total, stats] = await Promise.all([
    prisma.walletTransaction.findMany({
      where,
      skip,
      take,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.walletTransaction.count({ where }),
    prisma.walletTransaction.groupBy({
      by: ['type'],
      where: { userId, status: 'COMPLETED' },
      _sum: { amount: true },
    }),
  ])

  // Calculate total credits and debits
  const creditSum = stats.find((s) => s.type === 'CREDIT')?._sum.amount || 0
  const debitSum = stats.find((s) => s.type === 'DEBIT')?._sum.amount || 0

  return {
    transactions,
    summary: {
      totalCredits: creditSum,
      totalDebits: debitSum,
    },
    meta: {
      page,
      limit: take,
      total,
      totalPages: Math.ceil(total / take),
    },
  }
}

/**
 * Check if user has sufficient balance
 */
export const hasSufficientBalance = async (userId: string, amount: number): Promise<boolean> => {
  const balance = await getWalletBalance(userId)
  return balance >= amount
}

/**
 * Transfer between wallets (e.g., for referral rewards)
 */
export const transferBetweenWallets = async (
  fromUserId: string,
  toUserId: string,
  amount: number,
  description: string
) => {
  // Verify both users exist
  const [fromUser, toUser] = await Promise.all([
    prisma.user.findUnique({ where: { id: fromUserId } }),
    prisma.user.findUnique({ where: { id: toUserId } }),
  ])

  if (!fromUser || !toUser) {
    throw new AppError('User not found', 404)
  }

  if (fromUser.walletBalance < amount) {
    throw new AppError('Insufficient balance', 400)
  }

  // Execute transfer in transaction
  await prisma.$transaction([
    // Deduct from sender
    prisma.user.update({
      where: { id: fromUserId },
      data: { walletBalance: { decrement: amount } },
    }),
    prisma.walletTransaction.create({
      data: {
        userId: fromUserId,
        type: 'DEBIT',
        amount,
        balanceBefore: fromUser.walletBalance,
        balanceAfter: fromUser.walletBalance - amount,
        description: `Transfer to user: ${description}`,
        referenceId: toUserId,
        referenceType: 'TRANSFER',
        status: 'COMPLETED',
      },
    }),
    // Add to receiver
    prisma.user.update({
      where: { id: toUserId },
      data: { walletBalance: { increment: amount } },
    }),
    prisma.walletTransaction.create({
      data: {
        userId: toUserId,
        type: 'CREDIT',
        amount,
        balanceBefore: toUser.walletBalance,
        balanceAfter: toUser.walletBalance + amount,
        description: `Transfer received: ${description}`,
        referenceId: fromUserId,
        referenceType: 'TRANSFER',
        status: 'COMPLETED',
      },
    }),
  ])

  logger.info(`Wallet transfer: From ${fromUserId} to ${toUserId}, Amount: ₹${amount}`)

  return { success: true }
}

/**
 * Add bonus/reward to wallet (Admin function)
 */
export const addBonus = async (
  userId: string,
  amount: number,
  reason: string
) => {
  return await addMoney({
    userId,
    amount,
    description: `Bonus: ${reason}`,
    referenceType: 'BONUS',
  })
}
