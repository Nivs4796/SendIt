import express, { Application } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import swaggerUi from 'swagger-ui-express'
import { config } from './config'
import { swaggerSpec } from './config/swagger'
import routes from './routes'
import { errorHandler, notFoundHandler } from './middleware/errorHandler'
import { httpLogger } from './middleware/httpLogger'
import { apiLimiter } from './middleware/rateLimiter'

const app: Application = express()

// Security middleware
app.use(helmet())

// CORS configuration - allow multiple origins for development
const allowedOrigins = [
  config.clientUrl,
  'http://localhost:3000',
  'http://localhost:3001',
  'http://localhost:3002',
  'http://localhost:3003',
]

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true)

    if (allowedOrigins.includes(origin)) {
      callback(null, true)
    } else {
      callback(null, true) // Allow all origins in development
    }
  },
  credentials: true,
}))

// Logging (skip in test environment)
if (process.env.NODE_ENV !== 'test') {
  app.use(httpLogger)
}

// Body parsing
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true }))

// Rate limiting (skip in test environment for faster tests)
if (process.env.NODE_ENV !== 'test') {
  app.use('/api', apiLimiter)
}

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

export default app
