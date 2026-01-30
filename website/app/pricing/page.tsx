import { Metadata } from 'next'
import { Container, SectionHeading, Card, CardContent } from '@/components/ui'
import { VEHICLE_PRICING } from '@/lib/constants'
import { Bike, Zap, Car, Truck, Check, Info } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Pricing',
  description: 'Transparent pricing for all SendIt delivery services. Check fares for cycles, 2-wheelers, 3-wheelers, and trucks.',
}

const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
  bike: Bike,
  zap: Zap,
  car: Car,
  truck: Truck,
}

const pricingFeatures = [
  'No hidden charges',
  'Taxes included in fare',
  'Upfront pricing before booking',
  'Wallet discounts available',
  'Coupon codes accepted',
]

export default function PricingPage() {
  return (
    <>
      {/* Hero */}
      <section className="py-16 lg:py-24 bg-gradient-to-b from-primary-50 to-white">
        <Container>
          <div className="max-w-3xl mx-auto text-center">
            <span className="inline-block px-4 py-2 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mb-6">
              Transparent Pricing
            </span>
            <h1 className="text-4xl md:text-5xl font-bold text-secondary-900 mb-6">
              Simple, Fair Pricing
            </h1>
            <p className="text-xl text-secondary-500">
              Know exactly what you'll pay before you book. No surprises, no hidden fees.
            </p>
          </div>
        </Container>
      </section>

      {/* Pricing Table */}
      <section className="section-padding bg-white">
        <Container>
          <SectionHeading
            badge="Fare Structure"
            title="Delivery Rates by Vehicle"
            subtitle="Choose the right vehicle based on your package size and delivery distance."
          />

          <div className="overflow-x-auto">
            <table className="w-full min-w-[600px]">
              <thead>
                <tr className="border-b border-secondary-200">
                  <th className="text-left py-4 px-4 text-secondary-500 font-medium">Vehicle Type</th>
                  <th className="text-left py-4 px-4 text-secondary-500 font-medium">Base Fare</th>
                  <th className="text-left py-4 px-4 text-secondary-500 font-medium">Per KM</th>
                  <th className="text-left py-4 px-4 text-secondary-500 font-medium">Max Weight</th>
                  <th className="text-left py-4 px-4 text-secondary-500 font-medium">Max Distance</th>
                </tr>
              </thead>
              <tbody>
                {VEHICLE_PRICING.map((vehicle) => {
                  const Icon = iconMap[vehicle.icon] || Bike
                  return (
                    <tr key={vehicle.type} className="border-b border-secondary-100 hover:bg-secondary-50">
                      <td className="py-4 px-4">
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 bg-primary-100 rounded-lg flex items-center justify-center text-primary-600">
                            <Icon className="w-5 h-5" />
                          </div>
                          <span className="font-semibold text-secondary-900">{vehicle.type}</span>
                        </div>
                      </td>
                      <td className="py-4 px-4">
                        <span className="text-secondary-900 font-semibold">
                          {typeof vehicle.baseFare === 'number' ? `₹${vehicle.baseFare}` : vehicle.baseFare}
                        </span>
                      </td>
                      <td className="py-4 px-4 text-secondary-600">{vehicle.perKm}</td>
                      <td className="py-4 px-4 text-secondary-600">{vehicle.maxWeight}</td>
                      <td className="py-4 px-4 text-secondary-600">{vehicle.maxDistance}</td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          </div>

          {/* Note */}
          <div className="mt-8 p-4 bg-primary-50 rounded-xl flex items-start gap-3">
            <Info className="w-5 h-5 text-primary-600 mt-0.5" />
            <div>
              <p className="text-primary-800 font-medium">How pricing works</p>
              <p className="text-primary-700 text-sm mt-1">
                Final fare = Base Fare + (Distance × Per KM Rate). Surge pricing may apply during peak hours or high demand periods.
              </p>
            </div>
          </div>
        </Container>
      </section>

      {/* Features */}
      <section className="section-padding bg-secondary-50">
        <Container size="sm">
          <SectionHeading
            badge="No Hidden Fees"
            title="What's Included"
            subtitle="We believe in transparent pricing with no surprises."
          />

          <div className="bg-white rounded-2xl p-8">
            <div className="grid sm:grid-cols-2 gap-4">
              {pricingFeatures.map((feature) => (
                <div key={feature} className="flex items-center gap-3">
                  <div className="w-6 h-6 bg-green-100 rounded-full flex items-center justify-center">
                    <Check className="w-4 h-4 text-green-600" />
                  </div>
                  <span className="text-secondary-700">{feature}</span>
                </div>
              ))}
            </div>
          </div>
        </Container>
      </section>

      {/* CTA */}
      <section className="section-padding bg-primary-600 text-white">
        <Container size="sm">
          <div className="text-center">
            <h2 className="text-3xl font-bold mb-4">Ready to Book?</h2>
            <p className="text-primary-100 mb-8">
              Download the app and get your first delivery at 50% off with code WELCOME50
            </p>
            <div className="flex flex-col sm:flex-row gap-4 justify-center">
              <a
                href="#"
                className="inline-flex items-center justify-center px-8 py-4 bg-white text-primary-600 font-semibold rounded-full hover:bg-primary-50 transition-colors"
              >
                Download User App
              </a>
              <a
                href="/become-pilot"
                className="inline-flex items-center justify-center px-8 py-4 border-2 border-white text-white font-semibold rounded-full hover:bg-white/10 transition-colors"
              >
                Become a Pilot
              </a>
            </div>
          </div>
        </Container>
      </section>
    </>
  )
}
