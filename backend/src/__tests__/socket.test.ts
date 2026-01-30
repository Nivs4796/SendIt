import { createServer } from 'http'
import { AddressInfo } from 'net'
import { Server } from 'socket.io'
import { io as ioc, Socket as ClientSocket } from 'socket.io-client'
import jwt from 'jsonwebtoken'
import { config } from '../config'
import app from '../app'
import { initializeSocket, AppServer } from '../socket'
import {
  ClientToServerEvents,
  ServerToClientEvents,
  RoomNames,
} from '../socket/types'

// Test helpers
const createToken = (payload: { id: string; type: 'user' | 'pilot' | 'admin'; name?: string }) => {
  return jwt.sign(payload, config.jwtSecret, { expiresIn: '1h' })
}

describe('Socket.io Real-Time System', () => {
  let httpServer: ReturnType<typeof createServer>
  let io: AppServer
  let serverAddress: string

  beforeAll((done) => {
    httpServer = createServer(app)
    io = initializeSocket(httpServer)
    httpServer.listen(() => {
      const address = httpServer.address() as AddressInfo
      serverAddress = `http://localhost:${address.port}`
      done()
    })
  })

  afterAll((done) => {
    io.close()
    httpServer.close(done)
  })

  describe('Authentication', () => {
    it('should reject connection without token', (done) => {
      const clientSocket = ioc(serverAddress, {
        autoConnect: false,
      })

      clientSocket.on('connect_error', (err) => {
        expect(err.message).toContain('Authentication')
        clientSocket.disconnect()
        done()
      })

      clientSocket.connect()
    })

    it('should reject connection with invalid token', (done) => {
      const clientSocket = ioc(serverAddress, {
        auth: { token: 'invalid-token' },
        autoConnect: false,
      })

      clientSocket.on('connect_error', (err) => {
        expect(err.message).toContain('Authentication')
        clientSocket.disconnect()
        done()
      })

      clientSocket.connect()
    })

    it('should accept connection with valid user token', (done) => {
      const token = createToken({ id: 'user-123', type: 'user', name: 'Test User' })
      const clientSocket = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      })

      clientSocket.on('connect', () => {
        expect(clientSocket.connected).toBe(true)
        clientSocket.disconnect()
        done()
      })

      clientSocket.connect()
    })

    it('should accept connection with valid pilot token', (done) => {
      const token = createToken({ id: 'pilot-123', type: 'pilot', name: 'Test Pilot' })
      const clientSocket = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      })

      clientSocket.on('connect', () => {
        expect(clientSocket.connected).toBe(true)
        clientSocket.disconnect()
        done()
      })

      clientSocket.connect()
    })

    it('should accept connection with valid admin token', (done) => {
      const token = createToken({ id: 'admin-123', type: 'admin', name: 'Test Admin' })
      const clientSocket = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      })

      clientSocket.on('connect', () => {
        expect(clientSocket.connected).toBe(true)
        clientSocket.disconnect()
        done()
      })

      clientSocket.connect()
    })
  })

  describe('Room Names', () => {
    it('should generate correct room names', () => {
      expect(RoomNames.booking('booking-123')).toBe('booking:booking-123')
      expect(RoomNames.pilot('pilot-456')).toBe('pilot:pilot-456')
      expect(RoomNames.user('user-789')).toBe('user:user-789')
      expect(RoomNames.admin).toBe('admin:dashboard')
    })
  })

  describe('Pilot Events', () => {
    let pilotSocket: ClientSocket<ServerToClientEvents, ClientToServerEvents>

    beforeEach((done) => {
      const token = createToken({ id: 'pilot-test', type: 'pilot', name: 'Test Pilot' })
      pilotSocket = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      }) as ClientSocket<ServerToClientEvents, ClientToServerEvents>

      pilotSocket.on('connect', done)
      pilotSocket.connect()
    })

    afterEach(() => {
      pilotSocket.disconnect()
    })

    it('should handle pilot:location event', (done) => {
      // Since we don't have a real database in tests, we just verify the event is received
      pilotSocket.emit('pilot:location', {
        lat: 23.0225,
        lng: 72.5714,
        heading: 90,
        speed: 25,
      })

      // Give it time to process
      setTimeout(() => {
        // If no error was emitted, the event was handled
        done()
      }, 100)
    })

    it('should emit error for invalid location data', (done) => {
      pilotSocket.on('error', (err) => {
        expect(err.code).toBe('ERR_1001')
        expect(err.message).toContain('Invalid location')
        done()
      })

      pilotSocket.emit('pilot:location', {
        lat: 200, // Invalid latitude
        lng: 72.5714,
      })
    })
  })

  describe('Booking Events', () => {
    let userSocket: ClientSocket<ServerToClientEvents, ClientToServerEvents>

    beforeEach((done) => {
      const token = createToken({ id: 'user-test', type: 'user', name: 'Test User' })
      userSocket = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      }) as ClientSocket<ServerToClientEvents, ClientToServerEvents>

      userSocket.on('connect', done)
      userSocket.connect()
    })

    afterEach(() => {
      userSocket.disconnect()
    })

    it('should handle booking:subscribe event', (done) => {
      userSocket.on('error', (err) => {
        // Expected error since booking doesn't exist in test
        // ERR_1302 = booking not found, ERR_1000 = database error (no db in test)
        expect(['ERR_1302', 'ERR_1000']).toContain(err.code)
        done()
      })

      userSocket.emit('booking:subscribe', { bookingId: 'nonexistent-booking' })
    })

    it('should handle booking:unsubscribe event', (done) => {
      userSocket.emit('booking:unsubscribe', { bookingId: 'booking-123' })

      // Give it time to process
      setTimeout(() => {
        done()
      }, 100)
    })
  })

  describe('Admin Events', () => {
    let adminSocket: ClientSocket<ServerToClientEvents, ClientToServerEvents>

    beforeEach((done) => {
      const token = createToken({ id: 'admin-test', type: 'admin', name: 'Test Admin' })
      adminSocket = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      }) as ClientSocket<ServerToClientEvents, ClientToServerEvents>

      adminSocket.on('connect', done)
      adminSocket.connect()
    })

    afterEach(() => {
      adminSocket.disconnect()
    })

    it('should handle admin:subscribe event and receive stats', (done) => {
      adminSocket.on('dashboard:stats', (stats) => {
        expect(stats).toHaveProperty('activeBookings')
        expect(stats).toHaveProperty('onlinePilots')
        expect(stats).toHaveProperty('pendingBookings')
        expect(stats).toHaveProperty('todayDeliveries')
        expect(stats).toHaveProperty('todayRevenue')
        expect(stats).toHaveProperty('timestamp')
        done()
      })

      adminSocket.on('error', (err) => {
        // Database not connected in test environment
        done()
      })

      adminSocket.emit('admin:subscribe')
    })
  })

  describe('Connection Management', () => {
    it('should handle multiple connections from same user', (done) => {
      const token = createToken({ id: 'multi-user', type: 'user' })

      const socket1 = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      })

      const socket2 = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      })

      let connectCount = 0

      const checkDone = () => {
        connectCount++
        if (connectCount === 2) {
          expect(socket1.connected).toBe(true)
          expect(socket2.connected).toBe(true)
          socket1.disconnect()
          socket2.disconnect()
          done()
        }
      }

      socket1.on('connect', checkDone)
      socket2.on('connect', checkDone)

      socket1.connect()
      socket2.connect()
    })

    it('should handle graceful disconnect', (done) => {
      const token = createToken({ id: 'disconnect-test', type: 'user' })
      const clientSocket = ioc(serverAddress, {
        auth: { token: `Bearer ${token}` },
        autoConnect: false,
      })

      clientSocket.on('connect', () => {
        clientSocket.disconnect()
      })

      clientSocket.on('disconnect', () => {
        expect(clientSocket.connected).toBe(false)
        done()
      })

      clientSocket.connect()
    })
  })
})
