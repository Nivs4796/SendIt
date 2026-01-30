'use client'

import { motion } from 'framer-motion'
import { Check } from 'lucide-react'
import { Container, SectionHeading } from '@/components/ui'
import { FEATURES } from '@/lib/constants'

export function Features() {
  return (
    <section className="section-padding bg-white">
      <Container>
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left - Image */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
            className="order-2 lg:order-1"
          >
            <div className="relative">
              <div className="aspect-square bg-gradient-to-br from-primary-100 to-primary-200 rounded-3xl flex items-center justify-center">
                <div className="text-center p-8">
                  <div className="w-32 h-32 bg-primary-500 rounded-full mx-auto mb-6 flex items-center justify-center">
                    <span className="text-white text-6xl font-bold">D</span>
                  </div>
                  <p className="text-primary-700 font-medium text-lg">
                    App Screenshot
                  </p>
                </div>
              </div>

              {/* Decorative elements */}
              <div className="absolute -top-4 -right-4 w-24 h-24 bg-accent-500 rounded-2xl opacity-20" />
              <div className="absolute -bottom-4 -left-4 w-32 h-32 bg-primary-500 rounded-full opacity-10" />
            </div>
          </motion.div>

          {/* Right - Content */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
            className="order-1 lg:order-2"
          >
            <span className="inline-block px-4 py-2 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mb-6">
              Why Choose Us
            </span>
            <h2 className="text-3xl md:text-4xl font-bold text-secondary-900 mb-6">
              What Sets Us Apart
            </h2>
            <p className="text-lg text-secondary-500 mb-8">
              We're not just another delivery service. Here's why thousands trust SendIt for their delivery needs.
            </p>

            <div className="grid sm:grid-cols-2 gap-4">
              {FEATURES.map((feature, index) => (
                <motion.div
                  key={feature}
                  initial={{ opacity: 0, y: 10 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  transition={{ duration: 0.3, delay: index * 0.05 }}
                  viewport={{ once: true }}
                  className="flex items-start gap-3"
                >
                  <div className="w-6 h-6 bg-primary-100 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                    <Check className="w-4 h-4 text-primary-600" />
                  </div>
                  <span className="text-secondary-700">{feature}</span>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </div>
      </Container>
    </section>
  )
}
