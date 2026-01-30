import { RoomNames } from './types'
import type { AppServer, AppSocket } from './index'
import logger from '../config/logger'

/**
 * Join a booking room for real-time tracking
 */
export function joinBookingRoom(socket: AppSocket, bookingId: string): void {
  const roomName = RoomNames.booking(bookingId)
  socket.join(roomName)
  socket.data.subscribedBookings.add(bookingId)
  logger.debug(`${socket.data.user.type}:${socket.data.user.id} joined ${roomName}`)
}

/**
 * Leave a booking room
 */
export function leaveBookingRoom(socket: AppSocket, bookingId: string): void {
  const roomName = RoomNames.booking(bookingId)
  socket.leave(roomName)
  socket.data.subscribedBookings.delete(bookingId)
  logger.debug(`${socket.data.user.type}:${socket.data.user.id} left ${roomName}`)
}

/**
 * Leave all booking rooms (on disconnect)
 */
export function leaveAllBookingRooms(socket: AppSocket): void {
  socket.data.subscribedBookings.forEach((bookingId) => {
    socket.leave(RoomNames.booking(bookingId))
  })
  socket.data.subscribedBookings.clear()
}

/**
 * Join admin dashboard room
 */
export function joinAdminRoom(socket: AppSocket): void {
  socket.join(RoomNames.admin)
  logger.debug(`Admin ${socket.data.user.id} joined dashboard room`)
}

/**
 * Leave admin dashboard room
 */
export function leaveAdminRoom(socket: AppSocket): void {
  socket.leave(RoomNames.admin)
  logger.debug(`Admin ${socket.data.user.id} left dashboard room`)
}

/**
 * Get count of sockets in a room
 */
export async function getRoomSize(io: AppServer, roomName: string): Promise<number> {
  const sockets = await io.in(roomName).fetchSockets()
  return sockets.length
}

/**
 * Get all online pilots
 */
export async function getOnlinePilots(io: AppServer): Promise<string[]> {
  const allSockets = await io.fetchSockets()
  return allSockets
    .filter((s) => s.data.user?.type === 'pilot')
    .map((s) => s.data.user.id)
}

/**
 * Check if a user is connected
 */
export async function isUserConnected(io: AppServer, userId: string, type: 'user' | 'pilot' | 'admin'): Promise<boolean> {
  const roomName = type === 'user'
    ? RoomNames.user(userId)
    : type === 'pilot'
      ? RoomNames.pilot(userId)
      : RoomNames.admin

  const size = await getRoomSize(io, roomName)
  return size > 0
}
