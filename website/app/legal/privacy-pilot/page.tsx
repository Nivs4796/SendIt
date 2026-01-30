import { Metadata } from 'next'
import { Container } from '@/components/ui'
import { SITE_CONFIG } from '@/lib/constants'

export const metadata: Metadata = {
  title: 'Privacy Policy - Pilot',
  description: 'Privacy policy for SendIt delivery pilots. Learn how we handle pilot data.',
}

export default function PrivacyPilotPage() {
  return (
    <section className="section-padding bg-white">
      <Container size="sm">
        <h1 className="text-3xl md:text-4xl font-bold text-secondary-900 mb-2">
          Privacy Policy
        </h1>
        <p className="text-secondary-500 mb-8">For Pilots - Last updated: January 2026</p>

        <div className="prose prose-lg max-w-none prose-headings:text-secondary-900 prose-p:text-secondary-600">
          <h2>1. Introduction</h2>
          <p>
            This Privacy Policy explains how {SITE_CONFIG.name} collects, uses, and protects
            information from our delivery partners ("Pilots").
          </p>

          <h2>2. Information We Collect</h2>
          <h3>Personal Information</h3>
          <ul>
            <li>Full name, date of birth, phone number, email</li>
            <li>Address and proof of residence</li>
            <li>Government ID (Aadhaar, PAN, etc.)</li>
            <li>Driving license</li>
            <li>Bank account details</li>
            <li>Profile photo</li>
          </ul>

          <h3>Vehicle Information</h3>
          <ul>
            <li>Vehicle registration certificate</li>
            <li>Insurance documents</li>
            <li>Pollution certificate</li>
            <li>Vehicle photos</li>
          </ul>

          <h3>Operational Data</h3>
          <ul>
            <li>Real-time location during active deliveries</li>
            <li>Delivery history and performance metrics</li>
            <li>Earnings and transaction records</li>
            <li>Ratings and reviews</li>
          </ul>

          <h2>3. How We Use Your Information</h2>
          <ul>
            <li>Verify your identity and eligibility</li>
            <li>Match you with delivery requests</li>
            <li>Process payments and track earnings</li>
            <li>Provide navigation and delivery support</li>
            <li>Improve safety and service quality</li>
            <li>Comply with regulatory requirements</li>
          </ul>

          <h2>4. Location Tracking</h2>
          <p>
            We track your location when you are online and during active deliveries.
            This is essential for:
          </p>
          <ul>
            <li>Matching you with nearby orders</li>
            <li>Providing real-time tracking to customers</li>
            <li>Navigation assistance</li>
            <li>Safety and incident response</li>
          </ul>

          <h2>5. Information Sharing</h2>
          <p>We share your information with:</p>
          <ul>
            <li>Customers (name, phone, vehicle details during deliveries)</li>
            <li>Payment processors (for earnings transfers)</li>
            <li>Background verification agencies</li>
            <li>Insurance providers</li>
            <li>Regulatory authorities (when required)</li>
          </ul>

          <h2>6. Data Security</h2>
          <p>
            Your documents and personal information are stored securely with
            encryption and access controls. We conduct regular security audits.
          </p>

          <h2>7. Your Rights</h2>
          <p>You have the right to:</p>
          <ul>
            <li>Access your personal data</li>
            <li>Update incorrect information</li>
            <li>Request data deletion (subject to legal requirements)</li>
            <li>Opt-out of promotional communications</li>
          </ul>

          <h2>8. Data Retention</h2>
          <p>
            We retain your data for the duration of your partnership and for 7 years
            after termination for legal and tax compliance.
          </p>

          <h2>9. Updates to This Policy</h2>
          <p>
            Changes to this policy will be communicated via the Pilot app.
            Continued use constitutes acceptance of updated terms.
          </p>

          <h2>10. Contact</h2>
          <p>
            For privacy queries, contact us at {SITE_CONFIG.email}.
          </p>
        </div>
      </Container>
    </section>
  )
}
