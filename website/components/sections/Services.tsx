'use client'

import { motion } from 'framer-motion'
import Link from 'next/link'
import { Package, Users, Calendar, Leaf, ArrowRight } from 'lucide-react'
import { Container, SectionHeading, Card, CardContent } from '@/components/ui'
import { SERVICES } from '@/lib/constants'

const iconMap: Record<string, React.ReactNode> = {
  package: <Package className="w-8 h-8" />,
  users: <Users className="w-8 h-8" />,
  calendar: <Calendar className="w-8 h-8" />,
  leaf: <Leaf className="w-8 h-8" />,
}

export function Services() {
  return (
    <section className="section-padding bg-secondary-50">
      <Container>
        <SectionHeading
          badge="Our Services"
          title="What We Deliver"
          subtitle="From small documents to heavy goods, we have the right vehicle for every delivery need."
        />

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {SERVICES.map((service, index) => (
            <motion.div
              key={service.title}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              viewport={{ once: true }}
            >
              <Link href={service.href}>
                <Card className="h-full group cursor-pointer">
                  <CardContent>
                    <div className="w-14 h-14 bg-primary-100 rounded-xl flex items-center justify-center text-primary-600 mb-4 group-hover:bg-primary-500 group-hover:text-white transition-colors">
                      {iconMap[service.icon]}
                    </div>
                    <h3 className="text-xl font-bold text-secondary-900 mb-2 group-hover:text-primary-600 transition-colors">
                      {service.title}
                    </h3>
                    <p className="text-secondary-500 mb-4">
                      {service.description}
                    </p>
                    <span className="inline-flex items-center text-primary-600 font-medium gap-2 group-hover:gap-3 transition-all">
                      Learn More
                      <ArrowRight className="w-4 h-4" />
                    </span>
                  </CardContent>
                </Card>
              </Link>
            </motion.div>
          ))}
        </div>
      </Container>
    </section>
  )
}
