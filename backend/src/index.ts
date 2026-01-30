import express, { Application } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import swaggerUi from 'swagger-ui-express'
import { config } from './config'
import prisma from './config/database'
import logger from './config/logger'
import { swaggerSpec } from './config/swagger'
import routes from './routes'
import { errorHandler, notFoundHandler } from './middleware/errorHandler'
import { httpLogger } from './middleware/httpLogger'
import { apiLimiter } from './middleware/rateLimiter'

const app: Application = express()

// Security middleware
app.use(helmet())
app.use(cors({
  origin: config.clientUrl,
  credentials: true,
}))

// Logging
app.use(httpLogger)

// Body parsing
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true }))

// Rate limiting
app.use('/api', apiLimiter)

// API Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'SendIt API Docs',
}))

// API Routes
app.use('/api/v1', routes)

// Root route
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Welcome to SendIt API',
    version: '1.0.0',
    docs: '/api-docs',
    health: '/api/v1/health',
  })
})

// Error handlers
app.use(notFoundHandler)
app.use(errorHandler)

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
