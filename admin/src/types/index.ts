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
  url: string
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
  plateNumber?: string       // Keep for backward compat
  registrationNo?: string    // Backend field name
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
  | 'ACCEPTED'
  | 'ARRIVED_PICKUP'
  | 'PICKED_UP'
  | 'IN_TRANSIT'
  | 'ARRIVED_DROP'
  | 'DELIVERED'
  | 'CANCELLED'

export interface BookingAddress {
  id: string
  address: string
  city: string
  state: string
  pincode: string
  landmark?: string
  lat?: number
  lng?: number
}

export interface Booking {
  id: string
  userId: string
  pilotId?: string
  vehicleTypeId: string
  status: BookingStatus
  pickupAddress: BookingAddress | null
  pickupLat?: number
  pickupLng?: number
  dropAddress: BookingAddress | null
  dropoffLat?: number
  dropoffLng?: number
  distance: number
  duration?: number
  estimatedPrice?: number
  baseFare?: number
  distanceFare?: number
  totalAmount?: number
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

// Analytics Types - Updated to match backend response
export interface BookingAnalytics {
  dailyBookings: {
    date: string
    total: number
    completed: number
    cancelled: number
    revenue: number
  }[]
  statusDistribution: { status: string; _count: number }[]
  vehicleDistribution: { vehicleTypeId: string; _count: number }[]
}

export interface RevenueAnalytics {
  daily: { date: string; revenue: number; orders: number }[]
  total: number
  totalOrders: number
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

// Coupon Types
export type DiscountType = 'PERCENTAGE' | 'FIXED'

export interface Coupon {
  id: string
  code: string
  description?: string
  discountType: DiscountType
  discountValue: number
  minOrderAmount?: number
  maxDiscount?: number
  usageLimit?: number
  usageCount: number
  perUserLimit: number
  vehicleTypeIds: string[]
  isActive: boolean
  startsAt: string
  expiresAt?: string
  createdAt: string
  updatedAt: string
}

export interface CouponStats {
  totalCoupons: number
  activeCoupons: number
  totalRedemptions: number
  totalDiscountGiven: number
}

export interface CreateCouponDto {
  code: string
  description?: string
  discountType?: DiscountType
  discountValue: number
  minOrderAmount?: number
  maxDiscount?: number
  usageLimit?: number
  perUserLimit?: number
  vehicleTypeIds?: string[]
  startsAt?: string
  expiresAt?: string
}

export interface UpdateCouponDto {
  description?: string
  discountType?: DiscountType
  discountValue?: number
  minOrderAmount?: number
  maxDiscount?: number
  usageLimit?: number
  perUserLimit?: number
  vehicleTypeIds?: string[]
  isActive?: boolean
  startsAt?: string
  expiresAt?: string
}
