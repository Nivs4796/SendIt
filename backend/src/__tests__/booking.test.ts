import request from 'supertest'
import app from '../app'
import prisma from '../config/database'
import { generateTestToken } from './setup'

describe('Booking API', () => {
  let userToken: string
  let userId: string
  let testBookingId: string

  beforeAll(async () => {
    // Get a test user
    const user = await prisma.user.findFirst({
      where: { phone: '+919876543210' },
    })
    if (user) {
      userId = user.id
      userToken = generateTestToken({ id: user.id, type: 'user' })
    }
  })

  describe('GET /api/v1/bookings/vehicle-types', () => {
    it('should return vehicle types without auth', async () => {
      const response = await request(app).get('/api/v1/bookings/vehicle-types')

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('vehicleTypes')
      expect(Array.isArray(response.body.data.vehicleTypes)).toBe(true)
      expect(response.body.data.vehicleTypes.length).toBeGreaterThan(0)
    })
  })

  describe('POST /api/v1/bookings/estimate', () => {
    it('should calculate price estimate with auth', async () => {
      const vehicleType = await prisma.vehicleType.findFirst()

      const response = await request(app)
        .post('/api/v1/bookings/estimate')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          vehicleTypeId: vehicleType?.id,
          pickupLat: 23.0225,
          pickupLng: 72.5714,
          dropLat: 23.0300,
          dropLng: 72.5800,
        })

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('distance')
      expect(response.body.data).toHaveProperty('estimatedPrice')
      expect(response.body.data).toHaveProperty('estimatedTime')
    })

    it('should reject estimate without auth', async () => {
      const response = await request(app)
        .post('/api/v1/bookings/estimate')
        .send({
          vehicleTypeId: 'some-id',
          pickupLat: 23.0225,
          pickupLng: 72.5714,
          dropLat: 23.0300,
          dropLng: 72.5800,
        })

      expect(response.status).toBe(401)
    })
  })

  describe('POST /api/v1/bookings', () => {
    it('should create a new booking', async () => {
      const vehicleType = await prisma.vehicleType.findFirst()

      const response = await request(app)
        .post('/api/v1/bookings')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          vehicleTypeId: vehicleType?.id,
          pickupAddress: 'Test Pickup Address',
          pickupLat: 23.0225,
          pickupLng: 72.5714,
          dropAddress: 'Test Drop Address',
          dropLat: 23.0300,
          dropLng: 72.5800,
          packageType: 'SMALL',
          packageDescription: 'Test Package',
          paymentMethod: 'CASH',
        })

      expect(response.status).toBe(201)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('booking')
      expect(response.body.data.booking).toHaveProperty('id')
      expect(response.body.data.booking).toHaveProperty('status', 'PENDING')

      testBookingId = response.body.data.booking.id
    })

    it('should reject booking with missing fields', async () => {
      const response = await request(app)
        .post('/api/v1/bookings')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          vehicleTypeId: 'some-id',
        })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })
  })

  describe('GET /api/v1/bookings', () => {
    it('should return user bookings', async () => {
      const response = await request(app)
        .get('/api/v1/bookings')
        .set('Authorization', `Bearer ${userToken}`)

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('bookings')
      expect(Array.isArray(response.body.data.bookings)).toBe(true)
    })

    it('should reject without auth', async () => {
      const response = await request(app).get('/api/v1/bookings')

      expect(response.status).toBe(401)
    })
  })

  describe('GET /api/v1/bookings/:id', () => {
    it('should return specific booking', async () => {
      // Get an existing booking
      const booking = await prisma.booking.findFirst({
        where: { userId },
      })

      if (booking) {
        const response = await request(app)
          .get(`/api/v1/bookings/${booking.id}`)
          .set('Authorization', `Bearer ${userToken}`)

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('booking')
        expect(response.body.data.booking.id).toBe(booking.id)
      }
    })

    it('should return 404 for non-existent booking', async () => {
      const response = await request(app)
        .get('/api/v1/bookings/nonexistent-id')
        .set('Authorization', `Bearer ${userToken}`)

      expect(response.status).toBe(404)
    })
  })

  describe('POST /api/v1/bookings/:id/cancel', () => {
    it('should cancel a pending booking', async () => {
      // Create a new booking to cancel
      const vehicleType = await prisma.vehicleType.findFirst()
      const createResponse = await request(app)
        .post('/api/v1/bookings')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          vehicleTypeId: vehicleType?.id,
          pickupAddress: 'Cancel Test Pickup',
          pickupLat: 23.0225,
          pickupLng: 72.5714,
          dropAddress: 'Cancel Test Drop',
          dropLat: 23.0300,
          dropLng: 72.5800,
          packageType: 'SMALL',
          packageDescription: 'Package to cancel',
          paymentMethod: 'CASH',
        })

      const bookingId = createResponse.body.data?.booking?.id

      if (bookingId) {
        const response = await request(app)
          .post(`/api/v1/bookings/${bookingId}/cancel`)
          .set('Authorization', `Bearer ${userToken}`)
          .send({ reason: 'Test cancellation' })

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data.booking.status).toBe('CANCELLED')
      }
    })
  })

  afterAll(async () => {
    // Cleanup test bookings
    if (testBookingId) {
      await prisma.booking.deleteMany({
        where: {
          id: testBookingId,
        },
      })
    }
  })
})
