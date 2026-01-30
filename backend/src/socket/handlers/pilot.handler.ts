import prisma from '../../config/database'
import logger from '../../config/logger'
import type { AppServer, AppSocket } from '../index'
import { emitToBooking } from '../index'
import { RoomNames, RATE_LIMITS, LocationData, LocationUpdatePayload } from '../types'
import { joinBookingRoom, leaveAllBookingRooms } from '../rooms'

// Track pilot disconnect timeouts for grace period
const disconnectTimeouts = new Map<string, NodeJS.Timeout>()

/**
 * Register pilot-specific socket event handlers
 */
export function registerPilotHandlers(io: AppServer, socket: AppSocket): void {
  const { user } = socket.data

  // Only register for pilot users
  if (user.type !== 'pilot') {
    return
  }

  /**
   * Pilot goes online for deliveries
   */
  socket.on('pilot:online', async ({ vehicleId }) => {
    try {
      // Clear any pending disconnect timeout
      const existingTimeout = disconnectTimeouts.get(user.id)
      if (existingTimeout) {
        clearTimeout(existingTimeout)
        disconnectTimeouts.delete(user.id)
      }

      // Verify vehicle belongs to pilot
      const vehicle = await prisma.vehicle.findFirst({
        where: {
          id: vehicleId,
          pilotId: user.id,
          isActive: true,
        },
      })

      if (!vehicle) {
        socket.emit('error', {
          code: 'ERR_1302',
          message: 'Vehicle not found or not active',
        })
        return
      }

      // Update pilot status
      await prisma.pilot.update({
        where: { id: user.id },
        data: {
          isOnline: true,
          lastLocationAt: new Date(),
        },
      })

      logger.info(`Pilot ${user.id} is now online with vehicle ${vehicleId}`)

      // Check for active bookings and auto-join their rooms
      const activeBookings = await prisma.booking.findMany({
        where: {
          pilotId: user.id,
          status: {
            in: ['ACCEPTED', 'ARRIVED_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_DROP'],
          },
        },
        select: { id: true },
      })

      activeBookings.forEach((booking) => {
        joinBookingRoom(socket, booking.id)
      })
    } catch (error) {
      logger.error('Error in pilot:online handler:', error)
      socket.emit('error', {
        code: 'ERR_1000',
        message: 'Failed to go online',
      })
    }
  })

  /**
   * Pilot goes offline
   */
  socket.on('pilot:offline', async () => {
    try {
      await prisma.pilot.update({
        where: { id: user.id },
        data: { isOnline: false },
      })

      leaveAllBookingRooms(socket)
      logger.info(`Pilot ${user.id} is now offline`)
    } catch (error) {
      logger.error('Error in pilot:offline handler:', error)
    }
  })

  /**
   * Pilot location update with throttling
   */
  socket.on('pilot:location', async (location: LocationData) => {
    try {
      const now = Date.now()
      const lastUpdate = socket.data.lastLocationUpdate || 0

      // Throttle: ignore if less than 1 second since last update
      if (now - lastUpdate < RATE_LIMITS.LOCATION_UPDATE_MS) {
        return
      }

      socket.data.lastLocationUpdate = now

      // Validate location data
      if (
        typeof location.lat !== 'number' ||
        typeof location.lng !== 'number' ||
        location.lat < -90 ||
        location.lat > 90 ||
        location.lng < -180 ||
        location.lng > 180
      ) {
        socket.emit('error', {
          code: 'ERR_1001',
          message: 'Invalid location data',
        })
        return
      }

      // Update pilot location in database
      await prisma.pilot.update({
        where: { id: user.id },
        data: {
          currentLat: location.lat,
          currentLng: location.lng,
          lastLocationAt: new Date(),
        },
      })

      // Find active booking for this pilot
      const activeBooking = await prisma.booking.findFirst({
        where: {
          pilotId: user.id,
          status: {
            in: ['ACCEPTED', 'ARRIVED_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_DROP'],
          },
        },
        select: { id: true },
      })

      if (activeBooking) {
        // Update booking location
        await prisma.booking.update({
          where: { id: activeBooking.id },
          data: {
            currentLat: location.lat,
            currentLng: location.lng,
          },
        })

        // Add to tracking history
        await prisma.trackingHistory.create({
          data: {
            bookingId: activeBooking.id,
            status: 'IN_TRANSIT',
            lat: location.lat,
            lng: location.lng,
          },
        })

        // Broadcast to booking room
        const locationUpdate: LocationUpdatePayload = {
          lat: location.lat,
          lng: location.lng,
          heading: location.heading,
          speed: location.speed,
          timestamp: new Date().toISOString(),
          pilotId: user.id,
        }

        emitToBooking(activeBooking.id, 'location:update', locationUpdate)
      }
    } catch (error) {
      logger.error('Error in pilot:location handler:', error)
    }
  })

  /**
   * Handle pilot disconnect with grace period
   */
  socket.on('disconnect', async () => {
    // Set a grace period before marking offline
    const timeout = setTimeout(async () => {
      try {
        // Check if pilot reconnected (socket in pilot room)
        const pilotRoom = RoomNames.pilot(user.id)
        const socketsInRoom = await io.in(pilotRoom).fetchSockets()

        if (socketsInRoom.length === 0) {
          // No reconnection, mark offline
          await prisma.pilot.update({
            where: { id: user.id },
            data: { isOnline: false },
          })
          logger.info(`Pilot ${user.id} marked offline after grace period`)
        }

        disconnectTimeouts.delete(user.id)
      } catch (error) {
        logger.error('Error in pilot disconnect grace period:', error)
      }
    }, RATE_LIMITS.PILOT_DISCONNECT_GRACE_MS)

    disconnectTimeouts.set(user.id, timeout)
    logger.debug(`Pilot ${user.id} disconnected, grace period started`)
  })
}

/**
 * Check for stale pilots and mark them offline
 * Call this periodically (e.g., every minute)
 */
export async function markStalePilotsOffline(): Promise<void> {
  try {
    const staleThreshold = new Date(Date.now() - RATE_LIMITS.PILOT_STALE_TIMEOUT_MS)

    const result = await prisma.pilot.updateMany({
      where: {
        isOnline: true,
        lastLocationAt: {
          lt: staleThreshold,
        },
      },
      data: {
        isOnline: false,
      },
    })

    if (result.count > 0) {
      logger.info(`Marked ${result.count} stale pilots as offline`)
    }
  } catch (error) {
    logger.error('Error marking stale pilots offline:', error)
  }
}
