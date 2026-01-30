# User Mobile App - Detailed Planning Document

## 1. Overview

The User App ("SendIt - Deliver with Ease") is the customer-facing mobile application for booking and tracking deliveries.

**Platform:** Flutter (iOS & Android)

## 2. Technology Stack

### Core
- **Framework:** Flutter 3.16+
- **Language:** Dart
- **Navigation:** GoRouter 13.x
- **State Management:** GetX
- **UI Components:** Material Design + Custom Widgets
- **Forms:** flutter_form_builder + form_builder_validators

### Key Packages
- **Maps:** google_maps_flutter
- **Location:** geolocator, geocoding
- **Payments:** razorpay_flutter
- **Notifications:** firebase_messaging
- **Camera:** image_picker
- **Storage:** shared_preferences, hive
- **WebSocket:** socket_io_client
- **HTTP:** dio with interceptors

## 3. App Architecture

### 3.1 Folder Structure
```
sendit_user/
├── lib/
│   ├── core/             # Core utilities
│   │   ├── api/          # API client
│   │   ├── constants/    # Constants & config
│   │   ├── theme/        # Design system
│   │   └── utils/        # Helper functions
│   ├── models/           # Data models
│   │   ├── user.dart
│   │   ├── order.dart
│   │   └── ...
│   ├── providers/        # State management
│   │   ├── auth_provider.dart
│   │   ├── order_provider.dart
│   │   ├── location_provider.dart
│   │   └── wallet_provider.dart
│   ├── screens/          # Screen widgets
│   │   ├── auth/
│   │   ├── home/
│   │   ├── booking/
│   │   ├── orders/
│   │   └── profile/
│   ├── widgets/          # Reusable widgets
│   │   ├── common/
│   │   ├── orders/
│   │   └── maps/
│   ├── services/         # Business logic
│   │   ├── location_service.dart
│   │   ├── socket_service.dart
│   │   └── payment_service.dart
│   ├── routes/           # Navigation/routing
│   │   └── app_router.dart
│   └── main.dart         # App entry point
├── assets/               # Images, fonts, icons
└── pubspec.yaml          # Dependencies
```

### 3.2 State Management (Riverpod)

**Providers:**
- `authProvider` - User authentication state
- `userProfileProvider` - User profile & preferences
- `orderProvider` - Active orders & history
- `locationProvider` - Current location, saved addresses
- `walletProvider` - Wallet balance & transactions
- `notificationProvider` - Notifications
- `referralProvider` - Referral data

**API Services (Dio + Retrofit):**
- `AuthApiService` - Authentication endpoints
- `OrderApiService` - Order management
- `WalletApiService` - Wallet operations
- `ProfileApiService` - User profile

## 4. Screen Specifications

### 4.1 Onboarding & Authentication

#### Screen 1: Splash Screen
**Components:**
- App logo with animation
- Loading indicator
- Auto-navigate after token check

**Logic:**
- Check AsyncStorage for auth token
- Validate token with backend
- Navigate to Home (if valid) or Login

#### Screen 2: Welcome/Onboarding (First Time)
**Components:**
- Swipeable carousel with 3-4 slides
- Feature highlights
- "Get Started" button

#### Screen 3: Phone Login
**Components:**
- Country code picker (+91 default)
- Phone number input (10 digits)
- "Send OTP" button
- Terms & Privacy links

**Validation:**
- Valid 10-digit phone number
- Country code required

**API Call:**
```typescript
POST /api/v1/auth/send-otp
{
  phone: "9484707535",
  country_code: "+91",
  user_type: "user"
}
```

#### Screen 4: OTP Verification
**Components:**
- 6-digit OTP input
- Auto-submit when complete
- Resend OTP button (60s countdown)
- Edit phone number option

**API Call:**
```typescript
POST /api/v1/auth/verify-otp
{
  otp_id: "uuid",
  otp: "123456",
  phone: "9484707535"
}
```

**Success Actions:**
- Store token in AsyncStorage
- Store user data in Redux
- Navigate to Profile Setup (new user) or Home

#### Screen 5: Profile Setup (New Users Only)
**Components:**
- Name input (required)
- Email input (optional)
- Profile picture upload (optional)
- "Continue" button

**API Call:**
```typescript
PUT /api/v1/users/profile
{
  name: "John Doe",
  email: "john@example.com"
}
```

### 4.2 Main Navigation

#### Bottom Tab Navigator
1. **Home** (House icon)
2. **Orders** (List icon)
3. **Wallet** (Wallet icon)
4. **Profile** (User icon)

### 4.3 Home Screen

#### Screen 6: Home
**Header:**
- Greeting: "Hello, [Name]" / "Good Morning"
- Notification bell icon (with badge count)

**Main Content:**
- Promotional banner (carousel)
- "Pickup Location" search input
- "Book SendIt for" section:
  - **Goods** card
  - **Passenger** card
- Vehicle category cards:
  - Cycle, 2 Wheeler, 3 Wheeler, Trucks
  - Each showing weight/distance limits

**Actions:**
- Tap location input → Navigate to Location Selection
- Tap Goods/Passenger → Set service type
- Tap vehicle card → Navigate to Booking Flow

**State Required:**
- Current location
- User profile
- Promotional banners (from API)

### 4.4 Booking Flow

#### Screen 7: Pickup Location Selection
**Components:**
- Search bar with autocomplete
- Map view with current location marker
- "Use Current Location" button
- Saved addresses list (Recent/Favorites)
- "Locate on Map" option
- Confirm button

**Features:**
- Google Places Autocomplete
- Draggable map pin
- Reverse geocoding
- Save new address option

**API Integration:**
- Google Places API
- Geocoding API

#### Screen 8: Drop Location Selection
**Similar to Pickup Screen**
- Additional "Add Stop" button for multiple destinations

#### Screen 9: Multiple Stops (Optional)
**Components:**
- Stop 1, Stop 2, Stop 3 inputs
- Reorder stops (drag handles)
- Remove stop button
- Add more stops
- Continue button

**Validation:**
- Maximum 5 stops
- All locations must be different

#### Screen 10: Vehicle Selection
**Components:**
- Tabs: Cycle | 2 Wheeler | 3 Wheeler | Trucks
- Vehicle variants with:
  - Icon/image
  - Display name
  - Description (weight, timing)
  - Price estimate
  - "Go Green" badge for EVs
- Selected vehicle highlight
- "Continue" button

**Dynamic Pricing:**
- Calculate based on distance, vehicle type
- Show loading state during calculation

**API Call:**
```typescript
POST /api/v1/orders/estimate
{
  pickup_lat: 23.0225,
  pickup_lng: 72.5714,
  drop_lat: 23.0395,
  drop_lng: 72.5661,
  vehicle_type: "2_wheeler",
  service_type: "goods"
}
```

#### Screen 11: Goods Type Selection (For Goods)
**Components:**
- Grid of goods types:
  - Catering, Electronics, Wood
  - Furniture, Machine, Construction
  - Groceries, Others
- Selected highlight
- Continue button

**State:**
- Store selected goods type

#### Screen 12: Review Booking
**Components:**
- Pickup & Drop addresses (editable)
- Selected vehicle display
- Goods type (if applicable)
- Loading/unloading time estimate
- "Apply Coupon" section
  - Input field
  - Apply button
  - Discount display
- Fare breakdown:
  - Trip Price
  - Discount (if any)
  - CGST & SGST
  - **Total Amount**
- Payment method selector:
  - Cash
  - Card/UPI
  - Wallet
- "Confirm & Book" button

**Coupon Validation API:**
```typescript
POST /api/v1/coupons/validate
{
  code: "WELCOME50",
  order_value: 94.40
}
```

**Book Order API:**
```typescript
POST /api/v1/orders
{
  pickup_address: "...",
  pickup_lat: 23.0225,
  pickup_lng: 72.5714,
  drop_address: "...",
  drop_lat: 23.0395,
  drop_lng: 72.5661,
  vehicle_type: "2_wheeler",
  service_type: "goods",
  package_details: { goods_type: "electronics", weight: 5 },
  payment_method: "wallet",
  coupon_code: "WELCOME50",
  total_amount: 47.20
}
```

#### Screen 13: Finding Driver
**Components:**
- Animated searching indicator
- Message: "Finding best driver for you..."
- Estimated wait time
- Cancel button (with warning dialog)

**Logic:**
- Connect to Socket.io
- Listen for `driver:assigned` event
- Show cancellation penalty warning before cancel

**WebSocket:**
```typescript
socket.emit('order:created', { order_id });
socket.on('driver:assigned', (data) => {
  // Navigate to Tracking screen
});
```

#### Screen 14: Order Tracking (Active Order)
**Components:**
- Full-screen map
- Driver marker (vehicle icon)
- Pickup & drop markers
- Route polyline
- Driver info card (bottom sheet):
  - Photo, Name, Rating
  - Vehicle number
  - Contact buttons (Call/Chat)
- Status timeline:
  - Order Placed ✓
  - Driver Assigned ✓
  - Picked Up ✓
  - In Transit ◌
  - Delivered ◌
- ETA display
- "Call Support" button

**Real-Time Updates:**
```typescript
socket.on('driver:location', ({ lat, lng, heading }) => {
  // Update driver marker
  // Update ETA
});

socket.on('order:status_changed', ({ status }) => {
  // Update status timeline
});
```

**Features:**
- Live location tracking (5-10s interval)
- Auto-center map on driver
- Route from driver → pickup → drop
- Push notifications for status changes

#### Screen 15: Delivery Complete
**Components:**
- Success animation
- Delivery photo (if available)
- Order summary
- "Rate Your Experience" section
- Star rating (1-5)
- Feedback text area
- "Submit" button
- "Done" button

**API Call:**
```typescript
POST /api/v1/orders/:id/rate
{
  rating: 5,
  feedback: "Excellent service!"
}
```

### 4.5 Schedule Pickup Flow

#### Screen 16: Schedule Pickup
**Components:**
- Date selector (Today/Tomorrow/Custom)
- Time slot selector (8:00 AM - 10:00 PM)
- 30-minute intervals
- Continue to location selection

**Validation:**
- Date must be today or future
- Time must be within operating hours
- At least 1 hour advance booking

**Modified Order Creation:**
```typescript
{
  ...orderData,
  is_scheduled: true,
  scheduled_date: "2026-01-30",
  scheduled_time: "14:00"
}
```

### 4.6 Orders Screen

#### Screen 17: Orders List
**Tabs:**
- Active (in-progress orders)
- Completed
- Cancelled

**Order Card Components:**
- Order ID
- Date & Time
- Pickup → Drop addresses (truncated)
- Vehicle type icon
- Amount
- Status badge
- Actions:
  - "Track" (for active)
  - "Rebook" (for completed)
  - "View Details"

**API Call:**
```typescript
GET /api/v1/orders?status=active&page=1&limit=20
```

#### Screen 18: Order Details
**Components:**
- Order number
- Status badge
- Pickup & Drop locations (full)
- Driver details (if assigned)
- Vehicle type
- Package details
- Fare breakdown
- Payment method
- Timestamps
- Delivery photo (if completed)
- Rating (if completed)
- "Download Invoice" button
- "Rebook" button

### 4.7 Wallet Screen

#### Screen 19: Wallet
**Header:**
- Balance display (large)
- "₹XXX Free Cash - Just for you!"

**Tabs:**
- All Transactions
- Received
- Used
- Expired

**Transaction List:**
- Transaction type icon
- Description
- Date & time
- Amount (+ or -)
- Balance after

**Actions:**
- "Add Money" button (header)
- Filter dropdown

**API Call:**
```typescript
GET /api/v1/wallet/transactions?type=all&page=1
```

#### Screen 20: Add Money
**Components:**
- Predefined amount chips (₹100, ₹200, ₹500, ₹1000)
- Custom amount input
- Payment method selector
- "Add Money" button

**Payment Integration:**
```typescript
import Razorpay from 'razorpay-react-native';

const options = {
  amount: '10000', // in paise
  currency: 'INR',
  name: 'SendIt',
  description: 'Add money to wallet',
  prefill: {
    email: user.email,
    contact: user.phone
  }
};

RazorpayCheckout.open(options)
  .then((data) => {
    // Payment success
    // Call API to update wallet
  })
  .catch((error) => {
    // Payment failed
  });
```

### 4.8 Profile Screen

#### Screen 21: Profile
**Header:**
- Profile picture (editable)
- Name & phone
- Rides count
- Reward Points

**Sections:**

**Account:**
- Personal Information →
- Saved Addresses →
- Download Invoice →
- Notification Settings →

**Benefits:**
- Rewards & Refer Friends →

**Support & Legal:**
- Help and Support →
- Terms and Conditions →
- Privacy Policy →

**Action:**
- Logout button (with confirmation)

#### Screen 22: Personal Information
**Components:**
- Name input
- Email input
- Phone (non-editable, show change option)
- Profile picture upload
- "Save Changes" button

#### Screen 23: Saved Addresses
**Components:**
- Address cards:
  - Label (Home, Work, Other)
  - Full address
  - Edit/Delete buttons
- "Add New Address" button

**Address Card:**
- Icon (home/work/location)
- Label & full address
- "Set as Default" checkbox
- Edit & Delete icons

#### Screen 24: Referral Program
**Components:**
- Referral code display (large)
- Copy code button
- Share button (native share)
- "Refer More, Earn More" progress:
  - Progress bar (5/10)
  - "₹50 per referral"
- History section:
  - Name of referred user
  - Status (Signed up, Completed ride)
  - Reward earned
- Total rewards display

**Share Text:**
```
Join SendIt and get ₹50 free credits! Use my code: 5DTJ23
Download: [App Link]
```

#### Screen 25: Notifications
**Components:**
- Notification cards:
  - Icon (order/promo/system)
  - Title
  - Message
  - Time
  - Unread indicator
- Mark all as read button
- Clear all option

**API Call:**
```typescript
GET /api/v1/notifications?page=1&limit=20
```

#### Screen 26: Help & Support
**Components:**
- Contact options:
  - In-app Chat
  - Email (support@drop-it.co)
  - Phone (+91 94847 07535)
- Category selector: Inquiry, Support, Feedback
- Message input
- Attachments (optional)
- Submit button

**FAQ Section:**
- Expandable accordion with common questions

## 5. Component Library

### 5.1 Common Components

#### Button Component
```typescript
<Button
  variant="primary" // primary, secondary, outline, text
  size="large" // small, medium, large
  onPress={handlePress}
  loading={isLoading}
  disabled={isDisabled}
>
  Button Text
</Button>
```

#### Input Component
```typescript
<Input
  label="Phone Number"
  placeholder="Enter phone"
  value={phone}
  onChangeText={setPhone}
  error={errors.phone}
  keyboardType="phone-pad"
  leftIcon={<PhoneIcon />}
/>
```

#### LocationSearchInput
- Autocomplete with Google Places
- Recent searches
- Current location option

#### MapView Component
- Google Maps integration
- Custom markers
- Route polyline
- Current location button

#### VehicleCard
- Vehicle icon
- Name & description
- Price display
- Selection state

#### OrderCard
- Order summary
- Status badge
- Action buttons

#### AddressCard
- Label & address
- Edit/delete actions
- Default indicator

### 5.2 Feature-Specific Components

#### DriverInfoCard (Bottom Sheet)
- Driver photo, name, rating
- Vehicle details
- Contact buttons
- Collapsible

#### StatusTimeline
- Step indicator
- Status labels
- Timestamps

#### FareSummary
- Line items
- Subtotal, taxes, discount
- Total amount (highlighted)

## 6. Services

### 6.1 Location Service
```typescript
// location.service.ts
export class LocationService {
  getCurrentLocation(): Promise<Coordinates>
  watchLocation(callback): Subscription
  reverseGeocode(lat, lng): Promise<Address>
  getPlaceSuggestions(query): Promise<Place[]>
  calculateDistance(origin, destination): Promise<number>
}
```

### 6.2 Socket Service
```typescript
// socket.service.ts
export class SocketService {
  connect(token: string): void
  disconnect(): void
  subscribeToOrder(orderId: string): void
  onDriverAssigned(callback): void
  onDriverLocation(callback): void
  onOrderStatusChange(callback): void
}
```

### 6.3 Payment Service
```typescript
// payment.service.ts
export class PaymentService {
  initiatePayment(amount, orderId): Promise<PaymentResult>
  processWalletPayment(amount, orderId): Promise<boolean>
  addMoneyToWallet(amount): Promise<PaymentResult>
}
```

### 6.4 Notification Service
```typescript
// notification.service.ts
export class NotificationService {
  requestPermission(): Promise<boolean>
  getToken(): Promise<string>
  onNotificationReceived(callback): void
  onNotificationClicked(callback): void
  showLocalNotification(title, body): void
}
```

## 7. Offline Capabilities

### Data to Cache
- User profile
- Saved addresses
- Recent orders
- Wallet balance (synced when online)

### Offline Features
- View order history
- Access saved addresses
- View profile
- Queue actions (sync when online)

## 8. Push Notifications

### Notification Types
1. **Order Updates**
   - Driver assigned
   - Driver arrived
   - Package picked up
   - Out for delivery
   - Delivered

2. **Promotional**
   - New offers
   - Coupon codes
   - Referral rewards

3. **Transactional**
   - Wallet credits
   - Payment confirmations

### Implementation
```typescript
// Setup FCM
import messaging from '@react-native-firebase/messaging';

// Request permission
const authStatus = await messaging().requestPermission();

// Get token
const token = await messaging().getToken();
// Send to backend

// Foreground handler
messaging().onMessage(async remoteMessage => {
  // Show in-app notification
});

// Background handler
messaging().setBackgroundMessageHandler(async remoteMessage => {
  // Handle background notification
});
```

## 9. Analytics Events

### Track Key Events
- `app_opened`
- `user_registered`
- `booking_started`
- `vehicle_selected`
- `booking_confirmed`
- `payment_completed`
- `order_cancelled`
- `rating_submitted`
- `referral_shared`
- `wallet_recharged`

### Implementation
```typescript
import analytics from '@react-native-firebase/analytics';

await analytics().logEvent('booking_confirmed', {
  order_id: orderId,
  vehicle_type: vehicleType,
  amount: totalAmount,
  payment_method: paymentMethod
});
```

## 10. Error Handling

### Network Errors
- Show retry option
- Offline mode banner
- Queue failed requests

### API Errors
- User-friendly error messages
- Form validation errors
- Toast notifications for general errors

### Payment Errors
- Clear error messages
- Retry option
- Contact support link

## 11. Performance Optimization

### Image Optimization
- Use WebP format
- Lazy loading
- Image caching (react-native-fast-image)

### List Performance
- FlatList with pagination
- Item memoization
- ViewabilityConfig optimization

### Map Performance
- Debounce location updates
- Limit visible markers
- Polyline simplification

### Bundle Size
- Code splitting
- Remove unused libraries
- Optimize images

## 12. Testing Strategy

### Unit Tests
- Redux slices
- Utility functions
- Services

### Integration Tests
- API calls
- Navigation flows
- Payment flows

### E2E Tests (Detox)
- Complete booking flow
- Login/logout
- Order tracking

## 13. Development Checklist

### Phase 1: Setup
- [ ] Initialize React Native project
- [ ] Setup TypeScript
- [ ] Configure navigation
- [ ] Setup Redux store
- [ ] Configure API client
- [ ] Setup Google Maps
- [ ] Configure Firebase

### Phase 2: Authentication
- [ ] Splash screen
- [ ] Phone login screen
- [ ] OTP verification
- [ ] Profile setup
- [ ] Token management

### Phase 3: Core Booking Flow
- [ ] Home screen
- [ ] Location selection
- [ ] Vehicle selection
- [ ] Review booking
- [ ] Payment integration
- [ ] Finding driver screen
- [ ] Order tracking

### Phase 4: Additional Screens
- [ ] Orders history
- [ ] Order details
- [ ] Wallet screens
- [ ] Profile screens
- [ ] Referral program
- [ ] Notifications

### Phase 5: Advanced Features
- [ ] Scheduled pickup
- [ ] Multiple stops
- [ ] Coupon system
- [ ] Real-time tracking
- [ ] Push notifications

### Phase 6: Polish
- [ ] Loading states
- [ ] Error handling
- [ ] Animations
- [ ] Offline support
- [ ] Analytics integration
- [ ] Testing

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29
