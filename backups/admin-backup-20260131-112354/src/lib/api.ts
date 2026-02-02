import Cookies from 'js-cookie'
import type { ApiResponse } from '@/types'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1'

class ApiClient {
  private baseUrl: string

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl
  }

  private getHeaders(): HeadersInit {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    }

    const token = Cookies.get('admin_token')
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    return headers
  }

  private async handleResponse<T>(response: Response): Promise<ApiResponse<T>> {
    const data = await response.json()

    if (!response.ok) {
      if (response.status === 401) {
        // Token expired or invalid
        Cookies.remove('admin_token')
        if (typeof window !== 'undefined') {
          window.location.href = '/login'
        }
      }
      throw new Error(data.message || 'An error occurred')
    }

    return data
  }

  async get<T>(endpoint: string, params?: Record<string, string | number | boolean | undefined>): Promise<ApiResponse<T>> {
    const url = new URL(`${this.baseUrl}${endpoint}`)
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined) {
          url.searchParams.append(key, String(value))
        }
      })
    }

    const response = await fetch(url.toString(), {
      method: 'GET',
      headers: this.getHeaders(),
    })

    return this.handleResponse<T>(response)
  }

  async post<T>(endpoint: string, body?: unknown): Promise<ApiResponse<T>> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: body ? JSON.stringify(body) : undefined,
    })

    return this.handleResponse<T>(response)
  }

  async put<T>(endpoint: string, body?: unknown): Promise<ApiResponse<T>> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'PUT',
      headers: this.getHeaders(),
      body: body ? JSON.stringify(body) : undefined,
    })

    return this.handleResponse<T>(response)
  }

  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      method: 'DELETE',
      headers: this.getHeaders(),
    })

    return this.handleResponse<T>(response)
  }
}

export const api = new ApiClient(API_BASE_URL)

// Admin API endpoints
export const adminApi = {
  // Dashboard
  getDashboard: () => api.get('/admin/dashboard'),

  // Users
  listUsers: (params?: { page?: number; limit?: number; search?: string; active?: boolean }) =>
    api.get('/admin/users', params),
  getUserDetails: (userId: string) => api.get(`/admin/users/${userId}`),
  updateUserStatus: (userId: string, isActive: boolean) =>
    api.put(`/admin/users/${userId}/status`, { isActive }),
  updateUser: (userId: string, data: { name?: string; email?: string; phone?: string }) =>
    api.put(`/admin/users/${userId}`, data),

  // Pilots
  listPilots: (params?: { page?: number; limit?: number; status?: string; search?: string; online?: boolean }) =>
    api.get('/admin/pilots', params),
  getPilotDetails: (pilotId: string) => api.get(`/admin/pilots/${pilotId}`),
  updatePilotStatus: (pilotId: string, status: string, reason?: string) =>
    api.put(`/admin/pilots/${pilotId}/status`, { status, reason }),
  updatePilot: (pilotId: string, data: { name?: string; email?: string; phone?: string; dateOfBirth?: string; gender?: string }) =>
    api.put(`/admin/pilots/${pilotId}`, data),
  verifyDocument: (documentId: string, status: 'APPROVED' | 'REJECTED', rejectedReason?: string) =>
    api.put(`/admin/documents/${documentId}/verify`, { status, rejectedReason }),

  // Bookings
  listBookings: (params?: { page?: number; limit?: number; status?: string; search?: string; dateFrom?: string; dateTo?: string }) =>
    api.get('/admin/bookings', params),
  getBookingDetails: (bookingId: string) => api.get(`/admin/bookings/${bookingId}`),
  assignPilot: (bookingId: string, pilotId: string) =>
    api.post(`/admin/bookings/${bookingId}/assign`, { pilotId }),
  cancelBooking: (bookingId: string, reason: string) =>
    api.post(`/admin/bookings/${bookingId}/cancel`, { reason }),

  // Vehicles
  listVehicles: (params?: { page?: number; limit?: number; search?: string; verified?: boolean; vehicleTypeId?: string }) =>
    api.get('/admin/vehicles', params),
  getVehicleDetails: (vehicleId: string) => api.get(`/admin/vehicles/${vehicleId}`),
  verifyVehicle: (vehicleId: string, isVerified: boolean, reason?: string) =>
    api.put(`/admin/vehicles/${vehicleId}/verify`, { isVerified, reason }),

  // Wallet
  listWalletTransactions: (params?: { page?: number; limit?: number; userId?: string; type?: string; dateFrom?: string; dateTo?: string }) =>
    api.get('/admin/wallet/transactions', params),

  // Settings
  getSettings: () => api.get('/admin/settings'),
  updateSetting: (key: string, value: string, description?: string) =>
    api.put('/admin/settings', { key, value, description }),
  updateSettingsBulk: (settings: { key: string; value: string }[]) =>
    api.put('/admin/settings/bulk', { settings }),

  // Analytics
  getBookingAnalytics: (days?: number) => api.get('/admin/analytics/bookings', { days }),
  getRevenueAnalytics: (days?: number) => api.get('/admin/analytics/revenue', { days }),
}

// Auth API
export const authApi = {
  login: (email: string, password: string) =>
    api.post('/auth/admin/login', { email, password }),
  logout: () => api.post('/auth/admin/logout'),
}
