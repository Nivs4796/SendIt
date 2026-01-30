import request from 'supertest'
import app from '../app'
import prisma from '../config/database'
import { generateTestToken } from './setup'

describe('Wallet API', () => {
  let userToken: string
  let adminToken: string
  let userId: string

  beforeAll(async () => {
    // Get a test user
    const user = await prisma.user.findFirst({
      where: { phone: '+919876543210' },
    })
    if (user) {
      userId = user.id
      userToken = generateTestToken({ id: user.id, type: 'user' })
    }

    // Get admin
    const admin = await prisma.admin.findFirst({
      where: { email: 'admin@sendit.co.in' },
    })
    if (admin) {
      adminToken = generateTestToken({ id: admin.id, type: 'admin' })
    }
  })

  describe('GET /api/v1/wallet/balance', () => {
    it('should return user wallet balance', async () => {
      const response = await request(app)
        .get('/api/v1/wallet/balance')
        .set('Authorization', `Bearer ${userToken}`)

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('balance')
      expect(typeof response.body.data.balance).toBe('number')
    })

    it('should reject without auth', async () => {
      const response = await request(app).get('/api/v1/wallet/balance')

      expect(response.status).toBe(401)
    })
  })

  describe('GET /api/v1/wallet/transactions', () => {
    it('should return wallet transactions', async () => {
      const response = await request(app)
        .get('/api/v1/wallet/transactions')
        .set('Authorization', `Bearer ${userToken}`)

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('transactions')
      expect(Array.isArray(response.body.data.transactions)).toBe(true)
    })

    it('should support pagination', async () => {
      const response = await request(app)
        .get('/api/v1/wallet/transactions?page=1&limit=5')
        .set('Authorization', `Bearer ${userToken}`)

      expect(response.status).toBe(200)
      expect(response.body.meta).toHaveProperty('page', 1)
      expect(response.body.meta).toHaveProperty('limit', 5)
    })
  })

  describe('POST /api/v1/wallet/add-money', () => {
    it('should add money to wallet', async () => {
      const initialBalance = await prisma.user.findUnique({
        where: { id: userId },
        select: { walletBalance: true },
      })

      const response = await request(app)
        .post('/api/v1/wallet/add-money')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          amount: 100,
          paymentMethod: 'UPI',
          transactionId: `TEST_${Date.now()}`,
        })

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('balance')
      expect(response.body.data).toHaveProperty('transaction')

      // Verify balance increased
      const newBalance = response.body.data.balance
      expect(newBalance).toBe((initialBalance?.walletBalance || 0) + 100)
    })

    it('should reject negative amount', async () => {
      const response = await request(app)
        .post('/api/v1/wallet/add-money')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          amount: -50,
          paymentMethod: 'UPI',
        })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })

    it('should reject zero amount', async () => {
      const response = await request(app)
        .post('/api/v1/wallet/add-money')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          amount: 0,
          paymentMethod: 'UPI',
        })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })
  })

  describe('Admin Wallet Operations', () => {
    describe('POST /api/v1/wallet/admin/credit', () => {
      it('should credit user wallet (admin)', async () => {
        const response = await request(app)
          .post('/api/v1/wallet/admin/credit')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            userId: userId,
            amount: 50,
            description: 'Test admin credit',
            type: 'BONUS',
          })

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('transaction')
        expect(response.body.data.transaction.type).toBe('BONUS')
      })

      it('should reject without admin auth', async () => {
        const response = await request(app)
          .post('/api/v1/wallet/admin/credit')
          .set('Authorization', `Bearer ${userToken}`)
          .send({
            userId: userId,
            amount: 50,
            description: 'Test',
            type: 'BONUS',
          })

        expect(response.status).toBe(403)
      })
    })

    describe('POST /api/v1/wallet/admin/debit', () => {
      it('should debit user wallet (admin)', async () => {
        const response = await request(app)
          .post('/api/v1/wallet/admin/debit')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            userId: userId,
            amount: 10,
            description: 'Test admin debit',
            type: 'DEDUCTION',
          })

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('transaction')
      })

      it('should reject debit exceeding balance', async () => {
        const user = await prisma.user.findUnique({
          where: { id: userId },
          select: { walletBalance: true },
        })

        const response = await request(app)
          .post('/api/v1/wallet/admin/debit')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            userId: userId,
            amount: (user?.walletBalance || 0) + 10000,
            description: 'Exceeding balance',
            type: 'DEDUCTION',
          })

        expect(response.status).toBe(400)
        expect(response.body).toHaveProperty('success', false)
      })
    })
  })
})
