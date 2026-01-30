import request from 'supertest'
import app from '../app'

describe('Health API', () => {
  describe('GET /api/v1/health', () => {
    it('should return health status', async () => {
      const response = await request(app).get('/api/v1/health')

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body).toHaveProperty('message', 'SendIt API is running')
      expect(response.body).toHaveProperty('timestamp')
      expect(response.body).toHaveProperty('version', '1.0.0')
    })
  })

  describe('GET /', () => {
    it('should return welcome message', async () => {
      const response = await request(app).get('/')

      expect(response.status).toBe(200)
      expect(response.body).toHaveProperty('success', true)
      expect(response.body).toHaveProperty('message', 'Welcome to SendIt API')
      expect(response.body).toHaveProperty('version', '1.0.0')
      expect(response.body).toHaveProperty('docs', '/api-docs')
    })
  })

  describe('GET /nonexistent', () => {
    it('should return 404 for unknown routes', async () => {
      const response = await request(app).get('/nonexistent')

      expect(response.status).toBe(404)
      expect(response.body).toHaveProperty('success', false)
    })
  })
})
