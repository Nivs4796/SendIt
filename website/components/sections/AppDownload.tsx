'use client'

import { motion } from 'framer-motion'
import Image from 'next/image'
import { Smartphone, QrCode } from 'lucide-react'
import { Container, Button } from '@/components/ui'
import { SITE_CONFIG } from '@/lib/constants'

export function AppDownload() {
  return (
    <section className="section-padding bg-gradient-to-br from-primary-600 to-primary-700 text-white overflow-hidden">
      <Container>
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Content */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
          >
            <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold mb-6">
              Download the {SITE_CONFIG.name} App
            </h2>
            <p className="text-xl text-primary-100 mb-8 max-w-lg">
              Get the best delivery experience on your phone. Track orders in real-time, earn rewards, and more.
            </p>

            <div className="grid sm:grid-cols-2 gap-6 mb-8">
              {/* User App */}
              <div className="bg-white/10 backdrop-blur rounded-2xl p-6">
                <h3 className="font-semibold text-lg mb-4">For Users</h3>
                <div className="flex gap-3 mb-4">
                  <a href="#" className="block">
                    <div className="bg-black rounded-lg px-4 py-2 flex items-center gap-2 hover:bg-gray-900 transition-colors">
                      <Smartphone className="w-5 h-5" />
                      <div className="text-left">
                        <p className="text-[10px] leading-none">Download on the</p>
                        <p className="text-sm font-semibold">App Store</p>
                      </div>
                    </div>
                  </a>
                  <a href="#" className="block">
                    <div className="bg-black rounded-lg px-4 py-2 flex items-center gap-2 hover:bg-gray-900 transition-colors">
                      <Smartphone className="w-5 h-5" />
                      <div className="text-left">
                        <p className="text-[10px] leading-none">Get it on</p>
                        <p className="text-sm font-semibold">Google Play</p>
                      </div>
                    </div>
                  </a>
                </div>
                <div className="flex items-center gap-3 text-sm text-primary-100">
                  <QrCode className="w-5 h-5" />
                  <span>Scan QR to download</span>
                </div>
              </div>

              {/* Pilot App */}
              <div className="bg-white/10 backdrop-blur rounded-2xl p-6">
                <h3 className="font-semibold text-lg mb-4">For Pilots</h3>
                <div className="flex gap-3 mb-4">
                  <a href="#" className="block">
                    <div className="bg-black rounded-lg px-4 py-2 flex items-center gap-2 hover:bg-gray-900 transition-colors">
                      <Smartphone className="w-5 h-5" />
                      <div className="text-left">
                        <p className="text-[10px] leading-none">Download on the</p>
                        <p className="text-sm font-semibold">App Store</p>
                      </div>
                    </div>
                  </a>
                  <a href="#" className="block">
                    <div className="bg-black rounded-lg px-4 py-2 flex items-center gap-2 hover:bg-gray-900 transition-colors">
                      <Smartphone className="w-5 h-5" />
                      <div className="text-left">
                        <p className="text-[10px] leading-none">Get it on</p>
                        <p className="text-sm font-semibold">Google Play</p>
                      </div>
                    </div>
                  </a>
                </div>
                <div className="flex items-center gap-3 text-sm text-primary-100">
                  <QrCode className="w-5 h-5" />
                  <span>Scan QR to download</span>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Phone Mockups */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.5, delay: 0.2 }}
            viewport={{ once: true }}
            className="relative"
          >
            <div className="flex justify-center gap-4">
              {/* Phone 1 - User App */}
              <div className="w-48 lg:w-56">
                <div className="bg-white rounded-[2.5rem] p-2 shadow-2xl overflow-hidden">
                  <Image
                    src="/images/app-screenshot-user.svg"
                    alt="SendIt User App"
                    width={280}
                    height={560}
                    className="w-full rounded-[2rem]"
                  />
                </div>
              </div>

              {/* Phone 2 - Pilot App */}
              <div className="w-48 lg:w-56 mt-8">
                <div className="bg-white rounded-[2.5rem] p-2 shadow-2xl overflow-hidden">
                  <Image
                    src="/images/app-screenshot-pilot.svg"
                    alt="SendIt Pilot App"
                    width={280}
                    height={560}
                    className="w-full rounded-[2rem]"
                  />
                </div>
              </div>
            </div>

            {/* Decorative elements */}
            <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-2xl" />
            <div className="absolute -bottom-10 -left-10 w-60 h-60 bg-primary-400/20 rounded-full blur-3xl" />
          </motion.div>
        </div>
      </Container>
    </section>
  )
}
