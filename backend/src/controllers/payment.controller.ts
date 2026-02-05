import { Request, Response, NextFunction } from 'express'
import * as paymentService from '../services/payment.service'
import { formatResponse } from '../utils/helpers'

/**
 * Create Razorpay order for booking payment
 */
export const createOrder = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { bookingId, amount } = req.body

    const order = await paymentService.createRazorpayOrder({
      userId,
      bookingId,
      amount,
    })

    res.json(formatResponse(true, 'Order created', order))
  } catch (error) {
    next(error)
  }
}

/**
 * Verify Razorpay payment
 */
export const verifyPayment = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { orderId, paymentId, signature, bookingId } = req.body

    const result = await paymentService.verifyRazorpayPayment({
      userId,
      orderId,
      paymentId,
      signature,
      bookingId,
    })

    res.json(formatResponse(true, 'Payment verified', result))
  } catch (error) {
    next(error)
  }
}

/**
 * Create order for wallet topup
 */
export const createWalletOrder = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { amount } = req.body

    const order = await paymentService.createWalletTopupOrder({
      userId,
      amount,
    })

    res.json(formatResponse(true, 'Order created for wallet topup', order))
  } catch (error) {
    next(error)
  }
}

/**
 * Verify wallet topup payment
 */
export const verifyWalletPayment = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const userId = req.user!.id
    const { orderId, paymentId, signature, amount } = req.body

    const result = await paymentService.verifyWalletTopup({
      userId,
      orderId,
      paymentId,
      signature,
      amount,
    })

    res.json(formatResponse(true, 'Wallet credited successfully', result))
  } catch (error) {
    next(error)
  }
}
