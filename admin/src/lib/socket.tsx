'use client'

import { createContext, useContext, useEffect, useState, useCallback } from 'react'
import { io, Socket } from 'socket.io-client'
import Cookies from 'js-cookie'
import type { RealtimeStats, Booking } from '@/types'

const SOCKET_URL = process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:3000'

interface PilotLocation {
  bookingId: string
  lat: number
  lng: number
  timestamp: string
}

interface SocketContextType {
  socket: Socket | null
  isConnected: boolean
  realtimeStats: RealtimeStats | null
  bookingUpdates: Booking[]
  pilotLocations: Map<string, PilotLocation>
  subscribeToBooking: (bookingId: string) => void
  unsubscribeFromBooking: (bookingId: string) => void
}

const SocketContext = createContext<SocketContextType>({
  socket: null,
  isConnected: false,
  realtimeStats: null,
  bookingUpdates: [],
  pilotLocations: new Map(),
  subscribeToBooking: () => {},
  unsubscribeFromBooking: () => {},
})

export function SocketProvider({ children }: { children: React.ReactNode }) {
  const [socket, setSocket] = useState<Socket | null>(null)
  const [isConnected, setIsConnected] = useState(false)
  const [realtimeStats, setRealtimeStats] = useState<RealtimeStats | null>(null)
  const [bookingUpdates, setBookingUpdates] = useState<Booking[]>([])
  const [pilotLocations, setPilotLocations] = useState<Map<string, PilotLocation>>(new Map())

  useEffect(() => {
    const token = Cookies.get('admin_token')
    if (!token) return

    const socketInstance = io(SOCKET_URL, {
      auth: { token: `Bearer ${token}` },
      transports: ['websocket', 'polling'],
    })

    socketInstance.on('connect', () => {
      setIsConnected(true)
      // Subscribe to admin dashboard updates
      socketInstance.emit('admin:subscribe')
    })

    socketInstance.on('disconnect', () => {
      setIsConnected(false)
    })

    socketInstance.on('dashboard:stats', (stats: RealtimeStats) => {
      setRealtimeStats(stats)
    })

    socketInstance.on('booking:new', (booking: Booking) => {
      setBookingUpdates((prev) => [booking, ...prev.slice(0, 9)])
    })

    socketInstance.on('booking:updated', (booking: Booking) => {
      setBookingUpdates((prev) => {
        const index = prev.findIndex((b) => b.id === booking.id)
        if (index >= 0) {
          const updated = [...prev]
          updated[index] = booking
          return updated
        }
        return [booking, ...prev.slice(0, 9)]
      })
    })

    // Listen for pilot location updates
    socketInstance.on('booking:location', (location: PilotLocation) => {
      setPilotLocations((prev) => {
        const updated = new Map(prev)
        updated.set(location.bookingId, location)
        return updated
      })
    })

    socketInstance.on('error', (error) => {
      console.error('Socket error:', error)
    })

    setSocket(socketInstance)

    return () => {
      socketInstance.disconnect()
    }
  }, [])

  // Subscribe to a specific booking for tracking
  const subscribeToBooking = useCallback((bookingId: string) => {
    if (socket && isConnected) {
      socket.emit('admin:booking:subscribe', { bookingId })
    }
  }, [socket, isConnected])

  // Unsubscribe from a specific booking
  const unsubscribeFromBooking = useCallback((bookingId: string) => {
    if (socket && isConnected) {
      socket.emit('admin:booking:unsubscribe', { bookingId })
      setPilotLocations((prev) => {
        const updated = new Map(prev)
        updated.delete(bookingId)
        return updated
      })
    }
  }, [socket, isConnected])

  return (
    <SocketContext.Provider value={{
      socket,
      isConnected,
      realtimeStats,
      bookingUpdates,
      pilotLocations,
      subscribeToBooking,
      unsubscribeFromBooking,
    }}>
      {children}
    </SocketContext.Provider>
  )
}

export function useSocket() {
  const context = useContext(SocketContext)
  if (!context) {
    throw new Error('useSocket must be used within a SocketProvider')
  }
  return context
}
