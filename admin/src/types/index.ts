// API Response Types
export interface ApiResponse<T> {
  success: boolean
  message: string
  data?: T
  meta?: PaginationMeta
  errors?: { field: string; message: string }[]
}

export interface PaginationMeta {
  page: number
  limit: number
  total: number
  totalPages: number
}

// User Types
export interface User {
  id: string
  name: string
  email: string
  phone: string
  isActive: boolean
  createdAt: string
  updatedAt: string
  addresses?: Address[]
  bookings?: Booking[]
}

export interface Address {
  id: string
  userId: string
  label: string
  address: string
  landmark?: string
  city: string
  state: string
  pincode: string
  lat: number
  lng: number
  isDefault: boolean
  createdAt: string
  updatedAt: string
}

// Pilot Types
export type PilotStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'SUSPENDED'
export type Gender = 'MALE' | 'FEMALE' | 'OTHER'

export interface Pilot {
  id: string
  name: string
  email: string
  phone: string
  profileImage?: string
  dateOfBirth?: string
  gender?: Gender
  status: PilotStatus
  isOnline: boolean
  isAvailable: boolean
  currentLat?: number
  currentLng?: number
  rating: number
  totalRides?: number
  totalDeliveries?: number
  createdAt: string
  updatedAt: string
  documents?: PilotDocument[]
  vehicles?: Vehicle[]
}

export interface PilotDocument {
  id: string
  type: string
  documentUrl: string
  status: 'PENDING' | 'APPROVED' | 'REJECTED'
  rejectedReason?: string
  expiryDate?: string
}

// Vehicle Types
export interface VehicleType {
  id: string
  name: string
  description: string
  basePrice: number
  pricePerKm: number
  icon?: string
}

export interface Vehicle {
  id: string
  pilotId: string
  vehicleTypeId: string
  plateNumber: string
  model: string
  color: string
  year: number
  isActive: boolean
  isVerified: boolean
  vehicleType?: VehicleType
  pilot?: Pilot
}

// Booking Types
export type BookingStatus =
  | 'PENDING'
  | 'SEARCHING'
  | 'CONFIRMED'
  | 'PILOT_ARRIVED'
  | 'PICKED_UP'
  | 'IN_TRANSIT'
  | 'DELIVERED'
  | 'CANCELLED'

export interface Booking {
  id: string
  userId: string
  pilotId?: string
  vehicleTypeId: string
  status: BookingStatus
  pickupAddress: string
  pickupLat: number
  pickupLng: number
  dropoffAddress: string
  dropoffLat: number
  dropoffLng: number
  distance: number
  duration: number
  estimatedPrice: number
  finalPrice?: number
  paymentMethod: 'CASH' | 'WALLET' | 'CARD'
  paymentStatus: 'PENDING' | 'COMPLETED' | 'FAILED' | 'REFUNDED'
  notes?: string
  cancelReason?: string
  createdAt: string
  updatedAt: string
  user?: User
  pilot?: Pilot
  vehicleType?: VehicleType
}

// Wallet Types
export interface WalletTransaction {
  id: string
  userId: string
  type: 'CREDIT' | 'DEBIT'
  amount: number
  description: string
  referenceId?: string
  createdAt: string
  user?: User
}

// Dashboard Types
export interface DashboardStats {
  totalUsers: number
  totalPilots: number
  totalBookings: number
  totalRevenue: number
  pendingPilots: number
  activeBookings: number
  onlinePilots: number
  todayBookings: number
  todayRevenue: number
}

export interface RealtimeStats {
  activeBookings: number
  onlinePilots: number
  pendingBookings: number
  todayDeliveries: number
  todayRevenue: number
  timestamp: string
}

// Analytics Types
export interface BookingAnalytics {
  totalBookings: number
  bookingsByStatus: Record<BookingStatus, number>
  dailyBookings: { date: string; count: number }[]
  completionRate: number
  cancellationRate: number
}

export interface RevenueAnalytics {
  totalRevenue: number
  dailyRevenue: { date: string; amount: number }[]
  averageBookingValue: number
  revenueByPaymentMethod: Record<string, number>
}

// Settings Types
export interface Setting {
  key: string
  value: string
  description?: string
}

// Admin Auth Types
export interface Admin {
  id: string
  name: string
  email: string
  role: string
}

export interface LoginCredentials {
  email: string
  password: string
}

export interface AuthState {
  admin: Admin | null
  token: string | null
  isAuthenticated: boolean
  isLoading: boolean
}
