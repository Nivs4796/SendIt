# SendIt Pilot App

> Deliver & Earn - The driver/delivery partner app for SendIt

## 🏗️ Architecture

This app follows the **same architecture as user_app** for consistency and code sharing.

### Folder Structure

```
lib/
├── main.dart                    # App entry point
└── app/
    ├── core/                    # Core utilities (shared with user_app)
    │   ├── constants/           # App constants, API endpoints
    │   ├── controllers/         # Global controllers (theme, etc.)
    │   ├── extensions/          # Dart extensions
    │   ├── services/            # Core services (location, socket, etc.)
    │   ├── theme/               # App theme, colors, text styles
    │   ├── utils/               # Helper functions
    │   └── widgets/             # Common widgets
    │       └── inputs/          # Input components
    │
    ├── data/                    # Data layer
    │   ├── models/              # Data models
    │   │   ├── pilot_model.dart
    │   │   ├── job_model.dart
    │   │   ├── vehicle_model.dart
    │   │   ├── earnings_model.dart
    │   │   └── ...
    │   ├── providers/           # API providers (Dio client)
    │   └── repositories/        # Data repositories
    │
    ├── modules/                 # Feature modules (GetX pattern)
    │   ├── splash/
    │   ├── auth/
    │   ├── registration/        # Multi-step pilot registration
    │   ├── home/                # Dashboard with online/offline toggle
    │   ├── jobs/                # Job management
    │   ├── earnings/            # Earnings dashboard
    │   ├── wallet/              # Wallet & transactions
    │   ├── vehicles/            # Vehicle management
    │   ├── profile/             # Profile settings
    │   ├── notifications/       # Notification center
    │   └── rewards/             # Rewards & referrals
    │
    └── routes/                  # Navigation
        ├── app_routes.dart      # Route constants
        └── app_pages.dart       # Route configurations
```

### Module Structure (GetX Pattern)

Each module follows this structure:
```
modules/[feature]/
├── bindings/
│   └── [feature]_binding.dart   # Dependency injection
├── controllers/
│   └── [feature]_controller.dart # Business logic
├── views/
│   └── [feature]_view.dart      # UI screens
└── widgets/
    └── [widget_name].dart       # Module-specific widgets
```

## 🔧 Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.16+ |
| State Management | GetX |
| HTTP Client | Dio |
| Local Storage | GetStorage, Hive |
| Maps | google_maps_flutter |
| Location | geolocator |
| Real-time | socket_io_client |
| Charts | fl_chart |

## 🚀 Getting Started

### Prerequisites
- Flutter 3.16+
- Dart 3.2+
- Android Studio / Xcode
- Google Maps API key

### Setup

```bash
# Navigate to pilot_app
cd pilot_app

# Get dependencies
flutter pub get

# Run code generation (if needed)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device
flutter run
```

### Environment Configuration

Create `lib/app/core/constants/env_config.dart`:
```dart
class EnvConfig {
  static const String baseUrl = 'http://your-api-url.com/api/v1';
  static const String socketUrl = 'ws://your-socket-url.com';
  static const String googleMapsApiKey = 'YOUR_API_KEY';
}
```

## 📱 Features

### Phase 1: Authentication & Registration
- [x] Phone login with OTP
- [ ] Multi-step registration (personal → vehicle → documents → bank)
- [ ] Document upload
- [ ] Verification status tracking

### Phase 2: Dashboard & Online/Offline
- [ ] Home dashboard with stats
- [ ] Online/offline toggle
- [ ] Background location tracking
- [ ] WebSocket connection for job dispatch

### Phase 3: Job Management
- [ ] Incoming job popup (30s timer)
- [ ] Accept/decline jobs
- [ ] Active job screen with navigation
- [ ] Photo capture for pickup/delivery
- [ ] Status updates

### Phase 4: Earnings & Wallet
- [ ] Earnings dashboard with charts
- [ ] Wallet balance
- [ ] Add money / Withdraw
- [ ] Transaction history

### Phase 5: Vehicles & Profile
- [ ] My vehicles list
- [ ] Add/switch vehicles
- [ ] Profile management
- [ ] Document renewal

## 🔗 API Endpoints

See `docs/planning/pilot-app-implementation-roadmap.md` for full API specification.

### Key Endpoints
```
POST /pilots/register           # Full registration
GET  /pilots/verification-status
PUT  /pilots/online-status
PUT  /pilots/jobs/:id/accept
PUT  /pilots/jobs/:id/status
GET  /pilots/earnings
GET  /pilots/wallet
```

### WebSocket Events
```
Emit: pilot:location            # Send location updates
Emit: pilot:online              # Online status
Listen: job:new                 # New job requests
Listen: job:cancelled           # Job cancelled
```

## 🎨 Theme

Uses the same theme system as user_app:
- **Primary**: Green (#10B981)
- **Dark mode**: Default enabled
- **Font**: Google Fonts (same as user_app)

## 📝 Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use GetX for state management
- Keep controllers lean - move business logic to services
- Use repositories for data access

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📦 Building

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📄 Related Documentation

- [Pilot App Plan](../docs/planning/pilot-app-plan.md) - Full specifications
- [Implementation Roadmap](../docs/planning/pilot-app-implementation-roadmap.md) - Phase-by-phase plan
- [User App](../user_app/) - Reference implementation
