import prisma from '../../config/database'
import logger from '../../config/logger'
import type { AppServer, AppSocket } from '../index'
import { joinAdminRoom, leaveAdminRoom } from '../rooms'
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
