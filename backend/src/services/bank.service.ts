import prisma from '../config/database'
import { AppError, NotFoundError } from '../middleware/errorHandler'
import logger from '../config/logger'
import axios from 'axios'

interface CreateBankAccountInput {
  pilotId: string
  accountName: string
  accountNumber: string
  ifscCode: string
  bankName: string
  branchName?: string
}

interface IFSCResponse {
  BANK: string
  BRANCH: string
  ADDRESS: string
  CITY: string
  DISTRICT: string
  STATE: string
  IFSC: string
  MICR?: string
  UPI?: boolean
  RTGS?: boolean
  NEFT?: boolean
  IMPS?: boolean
}

/**
 * Get all bank accounts for a pilot
 */
export const getPilotBankAccounts = async (pilotId: string) => {
  const accounts = await prisma.bankAccount.findMany({
    where: { pilotId },
    orderBy: [{ isPrimary: 'desc' }, { createdAt: 'desc' }],
  })

  return accounts
}

/**
 * Get a specific bank account
 */
export const getBankAccountById = async (accountId: string, pilotId: string) => {
  const account = await prisma.bankAccount.findFirst({
    where: { id: accountId, pilotId },
  })

  if (!account) {
    throw new NotFoundError('Bank account')
  }

  return account
}

/**
 * Get primary bank account for a pilot
 */
export const getPrimaryBankAccount = async (pilotId: string) => {
  const account = await prisma.bankAccount.findFirst({
    where: { pilotId, isPrimary: true },
  })

  return account
}

/**
 * Add a new bank account
 */
export const createBankAccount = async (input: CreateBankAccountInput) => {
  const { pilotId, accountName, accountNumber, ifscCode, bankName, branchName } = input

  // Check if this is the first account (make it primary)
  const existingAccounts = await prisma.bankAccount.count({
    where: { pilotId },
  })

  const isPrimary = existingAccounts === 0

  // Check for duplicate account number for this pilot
  const duplicateAccount = await prisma.bankAccount.findFirst({
    where: { pilotId, accountNumber },
  })

  if (duplicateAccount) {
    throw new AppError('This account number is already added', 400)
  }

  const account = await prisma.bankAccount.create({
    data: {
      pilotId,
      accountName,
      accountNumber,
      ifscCode: ifscCode.toUpperCase(),
      bankName,
      branchName,
      isPrimary,
    },
  })

  logger.info(`Bank account added: Pilot ${pilotId}, Account: ${accountNumber.slice(-4)}`)
  return account
}

/**
 * Delete a bank account
 */
export const deleteBankAccount = async (accountId: string, pilotId: string) => {
  const account = await getBankAccountById(accountId, pilotId)

  // Check if there are pending withdrawals for this account
  const pendingWithdrawals = await prisma.withdrawalRequest.count({
    where: { bankAccountId: accountId, status: 'PENDING' },
  })

  if (pendingWithdrawals > 0) {
    throw new AppError('Cannot delete account with pending withdrawals', 400)
  }

  // If this was primary, make another account primary
  if (account.isPrimary) {
    const otherAccount = await prisma.bankAccount.findFirst({
      where: { pilotId, id: { not: accountId } },
    })

    if (otherAccount) {
      await prisma.bankAccount.update({
        where: { id: otherAccount.id },
        data: { isPrimary: true },
      })
    }
  }

  await prisma.bankAccount.delete({
    where: { id: accountId },
  })

  logger.info(`Bank account deleted: Pilot ${pilotId}, Account ID: ${accountId}`)
  return { success: true }
}

/**
 * Set a bank account as primary
 */
export const setPrimaryAccount = async (accountId: string, pilotId: string) => {
  // Verify account exists and belongs to pilot
  await getBankAccountById(accountId, pilotId)

  // Transaction to update primary status
  await prisma.$transaction([
    // Remove primary from all accounts
    prisma.bankAccount.updateMany({
      where: { pilotId },
      data: { isPrimary: false },
    }),
    // Set new primary
    prisma.bankAccount.update({
      where: { id: accountId },
      data: { isPrimary: true },
    }),
  ])

  const updatedAccount = await getBankAccountById(accountId, pilotId)
  logger.info(`Primary bank account changed: Pilot ${pilotId}, Account ID: ${accountId}`)

  return updatedAccount
}

/**
 * Lookup IFSC code using Razorpay API
 */
export const lookupIFSC = async (ifscCode: string): Promise<IFSCResponse | null> => {
  try {
    const response = await axios.get<IFSCResponse>(
      `https://ifsc.razorpay.com/${ifscCode.toUpperCase()}`,
      { timeout: 5000 }
    )

    return response.data
  } catch (error: unknown) {
    if (axios.isAxiosError(error) && error.response?.status === 404) {
      return null
    }
    logger.error(`IFSC lookup failed: ${String(error)}`)
    throw new AppError('IFSC lookup service unavailable', 503)
  }
}

/**
 * Validate bank account details (basic validation)
 */
export const validateBankDetails = async (
  accountNumber: string,
  ifscCode: string
): Promise<{ valid: boolean; message?: string; bankDetails?: IFSCResponse }> => {
  // Basic account number validation (Indian bank accounts are typically 9-18 digits)
  if (!/^\d{9,18}$/.test(accountNumber)) {
    return { valid: false, message: 'Invalid account number format' }
  }

  // IFSC validation
  if (!/^[A-Z]{4}0[A-Z0-9]{6}$/.test(ifscCode.toUpperCase())) {
    return { valid: false, message: 'Invalid IFSC code format' }
  }

  // Lookup IFSC
  const bankDetails = await lookupIFSC(ifscCode)
  if (!bankDetails) {
    return { valid: false, message: 'IFSC code not found' }
  }

  return { valid: true, bankDetails }
}
