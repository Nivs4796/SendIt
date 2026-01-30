import { PrismaClient } from '@prisma/client'
import { PrismaPg } from '@prisma/adapter-pg'
import { Pool } from 'pg'
import bcrypt from 'bcryptjs'
import 'dotenv/config'

// Create PostgreSQL connection pool
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

// Create Prisma adapter
const adapter = new PrismaPg(pool)

// Create Prisma client
const prisma = new PrismaClient({ adapter })

// Helper to generate random coordinates in Ahmedabad
const randomAhmedabadCoords = () => ({
  lat: 23.0225 + (Math.random() - 0.5) * 0.1,
  lng: 72.5714 + (Math.random() - 0.5) * 0.1,
})

async function main() {
  console.log('🌱 Starting database seed...\n')

  // ============================================
  // VEHICLE TYPES
  // ============================================
  const vehicleTypes = await Promise.all([
    prisma.vehicleType.upsert({
      where: { name: 'Cycle' },
      update: {},
      create: {
        name: 'Cycle',
        description: 'Perfect for documents and small packages',
        icon: 'bicycle',
        maxWeight: 5,
        basePrice: 20,
        pricePerKm: 5,
      },
    }),
    prisma.vehicleType.upsert({
      where: { name: 'EV Cycle' },
      update: {},
      create: {
        name: 'EV Cycle',
        description: 'Eco-friendly electric cycle for short distances',
        icon: 'ev-bicycle',
        maxWeight: 5,
        basePrice: 25,
        pricePerKm: 6,
      },
    }),
    prisma.vehicleType.upsert({
      where: { name: '2 Wheeler' },
      update: {},
      create: {
        name: '2 Wheeler',
        description: 'Quick delivery for medium packages',
        icon: 'motorcycle',
        maxWeight: 10,
        basePrice: 30,
        pricePerKm: 8,
      },
    }),
    prisma.vehicleType.upsert({
      where: { name: '3 Wheeler' },
      update: {},
      create: {
        name: '3 Wheeler',
        description: 'Ideal for bulk items and larger packages',
        icon: 'auto-rickshaw',
        maxWeight: 100,
        basePrice: 50,
        pricePerKm: 12,
      },
    }),
    prisma.vehicleType.upsert({
      where: { name: 'Truck' },
      update: {},
      create: {
        name: 'Truck',
        description: 'Heavy goods and commercial deliveries',
        icon: 'truck',
        maxWeight: 1000,
        basePrice: 200,
        pricePerKm: 25,
      },
    }),
  ])
  console.log(`✅ Created ${vehicleTypes.length} vehicle types`)

  // ============================================
  // ADMINS
  // ============================================
  const hashedPassword = await bcrypt.hash('admin123', 10)
  const admins = await Promise.all([
    prisma.admin.upsert({
      where: { email: 'admin@sendit.co.in' },
      update: {},
      create: {
        email: 'admin@sendit.co.in',
        password: hashedPassword,
        name: 'Super Admin',
        role: 'SUPER_ADMIN',
      },
    }),
    prisma.admin.upsert({
      where: { email: 'support@sendit.co.in' },
      update: {},
      create: {
        email: 'support@sendit.co.in',
        password: hashedPassword,
        name: 'Support Admin',
        role: 'SUPPORT',
      },
    }),
  ])
  console.log(`✅ Created ${admins.length} admins`)

  // ============================================
  // USERS
  // ============================================
  const users = await Promise.all([
    prisma.user.upsert({
      where: { phone: '+919876543210' },
      update: {},
      create: {
        phone: '+919876543210',
        email: 'rahul@example.com',
        name: 'Rahul Sharma',
        walletBalance: 500,
        isVerified: true,
        isActive: true,
      },
    }),
    prisma.user.upsert({
      where: { phone: '+919876543211' },
      update: {},
      create: {
        phone: '+919876543211',
        email: 'priya@example.com',
        name: 'Priya Patel',
        walletBalance: 250,
        isVerified: true,
        isActive: true,
      },
    }),
    prisma.user.upsert({
      where: { phone: '+919876543212' },
      update: {},
      create: {
        phone: '+919876543212',
        email: 'amit@example.com',
        name: 'Amit Singh',
        walletBalance: 100,
        isVerified: true,
        isActive: true,
      },
    }),
    prisma.user.upsert({
      where: { phone: '+919876543213' },
      update: {},
      create: {
        phone: '+919876543213',
        email: 'neha@example.com',
        name: 'Neha Gupta',
        walletBalance: 0,
        isVerified: true,
        isActive: true,
      },
    }),
    prisma.user.upsert({
      where: { phone: '+919876543214' },
      update: {},
      create: {
        phone: '+919876543214',
        name: 'Test User',
        walletBalance: 1000,
        isVerified: false,
        isActive: true,
      },
    }),
  ])
  console.log(`✅ Created ${users.length} users`)

  // ============================================
  // USER ADDRESSES
  // ============================================
  const addresses = await Promise.all([
    // Rahul's addresses
    prisma.address.create({
      data: {
        userId: users[0].id,
        label: 'Home',
        address: '123 Satellite Road, Jodhpur',
        landmark: 'Near Iscon Temple',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380015',
        lat: 23.0301,
        lng: 72.5171,
        isDefault: true,
      },
    }),
    prisma.address.create({
      data: {
        userId: users[0].id,
        label: 'Office',
        address: '45 SG Highway, Bodakdev',
        landmark: 'Opposite Rajpath Club',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380054',
        lat: 23.0469,
        lng: 72.5120,
        isDefault: false,
      },
    }),
    // Priya's address
    prisma.address.create({
      data: {
        userId: users[1].id,
        label: 'Home',
        address: '78 CG Road, Navrangpura',
        landmark: 'Near Parimal Garden',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380009',
        lat: 23.0339,
        lng: 72.5612,
        isDefault: true,
      },
    }),
    // Amit's address
    prisma.address.create({
      data: {
        userId: users[2].id,
        label: 'Home',
        address: '56 Vastrapur, Near Lake',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380054',
        lat: 23.0365,
        lng: 72.5296,
        isDefault: true,
      },
    }),
    // Neha's address
    prisma.address.create({
      data: {
        userId: users[3].id,
        label: 'Home',
        address: '90 Maninagar, Near Railway Crossing',
        city: 'Ahmedabad',
        state: 'Gujarat',
        pincode: '380008',
        lat: 22.9998,
        lng: 72.6035,
        isDefault: true,
      },
    }),
  ])
  console.log(`✅ Created ${addresses.length} addresses`)

  // ============================================
  // PILOTS
  // ============================================
  const pilots = await Promise.all([
    prisma.pilot.upsert({
      where: { phone: '+919898989801' },
      update: {},
      create: {
        phone: '+919898989801',
        email: 'vijay.pilot@example.com',
        name: 'Vijay Kumar',
        gender: 'MALE',
        aadhaarNumber: '123456789012',
        licenseNumber: 'GJ01-2020-1234567',
        status: 'APPROVED',
        isVerified: true,
        isActive: true,
        isOnline: true,
        currentLat: 23.0225,
        currentLng: 72.5714,
        rating: 4.8,
        totalDeliveries: 156,
        totalEarnings: 45000,
      },
    }),
    prisma.pilot.upsert({
      where: { phone: '+919898989802' },
      update: {},
      create: {
        phone: '+919898989802',
        email: 'suresh.pilot@example.com',
        name: 'Suresh Patel',
        gender: 'MALE',
        aadhaarNumber: '123456789013',
        licenseNumber: 'GJ01-2019-7654321',
        status: 'APPROVED',
        isVerified: true,
        isActive: true,
        isOnline: true,
        currentLat: 23.0350,
        currentLng: 72.5500,
        rating: 4.5,
        totalDeliveries: 89,
        totalEarnings: 28000,
      },
    }),
    prisma.pilot.upsert({
      where: { phone: '+919898989803' },
      update: {},
      create: {
        phone: '+919898989803',
        email: 'ramesh.pilot@example.com',
        name: 'Ramesh Singh',
        gender: 'MALE',
        aadhaarNumber: '123456789014',
        licenseNumber: 'GJ01-2021-9876543',
        status: 'APPROVED',
        isVerified: true,
        isActive: true,
        isOnline: false,
        currentLat: 23.0100,
        currentLng: 72.5900,
        rating: 4.2,
        totalDeliveries: 45,
        totalEarnings: 15000,
      },
    }),
    prisma.pilot.upsert({
      where: { phone: '+919898989804' },
      update: {},
      create: {
        phone: '+919898989804',
        email: 'meena.pilot@example.com',
        name: 'Meena Devi',
        gender: 'FEMALE',
        aadhaarNumber: '123456789015',
        status: 'PENDING',
        isVerified: false,
        isActive: true,
        isOnline: false,
        rating: 0,
        totalDeliveries: 0,
        totalEarnings: 0,
      },
    }),
    prisma.pilot.upsert({
      where: { phone: '+919898989805' },
      update: {},
      create: {
        phone: '+919898989805',
        name: 'Suspended Pilot',
        gender: 'MALE',
        status: 'SUSPENDED',
        isVerified: false,
        isActive: false,
        isOnline: false,
        rating: 2.1,
        totalDeliveries: 12,
        totalEarnings: 3500,
      },
    }),
  ])
  console.log(`✅ Created ${pilots.length} pilots`)

  // ============================================
  // PILOT VEHICLES
  // ============================================
  const vehicles = await Promise.all([
    // Vijay - 2 Wheeler
    prisma.vehicle.create({
      data: {
        pilotId: pilots[0].id,
        vehicleTypeId: vehicleTypes[2].id, // 2 Wheeler
        registrationNo: 'GJ01AB1234',
        model: 'Honda Activa',
        color: 'Black',
        isActive: true,
        isVerified: true,
      },
    }),
    // Suresh - 3 Wheeler
    prisma.vehicle.create({
      data: {
        pilotId: pilots[1].id,
        vehicleTypeId: vehicleTypes[3].id, // 3 Wheeler
        registrationNo: 'GJ01CD5678',
        model: 'Bajaj Auto',
        color: 'Yellow',
        isActive: true,
        isVerified: true,
      },
    }),
    // Ramesh - Cycle
    prisma.vehicle.create({
      data: {
        pilotId: pilots[2].id,
        vehicleTypeId: vehicleTypes[0].id, // Cycle
        model: 'Hero Sprint',
        color: 'Blue',
        isActive: true,
        isVerified: true,
      },
    }),
  ])
  console.log(`✅ Created ${vehicles.length} vehicles`)

  // ============================================
  // PILOT BANK ACCOUNTS
  // ============================================
  const bankAccounts = await Promise.all([
    prisma.bankAccount.create({
      data: {
        pilotId: pilots[0].id,
        accountName: 'Vijay Kumar',
        accountNumber: '1234567890123456',
        ifscCode: 'SBIN0001234',
        bankName: 'State Bank of India',
        isVerified: true,
      },
    }),
    prisma.bankAccount.create({
      data: {
        pilotId: pilots[1].id,
        accountName: 'Suresh Patel',
        accountNumber: '9876543210987654',
        ifscCode: 'HDFC0005678',
        bankName: 'HDFC Bank',
        isVerified: true,
      },
    }),
  ])
  console.log(`✅ Created ${bankAccounts.length} bank accounts`)

  // ============================================
  // PILOT DOCUMENTS
  // ============================================
  const documents = await Promise.all([
    prisma.document.create({
      data: {
        pilotId: pilots[0].id,
        type: 'AADHAAR_FRONT',
        url: '/uploads/docs/vijay-aadhaar-front.jpg',
        status: 'APPROVED',
        verifiedAt: new Date(),
      },
    }),
    prisma.document.create({
      data: {
        pilotId: pilots[0].id,
        type: 'LICENSE_FRONT',
        url: '/uploads/docs/vijay-license-front.jpg',
        status: 'APPROVED',
        verifiedAt: new Date(),
      },
    }),
    prisma.document.create({
      data: {
        pilotId: pilots[3].id,
        type: 'AADHAAR_FRONT',
        url: '/uploads/docs/meena-aadhaar-front.jpg',
        status: 'PENDING',
      },
    }),
  ])
  console.log(`✅ Created ${documents.length} documents`)

  // ============================================
  // BOOKINGS
  // ============================================
  const bookings = await Promise.all([
    // Completed booking
    prisma.booking.create({
      data: {
        bookingNumber: 'SI2026013001',
        userId: users[0].id,
        pilotId: pilots[0].id,
        vehicleId: vehicles[0].id,
        vehicleTypeId: vehicleTypes[2].id,
        pickupAddressId: addresses[0].id,
        dropAddressId: addresses[1].id,
        packageType: 'PARCEL',
        packageWeight: 2,
        packageDescription: 'Office documents',
        distance: 5.2,
        baseFare: 30,
        distanceFare: 41.6,
        taxes: 3.58,
        totalAmount: 75.18,
        paymentMethod: 'CASH',
        paymentStatus: 'COMPLETED',
        status: 'DELIVERED',
        pickupOtp: '1234',
        deliveryOtp: '5678',
        acceptedAt: new Date(Date.now() - 3600000),
        pickedUpAt: new Date(Date.now() - 3000000),
        deliveredAt: new Date(Date.now() - 1800000),
      },
    }),
    // In-transit booking
    prisma.booking.create({
      data: {
        bookingNumber: 'SI2026013002',
        userId: users[1].id,
        pilotId: pilots[1].id,
        vehicleId: vehicles[1].id,
        vehicleTypeId: vehicleTypes[3].id,
        pickupAddressId: addresses[2].id,
        dropAddressId: addresses[3].id,
        packageType: 'GROCERY',
        packageWeight: 15,
        packageDescription: 'Weekly groceries',
        distance: 8.5,
        baseFare: 50,
        distanceFare: 102,
        taxes: 7.6,
        totalAmount: 159.6,
        paymentMethod: 'WALLET',
        paymentStatus: 'PENDING',
        status: 'IN_TRANSIT',
        pickupOtp: '2345',
        deliveryOtp: '6789',
        acceptedAt: new Date(Date.now() - 1800000),
        pickedUpAt: new Date(Date.now() - 900000),
        currentLat: 23.0350,
        currentLng: 72.5450,
      },
    }),
    // Pending booking
    prisma.booking.create({
      data: {
        bookingNumber: 'SI2026013003',
        userId: users[2].id,
        vehicleTypeId: vehicleTypes[0].id,
        pickupAddressId: addresses[3].id,
        dropAddressId: addresses[4].id,
        packageType: 'DOCUMENT',
        packageDescription: 'Important documents',
        distance: 3.2,
        baseFare: 20,
        distanceFare: 16,
        taxes: 1.8,
        totalAmount: 37.8,
        paymentMethod: 'CASH',
        paymentStatus: 'PENDING',
        status: 'PENDING',
        pickupOtp: '3456',
        deliveryOtp: '7890',
      },
    }),
    // Cancelled booking
    prisma.booking.create({
      data: {
        bookingNumber: 'SI2026013004',
        userId: users[3].id,
        vehicleTypeId: vehicleTypes[2].id,
        pickupAddressId: addresses[4].id,
        dropAddressId: addresses[0].id,
        packageType: 'FOOD',
        distance: 6.1,
        baseFare: 30,
        distanceFare: 48.8,
        taxes: 3.94,
        totalAmount: 82.74,
        paymentMethod: 'CASH',
        paymentStatus: 'PENDING',
        status: 'CANCELLED',
        cancelledAt: new Date(Date.now() - 7200000),
        cancelReason: 'Customer requested cancellation',
        pickupOtp: '4567',
        deliveryOtp: '8901',
      },
    }),
  ])
  console.log(`✅ Created ${bookings.length} bookings`)

  // ============================================
  // TRACKING HISTORY
  // ============================================
  const trackingHistory = await Promise.all([
    // Completed booking history
    prisma.trackingHistory.create({
      data: { bookingId: bookings[0].id, status: 'PENDING', note: 'Booking created' },
    }),
    prisma.trackingHistory.create({
      data: { bookingId: bookings[0].id, status: 'ACCEPTED', note: 'Pilot accepted' },
    }),
    prisma.trackingHistory.create({
      data: { bookingId: bookings[0].id, status: 'ARRIVED_PICKUP', lat: 23.0301, lng: 72.5171 },
    }),
    prisma.trackingHistory.create({
      data: { bookingId: bookings[0].id, status: 'PICKED_UP', lat: 23.0301, lng: 72.5171 },
    }),
    prisma.trackingHistory.create({
      data: { bookingId: bookings[0].id, status: 'IN_TRANSIT', lat: 23.0385, lng: 72.5145 },
    }),
    prisma.trackingHistory.create({
      data: { bookingId: bookings[0].id, status: 'DELIVERED', lat: 23.0469, lng: 72.5120 },
    }),
    // In-transit booking history
    prisma.trackingHistory.create({
      data: { bookingId: bookings[1].id, status: 'PENDING', note: 'Booking created' },
    }),
    prisma.trackingHistory.create({
      data: { bookingId: bookings[1].id, status: 'ACCEPTED', note: 'Pilot accepted' },
    }),
    prisma.trackingHistory.create({
      data: { bookingId: bookings[1].id, status: 'PICKED_UP', lat: 23.0339, lng: 72.5612 },
    }),
    prisma.trackingHistory.create({
      data: { bookingId: bookings[1].id, status: 'IN_TRANSIT', lat: 23.0350, lng: 72.5450 },
    }),
  ])
  console.log(`✅ Created ${trackingHistory.length} tracking records`)

  // ============================================
  // REVIEWS
  // ============================================
  const reviews = await Promise.all([
    prisma.review.create({
      data: {
        bookingId: bookings[0].id,
        userId: users[0].id,
        pilotId: pilots[0].id,
        rating: 5,
        comment: 'Excellent service! Very quick delivery.',
      },
    }),
  ])
  console.log(`✅ Created ${reviews.length} reviews`)

  // ============================================
  // EARNINGS
  // ============================================
  const earnings = await Promise.all([
    prisma.earning.create({
      data: {
        pilotId: pilots[0].id,
        bookingId: bookings[0].id,
        amount: 60.14, // 80% of 75.18
        type: 'DELIVERY',
        status: 'PAID',
        description: 'Delivery earnings',
      },
    }),
    prisma.earning.create({
      data: {
        pilotId: pilots[0].id,
        amount: 100,
        type: 'BONUS',
        status: 'PAID',
        description: 'Weekly performance bonus',
      },
    }),
  ])
  console.log(`✅ Created ${earnings.length} earnings`)

  // ============================================
  // COUPONS
  // ============================================
  const coupons = await Promise.all([
    prisma.coupon.create({
      data: {
        code: 'WELCOME50',
        description: 'Get 50% off on your first order',
        discountType: 'PERCENTAGE',
        discountValue: 50,
        maxDiscount: 100,
        minOrderAmount: 50,
        usageLimit: 1000,
        perUserLimit: 1,
        isActive: true,
        expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
      },
    }),
    prisma.coupon.create({
      data: {
        code: 'FLAT20',
        description: 'Flat ₹20 off on any order',
        discountType: 'FIXED',
        discountValue: 20,
        minOrderAmount: 30,
        usageLimit: 500,
        perUserLimit: 3,
        isActive: true,
        expiresAt: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000), // 15 days
      },
    }),
    prisma.coupon.create({
      data: {
        code: 'TRUCK10',
        description: '10% off on Truck deliveries',
        discountType: 'PERCENTAGE',
        discountValue: 10,
        maxDiscount: 500,
        vehicleTypeIds: [vehicleTypes[4].id], // Truck only
        usageLimit: 100,
        perUserLimit: 2,
        isActive: true,
      },
    }),
    prisma.coupon.create({
      data: {
        code: 'EXPIRED',
        description: 'This coupon has expired',
        discountType: 'PERCENTAGE',
        discountValue: 25,
        isActive: false,
        expiresAt: new Date(Date.now() - 24 * 60 * 60 * 1000), // Yesterday
      },
    }),
  ])
  console.log(`✅ Created ${coupons.length} coupons`)

  // ============================================
  // WALLET TRANSACTIONS
  // ============================================
  const walletTxns = await Promise.all([
    prisma.walletTransaction.create({
      data: {
        userId: users[0].id,
        type: 'CREDIT',
        amount: 500,
        balanceBefore: 0,
        balanceAfter: 500,
        description: 'Added via app',
        referenceType: 'TOPUP',
        status: 'COMPLETED',
      },
    }),
    prisma.walletTransaction.create({
      data: {
        userId: users[1].id,
        type: 'CREDIT',
        amount: 300,
        balanceBefore: 0,
        balanceAfter: 300,
        description: 'Referral bonus',
        referenceType: 'BONUS',
        status: 'COMPLETED',
      },
    }),
    prisma.walletTransaction.create({
      data: {
        userId: users[1].id,
        type: 'DEBIT',
        amount: 50,
        balanceBefore: 300,
        balanceAfter: 250,
        description: 'Payment for booking',
        referenceType: 'BOOKING',
        status: 'COMPLETED',
      },
    }),
  ])
  console.log(`✅ Created ${walletTxns.length} wallet transactions`)

  // ============================================
  // SETTINGS
  // ============================================
  const settings = await Promise.all([
    prisma.setting.upsert({
      where: { key: 'platform_fee_percent' },
      update: {},
      create: { key: 'platform_fee_percent', value: '20', description: 'Platform fee percentage' },
    }),
    prisma.setting.upsert({
      where: { key: 'gst_percent' },
      update: {},
      create: { key: 'gst_percent', value: '5', description: 'GST percentage' },
    }),
    prisma.setting.upsert({
      where: { key: 'pilot_search_radius_km' },
      update: {},
      create: { key: 'pilot_search_radius_km', value: '5', description: 'Search radius in km' },
    }),
    prisma.setting.upsert({
      where: { key: 'min_wallet_balance' },
      update: {},
      create: { key: 'min_wallet_balance', value: '0', description: 'Min wallet balance for pilots' },
    }),
    prisma.setting.upsert({
      where: { key: 'cancellation_fee_percent' },
      update: {},
      create: { key: 'cancellation_fee_percent', value: '10', description: 'Cancellation fee %' },
    }),
    prisma.setting.upsert({
      where: { key: 'job_offer_timeout_seconds' },
      update: {},
      create: { key: 'job_offer_timeout_seconds', value: '30', description: 'Job offer timeout' },
    }),
    prisma.setting.upsert({
      where: { key: 'max_active_bookings_per_pilot' },
      update: {},
      create: { key: 'max_active_bookings_per_pilot', value: '1', description: 'Max active jobs' },
    }),
  ])
  console.log(`✅ Created ${settings.length} settings`)

  // ============================================
  // SERVICE AREA
  // ============================================
  const serviceArea = await prisma.serviceArea.upsert({
    where: { id: 'ahmedabad-main' },
    update: {},
    create: {
      id: 'ahmedabad-main',
      name: 'Ahmedabad City',
      city: 'Ahmedabad',
      state: 'Gujarat',
      polygon: {
        type: 'Polygon',
        coordinates: [[
          [72.4714, 22.9419],
          [72.6714, 22.9419],
          [72.6714, 23.1419],
          [72.4714, 23.1419],
          [72.4714, 22.9419],
        ]],
      },
      isActive: true,
    },
  })
  console.log(`✅ Created service area: ${serviceArea.name}`)

  // ============================================
  // SUMMARY
  // ============================================
  console.log('\n' + '='.repeat(50))
  console.log('🎉 DATABASE SEED COMPLETED SUCCESSFULLY!')
  console.log('='.repeat(50))
  console.log('\n📊 Summary:')
  console.log(`   • ${vehicleTypes.length} Vehicle Types`)
  console.log(`   • ${admins.length} Admins`)
  console.log(`   • ${users.length} Users`)
  console.log(`   • ${addresses.length} Addresses`)
  console.log(`   • ${pilots.length} Pilots`)
  console.log(`   • ${vehicles.length} Vehicles`)
  console.log(`   • ${bookings.length} Bookings`)
  console.log(`   • ${coupons.length} Coupons`)
  console.log(`   • ${settings.length} Settings`)

  console.log('\n📝 Test Credentials:')
  console.log('   Admin:')
  console.log('     Email: admin@sendit.co.in')
  console.log('     Password: admin123')
  console.log('\n   Users (OTP login):')
  console.log('     +919876543210 (Rahul - ₹500 wallet)')
  console.log('     +919876543211 (Priya - ₹250 wallet)')
  console.log('     +919876543212 (Amit - ₹100 wallet)')
  console.log('\n   Pilots (OTP login):')
  console.log('     +919898989801 (Vijay - Online, Approved)')
  console.log('     +919898989802 (Suresh - Online, Approved)')
  console.log('     +919898989803 (Ramesh - Offline, Approved)')
  console.log('\n   Coupons:')
  console.log('     WELCOME50 - 50% off (max ₹100)')
  console.log('     FLAT20 - ₹20 off')
  console.log('     TRUCK10 - 10% off on Truck')
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
    await pool.end()
  })
