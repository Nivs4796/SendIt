# Error Handling & Response Standards

## 1. Overview

This document defines the standard error handling approach, error codes, and response formats across all platforms (Backend API, Mobile Apps, Admin Dashboard).

---

## 2. Standard Error Response Format

### 2.1 API Error Response

All API errors should follow this JSON structure:

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "User-friendly error message",
    "details": "Technical details (optional, dev mode only)",
    "field": "fieldName (for validation errors)",
    "timestamp": "2026-01-29T10:30:00Z",
    "path": "/api/v1/orders",
    "requestId": "uuid"
  }
}
```

### 2.2 Success Response Format

```json
{
  "success": true,
  "data": { /* response data */ },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150
  }
}
```

---

## 3. HTTP Status Codes

| Status Code | Usage |
|-------------|-------|
| **200 OK** | Successful GET, PUT, PATCH requests |
| **201 Created** | Successful POST request (resource created) |
| **204 No Content** | Successful DELETE request |
| **400 Bad Request** | Validation errors, malformed requests |
| **401 Unauthorized** | Missing or invalid authentication |
| **403 Forbidden** | Valid auth but insufficient permissions |
| **404 Not Found** | Resource not found |
| **409 Conflict** | Resource conflict (duplicate, state issue) |
| **422 Unprocessable Entity** | Validation failed |
| **429 Too Many Requests** | Rate limit exceeded |
| **500 Internal Server Error** | Server error |
| **503 Service Unavailable** | Maintenance mode, service down |

---

## 4. Error Codes Catalog

### 4.1 Authentication Errors (1xxx)

| Code | Message | HTTP Status |
|------|---------|-------------|
| `AUTH_1001` | Invalid or expired token | 401 |
| `AUTH_1002` | Missing authentication token | 401 |
| `AUTH_1003` | Invalid OTP | 400 |
| `AUTH_1004` | OTP expired | 400 |
| `AUTH_1005` | Maximum OTP attempts exceeded | 429 |
| `AUTH_1006` | Phone number not registered | 404 |
| `AUTH_1007` | Account suspended | 403 |
| `AUTH_1008` | Invalid refresh token | 401 |

### 4.2 Validation Errors (2xxx)

| Code | Message | HTTP Status |
|------|---------|-------------|
| `VAL_2001` | Invalid phone number format | 400 |
| `VAL_2002` | Invalid email format | 400 |
| `VAL_2003` | Required field missing | 400 |
| `VAL_2004` | Invalid date format | 400 |
| `VAL_2005` | Value out of range | 400 |
| `VAL_2006` | Invalid file type | 400 |
| `VAL_2007` | File size exceeds limit | 400 |
| `VAL_2008` | Invalid coordinates | 400 |

### 4.3 Order Errors (3xxx)

| Code | Message | HTTP Status |
|------|---------|-------------|
| `ORD_3001` | Order not found | 404 |
| `ORD_3002` | Cannot cancel order (already in progress) | 409 |
| `ORD_3003` | No drivers available | 503 |
| `ORD_3004` | Pickup location outside service area | 400 |
| `ORD_3005` | Drop location outside service area | 400 |
| `ORD_3006` | Distance exceeds vehicle capacity | 400 |
| `ORD_3007` | Order already cancelled | 409 |
| `ORD_3008` | Order already completed | 409 |
| `ORD_3009` | Scheduled time must be in future | 400 |
| `ORD_3010` | Scheduled time outside operating hours | 400 |

### 4.4 Payment Errors (4xxx)

| Code | Message | HTTP Status |
|------|---------|-------------|
| `PAY_4001` | Payment failed | 400 |
| `PAY_4002` | Insufficient wallet balance | 400 |
| `PAY_4003` | Invalid payment method | 400 |
| `PAY_4004` | Payment gateway error | 502 |
| `PAY_4005` | Refund failed | 500 |
| `PAY_4006` | Invalid coupon code | 400 |
| `PAY_4007` | Coupon expired | 400 |
| `PAY_4008` | Coupon usage limit exceeded | 400 |
| `PAY_4009` | Minimum order value not met | 400 |
| `PAY_4010` | Transaction already processed | 409 |

### 4.5 Pilot Errors (5xxx)

| Code | Message | HTTP Status |
|------|---------|-------------|
| `PIL_5001` | Pilot not found | 404 |
| `PIL_5002` | Pilot verification pending | 403 |
| `PIL_5003` | Pilot verification rejected | 403 |
| `PIL_5004` | Pilot is offline | 400 |
| `PIL_5005` | Pilot already has active job | 409 |
| `PIL_5006` | Invalid vehicle type | 400 |
| `PIL_5007` | Vehicle not verified | 403 |
| `PIL_5008` | Document expired | 400 |
| `PIL_5009` | Minimum age requirement not met | 400 |
| `PIL_5010` | Job acceptance timeout | 408 |

### 4.6 Wallet Errors (6xxx)

| Code | Message | HTTP Status |
|------|---------|-------------|
| `WAL_6001` | Insufficient balance | 400 |
| `WAL_6002` | Below minimum withdrawal amount | 400 |
| `WAL_6003` | Withdrawal limit exceeded | 400 |
| `WAL_6004` | Bank details not verified | 403 |
| `WAL_6005` | Transaction not found | 404 |
| `WAL_6006` | Transaction already reversed | 409 |

### 4.7 System Errors (9xxx)

| Code | Message | HTTP Status |
|------|---------|-------------|
| `SYS_9001` | Internal server error | 500 |
| `SYS_9002` | Database connection error | 500 |
| `SYS_9003` | External service unavailable | 503 |
| `SYS_9004` | Rate limit exceeded | 429 |
| `SYS_9005` | Maintenance mode active | 503 |
| `SYS_9006` | Request timeout | 408 |

---

## 5. Validation Error Format

For multiple validation errors:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more fields are invalid",
    "errors": [
      {
        "field": "phone",
        "code": "VAL_2001",
        "message": "Invalid phone number format"
      },
      {
        "field": "email",
        "code": "VAL_2002",
        "message": "Invalid email format"
      }
    ]
  }
}
```

---

## 6. Backend Implementation

### 6.1 Error Handler Middleware

```typescript
// middleware/errorHandler.ts
export class AppError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    public message: string,
    public field?: string,
    public details?: any
  ) {
    super(message);
  }
}

export const errorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const statusCode = err.statusCode || 500;
  const code = err.code || 'SYS_9001';
  
  const response = {
    success: false,
    error: {
      code,
      message: err.message,
      field: err.field,
      timestamp: new Date().toISOString(),
      path: req.path,
      requestId: req.id
    }
  };
  
  // Only include details in development
  if (process.env.NODE_ENV === 'development') {
    response.error.details = err.details || err.stack;
  }
  
  // Log error
  logger.error('API Error', {
    code,
    message: err.message,
    path: req.path,
    method: req.method,
    userId: req.user?.id,
    stack: err.stack
  });
  
  res.status(statusCode).json(response);
};
```

### 6.2 Usage in Controllers

```typescript
// controllers/orderController.ts
export const createOrder = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { pickup_lat, pickup_lng, drop_lat, drop_lng } = req.body;
    
    // Check service area
    if (!isInServiceArea(pickup_lat, pickup_lng)) {
      throw new AppError(
        400,
        'ORD_3004',
        'Pickup location is outside our service area',
        'pickup_location'
      );
    }
    
    // Create order logic
    const order = await orderService.create(req.body);
    
    res.status(201).json({
      success: true,
      data: order
    });
  } catch (error) {
    next(error);
  }
};
```

---

## 7. Mobile App Error Handling (Flutter)

### 7.1 Error Model

```dart
// models/api_error.dart
class ApiError {
  final String code;
  final String message;
  final String? field;
  final String? details;
  
  ApiError({
    required this.code,
    required this.message,
    this.field,
    this.details,
  });
  
  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['error']['code'],
      message: json['error']['message'],
      field: json['error']['field'],
      details: json['error']['details'],
    );
  }
  
  // User-friendly message mapping
  String get userMessage {
    switch (code) {
      case 'AUTH_1003':
        return 'Invalid OTP. Please try again.';
      case 'ORD_3003':
        return 'No drivers available nearby. Please try again in a few minutes.';
      case 'PAY_4002':
        return 'Insufficient wallet balance. Please add money to continue.';
      default:
        return message;
    }
  }
}
```

### 7.2 API Client with Error Handling

```dart
// services/api_client.dart
class ApiClient {
  final Dio _dio;
  
  Future<Response> request(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  ApiError _handleError(DioException error) {
    if (error.response != null) {
      return ApiError.fromJson(error.response!.data);
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return ApiError(
        code: 'SYS_9006',
        message: 'Connection timeout. Please check your internet.',
      );
    } else {
      return ApiError(
        code: 'SYS_9001',
        message: 'Something went wrong. Please try again.',
      );
    }
  }
}
```

### 7.3 UI Error Display

```dart
// widgets/error_snackbar.dart
void showErrorSnackbar(BuildContext context, ApiError error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.userMessage),
      backgroundColor: Colors.red,
      action: error.code.startsWith('ORD_') 
        ? SnackBarAction(
            label: 'Retry',
            onPressed: () {
              // Retry logic
            },
          )
        : null,
    ),
  );
}
```

---

## 8. Retry Logic

### 8.1 Backend - Exponential Backoff

```typescript
// utils/retry.ts
export async function retryWithBackoff<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  baseDelay: number = 1000
): Promise<T> {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      if (attempt === maxRetries - 1) throw error;
      
      const delay = baseDelay * Math.pow(2, attempt);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
  throw new Error('Max retries exceeded');
}

// Usage
const result = await retryWithBackoff(
  () => paymentGateway.charge(amount),
  3,
  2000
);
```

### 8.2 Mobile - Network Error Retry

```dart
// services/retry_interceptor.dart
class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
  
  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           (err.response?.statusCode ?? 0) >= 500;
  }
  
  Future<Response> _retry(RequestOptions options) async {
    await Future.delayed(Duration(seconds: 2));
    return await Dio().fetch(options);
  }
}
```

---

## 9. Offline Error Handling

### 9.1 Mobile - Queue Failed Requests

```dart
// services/offline_queue.dart
class OfflineQueue {
  final box = Hive.box('offline_requests');
  
  Future<void> queueRequest(String endpoint, Map<String, dynamic> data) async {
    await box.add({
      'endpoint': endpoint,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  Future<void> syncPendingRequests() async {
    final requests = box.values.toList();
    
    for (var request in requests) {
      try {
        await apiClient.post(request['endpoint'], data: request['data']);
        await box.delete(request.key);
      } catch (e) {
        // Keep in queue for later
      }
    }
  }
}
```

---

## 10. Error Logging & Monitoring

### 10.1 Backend Logging

```typescript
// utils/logger.ts
import winston from 'winston';

export const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' }),
  ],
});

// Log with context
logger.error('Order creation failed', {
  errorCode: 'ORD_3003',
  userId: 'uuid',
  orderData: {...},
  timestamp: new Date(),
});
```

### 10.2 Sentry Integration

```typescript
// app.ts
import * as Sentry from '@sentry/node';

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
});

// Capture errors
app.use(Sentry.Handlers.requestHandler());
app.use(Sentry.Handlers.errorHandler());
```

---

## 11. User-Friendly Error Messages

### Mapping Technical Errors to User Messages

| Technical Error | User-Friendly Message |
|----------------|----------------------|
| `Database connection failed` | "We're experiencing technical difficulties. Please try again." |
| `Payment gateway timeout` | "Payment is taking longer than expected. Please check your bank app." |
| `No drivers in radius` | "No drivers available nearby. We'll keep searching for you." |
| `Invalid token` | "Your session has expired. Please login again." |
| `Validation error` | "Please check the highlighted fields and try again." |

---

## 12. Best Practices

1. **Always return consistent JSON structure**
2. **Use appropriate HTTP status codes**
3. **Include error codes for programmatic handling**
4. **Log all errors server-side**
5. **Never expose sensitive data in error messages**
6. **Provide actionable error messages**
7. **Implement retry logic for network errors**
8. **Queue failed requests when offline**
9. **Monitor error rates in production**
10. **Test error scenarios thoroughly**

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29  
**Status:** Production Ready
