import { Server as HttpServer } from 'http'
import { Server, Socket } from 'socket.io'
import jwt from 'jsonwebtoken'
import { config } from '../config'
import logger from '../config/logger'
import {
  ClientToServerEvents,
  ServerToClientEvents,
  InterServerEvents,
  SocketData,
  RoomNames,
} from './types'
import { registerPilotHandlers } from './handlers/pilot.handler'
import { registerBookingHandlers } from './handlers/booking.handler'
import { registerAdminHandlers } from './handlers/admin.handler'

// Type alias for our socket instance
export type AppSocket = Socket<
  ClientToServerEvents,
  ServerToClientEvents,
  InterServerEvents,
  SocketData
>

// Type alias for our io server
export type AppServer = Server<
  ClientToServerEvents,
  ServerToClientEvents,
  InterServerEvents,
  SocketData
>

// Global IO instance (exported for use in services)
let io: AppServer | null = null

interface JwtPayload {
  id: string
  type: 'user' | 'pilot' | 'admin'
  name?: string
  iat?: number
  exp?: number
}

/**
 * Initialize Socket.io server with JWT authentication
 */
export function initializeSocket(httpServer: HttpServer): AppServer {
  io = new Server<
    ClientToServerEvents,
    ServerToClientEvents,
    InterServerEvents,
    SocketData
  >(httpServer, {
    cors: {
      origin: config.clientUrl,
      credentials: true,
    },
    pingTimeout: 60000,
    pingInterval: 25000,
  })

  // JWT Authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token

      if (!token) {
        return next(new Error('Authentication required'))
      }

      // Remove 'Bearer ' prefix if present
      const tokenValue = token.startsWith('Bearer ')
        ? token.slice(7)
        : token

      // Verify JWT
      const decoded = jwt.verify(tokenValue, config.jwtSecret) as JwtPayload

      if (!decoded.id || !decoded.type) {
        return next(new Error('Invalid token payload'))
      }

      // Attach user data to socket
      socket.data.user = {
        id: decoded.id,
        type: decoded.type,
        name: decoded.name,
      }
      socket.data.subscribedBookings = new Set()

      next()
    } catch (error) {
      logger.warn('Socket authentication failed:', error)
      next(new Error('Authentication failed'))
    }
  })

  // Connection handler
  io.on('connection', (socket: AppSocket) => {
    const { user } = socket.data

    logger.info(`Socket connected: ${user.type}:${user.id}`)

    // Auto-join personal room based on user type
    if (user.type === 'user') {
      socket.join(RoomNames.user(user.id))
    } else if (user.type === 'pilot') {
      socket.join(RoomNames.pilot(user.id))
    }

    // Register event handlers based on user type
    registerPilotHandlers(io!, socket)
    registerBookingHandlers(io!, socket)
    registerAdminHandlers(io!, socket)

    // Handle disconnection
    socket.on('disconnect', (reason) => {
      logger.info(`Socket disconnected: ${user.type}:${user.id} - ${reason}`)
    })

    // Handle errors
    socket.on('error', (error) => {
      logger.error(`Socket error for ${user.type}:${user.id}:`, error)
    })
  })

  logger.info('Socket.io server initialized')

  return io
}

/**
 * Get the Socket.io server instance
 */
export function getIO(): AppServer {
  if (!io) {
    throw new Error('Socket.io not initialized. Call initializeSocket first.')
  }
  return io
}

/**
 * Emit to a specific user's room
 */
export function emitToUser(userId: string, event: keyof ServerToClientEvents, data: unknown): void {
  if (!io) return
  io.to(RoomNames.user(userId)).emit(event, data as never)
}

/**
 * Emit to a specific pilot's room
 */
export function emitToPilot(pilotId: string, event: keyof ServerToClientEvents, data: unknown): void {
  if (!io) return
  io.to(RoomNames.pilot(pilotId)).emit(event, data as never)
}

/**
 * Emit to a booking room (user + pilot tracking)
 */
export function emitToBooking(bookingId: string, event: keyof ServerToClientEvents, data: unknown): void {
  if (!io) return
  io.to(RoomNames.booking(bookingId)).emit(event, data as never)
}

/**
 * Emit to admin dashboard
 */
export function emitToAdmin(event: keyof ServerToClientEvents, data: unknown): void {
  if (!io) return
  io.to(RoomNames.admin).emit(event, data as never)
}

export default { initializeSocket, getIO, emitToUser, emitToPilot, emitToBooking, emitToAdmin }
