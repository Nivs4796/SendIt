import swaggerJsdoc from 'swagger-jsdoc'

const options: swaggerJsdoc.Options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'SendIt API',
      version: '1.0.0',
      description: 'SendIt Delivery Platform API Documentation',
      contact: {
        name: 'SendIt Team',
        email: 'support@sendit.co.in',
      },
    },
    servers: [
      {
        url: 'http://localhost:5000/api/v1',
        description: 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
      schemas: {
        // Standard Error Response
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string', example: 'Error message' },
            code: { type: 'string', example: 'ERR_1001', description: 'Error code for programmatic handling' },
            errors: {
              type: 'array',
              description: 'Validation errors (only present for validation failures)',
              items: {
                type: 'object',
                properties: {
                  field: { type: 'string', example: 'email' },
                  message: { type: 'string', example: 'Invalid email format' },
                },
              },
            },
          },
        },
        // Success Response
        Success: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            message: { type: 'string', example: 'Operation successful' },
            data: { type: 'object' },
          },
        },
        // Pagination Meta
        PaginationMeta: {
          type: 'object',
          properties: {
            page: { type: 'integer', example: 1 },
            limit: { type: 'integer', example: 10 },
            total: { type: 'integer', example: 100 },
            totalPages: { type: 'integer', example: 10 },
          },
        },
        // User Schema
        User: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            phone: { type: 'string', example: '+919876543210' },
            email: { type: 'string', format: 'email' },
            name: { type: 'string' },
            avatar: { type: 'string', format: 'uri' },
            isVerified: { type: 'boolean' },
            isActive: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        // Pilot Schema
        Pilot: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            phone: { type: 'string' },
            name: { type: 'string' },
            email: { type: 'string', format: 'email' },
            status: {
              type: 'string',
              enum: ['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'],
            },
            rating: { type: 'number', minimum: 0, maximum: 5 },
            totalDeliveries: { type: 'integer' },
            isOnline: { type: 'boolean' },
            currentLocation: {
              type: 'object',
              properties: {
                lat: { type: 'number' },
                lng: { type: 'number' },
              },
            },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // Booking Schema
        Booking: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            bookingNumber: { type: 'string', example: 'BK-123456' },
            status: {
              type: 'string',
              enum: ['PENDING', 'SEARCHING', 'CONFIRMED', 'PILOT_ARRIVED', 'PICKED_UP', 'IN_TRANSIT', 'DELIVERED', 'CANCELLED'],
            },
            totalAmount: { type: 'number' },
            distance: { type: 'number', description: 'Distance in kilometers' },
            pickupAddress: { $ref: '#/components/schemas/Address' },
            dropAddress: { $ref: '#/components/schemas/Address' },
            pilot: { $ref: '#/components/schemas/Pilot' },
            vehicle: { $ref: '#/components/schemas/Vehicle' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // Address Schema
        Address: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            label: { type: 'string', example: 'Home' },
            address: { type: 'string' },
            city: { type: 'string' },
            state: { type: 'string' },
            pincode: { type: 'string', pattern: '^[0-9]{6}$' },
            lat: { type: 'number', minimum: -90, maximum: 90 },
            lng: { type: 'number', minimum: -180, maximum: 180 },
            isDefault: { type: 'boolean' },
          },
        },
        // Vehicle Type Schema
        VehicleType: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            name: { type: 'string', example: 'Bike' },
            description: { type: 'string' },
            maxWeight: { type: 'number', description: 'Maximum weight in kg' },
            basePrice: { type: 'number' },
            pricePerKm: { type: 'number' },
            icon: { type: 'string', format: 'uri' },
            isActive: { type: 'boolean' },
          },
        },
        // Vehicle Schema
        Vehicle: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            registrationNo: { type: 'string', example: 'MH12AB1234' },
            model: { type: 'string' },
            color: { type: 'string' },
            vehicleType: { $ref: '#/components/schemas/VehicleType' },
            isActive: { type: 'boolean' },
            isVerified: { type: 'boolean' },
          },
        },
        // Review Schema
        Review: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            rating: { type: 'integer', minimum: 1, maximum: 5 },
            comment: { type: 'string' },
            booking: { $ref: '#/components/schemas/Booking' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // Coupon Schema
        Coupon: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            code: { type: 'string', example: 'WELCOME50' },
            description: { type: 'string' },
            discountType: {
              type: 'string',
              enum: ['PERCENTAGE', 'FIXED'],
            },
            discountValue: { type: 'number' },
            minOrderAmount: { type: 'number' },
            maxDiscount: { type: 'number' },
            usageLimit: { type: 'integer' },
            usedCount: { type: 'integer' },
            perUserLimit: { type: 'integer' },
            isActive: { type: 'boolean' },
            expiresAt: { type: 'string', format: 'date-time' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // Wallet Schema
        Wallet: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            userId: { type: 'string', format: 'uuid' },
            balance: { type: 'number', example: 500.0 },
            currency: { type: 'string', example: 'INR' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        // Wallet Transaction Schema
        WalletTransaction: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            type: { type: 'string', enum: ['CREDIT', 'DEBIT'] },
            amount: { type: 'number' },
            balance: { type: 'number', description: 'Balance after transaction' },
            description: { type: 'string' },
            referenceType: { type: 'string', enum: ['BOOKING', 'REFUND', 'BONUS', 'TOPUP'] },
            referenceId: { type: 'string' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // Job Offer Schema
        JobOffer: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            booking: { $ref: '#/components/schemas/Booking' },
            status: {
              type: 'string',
              enum: ['PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED'],
            },
            offeredAt: { type: 'string', format: 'date-time' },
            expiresAt: { type: 'string', format: 'date-time' },
            respondedAt: { type: 'string', format: 'date-time' },
          },
        },
        // Pilot Match Schema
        PilotMatch: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            name: { type: 'string' },
            phone: { type: 'string' },
            distance: { type: 'number', description: 'Distance in km' },
            rating: { type: 'number' },
            score: { type: 'number', description: 'Matching score (0-100)' },
            vehicle: { $ref: '#/components/schemas/Vehicle' },
          },
        },
        // Document Schema
        Document: {
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid' },
            type: {
              type: 'string',
              enum: ['DRIVING_LICENSE', 'AADHAR', 'PAN', 'RC', 'INSURANCE'],
            },
            fileUrl: { type: 'string', format: 'uri' },
            status: {
              type: 'string',
              enum: ['PENDING', 'APPROVED', 'REJECTED'],
            },
            rejectedReason: { type: 'string' },
            verifiedAt: { type: 'string', format: 'date-time' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        // Dashboard Stats Schema
        DashboardStats: {
          type: 'object',
          properties: {
            totalUsers: { type: 'integer' },
            totalPilots: { type: 'integer' },
            totalBookings: { type: 'integer' },
            totalRevenue: { type: 'number' },
            pendingPilots: { type: 'integer' },
            activeBookings: { type: 'integer' },
            todayBookings: { type: 'integer' },
            todayRevenue: { type: 'number' },
          },
        },
        // Setting Schema
        Setting: {
          type: 'object',
          properties: {
            key: { type: 'string', example: 'base_price' },
            value: { type: 'string' },
            description: { type: 'string' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
      },
      responses: {
        BadRequest: {
          description: 'Bad Request - Validation failed',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'Validation failed',
                code: 'ERR_1001',
                errors: [
                  { field: 'email', message: 'Invalid email format' },
                ],
              },
            },
          },
        },
        Unauthorized: {
          description: 'Unauthorized - Authentication required',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'Authentication required',
                code: 'ERR_1100',
              },
            },
          },
        },
        Forbidden: {
          description: 'Forbidden - Insufficient permissions',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'Insufficient permissions',
                code: 'ERR_1201',
              },
            },
          },
        },
        NotFound: {
          description: 'Not Found - Resource not found',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'Resource not found',
                code: 'ERR_1002',
              },
            },
          },
        },
        TooManyRequests: {
          description: 'Too Many Requests - Rate limit exceeded',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'Too many requests, please try again later',
                code: 'ERR_1003',
              },
            },
          },
        },
        InternalError: {
          description: 'Internal Server Error',
          content: {
            'application/json': {
              schema: { $ref: '#/components/schemas/Error' },
              example: {
                success: false,
                message: 'Internal server error',
                code: 'ERR_1000',
              },
            },
          },
        },
      },
    },
    tags: [
      { name: 'System', description: 'System health and status' },
      { name: 'Auth', description: 'Authentication endpoints' },
      { name: 'Users', description: 'User management' },
      { name: 'Pilots', description: 'Pilot management' },
      { name: 'Bookings', description: 'Booking management' },
      { name: 'Addresses', description: 'Address management' },
      { name: 'Vehicles', description: 'Vehicle management' },
      { name: 'Reviews', description: 'Review management' },
      { name: 'Coupons', description: 'Coupon management' },
      { name: 'Wallet', description: 'Wallet and transactions' },
      { name: 'Matching', description: 'Pilot-booking matching system' },
      { name: 'Admin', description: 'Admin dashboard and management' },
    ],
  },
  apis: ['./src/routes/*.ts'],
}

export const swaggerSpec = swaggerJsdoc(options)
