'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { MapPin, Car, Navigation, Star, UserPlus, Wifi, CheckCircle, Wallet } from 'lucide-react'
import { Container, SectionHeading } from '@/components/ui'
import { HOW_IT_WORKS_USER, HOW_IT_WORKS_PILOT } from '@/lib/constants'
import { cn } from '@/lib/utils'

const iconMap: Record<string, React.ReactNode> = {
  'map-pin': <MapPin className="w-6 h-6" />,
  'car': <Car className="w-6 h-6" />,
  'navigation': <Navigation className="w-6 h-6" />,
  'star': <Star className="w-6 h-6" />,
  'user-plus': <UserPlus className="w-6 h-6" />,
  'wifi': <Wifi className="w-6 h-6" />,
  'check-circle': <CheckCircle className="w-6 h-6" />,
  'wallet': <Wallet className="w-6 h-6" />,
}

export function HowItWorks() {
  const [activeTab, setActiveTab] = useState<'user' | 'pilot'>('user')

  const steps = activeTab === 'user' ? HOW_IT_WORKS_USER : HOW_IT_WORKS_PILOT

  return (
    <section className="section-padding bg-secondary-50">
      <Container>
        <SectionHeading
          badge="Simple Process"
          title="How It Works"
          subtitle="Get started in minutes. Book a delivery or become a pilot in just a few simple steps."
        />

        {/* Tabs */}
        <div className="flex justify-center mb-12">
          <div className="inline-flex bg-white rounded-full p-1 shadow-sm border border-secondary-200">
            <button
              onClick={() => setActiveTab('user')}
              className={cn(
                'px-6 py-3 rounded-full font-semibold transition-all',
                activeTab === 'user'
                  ? 'bg-primary-500 text-white shadow-md'
                  : 'text-secondary-600 hover:text-secondary-900'
              )}
            >
              For Users
            </button>
            <button
              onClick={() => setActiveTab('pilot')}
              className={cn(
                'px-6 py-3 rounded-full font-semibold transition-all',
                activeTab === 'pilot'
                  ? 'bg-primary-500 text-white shadow-md'
                  : 'text-secondary-600 hover:text-secondary-900'
              )}
            >
              For Pilots
            </button>
          </div>
        </div>

        {/* Steps */}
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {steps.map((step, index) => (
            <motion.div
              key={step.step}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              viewport={{ once: true }}
              className="relative"
            >
              {/* Connector line */}
              {index < steps.length - 1 && (
                <div className="hidden lg:block absolute top-12 left-[60%] w-full h-0.5 bg-primary-200" />
              )}

              <div className="text-center">
                <div className="relative inline-block mb-6">
                  <div className="w-24 h-24 bg-white rounded-2xl shadow-lg flex items-center justify-center text-primary-600">
                    {iconMap[step.icon]}
                  </div>
                  <div className="absolute -top-2 -right-2 w-8 h-8 bg-primary-500 rounded-full flex items-center justify-center text-white font-bold text-sm">
                    {step.step}
                  </div>
                </div>
                <h3 className="text-xl font-bold text-secondary-900 mb-2">
                  {step.title}
                </h3>
                <p className="text-secondary-500">
                  {step.description}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      </Container>
    </section>
  )
}
