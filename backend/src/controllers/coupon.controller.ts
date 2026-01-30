import { Request, Response, NextFunction } from 'express'
import * as couponService from '../services/coupon.service'
import { formatResponse } from '../utils/helpers'

/**
 * Create a new coupon (Admin)
 */
export const createCoupon = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const coupon = await couponService.createCoupon(req.body)
    res.status(201).json(formatResponse(true, 'Coupon created successfully', { coupon }))
  } catch (error) {
    next(error)
  }
}

/**
 * Get coupon by ID (Admin)
 */
export const getCoupon = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const id = req.params.id as string
    const coupon = await couponService.getCouponById(id)
    res.json(formatResponse(true, 'Coupon retrieved', { coupon }))
  } catch (error) {
    next(error)
  }
}

/**
 * Update a coupon (Admin)
 */
export const updateCoupon = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const id = req.params.id as string
    const coupon = await couponService.updateCoupon(id, req.body)
    res.json(formatResponse(true, 'Coupon updated', { coupon }))
  } catch (error) {
    next(error)
  }
}

/**
 * Delete a coupon (Admin)
 */
export const deleteCoupon = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const id = req.params.id as string
    await couponService.deleteCoupon(id)
    res.json(formatResponse(true, 'Coupon deleted'))
  } catch (error) {
    next(error)
  }
}

/**
 * List all coupons (Admin)
 */
export const listCoupons = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { page = '1', limit = '10', active } = req.query
    const isActive = active === 'true' ? true : active === 'false' ? false : undefined

    const result = await couponService.listCoupons(
      parseInt(page as string),
      parseInt(limit as string),
      isActive
    )

    res.json(formatResponse(true, 'Coupons retrieved', { coupons: result.coupons }, result.meta))
  } catch (error) {
    next(error)
  }
}

/**
 * Validate a coupon code (User)
 */
export const validateCoupon = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { code, orderAmount, vehicleTypeId } = req.body

    const result = await couponService.validateCoupon(
      code,
      userId,
      orderAmount,
      vehicleTypeId
    )

    if (result.valid) {
      res.json(formatResponse(true, result.message, {
        coupon: {
          id: result.coupon!.id,
          code: result.coupon!.code,
          description: result.coupon!.description,
          discountType: result.coupon!.discountType,
          discountValue: result.coupon!.discountValue,
        },
        discount: result.discount,
      }))
    } else {
      res.status(400).json(formatResponse(false, result.message))
    }
  } catch (error) {
    next(error)
  }
}

/**
 * Get available coupons for user
 */
export const getAvailableCoupons = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { orderAmount, vehicleTypeId } = req.query

    const coupons = await couponService.getAvailableCoupons(
      userId,
      orderAmount ? parseFloat(orderAmount as string) : undefined,
      vehicleTypeId as string | undefined
    )

    res.json(formatResponse(true, 'Available coupons retrieved', { coupons }))
  } catch (error) {
    next(error)
  }
}

/**
 * Get user's coupon usage history
 */
export const getCouponHistory = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { page = '1', limit = '10' } = req.query

    const result = await couponService.getUserCouponHistory(
      userId,
      parseInt(page as string),
      parseInt(limit as string)
    )

    res.json(formatResponse(true, 'Coupon history retrieved', { usages: result.usages }, result.meta))
  } catch (error) {
    next(error)
  }
}
