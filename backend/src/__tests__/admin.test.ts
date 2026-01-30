import request from 'supertest'
import app from '../app'
import prisma from '../config/database'
import { generateTestToken } from './setup'

describe('Admin API', () => {
  let adminToken: string
  let userToken: string

  beforeAll(async () => {
    // Get admin
    const admin = await prisma.admin.findFirst({
      where: { email: 'admin@sendit.co.in' },
    })
    if (admin) {
      adminToken = generateTestToken({ id: admin.id, type: 'admin' })
    }

    // Get user for unauthorized tests
    const user = await prisma.user.findFirst({
      where: { phone: '+919876543210' },
    })
    if (user) {
      userToken = generateTestToken({ id: user.id, type: 'user' })
    }
  })

  describe('GET /api/v1/admin/dashboard', () => {
    it('should return dashboard stats (admin)', async () => {
      const response = await request(app)
        .get('/api/v1/admin/dashboard')
        .set('Authorization', `Bearer ${adminToken}`)

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('totalUsers')
      expect(response.body.data).toHaveProperty('totalPilots')
      expect(response.body.data).toHaveProperty('totalBookings')
      expect(response.body.data).toHaveProperty('totalRevenue')
    })

    it('should reject non-admin users', async () => {
      const response = await request(app)
        .get('/api/v1/admin/dashboard')
        .set('Authorization', `Bearer ${userToken}`)

      expect(response.status).toBe(403)
    })

    it('should reject without auth', async () => {
      const response = await request(app).get('/api/v1/admin/dashboard')

      expect(response.status).toBe(401)
    })
  })

  describe('User Management', () => {
    describe('GET /api/v1/admin/users', () => {
      it('should list all users', async () => {
        const response = await request(app)
          .get('/api/v1/admin/users')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('users')
        expect(Array.isArray(response.body.data.users)).toBe(true)
        expect(response.body).toHaveProperty('meta')
      })

      it('should support search', async () => {
        const response = await request(app)
          .get('/api/v1/admin/users?search=Rahul')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body.data.users.length).toBeGreaterThanOrEqual(0)
      })

      it('should support pagination', async () => {
        const response = await request(app)
          .get('/api/v1/admin/users?page=1&limit=2')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body.meta.page).toBe(1)
        expect(response.body.meta.limit).toBe(2)
      })
    })

    describe('GET /api/v1/admin/users/:userId', () => {
      it('should return user details', async () => {
        const user = await prisma.user.findFirst()

        if (user) {
          const response = await request(app)
            .get(`/api/v1/admin/users/${user.id}`)
            .set('Authorization', `Bearer ${adminToken}`)

          expect(response.status).toBe(200)
          expect(response.body).toHaveProperty('success', true)
          expect(response.body.data).toHaveProperty('user')
          expect(response.body.data.user.id).toBe(user.id)
        }
      })

      it('should return 404 for non-existent user', async () => {
        const response = await request(app)
          .get('/api/v1/admin/users/nonexistent-id')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(404)
      })
    })

    describe('PUT /api/v1/admin/users/:userId/status', () => {
      it('should update user status', async () => {
        const user = await prisma.user.findFirst({
          where: { isActive: true },
        })

        if (user) {
          // Suspend user
          const response = await request(app)
            .put(`/api/v1/admin/users/${user.id}/status`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({ isActive: false })

          expect(response.status).toBe(200)
          expect(response.body).toHaveProperty('success', true)
          expect(response.body.data.user.isActive).toBe(false)

          // Reactivate user
          await request(app)
            .put(`/api/v1/admin/users/${user.id}/status`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({ isActive: true })
        }
      })
    })
  })

  describe('Pilot Management', () => {
    describe('GET /api/v1/admin/pilots', () => {
      it('should list all pilots', async () => {
        const response = await request(app)
          .get('/api/v1/admin/pilots')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('pilots')
        expect(Array.isArray(response.body.data.pilots)).toBe(true)
      })

      it('should filter by status', async () => {
        const response = await request(app)
          .get('/api/v1/admin/pilots?status=APPROVED')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        response.body.data.pilots.forEach((pilot: any) => {
          expect(pilot.status).toBe('APPROVED')
        })
      })

      it('should filter by online status', async () => {
        const response = await request(app)
          .get('/api/v1/admin/pilots?online=true')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        response.body.data.pilots.forEach((pilot: any) => {
          expect(pilot.isOnline).toBe(true)
        })
      })
    })

    describe('GET /api/v1/admin/pilots/:pilotId', () => {
      it('should return pilot details', async () => {
        const pilot = await prisma.pilot.findFirst()

        if (pilot) {
          const response = await request(app)
            .get(`/api/v1/admin/pilots/${pilot.id}`)
            .set('Authorization', `Bearer ${adminToken}`)

          expect(response.status).toBe(200)
          expect(response.body).toHaveProperty('success', true)
          expect(response.body.data).toHaveProperty('pilot')
          expect(response.body.data.pilot.id).toBe(pilot.id)
        }
      })
    })

    describe('PUT /api/v1/admin/pilots/:pilotId/status', () => {
      it('should update pilot status', async () => {
        const pilot = await prisma.pilot.findFirst({
          where: { status: 'PENDING' },
        })

        if (pilot) {
          const response = await request(app)
            .put(`/api/v1/admin/pilots/${pilot.id}/status`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({
              status: 'APPROVED',
              reason: 'Approved by test',
            })

          expect(response.status).toBe(200)
          expect(response.body).toHaveProperty('success', true)
          expect(response.body.data.pilot.status).toBe('APPROVED')
        }
      })
    })
  })

  describe('Booking Management', () => {
    describe('GET /api/v1/admin/bookings', () => {
      it('should list all bookings', async () => {
        const response = await request(app)
          .get('/api/v1/admin/bookings')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('bookings')
        expect(Array.isArray(response.body.data.bookings)).toBe(true)
      })

      it('should filter by status', async () => {
        const response = await request(app)
          .get('/api/v1/admin/bookings?status=DELIVERED')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        response.body.data.bookings.forEach((booking: any) => {
          expect(booking.status).toBe('DELIVERED')
        })
      })
    })

    describe('GET /api/v1/admin/bookings/:bookingId', () => {
      it('should return booking details', async () => {
        const booking = await prisma.booking.findFirst()

        if (booking) {
          const response = await request(app)
            .get(`/api/v1/admin/bookings/${booking.id}`)
            .set('Authorization', `Bearer ${adminToken}`)

          expect(response.status).toBe(200)
          expect(response.body).toHaveProperty('success', true)
          expect(response.body.data).toHaveProperty('booking')
          expect(response.body.data.booking.id).toBe(booking.id)
        }
      })
    })

    describe('POST /api/v1/admin/bookings/:bookingId/cancel', () => {
      it('should cancel a booking', async () => {
        const booking = await prisma.booking.findFirst({
          where: { status: 'PENDING' },
        })

        if (booking) {
          const response = await request(app)
            .post(`/api/v1/admin/bookings/${booking.id}/cancel`)
            .set('Authorization', `Bearer ${adminToken}`)
            .send({ reason: 'Cancelled by admin test' })

          expect(response.status).toBe(200)
          expect(response.body).toHaveProperty('success', true)
          expect(response.body.data.booking.status).toBe('CANCELLED')
        }
      })
    })
  })

  describe('Settings Management', () => {
    describe('GET /api/v1/admin/settings', () => {
      it('should return all settings', async () => {
        const response = await request(app)
          .get('/api/v1/admin/settings')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('settings')
      })
    })

    describe('PUT /api/v1/admin/settings', () => {
      it('should update a setting', async () => {
        const response = await request(app)
          .put('/api/v1/admin/settings')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            key: 'base_fare',
            value: '30',
            description: 'Updated base fare for testing',
          })

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data.setting.key).toBe('base_fare')
      })
    })

    describe('PUT /api/v1/admin/settings/bulk', () => {
      it('should update multiple settings', async () => {
        const response = await request(app)
          .put('/api/v1/admin/settings/bulk')
          .set('Authorization', `Bearer ${adminToken}`)
          .send({
            settings: [
              { key: 'base_fare', value: '25' },
              { key: 'per_km_rate', value: '12' },
            ],
          })

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data.settings).toHaveLength(2)
      })
    })
  })

  describe('Analytics', () => {
    describe('GET /api/v1/admin/analytics/bookings', () => {
      it('should return booking analytics', async () => {
        const response = await request(app)
          .get('/api/v1/admin/analytics/bookings')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('totalBookings')
        expect(response.body.data).toHaveProperty('bookingsByStatus')
        expect(response.body.data).toHaveProperty('dailyBookings')
      })

      it('should support days parameter', async () => {
        const response = await request(app)
          .get('/api/v1/admin/analytics/bookings?days=7')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
      })
    })

    describe('GET /api/v1/admin/analytics/revenue', () => {
      it('should return revenue analytics', async () => {
        const response = await request(app)
          .get('/api/v1/admin/analytics/revenue')
          .set('Authorization', `Bearer ${adminToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('totalRevenue')
        expect(response.body.data).toHaveProperty('dailyRevenue')
      })
    })
  })
})
