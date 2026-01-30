'use client'

import { useEffect, useRef, useState } from 'react'
import { motion, useInView } from 'framer-motion'
import { Container } from '@/components/ui'
import { STATS } from '@/lib/constants'

function AnimatedNumber({ value, suffix }: { value: number; suffix: string }) {
  const [count, setCount] = useState(0)
  const ref = useRef(null)
  const isInView = useInView(ref, { once: true })

  useEffect(() => {
    if (isInView) {
      const duration = 2000
      const steps = 60
      const stepValue = value / steps
      let current = 0

      const timer = setInterval(() => {
        current += stepValue
        if (current >= value) {
          setCount(value)
          clearInterval(timer)
        } else {
          setCount(Math.floor(current))
        }
      }, duration / steps)

      return () => clearInterval(timer)
    }
  }, [isInView, value])

  return (
    <span ref={ref}>
      {value % 1 === 0 ? count.toLocaleString() : count.toFixed(1)}
      {suffix}
    </span>
  )
}

export function Stats() {
  return (
    <section className="py-12 bg-white border-y border-secondary-100">
      <Container>
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-8">
          {STATS.map((stat, index) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              viewport={{ once: true }}
              className="text-center"
            >
              <p className="text-4xl lg:text-5xl font-bold text-primary-600 mb-2">
                <AnimatedNumber value={stat.value} suffix={stat.suffix} />
              </p>
              <p className="text-secondary-500 font-medium">{stat.label}</p>
            </motion.div>
          ))}
        </div>
      </Container>
    </section>
  )
}
