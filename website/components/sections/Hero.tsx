'use client'

import { motion } from 'framer-motion'
import Image from 'next/image'
import { ArrowRight, Play } from 'lucide-react'
import { Button, Container } from '@/components/ui'
import { SITE_CONFIG } from '@/lib/constants'

export function Hero() {
  return (
    <section className="relative overflow-hidden gradient-hero">
      <Container>
        <div className="py-16 lg:py-24">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            {/* Content */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5 }}
            >
              <span className="inline-block px-4 py-2 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mb-6">
                #1 Delivery Platform in Ahmedabad
              </span>
              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold text-secondary-900 leading-tight mb-6">
                Swift, Simple & Secure{' '}
                <span className="text-gradient">Delivery</span>{' '}
                at Your Fingertips
              </h1>
              <p className="text-xl text-secondary-600 mb-8 max-w-lg">
                On-demand courier delivery with real-time tracking. From documents to heavy goods - we deliver it all.
              </p>

              <div className="flex flex-col sm:flex-row gap-4 mb-8">
                <Button variant="primary" size="lg" className="gap-2">
                  Download User App
                  <ArrowRight className="w-5 h-5" />
                </Button>
                <Button variant="outline" size="lg">
                  Become a Pilot
                </Button>
              </div>

              {/* Trust Indicators */}
              <div className="flex items-center gap-6 text-sm text-secondary-500">
                <div className="flex items-center gap-2">
                  <div className="flex -space-x-2">
                    {[1, 2, 3, 4].map((i) => (
                      <div
                        key={i}
                        className="w-8 h-8 rounded-full bg-secondary-200 border-2 border-white"
                      />
                    ))}
                  </div>
                  <span>10K+ Users</span>
                </div>
                <div className="flex items-center gap-1">
                  <span className="text-accent-500">★</span>
                  <span>4.8 Rating</span>
                </div>
              </div>
            </motion.div>

            {/* Hero Image/Illustration */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 0.5, delay: 0.2 }}
              className="relative"
            >
              <div className="relative bg-white rounded-3xl shadow-2xl p-4 lg:p-6">
                {/* Hero illustration */}
                <div className="aspect-square rounded-2xl overflow-hidden">
                  <Image
                    src="/images/hero-illustration.svg"
                    alt="Fast delivery illustration"
                    width={500}
                    height={500}
                    className="w-full h-full object-contain"
                    priority
                  />
                </div>

                {/* Floating Elements */}
                <motion.div
                  animate={{ y: [0, -10, 0] }}
                  transition={{ duration: 2, repeat: Infinity }}
                  className="absolute -top-4 -right-4 bg-white rounded-xl shadow-lg p-4"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                      <span className="text-green-600">✓</span>
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-secondary-900">Delivered!</p>
                      <p className="text-xs text-secondary-500">2 mins ago</p>
                    </div>
                  </div>
                </motion.div>

                <motion.div
                  animate={{ y: [0, 10, 0] }}
                  transition={{ duration: 2.5, repeat: Infinity }}
                  className="absolute -bottom-4 -left-4 bg-white rounded-xl shadow-lg p-4"
                >
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                      <span className="text-primary-600">🚴</span>
                    </div>
                    <div>
                      <p className="text-sm font-semibold text-secondary-900">Driver nearby</p>
                      <p className="text-xs text-secondary-500">5 mins away</p>
                    </div>
                  </div>
                </motion.div>
              </div>
            </motion.div>
          </div>
        </div>
      </Container>

      {/* Background decorations */}
      <div className="absolute top-0 right-0 -z-10 w-1/2 h-full bg-gradient-to-l from-primary-100/50 to-transparent" />
      <div className="absolute bottom-0 left-0 -z-10 w-96 h-96 bg-primary-200/30 rounded-full blur-3xl" />
    </section>
  )
}
