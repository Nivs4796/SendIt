import { Request, Response, NextFunction } from 'express'
import * as addressService from '../services/address.service'
import { formatResponse } from '../utils/helpers'

export const createAddress = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const address = await addressService.createAddress({ ...req.body, userId: req.user!.id })
    res.status(201).json(formatResponse(true, 'Address created', { address }))
  } catch (error) {
    next(error)
  }
}

export const getAddresses = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const addresses = await addressService.getUserAddresses(req.user!.id)
    res.status(200).json(formatResponse(true, 'Addresses retrieved', { addresses }))
  } catch (error) {
    next(error)
  }
}

export const getAddress = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const address = await addressService.getAddressById(req.params.id as string, req.user!.id)
    res.status(200).json(formatResponse(true, 'Address retrieved', { address }))
  } catch (error) {
    next(error)
  }
}

export const updateAddress = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const address = await addressService.updateAddress(req.params.id as string, req.user!.id, req.body)
    res.status(200).json(formatResponse(true, 'Address updated', { address }))
  } catch (error) {
    next(error)
  }
}

export const deleteAddress = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    await addressService.deleteAddress(req.params.id as string, req.user!.id)
    res.status(200).json(formatResponse(true, 'Address deleted'))
  } catch (error) {
    next(error)
  }
}
