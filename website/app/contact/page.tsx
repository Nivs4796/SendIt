'use client'

import { useState } from 'react'
import Image from 'next/image'
import { Container, SectionHeading, Input, Button } from '@/components/ui'
import { SITE_CONFIG } from '@/lib/constants'
import { Mail, Phone, MapPin, Send, Check, Clock } from 'lucide-react'

const contactInfo = [
  {
    icon: Mail,
    label: 'Email',
    value: SITE_CONFIG.email,
    href: `mailto:${SITE_CONFIG.email}`,
  },
  {
    icon: Phone,
    label: 'Phone',
    value: SITE_CONFIG.phone,
    href: `tel:${SITE_CONFIG.phone}`,
  },
  {
    icon: MapPin,
    label: 'Location',
    value: SITE_CONFIG.location,
    href: '#',
  },
  {
    icon: Clock,
    label: 'Support Hours',
    value: '24/7 Available',
    href: '#',
  },
]

const categories = [
  { value: 'inquiry', label: 'General Inquiry' },
  { value: 'support', label: 'Customer Support' },
  { value: 'feedback', label: 'Feedback' },
  { value: 'partnership', label: 'Business Partnership' },
  { value: 'pilot', label: 'Pilot Support' },
]

export default function ContactPage() {
  const [submitted, setSubmitted] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    category: 'inquiry',
    message: '',
  })

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    // TODO: Integrate with backend
    setSubmitted(true)
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value })
  }

  return (
    <>
      {/* Hero */}
      <section className="py-16 lg:py-24 bg-gradient-to-b from-primary-50 to-white">
        <Container>
          <div className="max-w-3xl mx-auto text-center">
            <span className="inline-block px-4 py-2 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mb-6">
              Get in Touch
            </span>
            <h1 className="text-4xl md:text-5xl font-bold text-secondary-900 mb-6">
              We'd Love to Hear from You
            </h1>
            <p className="text-xl text-secondary-500">
              Have questions, feedback, or need support? Our team is here to help.
            </p>
          </div>
        </Container>
      </section>

      {/* Contact Form & Info */}
      <section className="section-padding bg-white">
        <Container>
          <div className="grid lg:grid-cols-3 gap-12">
            {/* Contact Info */}
            <div className="lg:col-span-1">
              <h2 className="text-2xl font-bold text-secondary-900 mb-6">Contact Information</h2>
              <div className="space-y-6">
                {contactInfo.map((info) => (
                  <a
                    key={info.label}
                    href={info.href}
                    className="flex items-start gap-4 group"
                  >
                    <div className="w-12 h-12 bg-primary-100 rounded-xl flex items-center justify-center text-primary-600 group-hover:bg-primary-500 group-hover:text-white transition-colors">
                      <info.icon className="w-5 h-5" />
                    </div>
                    <div>
                      <p className="text-sm text-secondary-500">{info.label}</p>
                      <p className="font-medium text-secondary-900 group-hover:text-primary-600 transition-colors">
                        {info.value}
                      </p>
                    </div>
                  </a>
                ))}
              </div>

              {/* Social Links */}
              <div className="mt-8 pt-8 border-t border-secondary-100">
                <p className="text-sm text-secondary-500 mb-4">Follow us on social media</p>
                <div className="flex gap-3">
                  {['Facebook', 'Twitter', 'Instagram', 'LinkedIn'].map((social) => (
                    <a
                      key={social}
                      href="#"
                      className="w-10 h-10 bg-secondary-100 rounded-full flex items-center justify-center text-secondary-600 hover:bg-primary-500 hover:text-white transition-colors"
                    >
                      {social.charAt(0)}
                    </a>
                  ))}
                </div>
              </div>

              {/* Illustration */}
              <div className="mt-8 hidden lg:block">
                <Image
                  src="/images/contact-illustration.svg"
                  alt="Customer support"
                  width={400}
                  height={300}
                  className="w-full rounded-2xl"
                />
              </div>
            </div>

            {/* Contact Form */}
            <div className="lg:col-span-2">
              {!submitted ? (
                <form onSubmit={handleSubmit} className="bg-secondary-50 rounded-2xl p-8">
                  <h2 className="text-2xl font-bold text-secondary-900 mb-6">Send us a Message</h2>

                  <div className="grid md:grid-cols-2 gap-6 mb-6">
                    <Input
                      label="Full Name"
                      name="name"
                      placeholder="John Doe"
                      value={formData.name}
                      onChange={handleChange}
                      required
                    />
                    <Input
                      label="Email Address"
                      name="email"
                      type="email"
                      placeholder="john@example.com"
                      value={formData.email}
                      onChange={handleChange}
                      required
                    />
                  </div>

                  <div className="grid md:grid-cols-2 gap-6 mb-6">
                    <Input
                      label="Phone Number"
                      name="phone"
                      type="tel"
                      placeholder="+91 98765 43210"
                      value={formData.phone}
                      onChange={handleChange}
                      required
                    />
                    <div>
                      <label className="block text-sm font-medium text-secondary-700 mb-2">
                        Category
                      </label>
                      <select
                        name="category"
                        value={formData.category}
                        onChange={handleChange}
                        className="w-full px-4 py-3 rounded-xl border border-secondary-200 bg-white text-secondary-900 focus:outline-none focus:ring-2 focus:ring-primary-500"
                      >
                        {categories.map((cat) => (
                          <option key={cat.value} value={cat.value}>
                            {cat.label}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>

                  <div className="mb-6">
                    <label className="block text-sm font-medium text-secondary-700 mb-2">
                      Message
                    </label>
                    <textarea
                      name="message"
                      rows={5}
                      placeholder="How can we help you?"
                      value={formData.message}
                      onChange={handleChange}
                      required
                      className="w-full px-4 py-3 rounded-xl border border-secondary-200 bg-white text-secondary-900 placeholder:text-secondary-400 focus:outline-none focus:ring-2 focus:ring-primary-500 resize-none"
                    />
                  </div>

                  <Button type="submit" variant="primary" size="lg" className="w-full gap-2">
                    Send Message
                    <Send className="w-5 h-5" />
                  </Button>
                </form>
              ) : (
                <div className="bg-green-50 rounded-2xl p-12 text-center">
                  <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6">
                    <Check className="w-8 h-8 text-green-600" />
                  </div>
                  <h2 className="text-2xl font-bold text-green-800 mb-2">Message Sent!</h2>
                  <p className="text-green-700 mb-6">
                    Thank you for reaching out. We'll get back to you within 24 hours.
                  </p>
                  <Button
                    variant="outline"
                    onClick={() => {
                      setSubmitted(false)
                      setFormData({ name: '', email: '', phone: '', category: 'inquiry', message: '' })
                    }}
                  >
                    Send Another Message
                  </Button>
                </div>
              )}
            </div>
          </div>
        </Container>
      </section>
    </>
  )
}
