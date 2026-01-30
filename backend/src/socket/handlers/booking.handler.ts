import prisma from '../../config/database'
import logger from '../../config/logger'
import type { AppServer, AppSocket } from '../index'
import { joinBookingRoom, leaveBookingRoom, leaveAllBookingRooms } from '../rooms'
import { RATE_LIMITS } from '../types'

// Track subscription rate limiting
const subscriptionCounts = new Map<string, { count: number; resetAt: number }>()

/**
 * Register booking-related socket event handlers
 */
export function registerBookingHandlers(io: AppServer, socket: AppSocket): void {
  const { user } = socket.data

  // Users and pilots can subscribe to bookings
  if (user.type !== 'user' && user.type !== 'pilot') {
    return
  }

  /**
   * Subscribe to a booking for real-time updates
   */
  socket.on('booking:subscribe', async ({ bookingId }) => {
    try {
      // Rate limiting check
      const now = Date.now()
      const rateKey = `${user.type}:${user.id}`
      const rateData = subscriptionCounts.get(rateKey) || { count: 0, resetAt: now + 60000 }

      if (now > rateData.resetAt) {
        rateData.count = 0
        rateData.resetAt = now + 60000
      }

      if (rateData.count >= RATE_LIMITS.SUBSCRIPTION_PER_MIN) {
        socket.emit('error', {
          code: 'ERR_1003',
          message: 'Too many subscription requests',
        })
        return
      }

      rateData.count++
      subscriptionCounts.set(rateKey, rateData)

      // Verify booking exists and user has access
      const booking = await prisma.booking.findUnique({
        where: { id: bookingId },
        select: {
          id: true,
          userId: true,
          pilotId: true,
          status: true,
        },
      })

      if (!booking) {
        socket.emit('error', {
          code: 'ERR_1302',
          message: 'Booking not found',
        })
        return
      }

      // Check authorization
      const isAuthorized =
        (user.type === 'user' && booking.userId === user.id) ||
        (user.type === 'pilot' && booking.pilotId === user.id)

      if (!isAuthorized) {
        socket.emit('error', {
          code: 'ERR_1201',
          message: 'Not authorized to view this booking',
        })
        return
      }

      // Check if booking is in a trackable status
      const trackableStatuses = [
        'ACCEPTED',
        'ARRIVED_PICKUP',
        'PICKED_UP',
        'IN_TRANSIT',
        'ARRIVED_DROP',
      ]

      if (!trackableStatuses.includes(booking.status)) {
        socket.emit('error', {
          code: 'ERR_1400',
          message: 'Booking is not in a trackable status',
        })
        return
      }

      // Join the booking room
      joinBookingRoom(socket, bookingId)

      logger.info(`${user.type}:${user.id} subscribed to booking ${bookingId}`)
    } catch (error) {
      logger.error('Error in booking:subscribe handler:', error)
      socket.emit('error', {
        code: 'ERR_1000',
        message: 'Failed to subscribe to booking',
      })
    }
  })

  /**
   * Unsubscribe from a booking
   */
  socket.on('booking:unsubscribe', ({ bookingId }) => {
    leaveBookingRoom(socket, bookingId)
    logger.info(`${user.type}:${user.id} unsubscribed from booking ${bookingId}`)
  })

  /**
   * Clean up on disconnect
   */
  socket.on('disconnect', () => {
    leaveAllBookingRooms(socket)
  })
}
