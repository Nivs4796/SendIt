import prisma from '../config/database'

// Test timeouts
jest.setTimeout(30000)

// Global test setup
beforeAll(async () => {
  // Connect to database
  await prisma.$connect()
})

// Global test teardown
afterAll(async () => {
  await prisma.$disconnect()
})

// Helper to generate test JWT token
export const generateTestToken = (payload: {
  id: string
  type: 'user' | 'pilot' | 'admin'
}): string => {
  const jwt = require('jsonwebtoken')
  const { config } = require('../config')
  return jwt.sign(payload, config.jwtSecret, { expiresIn: '1h' })
}

// Test user IDs from seed data
export const testUsers = {
  user1: { phone: '+919876543210', name: 'Rahul Kumar' },
  user2: { phone: '+919876543211', name: 'Priya Sharma' },
}

export const testPilots = {
  pilot1: { phone: '+919898989801', name: 'Vijay Singh' },
  pilot2: { phone: '+919898989802', name: 'Suresh Patel' },
}

export const testAdmin = {
  email: 'admin@sendit.co.in',
  password: 'admin123',
}

export const testCoupons = {
  welcome: 'WELCOME50',
  flat: 'FLAT20',
  truck: 'TRUCK10',
  expired: 'EXPIRED',
}
