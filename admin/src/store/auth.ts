import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import Cookies from 'js-cookie'
import type { Admin, AuthState } from '@/types'

interface AuthStore extends AuthState {
  login: (admin: Admin, token: string) => void
  logout: () => void
  setLoading: (isLoading: boolean) => void
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      admin: null,
      token: null,
      isAuthenticated: false,
      isLoading: true,

      login: (admin: Admin, token: string) => {
        Cookies.set('admin_token', token, { expires: 7 })
        set({ admin, token, isAuthenticated: true, isLoading: false })
      },

      logout: () => {
        Cookies.remove('admin_token')
        set({ admin: null, token: null, isAuthenticated: false, isLoading: false })
      },

      setLoading: (isLoading: boolean) => {
        set({ isLoading })
      },
    }),
    {
      name: 'admin-auth',
      partialize: (state) => ({
        admin: state.admin,
        token: state.token,
        isAuthenticated: state.isAuthenticated,
      }),
    }
  )
)
