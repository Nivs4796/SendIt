import app from './app'
import prisma from './config/database'
import logger from './config/logger'
import { config } from './config'

// Start server
const startServer = async () => {
  try {
    await prisma.$connect()
    logger.info('Database connected successfully')

    app.listen(config.port, () => {
      logger.info(`
🚀 SendIt API Server Started
━━━━━━━━━━━━━━━━━━━━━━━━━━━
📡 Port: ${config.port}
🌍 Environment: ${config.nodeEnv}
🔗 URL: ${config.appUrl}
📚 API Docs: ${config.appUrl}/api-docs
📊 Health: ${config.appUrl}/api/v1/health
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
  await prisma.$disconnect()
  process.exit(0)
})

process.on('SIGTERM', async () => {
  logger.info('SIGTERM received. Shutting down gracefully...')
  await prisma.$disconnect()
  process.exit(0)
})

startServer()

export default app
