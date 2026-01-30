import { Metadata } from 'next'
import { Container } from '@/components/ui'
import { SITE_CONFIG } from '@/lib/constants'

export const metadata: Metadata = {
  title: 'Privacy Policy - User',
  description: 'Privacy policy for SendIt users. Learn how we collect, use, and protect your data.',
}

export default function PrivacyUserPage() {
  return (
    <section className="section-padding bg-white">
      <Container size="sm">
        <h1 className="text-3xl md:text-4xl font-bold text-secondary-900 mb-2">
          Privacy Policy
        </h1>
        <p className="text-secondary-500 mb-8">For Users - Last updated: January 2026</p>

        <div className="prose prose-lg max-w-none prose-headings:text-secondary-900 prose-p:text-secondary-600">
          <h2>1. Introduction</h2>
          <p>
            {SITE_CONFIG.name} ("we", "our", "us") is committed to protecting your privacy.
            This Privacy Policy explains how we collect, use, and safeguard your information.
          </p>

          <h2>2. Information We Collect</h2>
          <h3>Personal Information</h3>
          <ul>
            <li>Name, phone number, email address</li>
            <li>Delivery addresses</li>
            <li>Payment information</li>
            <li>Profile photo (optional)</li>
          </ul>

          <h3>Usage Information</h3>
          <ul>
            <li>Device information (model, OS version)</li>
            <li>Location data (when using the app)</li>
            <li>Order history and preferences</li>
            <li>App usage patterns</li>
          </ul>

          <h2>3. How We Use Your Information</h2>
          <ul>
            <li>Process and fulfill delivery orders</li>
            <li>Communicate order updates and support</li>
            <li>Improve our services and user experience</li>
            <li>Send promotional offers (with consent)</li>
            <li>Prevent fraud and ensure security</li>
            <li>Comply with legal obligations</li>
          </ul>

          <h2>4. Information Sharing</h2>
          <p>We share your information with:</p>
          <ul>
            <li>Delivery Pilots (name, phone, addresses for deliveries)</li>
            <li>Payment processors (to process transactions)</li>
            <li>Analytics providers (anonymized data)</li>
            <li>Law enforcement (when legally required)</li>
          </ul>

          <h2>5. Data Security</h2>
          <p>
            We implement industry-standard security measures including:
          </p>
          <ul>
            <li>Encryption of data in transit and at rest</li>
            <li>Secure payment processing</li>
            <li>Regular security audits</li>
            <li>Access controls and authentication</li>
          </ul>

          <h2>6. Your Rights</h2>
          <p>You have the right to:</p>
          <ul>
            <li>Access your personal data</li>
            <li>Correct inaccurate information</li>
            <li>Delete your account and data</li>
            <li>Opt-out of marketing communications</li>
            <li>Data portability</li>
          </ul>

          <h2>7. Cookies & Tracking</h2>
          <p>
            We use cookies and similar technologies to enhance your experience,
            analyze usage, and deliver personalized content. You can manage
            cookie preferences in your browser settings.
          </p>

          <h2>8. Data Retention</h2>
          <p>
            We retain your data for as long as your account is active or as needed
            to provide services. Transaction data is retained for 7 years for
            legal compliance.
          </p>

          <h2>9. Children's Privacy</h2>
          <p>
            Our services are not intended for users under 16. We do not knowingly
            collect information from children under 16.
          </p>

          <h2>10. Updates to This Policy</h2>
          <p>
            We may update this policy periodically. We will notify you of significant
            changes via email or app notification.
          </p>

          <h2>11. Contact Us</h2>
          <p>
            For privacy-related queries, contact our Data Protection Officer at {SITE_CONFIG.email}.
          </p>
        </div>
      </Container>
    </section>
  )
}
