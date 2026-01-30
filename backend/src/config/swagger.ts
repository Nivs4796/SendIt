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
        Error: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string' },
            errors: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  field: { type: 'string' },
                  message: { type: 'string' },
                },
              },
            },
          },
        },
        User: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            phone: { type: 'string' },
            email: { type: 'string' },
            name: { type: 'string' },
            avatar: { type: 'string' },
            isVerified: { type: 'boolean' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Pilot: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            phone: { type: 'string' },
            name: { type: 'string' },
            email: { type: 'string' },
            status: { type: 'string', enum: ['PENDING', 'APPROVED', 'REJECTED', 'SUSPENDED'] },
            rating: { type: 'number' },
            totalDeliveries: { type: 'integer' },
            isOnline: { type: 'boolean' },
          },
        },
        Booking: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            bookingNumber: { type: 'string' },
            status: { type: 'string', enum: ['PENDING', 'ACCEPTED', 'ARRIVED_PICKUP', 'PICKED_UP', 'IN_TRANSIT', 'ARRIVED_DROP', 'DELIVERED', 'CANCELLED'] },
            totalAmount: { type: 'number' },
            distance: { type: 'number' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        Address: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            label: { type: 'string' },
            address: { type: 'string' },
            city: { type: 'string' },
            state: { type: 'string' },
            pincode: { type: 'string' },
            lat: { type: 'number' },
            lng: { type: 'number' },
          },
        },
        VehicleType: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            name: { type: 'string' },
            description: { type: 'string' },
            maxWeight: { type: 'number' },
            basePrice: { type: 'number' },
            pricePerKm: { type: 'number' },
          },
        },
        Vehicle: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            registrationNo: { type: 'string' },
            model: { type: 'string' },
            color: { type: 'string' },
            isActive: { type: 'boolean' },
            isVerified: { type: 'boolean' },
          },
        },
        Review: {
          type: 'object',
          properties: {
            id: { type: 'string' },
            rating: { type: 'number', minimum: 1, maximum: 5 },
            comment: { type: 'string' },
            createdAt: { type: 'string', format: 'date-time' },
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
    ],
  },
  apis: ['./src/routes/*.ts'],
}

export const swaggerSpec = swaggerJsdoc(options)
