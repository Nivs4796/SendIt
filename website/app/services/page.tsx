import { Metadata } from 'next'
import Image from 'next/image'
import { Container, SectionHeading, Card, CardContent } from '@/components/ui'
import { Package, Users, Calendar, Leaf, Truck, Bike, Car, Zap, Check } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Our Services',
  description: 'Explore SendIt\'s delivery services - goods delivery, passenger rides, scheduled pickups, and eco-friendly EV options.',
}

const services = [
  {
    id: 'goods',
    icon: Package,
    title: 'Goods Delivery',
    description: 'Send parcels, documents, groceries, and more with our reliable delivery network.',
    image: '/images/services/goods-delivery.svg',
    features: [
      'Same-day delivery within city',
      'Real-time GPS tracking',
      'Photo proof of delivery',
      'COD & online payment options',
      'Insurance available',
    ],
    vehicles: ['Cycle', '2 Wheeler', '3 Wheeler', 'Truck'],
    useCases: ['E-commerce packages', 'Documents', 'Groceries', 'Food delivery', 'Gifts'],
  },
  {
    id: 'passenger',
    icon: Users,
    title: 'Passenger Rides',
    description: 'Quick and affordable 2-wheeler and auto rides for your daily commute.',
    image: '/images/services/passenger-rides.svg',
    features: [
      'Affordable pricing',
      'Professional drivers',
      'Safe & comfortable',
      'Live tracking',
      'Multiple payment options',
    ],
    vehicles: ['2 Wheeler', '3 Wheeler Auto'],
    useCases: ['Daily commute', 'Airport transfers', 'Short trips', 'Quick errands'],
  },
  {
    id: 'scheduled',
    icon: Calendar,
    title: 'Scheduled Pickup',
    description: 'Book deliveries in advance for planned shipments and business needs.',
    image: '/images/services/scheduled-pickup.svg',
    features: [
      'Book up to 7 days in advance',
      'Flexible time slots',
      'Priority matching',
      'Perfect for businesses',
      'Recurring bookings',
    ],
    vehicles: ['All vehicle types'],
    useCases: ['Business deliveries', 'Regular shipments', 'Planned moves', 'Recurring orders'],
  },
  {
    id: 'ev',
    icon: Leaf,
    title: 'EV Eco-Friendly',
    description: 'Sustainable delivery options with electric vehicles for a greener tomorrow.',
    image: '/images/services/ev-delivery.svg',
    features: [
      'Zero emissions',
      'Cost-effective',
      'Teen pilot program (16+)',
      'Perfect for short distances',
      'Lower carbon footprint',
    ],
    vehicles: ['EV Cycle', 'EV 2 Wheeler'],
    useCases: ['Eco-conscious deliveries', 'Short distance', 'Documents', 'Small packages'],
  },
]

const vehicleTypes = [
  {
    icon: Bike,
    name: 'Cycle',
    capacity: 'Up to 5 KG',
    distance: '5 KM max',
    best: 'Documents, small packages',
  },
  {
    icon: Zap,
    name: 'EV Cycle',
    capacity: 'Up to 5 KG',
    distance: 'Flexible',
    best: 'Eco-friendly deliveries',
  },
  {
    icon: Bike,
    name: '2 Wheeler',
    capacity: 'Up to 10 KG',
    distance: 'City-wide',
    best: 'Quick deliveries',
  },
  {
    icon: Car,
    name: '3 Wheeler',
    capacity: 'Up to 100 KG',
    distance: 'City-wide',
    best: 'Medium loads',
  },
  {
    icon: Truck,
    name: 'Truck',
    capacity: '500+ KG',
    distance: 'City-wide',
    best: 'Heavy goods, moving',
  },
]

export default function ServicesPage() {
  return (
    <>
      {/* Hero */}
      <section className="py-16 lg:py-24 bg-gradient-to-b from-primary-50 to-white">
        <Container>
          <div className="max-w-3xl mx-auto text-center">
            <span className="inline-block px-4 py-2 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mb-6">
              Our Services
            </span>
            <h1 className="text-4xl md:text-5xl font-bold text-secondary-900 mb-6">
              Delivery Solutions for Every Need
            </h1>
            <p className="text-xl text-secondary-500">
              From small documents to heavy goods, we have the right service and vehicle for your delivery needs.
            </p>
          </div>
        </Container>
      </section>

      {/* Services Detail */}
      <section className="section-padding bg-white">
        <Container>
          <div className="space-y-24">
            {services.map((service, index) => (
              <div
                key={service.id}
                id={service.id}
                className={`grid lg:grid-cols-2 gap-12 items-center ${
                  index % 2 === 1 ? 'lg:flex-row-reverse' : ''
                }`}
              >
                <div className={index % 2 === 1 ? 'lg:order-2' : ''}>
                  <div className="w-16 h-16 bg-primary-100 rounded-2xl flex items-center justify-center text-primary-600 mb-6">
                    <service.icon className="w-8 h-8" />
                  </div>
                  <h2 className="text-3xl font-bold text-secondary-900 mb-4">{service.title}</h2>
                  <p className="text-lg text-secondary-500 mb-6">{service.description}</p>

                  <div className="space-y-3 mb-6">
                    {service.features.map((feature) => (
                      <div key={feature} className="flex items-center gap-3">
                        <div className="w-5 h-5 bg-primary-100 rounded-full flex items-center justify-center">
                          <Check className="w-3 h-3 text-primary-600" />
                        </div>
                        <span className="text-secondary-700">{feature}</span>
                      </div>
                    ))}
                  </div>

                  <div className="flex flex-wrap gap-2">
                    {service.vehicles.map((vehicle) => (
                      <span
                        key={vehicle}
                        className="px-3 py-1 bg-secondary-100 text-secondary-700 rounded-full text-sm"
                      >
                        {vehicle}
                      </span>
                    ))}
                  </div>
                </div>

                <div className={index % 2 === 1 ? 'lg:order-1' : ''}>
                  <div className="rounded-3xl overflow-hidden">
                    <Image
                      src={service.image}
                      alt={service.title}
                      width={400}
                      height={300}
                      className="w-full h-auto"
                    />
                  </div>
                  <div className="bg-secondary-50 rounded-3xl p-6 mt-4">
                    <h3 className="font-semibold text-secondary-900 mb-4">Perfect For</h3>
                    <div className="grid grid-cols-2 gap-3">
                      {service.useCases.map((useCase) => (
                        <div
                          key={useCase}
                          className="bg-white rounded-xl p-3 text-center text-secondary-700 text-sm"
                        >
                          {useCase}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </Container>
      </section>

      {/* Vehicle Types */}
      <section className="section-padding bg-secondary-50">
        <Container>
          <SectionHeading
            badge="Vehicle Fleet"
            title="Choose Your Vehicle"
            subtitle="We have the right vehicle for every delivery size and distance."
          />

          <div className="grid md:grid-cols-2 lg:grid-cols-5 gap-6">
            {vehicleTypes.map((vehicle) => (
              <Card key={vehicle.name} className="text-center">
                <CardContent>
                  <div className="w-14 h-14 bg-primary-100 rounded-xl flex items-center justify-center text-primary-600 mx-auto mb-4">
                    <vehicle.icon className="w-7 h-7" />
                  </div>
                  <h3 className="text-lg font-bold text-secondary-900 mb-2">{vehicle.name}</h3>
                  <p className="text-sm text-secondary-500 mb-1">{vehicle.capacity}</p>
                  <p className="text-sm text-secondary-500 mb-3">{vehicle.distance}</p>
                  <p className="text-xs text-primary-600 font-medium">{vehicle.best}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </Container>
      </section>
    </>
  )
}
