'use client'

import { useState, useEffect } from 'react'
import Image from 'next/image'
import { motion, AnimatePresence } from 'framer-motion'
import { ChevronLeft, ChevronRight, Quote } from 'lucide-react'
import { Container, SectionHeading } from '@/components/ui'
import { TESTIMONIALS } from '@/lib/constants'

const avatars = [
  '/images/testimonials/user-1.svg',
  '/images/testimonials/user-2.svg',
  '/images/testimonials/user-3.svg',
  '/images/testimonials/user-4.svg',
]

export function Testimonials() {
  const [current, setCurrent] = useState(0)

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrent((prev) => (prev + 1) % TESTIMONIALS.length)
    }, 5000)
    return () => clearInterval(timer)
  }, [])

  const next = () => setCurrent((prev) => (prev + 1) % TESTIMONIALS.length)
  const prev = () => setCurrent((prev) => (prev - 1 + TESTIMONIALS.length) % TESTIMONIALS.length)

  return (
    <section className="section-padding bg-white">
      <Container size="sm">
        <SectionHeading
          badge="Testimonials"
          title="What People Say"
          subtitle="Hear from our happy customers and successful pilots."
        />

        <div className="relative">
          <AnimatePresence mode="wait">
            <motion.div
              key={current}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.3 }}
              className="bg-secondary-50 rounded-3xl p-8 lg:p-12"
            >
              <Quote className="w-12 h-12 text-primary-200 mb-6" />

              <p className="text-xl lg:text-2xl text-secondary-700 mb-8 leading-relaxed">
                "{TESTIMONIALS[current].text}"
              </p>

              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-full overflow-hidden">
                  <Image
                    src={avatars[current % avatars.length]}
                    alt={TESTIMONIALS[current].name}
                    width={56}
                    height={56}
                    className="w-full h-full object-cover"
                  />
                </div>
                <div>
                  <p className="font-semibold text-secondary-900">
                    {TESTIMONIALS[current].name}
                  </p>
                  <p className="text-secondary-500 text-sm">
                    {TESTIMONIALS[current].location}
                  </p>
                </div>
                <div className="ml-auto flex items-center gap-1">
                  {[...Array(TESTIMONIALS[current].rating)].map((_, i) => (
                    <span key={i} className="text-accent-500">★</span>
                  ))}
                </div>
              </div>
            </motion.div>
          </AnimatePresence>

          {/* Navigation */}
          <div className="flex justify-center items-center gap-4 mt-8">
            <button
              onClick={prev}
              className="w-10 h-10 rounded-full bg-white border border-secondary-200 flex items-center justify-center hover:bg-secondary-50 transition-colors"
              aria-label="Previous testimonial"
            >
              <ChevronLeft className="w-5 h-5 text-secondary-600" />
            </button>

            <div className="flex gap-2">
              {TESTIMONIALS.map((_, index) => (
                <button
                  key={index}
                  onClick={() => setCurrent(index)}
                  className={`w-2 h-2 rounded-full transition-all ${
                    index === current
                      ? 'bg-primary-500 w-6'
                      : 'bg-secondary-300 hover:bg-secondary-400'
                  }`}
                  aria-label={`Go to testimonial ${index + 1}`}
                />
              ))}
            </div>

            <button
              onClick={next}
              className="w-10 h-10 rounded-full bg-white border border-secondary-200 flex items-center justify-center hover:bg-secondary-50 transition-colors"
              aria-label="Next testimonial"
            >
              <ChevronRight className="w-5 h-5 text-secondary-600" />
            </button>
          </div>
        </div>
      </Container>
    </section>
  )
}
