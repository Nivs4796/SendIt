import { createServer } from 'http'
import app from './app'
import prisma from './config/database'
import logger from './config/logger'
import { config } from './config'
import { initializeSocket } from './socket'

// Create HTTP server
const httpServer = createServer(app)

// Initialize Socket.io
const io = initializeSocket(httpServer)

// Start server
const startServer = async () => {
  try {
    await prisma.$connect()
    logger.info('Database connected successfully')

    httpServer.listen(config.port, () => {
      logger.info(`
🚀 SendIt API Server Started
━━━━━━━━━━━━━━━━━━━━━━━━━━━
📡 Port: ${config.port}
🌍 Environment: ${config.nodeEnv}
🔗 URL: ${config.appUrl}
📚 API Docs: ${config.appUrl}/api-docs
📊 Health: ${config.appUrl}/api/v1/health
🔌 WebSocket: Enabled
━━━━━━━━━━━━━━━━━━━━━━━━━━━
      `)
    })
  } catch (error) {
    logger.error('Failed to start server:', error)
    process.exit(1)
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  logger.info('Shutting down gracefully...')
  io.close()
  await prisma.$disconnect()
  process.exit(0)
})

process.on('SIGTERM', async () => {
  logger.info('SIGTERM received. Shutting down gracefully...')
  io.close()
  await prisma.$disconnect()
  process.exit(0)
})

startServer()

export { io }
export default app
