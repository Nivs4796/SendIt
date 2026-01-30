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

async function main() {
  console.log('🌱 Starting database seed...')

  // Create Vehicle Types
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

  // Create Super Admin
  const hashedPassword = await bcrypt.hash('admin123', 10)
  const admin = await prisma.admin.upsert({
    where: { email: 'admin@sendit.co.in' },
    update: {},
    create: {
      email: 'admin@sendit.co.in',
      password: hashedPassword,
      name: 'Super Admin',
      role: 'SUPER_ADMIN',
    },
  })

  console.log(`✅ Created admin: ${admin.email}`)

  // Create Settings
  const settings = await Promise.all([
    prisma.setting.upsert({
      where: { key: 'platform_fee_percent' },
      update: {},
      create: {
        key: 'platform_fee_percent',
        value: '20',
        description: 'Platform fee percentage from each delivery',
      },
    }),
    prisma.setting.upsert({
      where: { key: 'gst_percent' },
      update: {},
      create: {
        key: 'gst_percent',
        value: '5',
        description: 'GST percentage on deliveries',
      },
    }),
    prisma.setting.upsert({
      where: { key: 'pilot_search_radius_km' },
      update: {},
      create: {
        key: 'pilot_search_radius_km',
        value: '5',
        description: 'Radius in km to search for nearby pilots',
      },
    }),
    prisma.setting.upsert({
      where: { key: 'min_wallet_balance' },
      update: {},
      create: {
        key: 'min_wallet_balance',
        value: '0',
        description: 'Minimum wallet balance required for pilots',
      },
    }),
    prisma.setting.upsert({
      where: { key: 'cancellation_fee_percent' },
      update: {},
      create: {
        key: 'cancellation_fee_percent',
        value: '10',
        description: 'Cancellation fee percentage',
      },
    }),
  ])

  console.log(`✅ Created ${settings.length} settings`)

  // Create Service Area (Ahmedabad)
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

  console.log('\n🎉 Database seed completed successfully!')
  console.log('\n📝 Admin Login Credentials:')
  console.log('   Email: admin@sendit.co.in')
  console.log('   Password: admin123')
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
