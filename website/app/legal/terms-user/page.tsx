import { Metadata } from 'next'
import { Container } from '@/components/ui'
import { SITE_CONFIG } from '@/lib/constants'

export const metadata: Metadata = {
  title: 'Terms & Conditions - User',
  description: 'Terms and conditions for using SendIt delivery services.',
}

export default function TermsUserPage() {
  return (
    <section className="section-padding bg-white">
      <Container size="sm">
        <h1 className="text-3xl md:text-4xl font-bold text-secondary-900 mb-2">
          Terms & Conditions
        </h1>
        <p className="text-secondary-500 mb-8">For Users - Last updated: January 2026</p>

        <div className="prose prose-lg max-w-none prose-headings:text-secondary-900 prose-p:text-secondary-600">
          <h2>1. Introduction</h2>
          <p>
            Welcome to {SITE_CONFIG.name}. These Terms and Conditions govern your use of our platform and services.
            By using our app or website, you agree to be bound by these terms.
          </p>

          <h2>2. Service Description</h2>
          <p>
            {SITE_CONFIG.name} provides an on-demand delivery platform connecting users with delivery partners ("Pilots")
            for the transportation of goods and packages within the city.
          </p>

          <h2>3. User Obligations</h2>
          <ul>
            <li>Provide accurate information when booking deliveries</li>
            <li>Ensure packages comply with our prohibited items policy</li>
            <li>Be available at pickup/drop locations during scheduled times</li>
            <li>Pay for services as agreed at the time of booking</li>
            <li>Treat Pilots with respect and courtesy</li>
          </ul>

          <h2>4. Prohibited Items</h2>
          <p>The following items cannot be sent via {SITE_CONFIG.name}:</p>
          <ul>
            <li>Illegal substances or contraband</li>
            <li>Weapons or explosives</li>
            <li>Hazardous materials</li>
            <li>Perishable goods (unless using appropriate packaging)</li>
            <li>Cash or high-value jewelry</li>
            <li>Live animals</li>
          </ul>

          <h2>5. Pricing & Payment</h2>
          <p>
            All prices are displayed upfront before booking. Prices include applicable taxes.
            Payment can be made via wallet, card, UPI, or cash on delivery.
          </p>

          <h2>6. Cancellation Policy</h2>
          <ul>
            <li>Free cancellation within 2 minutes of booking</li>
            <li>20% charge if cancelled after driver assignment (within 3 minutes)</li>
            <li>50% charge if cancelled more than 3 minutes after driver assignment</li>
            <li>No refund if package has been picked up</li>
          </ul>

          <h2>7. Liability</h2>
          <p>
            {SITE_CONFIG.name} acts as an intermediary platform. We are not liable for:
          </p>
          <ul>
            <li>Damage to improperly packaged items</li>
            <li>Delays due to traffic or weather conditions</li>
            <li>Loss of prohibited items</li>
          </ul>

          <h2>8. Dispute Resolution</h2>
          <p>
            Any disputes shall be resolved through our customer support team first.
            Unresolved disputes will be subject to arbitration in Ahmedabad, Gujarat.
          </p>

          <h2>9. Modifications</h2>
          <p>
            We reserve the right to modify these terms at any time. Continued use of the service
            after modifications constitutes acceptance of the new terms.
          </p>

          <h2>10. Contact</h2>
          <p>
            For questions about these terms, contact us at {SITE_CONFIG.email} or call {SITE_CONFIG.phone}.
          </p>
        </div>
      </Container>
    </section>
  )
}
