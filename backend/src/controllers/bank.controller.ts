import { Request, Response, NextFunction } from 'express'
import * as bankService from '../services/bank.service'
import { formatResponse } from '../utils/helpers'

// Helper to extract string param
const getParamAsString = (param: string | string[] | undefined): string => {
  if (Array.isArray(param)) return param[0]
  return param || ''
}

/**
 * Get pilot's bank accounts
 */
export const getBankAccounts = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const accounts = await bankService.getPilotBankAccounts(pilotId)

    res.json(formatResponse(true, 'Bank accounts retrieved', { accounts }))
  } catch (error) {
    next(error)
  }
}

/**
 * Add a new bank account
 */
export const addBankAccount = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const { accountName, accountNumber, ifscCode, bankName, branchName } = req.body

    const account = await bankService.createBankAccount({
      pilotId,
      accountName,
      accountNumber,
      ifscCode,
      bankName,
      branchName,
    })

    res.status(201).json(formatResponse(true, 'Bank account added successfully', account))
  } catch (error) {
    next(error)
  }
}

/**
 * Delete a bank account
 */
export const deleteBankAccount = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const id = getParamAsString(req.params.id)

    await bankService.deleteBankAccount(id, pilotId)

    res.json(formatResponse(true, 'Bank account deleted successfully'))
  } catch (error) {
    next(error)
  }
}

/**
 * Set a bank account as primary
 */
export const setPrimaryAccount = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const pilotId = req.user!.id
    const id = getParamAsString(req.params.id)

    const account = await bankService.setPrimaryAccount(id, pilotId)

    res.json(formatResponse(true, 'Primary account updated', account))
  } catch (error) {
    next(error)
  }
}

/**
 * Lookup IFSC code
 */
export const lookupIFSC = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const ifsc = req.query.ifsc as string | undefined

    if (!ifsc) {
      res.status(400).json(formatResponse(false, 'IFSC code is required'))
      return
    }

    const result = await bankService.lookupIFSC(ifsc)

    if (!result) {
      res.status(404).json(formatResponse(false, 'IFSC code not found'))
      return
    }

    res.json(formatResponse(true, 'IFSC details retrieved', {
      ifsc: result.IFSC,
      bank: result.BANK,
      branch: result.BRANCH,
      address: result.ADDRESS,
      city: result.CITY,
      district: result.DISTRICT,
      state: result.STATE,
      upi: result.UPI,
      rtgs: result.RTGS,
      neft: result.NEFT,
      imps: result.IMPS,
    }))
  } catch (error) {
    next(error)
  }
}

/**
 * Validate bank account details
 */
export const validateBankDetails = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const accountNumber = req.body.accountNumber as string
    const ifscCode = req.body.ifscCode as string

    const result = await bankService.validateBankDetails(accountNumber, ifscCode)

    res.json(formatResponse(result.valid, result.message || 'Bank details valid', {
      valid: result.valid,
      bankDetails: result.bankDetails,
    }))
  } catch (error) {
    next(error)
  }
}
