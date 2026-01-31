import prisma from '../../config/database'
import logger from '../../config/logger'
import type { AppServer, AppSocket } from '../index'
import { joinAdminRoom, leaveAdminRoom, joinBookingRoom, leaveBookingRoom } from '../rooms'
import { DashboardStatsPayload } from '../types'

/**
 * Register admin-specific socket event handlers
 */
export function registerAdminHandlers(io: AppServer, socket: AppSocket): void {
  const { user } = socket.data

  // Only register for admin users
  if (user.type !== 'admin') {
    return
  }

  /**
   * Subscribe to admin dashboard for live stats
   */
  socket.on('admin:subscribe', async () => {
    try {
      joinAdminRoom(socket)

      // Send initial stats
      const stats = await getDashboardStats()
      socket.emit('dashboard:stats', stats)

      logger.info(`Admin ${user.id} subscribed to dashboard`)
    } catch (error) {
      logger.error('Error in admin:subscribe handler:', error)
      socket.emit('error', {
        code: 'ERR_1000',
        message: 'Failed to subscribe to dashboard',
      })
    }
  })

  /**
   * Unsubscribe from admin dashboard
   */
  socket.on('admin:unsubscribe', () => {
    leaveAdminRoom(socket)
    logger.info(`Admin ${user.id} unsubscribed from dashboard`)
  })

  /**
   * Subscribe to a specific booking for live tracking
   */
  socket.on('admin:booking:subscribe', async ({ bookingId }) => {
    try {
      // Verify booking exists
      const booking = await prisma.booking.findUnique({
        where: { id: bookingId },
        select: {
          id: true,
          status: true,
          pilotId: true,
          pilot: {
            select: {
              currentLat: true,
              currentLng: true,
            },
          },
        },
      })

      if (!booking) {
        socket.emit('error', {
          code: 'ERR_1302',
          message: 'Booking not found',
        })
        return
      }

      // Join the booking room
      joinBookingRoom(socket, bookingId)

      // If pilot has location, send it immediately
      if (booking.pilot?.currentLat && booking.pilot?.currentLng) {
        socket.emit('booking:location', {
          bookingId,
          lat: booking.pilot.currentLat,
          lng: booking.pilot.currentLng,
          timestamp: new Date().toISOString(),
        })
      }

      logger.info(`Admin ${user.id} subscribed to booking ${bookingId}`)
    } catch (error) {
      logger.error('Error in admin:booking:subscribe handler:', error)
      socket.emit('error', {
        code: 'ERR_1000',
        message: 'Failed to subscribe to booking',
      })
    }
  })

  /**
   * Unsubscribe from a specific booking
   */
  socket.on('admin:booking:unsubscribe', ({ bookingId }) => {
    leaveBookingRoom(socket, bookingId)
    logger.info(`Admin ${user.id} unsubscribed from booking ${bookingId}`)
  })

  /**
   * Clean up on disconnect
   */
  socket.on('disconnect', () => {
    leaveAdminRoom(socket)
  })
}

/**
 * Get current dashboard statistics
 */
export async function getDashboardStats(): Promise<DashboardStatsPayload> {
  const today = new Date()
  today.setHours(0, 0, 0, 0)

  const [activeBookings, onlinePilots, pendingBookings, todayStats] = await Promise.all([
    prisma.booking.count({
      where: {
        status: { in: ['ACCEPTED', 'ARRIVED_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_DROP'] },
      },
    }),
    prisma.pilot.count({ where: { isOnline: true } }),
    prisma.booking.count({ where: { status: 'PENDING' } }),
    prisma.booking.aggregate({
      where: {
        createdAt: { gte: today },
        status: 'DELIVERED',
      },
      _count: true,
      _sum: { totalAmount: true },
    }),
  ])

  return {
    activeBookings,
    onlinePilots,
    pendingBookings,
    todayDeliveries: todayStats._count,
    todayRevenue: todayStats._sum.totalAmount || 0,
    timestamp: new Date().toISOString(),
  }
}
