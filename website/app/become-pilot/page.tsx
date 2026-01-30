import { Metadata } from 'next'
import Link from 'next/link'
import Image from 'next/image'
import { Container, SectionHeading, Card, CardContent, Button } from '@/components/ui'
import { PILOT_BENEFITS } from '@/lib/constants'
import {
  Clock, TrendingUp, CreditCard, Gift, Shield, Headphones,
  Smartphone, FileText, CheckCircle, Wallet, ChevronDown,
  Bike, Zap, Car, Truck
} from 'lucide-react'

export const metadata: Metadata = {
  title: 'Become a Pilot',
  description: 'Join SendIt as a delivery pilot. Flexible hours, competitive earnings, and weekly payouts. Start earning today!',
}

const iconMap: Record<string, React.ComponentType<{ className?: string }>> = {
  clock: Clock,
  'trending-up': TrendingUp,
  'credit-card': CreditCard,
  gift: Gift,
  shield: Shield,
  headphones: Headphones,
}

const requirements = [
  { label: 'Age 18+ (or 16-18 for EV Cycle with parental consent)', icon: CheckCircle },
  { label: 'Valid driving license (for motorized vehicles)', icon: FileText },
  { label: 'Vehicle registration & insurance documents', icon: FileText },
  { label: 'Smartphone with GPS', icon: Smartphone },
  { label: 'Bank account for payouts', icon: Wallet },
]

const steps = [
  { step: 1, title: 'Download App', description: 'Get the SendIt Pilot app from Play Store or App Store' },
  { step: 2, title: 'Register', description: 'Fill in your details and upload required documents' },
  { step: 3, title: 'Verification', description: 'Our team verifies your documents within 24-48 hours' },
  { step: 4, title: 'Start Earning', description: 'Go online and start accepting delivery requests' },
]

const faqs = [
  {
    question: 'How much can I earn as a SendIt pilot?',
    answer: 'Earnings depend on hours worked and orders completed. Active pilots earn ₹15,000-25,000+ per month working 6-8 hours daily.',
  },
  {
    question: 'When do I get paid?',
    answer: 'We process payouts every week. Your earnings are transferred directly to your bank account every Monday.',
  },
  {
    question: 'Can I work part-time?',
    answer: 'Absolutely! You choose your own hours. Work as much or as little as you want.',
  },
  {
    question: 'What if I don\'t have a vehicle?',
    answer: 'If you\'re 16-18, you can join our EV Cycle program with parental consent and we can help you get started.',
  },
  {
    question: 'Is there any joining fee?',
    answer: 'No! Joining SendIt as a pilot is completely free. There are no hidden charges or deposits.',
  },
]

const vehicleOptions = [
  { icon: Bike, name: 'Cycle', earnings: '₹300-500/day', requirement: 'No license needed' },
  { icon: Zap, name: 'EV Cycle', earnings: '₹400-600/day', requirement: '16+ with consent' },
  { icon: Bike, name: '2 Wheeler', earnings: '₹600-1000/day', requirement: 'Valid DL' },
  { icon: Car, name: '3 Wheeler', earnings: '₹800-1200/day', requirement: 'Valid DL' },
  { icon: Truck, name: 'Truck', earnings: '₹1500-2500/day', requirement: 'Commercial DL' },
]

export default function BecomePilotPage() {
  return (
    <>
      {/* Hero */}
      <section className="py-16 lg:py-24 bg-gradient-to-br from-secondary-900 to-secondary-800 text-white">
        <Container>
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            <div>
              <span className="inline-block px-4 py-2 bg-primary-500/20 text-primary-400 rounded-full text-sm font-semibold mb-6">
                Join 500+ Pilots
              </span>
              <h1 className="text-4xl md:text-5xl font-bold mb-6">
                Earn Money on Your Schedule
              </h1>
              <p className="text-xl text-secondary-300 mb-8">
                Become a SendIt pilot and enjoy flexible hours, competitive earnings, and weekly payouts. Your vehicle, your time, your earnings.
              </p>
              <div className="flex flex-col sm:flex-row gap-4">
                <Button size="lg" className="bg-primary-500 hover:bg-primary-600">
                  Download Pilot App
                </Button>
                <Button size="lg" variant="outline" className="border-white text-white hover:bg-white/10">
                  Watch How It Works
                </Button>
              </div>
            </div>
            <div className="relative">
              <div className="rounded-3xl overflow-hidden">
                <Image
                  src="/images/pilot-hero.svg"
                  alt="Become a SendIt Pilot"
                  width={500}
                  height={400}
                  className="w-full h-auto"
                />
              </div>
            </div>
          </div>
        </Container>
      </section>

      {/* Benefits */}
      <section className="section-padding bg-white">
        <Container>
          <SectionHeading
            badge="Why Join Us"
            title="Benefits of Being a SendIt Pilot"
            subtitle="We take care of our pilots with great benefits and support."
          />

          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {PILOT_BENEFITS.map((benefit) => {
              const Icon = iconMap[benefit.icon] || Clock
              return (
                <Card key={benefit.title}>
                  <CardContent>
                    <div className="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center text-primary-600 mb-4">
                      <Icon className="w-6 h-6" />
                    </div>
                    <h3 className="text-lg font-bold text-secondary-900 mb-2">{benefit.title}</h3>
                    <p className="text-secondary-500">{benefit.description}</p>
                  </CardContent>
                </Card>
              )
            })}
          </div>
        </Container>
      </section>

      {/* Vehicle Options */}
      <section className="section-padding bg-secondary-50">
        <Container>
          <SectionHeading
            badge="Vehicle Options"
            title="Earn with Any Vehicle"
            subtitle="Choose the vehicle that suits you best."
          />

          <div className="grid md:grid-cols-2 lg:grid-cols-5 gap-6">
            {vehicleOptions.map((vehicle) => (
              <Card key={vehicle.name} className="text-center">
                <CardContent>
                  <div className="w-14 h-14 bg-primary-100 rounded-xl flex items-center justify-center text-primary-600 mx-auto mb-4">
                    <vehicle.icon className="w-7 h-7" />
                  </div>
                  <h3 className="font-bold text-secondary-900 mb-1">{vehicle.name}</h3>
                  <p className="text-primary-600 font-semibold mb-2">{vehicle.earnings}</p>
                  <p className="text-sm text-secondary-500">{vehicle.requirement}</p>
                </CardContent>
              </Card>
            ))}
          </div>
        </Container>
      </section>

      {/* Requirements */}
      <section className="section-padding bg-white">
        <Container size="sm">
          <SectionHeading
            badge="Requirements"
            title="What You Need to Join"
            subtitle="Simple requirements to get started."
          />

          <div className="bg-secondary-50 rounded-2xl p-8">
            <div className="space-y-4">
              {requirements.map((req) => (
                <div key={req.label} className="flex items-center gap-4">
                  <div className="w-8 h-8 bg-primary-100 rounded-full flex items-center justify-center">
                    <req.icon className="w-4 h-4 text-primary-600" />
                  </div>
                  <span className="text-secondary-700">{req.label}</span>
                </div>
              ))}
            </div>
          </div>
        </Container>
      </section>

      {/* How to Join */}
      <section className="section-padding bg-primary-600 text-white">
        <Container>
          <SectionHeading
            badge="Get Started"
            title="How to Become a Pilot"
            subtitle="Join in 4 simple steps and start earning."
          />

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
            {steps.map((step, index) => (
              <div key={step.step} className="relative text-center">
                {index < steps.length - 1 && (
                  <div className="hidden lg:block absolute top-8 left-[60%] w-full h-0.5 bg-primary-400" />
                )}
                <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-primary-600 font-bold text-2xl mx-auto mb-4 relative z-10">
                  {step.step}
                </div>
                <h3 className="text-xl font-bold mb-2">{step.title}</h3>
                <p className="text-primary-100">{step.description}</p>
              </div>
            ))}
          </div>
        </Container>
      </section>

      {/* FAQ */}
      <section className="section-padding bg-white">
        <Container size="sm">
          <SectionHeading
            badge="FAQs"
            title="Frequently Asked Questions"
            subtitle="Got questions? We've got answers."
          />

          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <details
                key={index}
                className="group bg-secondary-50 rounded-xl overflow-hidden"
              >
                <summary className="flex items-center justify-between p-6 cursor-pointer list-none">
                  <span className="font-semibold text-secondary-900">{faq.question}</span>
                  <ChevronDown className="w-5 h-5 text-secondary-500 group-open:rotate-180 transition-transform" />
                </summary>
                <div className="px-6 pb-6 text-secondary-600">
                  {faq.answer}
                </div>
              </details>
            ))}
          </div>
        </Container>
      </section>

      {/* CTA */}
      <section className="section-padding bg-secondary-900 text-white">
        <Container size="sm">
          <div className="text-center">
            <h2 className="text-3xl font-bold mb-4">Ready to Start Earning?</h2>
            <p className="text-secondary-400 mb-8">
              Download the SendIt Pilot app and complete your registration today.
            </p>
            <Button size="lg" className="bg-primary-500 hover:bg-primary-600">
              Download Pilot App
            </Button>
          </div>
        </Container>
      </section>
    </>
  )
}
