import request from 'supertest'
import app from '../app'
import prisma from '../config/database'
import { testUsers, testAdmin } from './setup'

describe('Auth API', () => {
  describe('POST /api/v1/auth/request-otp', () => {
    it('should request OTP for existing user', async () => {
      const response = await request(app)
        .post('/api/v1/auth/request-otp')
        .send({ phone: testUsers.user1.phone })

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body).toHaveProperty('message')
      // In development mode, OTP is returned
      if (response.body.data?.otp) {
        expect(response.body.data.otp).toHaveLength(6)
      }
    })

    it('should request OTP for new user (registers new)', async () => {
      const newPhone = '+919999888877'
      const response = await request(app)
        .post('/api/v1/auth/request-otp')
        .send({ phone: newPhone })

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)

      // Cleanup: Delete the newly created user
      await prisma.user.deleteMany({ where: { phone: newPhone } })
    })

    it('should reject invalid phone format', async () => {
      const response = await request(app)
        .post('/api/v1/auth/request-otp')
        .send({ phone: '12345' })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })

    it('should reject missing phone', async () => {
      const response = await request(app)
        .post('/api/v1/auth/request-otp')
        .send({})

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })
  })

  describe('POST /api/v1/auth/verify-otp', () => {
    it('should verify valid OTP and return token', async () => {
      // First request OTP
      const otpResponse = await request(app)
        .post('/api/v1/auth/request-otp')
        .send({ phone: testUsers.user1.phone })

      const otp = otpResponse.body.data?.otp

      if (otp) {
        // Verify OTP
        const response = await request(app)
          .post('/api/v1/auth/verify-otp')
          .send({
            phone: testUsers.user1.phone,
            otp: otp,
          })

        expect(response.status).toBe(200)
        expect(response.body).toHaveProperty('success', true)
        expect(response.body.data).toHaveProperty('token')
        expect(response.body.data).toHaveProperty('user')
      }
    })

    it('should reject invalid OTP', async () => {
      const response = await request(app)
        .post('/api/v1/auth/verify-otp')
        .send({
          phone: testUsers.user1.phone,
          otp: '000000',
        })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })

    it('should reject missing fields', async () => {
      const response = await request(app)
        .post('/api/v1/auth/verify-otp')
        .send({ phone: testUsers.user1.phone })

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })
  })

  describe('POST /api/v1/auth/admin/login', () => {
    it('should login admin with valid credentials', async () => {
      const response = await request(app)
        .post('/api/v1/auth/admin/login')
        .send({
          email: testAdmin.email,
          password: testAdmin.password,
        })

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body.data).toHaveProperty('token')
      expect(response.body.data).toHaveProperty('admin')
      expect(response.body.data.admin.email).toBe(testAdmin.email)
    })

    it('should reject invalid password', async () => {
      const response = await request(app)
        .post('/api/v1/auth/admin/login')
        .send({
          email: testAdmin.email,
          password: 'wrongpassword',
        })

      expect(response.status).toBe(401)
      expect(response.body).toHaveProperty('success', false)
    })

    it('should reject non-existent admin', async () => {
      const response = await request(app)
        .post('/api/v1/auth/admin/login')
        .send({
          email: 'nonexistent@sendit.co.in',
          password: 'password',
        })

      expect(response.status).toBe(401)
      expect(response.body).toHaveProperty('success', false)
    })

    it('should reject missing credentials', async () => {
      const response = await request(app)
        .post('/api/v1/auth/admin/login')
        .send({})

      expect(response.status).toBe(400)
      expect(response.body).toHaveProperty('success', false)
    })
  })

  describe('POST /api/v1/auth/pilot/request-otp', () => {
    it('should request OTP for pilot registration', async () => {
      const response = await request(app)
        .post('/api/v1/auth/pilot/request-otp')
        .send({ phone: '+919111222333' })

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)

      // Cleanup
      await prisma.pilot.deleteMany({ where: { phone: '+919111222333' } })
    })
  })
})
