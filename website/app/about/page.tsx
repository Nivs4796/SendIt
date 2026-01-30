import { Metadata } from 'next'
import Image from 'next/image'
import { Container, SectionHeading } from '@/components/ui'
import { Target, Eye, Heart, Users, Award, Newspaper } from 'lucide-react'
import { SITE_CONFIG } from '@/lib/constants'

const teamMembers = [
  { name: 'Raj Patel', position: 'Founder & CEO', image: '/images/team/member-1.svg' },
  { name: 'Priya Sharma', position: 'Head of Operations', image: '/images/team/member-2.svg' },
  { name: 'Amit Kumar', position: 'CTO', image: '/images/team/member-3.svg' },
]

export const metadata: Metadata = {
  title: 'About Us',
  description: 'Learn about SendIt - Ahmedabad\'s fastest growing delivery platform. Our mission, values, and the team behind the service.',
}

const values = [
  {
    icon: Heart,
    title: 'Customer First',
    description: 'Every decision we make starts with how it impacts our customers.',
  },
  {
    icon: Target,
    title: 'Innovation',
    description: 'We constantly improve our technology to deliver better experiences.',
  },
  {
    icon: Users,
    title: 'Community',
    description: 'We build meaningful relationships with our pilots and partners.',
  },
  {
    icon: Award,
    title: 'Excellence',
    description: 'We strive for excellence in every delivery we make.',
  },
]

const milestones = [
  { year: '2024', title: 'Company Founded', description: 'Started with a vision to revolutionize local delivery' },
  { year: '2024', title: 'First 1000 Deliveries', description: 'Reached our first milestone within 3 months' },
  { year: '2025', title: '500+ Pilots', description: 'Built a strong network of delivery partners' },
  { year: '2026', title: '50K+ Deliveries', description: 'Trusted by thousands of customers in Ahmedabad' },
]

export default function AboutPage() {
  return (
    <>
      {/* Hero */}
      <section className="py-16 lg:py-24 bg-gradient-to-b from-primary-50 to-white">
        <Container>
          <div className="max-w-3xl mx-auto text-center">
            <span className="inline-block px-4 py-2 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mb-6">
              About {SITE_CONFIG.name}
            </span>
            <h1 className="text-4xl md:text-5xl font-bold text-secondary-900 mb-6">
              Delivering Happiness, One Package at a Time
            </h1>
            <p className="text-xl text-secondary-500">
              We're on a mission to make local delivery fast, reliable, and accessible for everyone in Ahmedabad.
            </p>
          </div>
        </Container>
      </section>

      {/* Mission & Vision */}
      <section className="section-padding bg-white">
        <Container>
          <div className="grid md:grid-cols-2 gap-12">
            <div className="bg-primary-50 rounded-3xl p-8 lg:p-12">
              <div className="w-14 h-14 bg-primary-100 rounded-xl flex items-center justify-center text-primary-600 mb-6">
                <Target className="w-7 h-7" />
              </div>
              <h2 className="text-2xl font-bold text-secondary-900 mb-4">Our Mission</h2>
              <p className="text-secondary-600 leading-relaxed">
                To empower local businesses and individuals with fast, reliable, and affordable delivery solutions while creating flexible earning opportunities for our delivery partners.
              </p>
            </div>
            <div className="bg-secondary-50 rounded-3xl p-8 lg:p-12">
              <div className="w-14 h-14 bg-secondary-100 rounded-xl flex items-center justify-center text-secondary-600 mb-6">
                <Eye className="w-7 h-7" />
              </div>
              <h2 className="text-2xl font-bold text-secondary-900 mb-4">Our Vision</h2>
              <p className="text-secondary-600 leading-relaxed">
                To become India's most trusted hyper-local delivery platform, known for speed, reliability, and the positive impact we create in communities we serve.
              </p>
            </div>
          </div>
        </Container>
      </section>

      {/* Values */}
      <section className="section-padding bg-secondary-50">
        <Container>
          <SectionHeading
            badge="Our Values"
            title="What We Stand For"
            subtitle="The principles that guide everything we do at SendIt."
          />

          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {values.map((value) => (
              <div key={value.title} className="bg-white rounded-2xl p-6 text-center">
                <div className="w-14 h-14 bg-primary-100 rounded-xl flex items-center justify-center text-primary-600 mx-auto mb-4">
                  <value.icon className="w-7 h-7" />
                </div>
                <h3 className="text-xl font-bold text-secondary-900 mb-2">{value.title}</h3>
                <p className="text-secondary-500">{value.description}</p>
              </div>
            ))}
          </div>
        </Container>
      </section>

      {/* Timeline */}
      <section className="section-padding bg-white">
        <Container size="sm">
          <SectionHeading
            badge="Our Journey"
            title="Milestones"
            subtitle="Key moments in our journey to transform local delivery."
          />

          <div className="relative">
            {/* Timeline line */}
            <div className="absolute left-4 md:left-1/2 top-0 bottom-0 w-0.5 bg-primary-200 transform md:-translate-x-1/2" />

            <div className="space-y-12">
              {milestones.map((milestone, index) => (
                <div
                  key={milestone.title}
                  className={`relative flex items-center gap-8 ${
                    index % 2 === 0 ? 'md:flex-row' : 'md:flex-row-reverse'
                  }`}
                >
                  {/* Dot */}
                  <div className="absolute left-4 md:left-1/2 w-4 h-4 bg-primary-500 rounded-full transform md:-translate-x-1/2 z-10" />

                  {/* Content */}
                  <div className={`ml-12 md:ml-0 md:w-1/2 ${index % 2 === 0 ? 'md:pr-12 md:text-right' : 'md:pl-12'}`}>
                    <span className="text-primary-600 font-semibold">{milestone.year}</span>
                    <h3 className="text-xl font-bold text-secondary-900 mt-1">{milestone.title}</h3>
                    <p className="text-secondary-500 mt-2">{milestone.description}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </Container>
      </section>

      {/* Team Placeholder */}
      <section className="section-padding bg-secondary-50">
        <Container>
          <SectionHeading
            badge="Our Team"
            title="Meet the People Behind SendIt"
            subtitle="A passionate team dedicated to transforming local delivery."
          />

          <div className="grid md:grid-cols-3 gap-8 max-w-4xl mx-auto">
            {teamMembers.map((member) => (
              <div key={member.name} className="bg-white rounded-2xl p-6 text-center">
                <div className="w-24 h-24 rounded-full mx-auto mb-4 overflow-hidden">
                  <Image
                    src={member.image}
                    alt={member.name}
                    width={96}
                    height={96}
                    className="w-full h-full object-cover"
                  />
                </div>
                <h3 className="text-lg font-bold text-secondary-900">{member.name}</h3>
                <p className="text-primary-600 text-sm">{member.position}</p>
              </div>
            ))}
          </div>
        </Container>
      </section>
    </>
  )
}
