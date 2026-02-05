import express, { Application } from 'express'
import cors from 'cors'
import helmet from 'helmet'
import path from 'path'
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

const isProduction = config.nodeEnv === 'production';

app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true)

    // In development, allow all origins
    if (!isProduction) return callback(null, true)

    // In production, check against allowed origins
    if (allowedOrigins.includes(origin)) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
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

// Static file serving for uploads
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads'), {
  maxAge: '1d', // Cache for 1 day
  etag: true,
}))

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
