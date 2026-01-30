/**
 * Test data fixtures for SendIt Admin Portal E2E tests
 * Based on seed.ts data
 */

/**
 * Test user data
 */
export const TEST_USERS = {
  count: 5,
  sample: {
    name: 'Arjun Sharma',
    email: 'arjun.sharma@example.com',
    phone: '+919876543210',
  },
};

/**
 * Test pilot data
 */
export const TEST_PILOTS = {
  total: 5,
  approved: 3,
  pending: 1,
  suspended: 1,
  sample: {
    approved: {
      name: 'Rajesh Kumar',
      phone: '+919988776655',
    },
    pending: {
      name: 'Sameer Ahmed',
      phone: '+919112233445',
    },
  },
};

/**
 * Test booking data
 */
export const TEST_BOOKINGS = {
  total: 4,
  statuses: {
    DELIVERED: 1,
    IN_TRANSIT: 1,
    PENDING: 1,
    CANCELLED: 1,
  },
};

/**
 * Test vehicle data
 */
export const TEST_VEHICLES = {
  total: 3,
  verified: 3,
};

/**
 * Test wallet transaction data
 */
export const TEST_WALLET_TRANSACTIONS = {
  total: 3,
  types: {
    CREDIT: 2,
    DEBIT: 1,
  },
};

/**
 * Test settings data
 */
export const TEST_SETTINGS = {
  total: 7,
  groups: [
    'pricing',
    'commission',
    'limits',
  ],
};

/**
 * Test coupon data
 */
export const TEST_COUPONS = {
  total: 4,
};

/**
 * Dashboard expected stats
 */
export const DASHBOARD_STATS = {
  statCards: 8,
  expectedStats: [
    'Total Users',
    'Total Pilots',
    'Total Bookings',
    'Revenue',
    'Active Bookings',
    'Online Pilots',
  ],
};

/**
 * API endpoints for verification
 */
export const API_ENDPOINTS = {
  base: 'http://localhost:5000/api',
  admin: {
    login: '/admin/login',
    dashboard: '/admin/dashboard',
    users: '/admin/users',
    pilots: '/admin/pilots',
    bookings: '/admin/bookings',
    vehicles: '/admin/vehicles',
    wallet: '/admin/wallet-transactions',
    analytics: '/admin/analytics',
    settings: '/admin/settings',
  },
};

/**
 * Helper function to generate test search queries
 */
export const SEARCH_QUERIES = {
  users: {
    byName: 'Arjun',
    byEmail: 'arjun',
    byPhone: '9876',
  },
  pilots: {
    byName: 'Rajesh',
    byPhone: '9988',
  },
  vehicles: {
    byPlate: 'MH',
    byModel: 'Activa',
  },
  bookings: {
    byId: 'BK',
  },
};

/**
 * Pagination defaults
 */
export const PAGINATION = {
  defaultLimit: 10,
  testLimits: [10, 25, 50],
};

/**
 * Timeout values for various operations
 */
export const TIMEOUTS = {
  shortWait: 1000,
  mediumWait: 3000,
  longWait: 5000,
  apiCall: 10000,
};
