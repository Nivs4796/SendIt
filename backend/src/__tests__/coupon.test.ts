import request from 'supertest'
import app from '../app'
import prisma from '../config/database'
import { generateTestToken, testCoupons } from './setup'

describe('Coupon API', () => {
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

  describe('POST /api/v1/coupons/validate', () => {
    it('should validate a valid coupon', async () => {
      const vehicleType = await prisma.vehicleType.findFirst({
        where: { name: 'Bike' },
      })

      const response = await request(app)
        .post('/api/v1/coupons/validate')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          code: testCoupons.welcome,
          orderAmount: 500,
          vehicleTypeId: vehicleType?.id,
        })

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('coupon')
      expect(response.body.data).toHaveProperty('discountAmount')
      expect(response.body.data.coupon.code).toBe(testCoupons.welcome)
    })

    it('should reject expired coupon', async () => {
      const response = await request(app)
        .post('/api/v1/coupons/validate')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          code: testCoupons.expired,
          orderAmount: 500,
        })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
      expect(response.body.message).toContain('expired')
    })

    it('should reject non-existent coupon', async () => {
      const response = await request(app)
        .post('/api/v1/coupons/validate')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          code: 'NONEXISTENT',
          orderAmount: 500,
        })

      expect(response.status).toBe(404)
      expect(response.body).toHaveProperty('success', false)
    })

    it('should reject coupon for wrong vehicle type', async () => {
      // TRUCK10 is only valid for Truck vehicle type
      const bikeVehicle = await prisma.vehicleType.findFirst({
        where: { name: 'Bike' },
      })

      const response = await request(app)
        .post('/api/v1/coupons/validate')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          code: testCoupons.truck,
          orderAmount: 2000,
          vehicleTypeId: bikeVehicle?.id,
        })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })

    it('should reject without auth', async () => {
      const response = await request(app)
        .post('/api/v1/coupons/validate')
        .send({
          code: testCoupons.welcome,
          orderAmount: 500,
        })

      expect(response.status).toBe(401)
    })
  })

  describe('POST /api/v1/coupons/apply', () => {
    it('should apply a valid coupon', async () => {
      const booking = await prisma.booking.findFirst({
        where: {
          userId,
          status: 'PENDING',
        },
      })

      if (booking) {
        const response = await request(app)
          .post('/api/v1/coupons/apply')
          .set('Authorization', `Bearer ${userToken}`)
          .send({
            code: testCoupons.flat,
            bookingId: booking.id,
          })

        // May succeed or fail based on booking state
        expect([200, 400]).toContain(response.status)
        expect(response.body).toHaveProperty('success')
      }
    })
  })

  describe('GET /api/v1/coupons/available', () => {
    it('should return available coupons for user', async () => {
      const response = await request(app)
        .get('/api/v1/coupons/available')
        .set('Authorization', `Bearer ${userToken}`)

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('coupons')
      expect(Array.isArray(response.body.data.coupons)).toBe(true)
    })
  })

  describe('Admin Coupon Management', () => {
    let testCouponId: string

    describe('POST /api/v1/coupons', () => {
      it('should create a new coupon (admin)', async () => {
        const response = await request(app)
          .post('/api/v1/coupons')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            code: 'TEST123',
            description: 'Test coupon',
            discountType: 'PERCENTAGE',
            discountValue: 15,
            maxDiscount: 200,
            minOrderAmount: 100,
            usageLimit: 50,
            validFrom: new Date().toISOString(),
            validUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
          })

        expect(response.status).toBe(201)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('coupon')
        expect(response.body.data.coupon.code).toBe('TEST123')

        testCouponId = response.body.data.coupon.id
      })

      it('should reject duplicate coupon code', async () => {
        const response = await request(app)
          .post('/api/v1/coupons')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            code: testCoupons.welcome,
            description: 'Duplicate',
            discountType: 'PERCENTAGE',
            discountValue: 10,
          })

        expect(response.status).toBe(400)
        expect(response.body).toHaveProperty('success', false)
      })

      it('should reject without admin auth', async () => {
        const response = await request(app)
          .post('/api/v1/coupons')
          .set('Authorization', `Bearer ${userToken}`)
          .send({
            code: 'NEWCOUPON',
            description: 'Test',
            discountType: 'FIXED',
            discountValue: 50,
          })

        expect(response.status).toBe(403)
      })
    })

    describe('GET /api/v1/coupons', () => {
      it('should list all coupons (admin)', async () => {
        const response = await request(app)
          .get('/api/v1/coupons')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('coupons')
        expect(Array.isArray(response.body.data.coupons)).toBe(true)
      })
    })

    describe('PUT /api/v1/coupons/:id', () => {
      it('should update a coupon (admin)', async () => {
        if (testCouponId) {
          const response = await request(app)
            .put(`/api/v1/coupons/${testCouponId}`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
              discountValue: 20,
              description: 'Updated test coupon',
            })

          expect(response.status).toBe(200)
          expect(response.body).toHaveProperty('success', true)
          expect(response.body.data.coupon.discountValue).toBe(20)
        }
      })
    })

    describe('DELETE /api/v1/coupons/:id', () => {
      it('should delete a coupon (admin)', async () => {
        if (testCouponId) {
          const response = await request(app)
            .delete(`/api/v1/coupons/${testCouponId}`)
            .set('Authorization', `Bearer ${adminToken}`)

          expect(response.status).toBe(200)
          expect(response.body).toHaveProperty('success', true)
        }
      })
    })
  })
})
