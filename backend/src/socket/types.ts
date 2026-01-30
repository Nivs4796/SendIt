import { BookingStatus } from '@prisma/client'

// ============================================
// Socket Data Types
// ============================================

export interface SocketUser {
  id: string
  type: 'user' | 'pilot' | 'admin'
  name?: string
}

export interface LocationData {
  lat: number
  lng: number
  heading?: number
  speed?: number
}

// ============================================
// Client → Server Events
// ============================================

export interface ClientToServerEvents {
  // Pilot events
  'pilot:online': (data: { vehicleId: string }) => void
  'pilot:offline': () => void
  'pilot:location': (data: LocationData) => void

  // Booking events (User)
  'booking:subscribe': (data: { bookingId: string }) => void
  'booking:unsubscribe': (data: { bookingId: string }) => void

  // Admin events
  'admin:subscribe': () => void
  'admin:unsubscribe': () => void
}

// ============================================
// Server → Client Events
// ============================================

export interface LocationUpdatePayload extends LocationData {
  timestamp: string
  pilotId: string
}

export interface BookingStatusPayload {
  bookingId: string
  status: BookingStatus
  timestamp: string
  pilotId?: string
  pilotName?: string
  pilotPhone?: string
}

export interface BookingOfferPayload {
  bookingId: string
  bookingNumber: string
  pickupAddress: {
    address: string
    lat: number
    lng: number
  }
  dropAddress: {
    address: string
    lat: number
    lng: number
  }
  distance: number
  totalAmount: number
  packageType: string
  expiresAt: string
}

export interface DashboardStatsPayload {
  activeBookings: number
  onlinePilots: number
  pendingBookings: number
  todayDeliveries: number
  todayRevenue: number
  timestamp: string
}

export interface NotificationPayload {
  id: string
  title: string
  body: string
  type: 'BOOKING' | 'PAYMENT' | 'PROMOTION' | 'SYSTEM' | 'CHAT'
  data?: Record<string, unknown>
  createdAt: string
}

export interface ServerToClientEvents {
  // Location updates (to booking room)
  'location:update': (data: LocationUpdatePayload) => void

  // Booking status (to booking room + user room)
  'booking:status': (data: BookingStatusPayload) => void

  // New booking offer (to pilot)
  'booking:offer': (data: BookingOfferPayload) => void
  'offer:expired': (data: { bookingId: string }) => void

  // Admin dashboard stats
  'dashboard:stats': (data: DashboardStatsPayload) => void

  // Notifications (to user/pilot)
  'notification': (data: NotificationPayload) => void

  // Error events
  'error': (data: { code: string; message: string }) => void
}

// ============================================
// Inter-Server Events (for scaling)
// ============================================

export interface InterServerEvents {
  ping: () => void
}

// ============================================
// Socket Data (attached to socket instance)
// ============================================

export interface SocketData {
  user: SocketUser
  lastLocationUpdate?: number
  subscribedBookings: Set<string>
}

// ============================================
// Room Names
// ============================================

export const RoomNames = {
  booking: (bookingId: string) => `booking:${bookingId}`,
  pilot: (pilotId: string) => `pilot:${pilotId}`,
  user: (userId: string) => `user:${userId}`,
  admin: 'admin:dashboard',
} as const

// ============================================
// Rate Limiting Constants
// ============================================

export const RATE_LIMITS = {
  LOCATION_UPDATE_MS: 1000, // 1 per second
  SUBSCRIPTION_PER_MIN: 10,
  PILOT_STALE_TIMEOUT_MS: 60000, // 60 seconds
  PILOT_DISCONNECT_GRACE_MS: 30000, // 30 seconds
} as const
