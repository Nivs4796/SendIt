import Razorpay from 'razorpay'
import crypto from 'crypto'
import prisma from '../config/database'
import { AppError, NotFoundError } from '../middleware/errorHandler'
import logger from '../config/logger'

// Initialize Razorpay - use env vars in production
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || 'rzp_test_placeholder',
  key_secret: process.env.RAZORPAY_KEY_SECRET || 'placeholder_secret',
})

interface CreateOrderInput {
  userId: string
  bookingId: string
  amount: number
}

interface VerifyPaymentInput {
  userId: string
  orderId: string
  paymentId: string
  signature: string
  bookingId?: string
}

interface WalletTopupInput {
  userId: string
  amount: number
}

interface VerifyWalletInput {
  userId: string
  orderId: string
  paymentId: string
  signature: string
  amount: number
}

/**
 * Create Razorpay order for booking payment
 */
export const createRazorpayOrder = async (input: CreateOrderInput) => {
  const { userId, bookingId, amount } = input

  // Verify booking exists and belongs to user
  const booking = await prisma.booking.findFirst({
    where: { id: bookingId, userId },
  })

  if (!booking) {
    throw new NotFoundError('Booking')
  }

  if (booking.paymentStatus === 'COMPLETED') {
    throw new AppError('Booking is already paid', 400)
  }

  // Amount in paise (INR * 100)
  const amountInPaise = Math.round(amount * 100)

  try {
    const order = await razorpay.orders.create({
      amount: amountInPaise,
      currency: 'INR',
      receipt: `booking_${bookingId}`,
      notes: {
        bookingId,
        userId,
      },
    })

    logger.info(`Razorpay order created: ${order.id} for booking ${bookingId}`)

    return {
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
      bookingId,
    }
  } catch (error: any) {
    logger.error('Razorpay order creation failed:', error)
    throw new AppError('Failed to create payment order', 500)
  }
}

/**
 * Verify Razorpay payment signature
 */
export const verifyRazorpayPayment = async (input: VerifyPaymentInput) => {
  const { userId, orderId, paymentId, signature, bookingId } = input

  // Verify signature
  const body = orderId + '|' + paymentId
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || 'placeholder_secret')
    .update(body.toString())
    .digest('hex')

  const isValid = expectedSignature === signature

  if (!isValid) {
    logger.warn(`Invalid payment signature for order ${orderId}`)
    throw new AppError('Invalid payment signature', 400)
  }

  // Update booking payment status
  if (bookingId) {
    const booking = await prisma.booking.findFirst({
      where: { id: bookingId, userId },
    })

    if (booking) {
      await prisma.booking.update({
        where: { id: bookingId },
        data: {
          paymentStatus: 'COMPLETED',
          paymentMethod: 'UPI', // or CARD based on Razorpay response
        },
      })

      // Create payment record
      await prisma.payment.create({
        data: {
          bookingId,
          amount: booking.totalAmount,
          method: 'UPI',
          status: 'COMPLETED',
          transactionId: paymentId,
          gatewayResponse: { orderId, paymentId, signature },
          paidAt: new Date(),
        },
      })

      logger.info(`Payment verified for booking ${bookingId}: ${paymentId}`)
    }
  }

  return {
    verified: true,
    paymentId,
    orderId,
  }
}

/**
 * Create order for wallet topup
 */
export const createWalletTopupOrder = async (input: WalletTopupInput) => {
  const { userId, amount } = input

  if (amount < 10 || amount > 10000) {
    throw new AppError('Amount must be between ₹10 and ₹10,000', 400)
  }

  const amountInPaise = Math.round(amount * 100)

  try {
    const order = await razorpay.orders.create({
      amount: amountInPaise,
      currency: 'INR',
      receipt: `wallet_${userId}_${Date.now()}`,
      notes: {
        userId,
        type: 'WALLET_TOPUP',
        amount: amount.toString(),
      },
    })

    logger.info(`Wallet topup order created: ${order.id} for user ${userId}`)

    return {
      orderId: order.id,
      amount: order.amount,
      currency: order.currency,
    }
  } catch (error: any) {
    logger.error('Wallet topup order creation failed:', error)
    throw new AppError('Failed to create topup order', 500)
  }
}

/**
 * Verify wallet topup payment
 */
export const verifyWalletTopup = async (input: VerifyWalletInput) => {
  const { userId, orderId, paymentId, signature, amount } = input

  // Verify signature
  const body = orderId + '|' + paymentId
  const expectedSignature = crypto
    .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET || 'placeholder_secret')
    .update(body.toString())
    .digest('hex')

  const isValid = expectedSignature === signature

  if (!isValid) {
    logger.warn(`Invalid wallet topup signature for order ${orderId}`)
    throw new AppError('Invalid payment signature', 400)
  }

  // Get user's current balance
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { walletBalance: true },
  })

  if (!user) {
    throw new NotFoundError('User')
  }

  const balanceBefore = user.walletBalance
  const balanceAfter = balanceBefore + amount

  // Update wallet balance and create transaction
  await prisma.$transaction([
    prisma.user.update({
      where: { id: userId },
      data: { walletBalance: balanceAfter },
    }),
    prisma.walletTransaction.create({
      data: {
        userId,
        type: 'CREDIT',
        amount,
        balanceBefore,
        balanceAfter,
        description: 'Wallet top-up via Razorpay',
        referenceId: paymentId,
        referenceType: 'RAZORPAY_TOPUP',
        status: 'COMPLETED',
      },
    }),
  ])

  logger.info(`Wallet credited for user ${userId}: ₹${amount}`)

  return {
    verified: true,
    newBalance: balanceAfter,
    amount,
  }
}
