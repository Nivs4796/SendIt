# Start Implementation Guide - Revised Order

## 🎯 Implementation Sequence

**Build Order:** Website → Admin Dashboard → Backend API → Mobile Apps

This guide provides step-by-step commands for each phase.

---

## Prerequisites

### Required Software
- **Node.js** 18+ LTS
- **npm** or **yarn**
- **Git**
- **VS Code** (recommended IDE)
- **PostgreSQL** 15+ (for Phase 3)
- **Redis** 7+ (for Phase 3)
- **Flutter** 3.16+ (for Phase 4)

### Accounts Needed
- GitHub (version control)
- Vercel or Netlify (website hosting)
- Google Cloud / AWS (later phases)
- Razorpay (Phase 3)

---

## PHASE 1: Marketing Website (Week 1-2)

### Step 1.1: Create Next.js Website Project

```bash
# Navigate to project root
cd /Users/sotsys386/Nirav/claude_projects/SendIt

# Create Next.js website with TypeScript
npx create-next-app@latest website --typescript --tailwind --app --src-dir --import-alias "@/*"

cd website
```

**Select these options:**
- ✅ Would you like to use TypeScript? **Yes**
- ✅ Would you like to use ESLint? **Yes**
- ✅ Would you like to use Tailwind CSS? **Yes**
- ✅ Would you like to use `src/` directory? **Yes**
- ✅ Would you like to use App Router? **Yes**
- ✅ Would you like to customize the default import alias? **No**

### Step 1.2: Install Additional Dependencies

```bash
# UI components
npm install @radix-ui/react-icons
npm install class-variance-authority clsx tailwind-merge
npm install lucide-react

# Form handling
npm install react-hook-form zod @hookform/resolvers

# Animations
npm install framer-motion

# SEO
npm install next-seo

# Contact form (optional)
npm install nodemailer
```

### Step 1.3: Project Structure

```bash
# Create folder structure
mkdir -p src/components/ui
mkdir -p src/components/sections
mkdir -p src/app/api
mkdir -p public/images
```

Expected structure:
```
website/
├── src/
│   ├── app/
│   │   ├── page.tsx          # Homepage
│   │   ├── about/page.tsx
│   │   ├── pricing/page.tsx
│   │   ├── contact/page.tsx
│   │   └── api/contact/route.ts
│   ├── components/
│   │   ├── ui/               # Reusable UI components
│   │   └── sections/         # Page sections (Hero, Features, etc.)
│   └── styles/
├── public/
└── package.json
```

### Step 1.4: Development

```bash
# Start development server
npm run dev
```

Navigate to `http://localhost:3000`

### Step 1.5: Key Pages to Build

Refer to `docs/planning/website-plan.md` for detailed specifications:

1. **Homepage** (`/`) - Hero, features, how it works, CTA
2. **About** (`/about`) - Company story, mission
3. **For Users** (`/for-users`) - User benefits
4. **For Pilots** (`/for-pilots`) - Pilot signup info
5. **Pricing** (`/pricing`) - Transparent pricing calculator
6. **Contact** (`/contact`) - Contact form
7. **Legal Pages** - Privacy, Terms, Refund policy

### Step 1.6: Deploy Website

```bash
# Initialize git (if not already)
git init
git add .
git commit -m "Initial website setup"

# Create GitHub repo and push
git remote add origin https://github.com/yourusername/sendit-website.git
git branch -M main
git push -u origin main
```

**Deploy to Vercel:**
1. Go to [vercel.com](https://vercel.com)
2. Import GitHub repository
3. Deploy (automatic)
4. Your website is live! 🎉

---

## PHASE 2: Admin Dashboard (Week 3-5)

### Step 2.1: Create Admin Dashboard Project

```bash
# Navigate back to project root
cd /Users/sotsys386/Nirav/claude_projects/SendIt

# Create Next.js admin dashboard
npx create-next-app@latest admin-dashboard --typescript --tailwind --app --src-dir

cd admin-dashboard
```

### Step 2.2: Install Shadcn UI

```bash
# Initialize shadcn/ui
npx shadcn-ui@latest init
```

Select:
- Style: **Default**
- Base color: **Slate**
- CSS variables: **Yes**

```bash
# Add components
npx shadcn-ui@latest add button
npx shadcn-ui@latest add card
npx shadcn-ui@latest add table
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add input
npx shadcn-ui@latest add label
npx shadcn-ui@latest add select
npx shadcn-ui@latest add tabs
npx shadcn-ui@latest add badge
npx shadcn-ui@latest add avatar
npx shadcn-ui@latest add dropdown-menu
```

### Step 2.3: Install Additional Dependencies

```bash
# Data visualization
npm install recharts

# Forms
npm install react-hook-form zod @hookform/resolvers

# Tables
npm install @tanstack/react-table

# Date picker
npm install date-fns react-day-picker

# Authentication (mock for now)
npm install next-auth bcryptjs
npm install -D @types/bcryptjs

# State management
npm install zustand

# Icons
npm install lucide-react
```

### Step 2.4: Project Structure

```bash
mkdir -p src/app/(auth)
mkdir -p src/app/(dashboard)
mkdir -p src/components/dashboard
mkdir -p src/lib
mkdir -p src/hooks
mkdir -p src/types
```

Structure:
```
admin-dashboard/
├── src/
│   ├── app/
│   │   ├── (auth)/
│   │   │   └── login/page.tsx
│   │   ├── (dashboard)/
│   │   │   ├── page.tsx              # Dashboard home
│   │   │   ├── users/page.tsx
│   │   │   ├── pilots/page.tsx
│   │   │   ├── orders/page.tsx
│   │   │   ├── pricing/page.tsx
│   │   │   └── settings/page.tsx
│   │   └── api/                      # Mock APIs initially
│   ├── components/
│   │   ├── ui/                       # Shadcn components
│   │   └── dashboard/                # Dashboard-specific
│   ├── lib/
│   │   ├── mock-data.ts              # Mock data for development
│   │   └── utils.ts
│   └── types/
│       └── index.ts
└── package.json
```

### Step 2.5: Create Mock Data

```bash
# Create mock data file
touch src/lib/mock-data.ts
```

This will simulate backend data until Phase 3 is ready.

### Step 2.6: Development

```bash
npm run dev
```

Navigate to `http://localhost:3000`

### Step 2.7: Key Modules to Build

Refer to `docs/planning/admin-dashboard-plan.md`:

1. **Authentication** - Login page (mock auth)
2. **Dashboard** - Overview with stats
3. **User Management** - List, view, suspend users
4. **Pilot Management** - Verification workflow
5. **Order Monitoring** - Real-time order board (mock data)
6. **Pricing Config** - Vehicle pricing settings
7. **Analytics** - Charts and reports

---

## PHASE 3: Backend API (Week 6-9)

### Step 3.1: Create Backend Project

```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt

# Create backend directory
mkdir backend
cd backend

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express cors helmet dotenv
npm install socket.io
npm install prisma @prisma/client
npm install bcryptjs jsonwebtoken
npm install express-validator
npm install redis ioredis
npm install bull
npm install winston
npm install axios

# Install dev dependencies
npm install -D typescript @types/node @types/express
npm install -D @types/bcryptjs @types/jsonwebtoken
npm install -D @types/cors
npm install -D nodemon ts-node
npm install -D eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
npm install -D jest @types/jest ts-jest supertest @types/supertest
```

### Step 3.2: Initialize TypeScript

```bash
npx tsc --init
```

Update `tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Step 3.3: Database Setup

```bash
# Initialize Prisma
npx prisma init
```

This creates:
- `prisma/schema.prisma`
- `.env` file

**Configure PostgreSQL:**

1. Install PostgreSQL (if not already):
```bash
# macOS
brew install postgresql@15
brew services start postgresql@15
```

2. Create database:
```bash
createdb sendit_dev
```

3. Update `.env`:
```
DATABASE_URL="postgresql://postgres:password@localhost:5432/sendit_dev"
JWT_SECRET="your-super-secret-jwt-key-change-in-production"
REDIS_URL="redis://localhost:6379"
PORT=5000
```

### Step 3.4: Define Database Schema

Edit `prisma/schema.prisma` using the schema from `docs/planning/backend-api-plan.md`

```bash
# Generate Prisma Client
npx prisma generate

# Run migrations
npx prisma migrate dev --name init
```

### Step 3.5: Project Structure

```bash
mkdir -p src/config
mkdir -p src/controllers
mkdir -p src/middleware
mkdir -p src/routes
mkdir -p src/services
mkdir -p src/utils
mkdir -p src/validators
mkdir -p src/types
mkdir -p src/jobs
```

Structure:
```
backend/
├── src/
│   ├── config/
│   │   ├── database.ts
│   │   └── redis.ts
│   ├── controllers/
│   │   ├── auth.controller.ts
│   │   ├── user.controller.ts
│   │   ├── order.controller.ts
│   │   └── pilot.controller.ts
│   ├── middleware/
│   │   ├── auth.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── validator.middleware.ts
│   ├── routes/
│   │   ├── auth.routes.ts
│   │   ├── user.routes.ts
│   │   ├── order.routes.ts
│   │   └── index.ts
│   ├── services/
│   │   ├── auth.service.ts
│   │   ├── order.service.ts
│   │   ├── payment.service.ts
│   │   └── driverMatching.service.ts
│   ├── utils/
│   │   ├── logger.ts
│   │   └── helpers.ts
│   ├── validators/
│   ├── jobs/
│   │   └── driverMatching.job.ts
│   ├── app.ts
│   └── server.ts
├── prisma/
│   └── schema.prisma
├── .env
└── package.json
```

### Step 3.6: Update package.json Scripts

```json
{
  "scripts": {
    "dev": "nodemon src/server.ts",
    "build": "tsc",
    "start": "node dist/server.js",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev",
    "test": "jest"
  }
}
```

### Step 3.7: Start Development

```bash
# Start Redis (required)
redis-server

# In another terminal, start backend
npm run dev
```

API will be available at `http://localhost:5000`

### Step 3.8: Integration with Admin Dashboard

Update admin dashboard to use real APIs:

```bash
cd ../admin-dashboard

# Create API client
touch src/lib/api-client.ts
```

Update environment variables:
```
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:5000/api/v1
```

---

## PHASE 4: Mobile Applications (Week 10-16)

### Step 4.1: Install Flutter

```bash
# Download Flutter SDK
# Visit: https://docs.flutter.dev/get-started/install/macos

# Or use Homebrew
brew install --cask flutter

# Verify installation
flutter doctor
```

### Step 4.2: Create User App

```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt

# Create Flutter project
flutter create sendit_user
cd sendit_user
```

### Step 4.3: User App Dependencies

Edit `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # Navigation
  go_router: ^13.0.0
  
  # HTTP & API
  dio: ^5.4.0
  retrofit: ^4.0.0
  
  # WebSocket
  socket_io_client: ^2.0.0
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.0
  
  # Payment
  razorpay_flutter: ^1.3.0
  
  # Notifications
  firebase_messaging: ^14.7.0
  firebase_core: ^2.24.0
  
  # Storage
  shared_preferences: ^2.2.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Image
  image_picker: ^1.0.0
  cached_network_image: ^3.3.0
  
  # Forms
  flutter_form_builder: ^9.1.0
  form_builder_validators: ^9.1.0
  
  # UI
  cupertino_icons: ^1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  retrofit_generator: ^7.0.0
```

```bash
flutter pub get
```

### Step 4.4: User App Structure

```bash
cd lib
rm widget_test.dart

mkdir -p core/api
mkdir -p core/constants
mkdir -p core/theme
mkdir -p core/utils
mkdir -p models
mkdir -p providers
mkdir -p screens
mkdir -p widgets
mkdir -p services
mkdir -p routes
```

### Step 4.5: Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project "SendIt"
3. Add iOS and Android apps
4. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
5. Follow Firebase setup instructions

### Step 4.6: Create Pilot App

```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt

flutter create sendit_pilot
cd sendit_pilot
```

Repeat similar setup as User App with additional packages:
- `background_location` for background tracking
- `workmanager` for background tasks

### Step 4.7: Run Mobile Apps

```bash
# User App
cd sendit_user
flutter run

# Pilot App (in another terminal)
cd sendit_pilot
flutter run
```

---

## Final Verification & Testing

### Website Checklist
- [ ] All pages render correctly
- [ ] Forms work
- [ ] SEO meta tags present
- [ ] Mobile responsive
- [ ] Deployed to production

### Admin Dashboard Checklist
- [ ] Login works
- [ ] All modules accessible
- [ ] Connected to backend API
- [ ] Real-time updates working
- [ ] Deployed securely

### Backend API Checklist
- [ ] All endpoints responding
- [ ] Database migrations complete
- [ ] Authentication working
- [ ] Payment integration tested
- [ ] WebSocket connections stable
- [ ] Background jobs processing

### Mobile Apps Checklist
- [ ] User app: Booking flow works
- [ ] Pilot app: Job acceptance works
- [ ] Real-time tracking functional
- [ ] Payment integration complete
- [ ] Push notifications working
- [ ] Ready for beta testing

---

## Troubleshooting

### Website Issues
```bash
# Clear Next.js cache
rm -rf .next
npm run dev
```

### Admin Dashboard Issues
```bash
# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Backend Issues
```bash
# Reset database
npx prisma migrate reset

# Check Redis
redis-cli ping  # Should return PONG
```

### Flutter Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## Next Steps

1. **Week 1-2:** Build and deploy marketing website
2. **Week 3-5:** Build admin dashboard
3. **Week 6-9:** Develop backend API
4. **Week 10-16:** Build mobile applications
5. **Week 17:** End-to-end testing
6. **Week 18:** Beta launch

**Good luck! 🚀**

Refer to individual planning documents for detailed specifications:
- `website-plan.md`
- `admin-dashboard-plan.md`
- `backend-api-plan.md`
- `user-app-plan.md`
- `pilot-app-plan.md`
