'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { Bell, ArrowRight, Check } from 'lucide-react'
import { Container, Button, Input } from '@/components/ui'

export function Newsletter() {
  const [phone, setPhone] = useState('')
  const [submitted, setSubmitted] = useState(false)

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // TODO: Integrate with backend
    setSubmitted(true)
  }

  return (
    <section className="section-padding bg-secondary-50">
      <Container size="sm">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          viewport={{ once: true }}
          className="text-center"
        >
          <div className="w-16 h-16 bg-primary-100 rounded-2xl flex items-center justify-center mx-auto mb-6">
            <Bell className="w-8 h-8 text-primary-600" />
          </div>

          <h2 className="text-3xl md:text-4xl font-bold text-secondary-900 mb-4">
            Stay Updated
          </h2>
          <p className="text-lg text-secondary-500 mb-8 max-w-md mx-auto">
            Get notified about new features, special offers, and delivery updates.
          </p>

          {!submitted ? (
            <form onSubmit={handleSubmit} className="max-w-md mx-auto">
              <div className="flex gap-3">
                <div className="flex-1 relative">
                  <span className="absolute left-4 top-1/2 -translate-y-1/2 text-secondary-400">
                    +91
                  </span>
                  <Input
                    type="tel"
                    placeholder="Enter your mobile number"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="pl-12"
                    required
                  />
                </div>
                <Button type="submit" variant="primary" className="flex-shrink-0 gap-2">
                  Notify Me
                  <ArrowRight className="w-4 h-4" />
                </Button>
              </div>
              <p className="text-sm text-secondary-400 mt-3">
                We'll never spam. Unsubscribe anytime.
              </p>
            </form>
          ) : (
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              className="bg-green-50 text-green-700 rounded-2xl p-6 max-w-md mx-auto"
            >
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Check className="w-6 h-6" />
              </div>
              <p className="font-semibold text-lg mb-1">You're on the list!</p>
              <p className="text-green-600">
                We'll notify you about the latest updates.
              </p>
            </motion.div>
          )}
        </motion.div>
      </Container>
    </section>
  )
}
