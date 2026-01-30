import { Metadata } from 'next'
import { Container } from '@/components/ui'
import { SITE_CONFIG } from '@/lib/constants'

export const metadata: Metadata = {
  title: 'Terms & Conditions - Pilot',
  description: 'Terms and conditions for SendIt delivery pilots.',
}

export default function TermsPilotPage() {
  return (
    <section className="section-padding bg-white">
      <Container size="sm">
        <h1 className="text-3xl md:text-4xl font-bold text-secondary-900 mb-2">
          Terms & Conditions
        </h1>
        <p className="text-secondary-500 mb-8">For Pilots - Last updated: January 2026</p>

        <div className="prose prose-lg max-w-none prose-headings:text-secondary-900 prose-p:text-secondary-600">
          <h2>1. Introduction</h2>
          <p>
            These Terms and Conditions govern your relationship with {SITE_CONFIG.name} as an independent
            delivery partner ("Pilot"). By registering as a Pilot, you agree to these terms.
          </p>

          <h2>2. Pilot Obligations</h2>
          <ul>
            <li>Maintain valid vehicle documents and driving license</li>
            <li>Keep vehicle in good working condition</li>
            <li>Follow all traffic rules and regulations</li>
            <li>Deliver packages safely and on time</li>
            <li>Treat customers with respect and professionalism</li>
            <li>Not consume alcohol or drugs while on duty</li>
          </ul>

          <h2>3. Commission Structure</h2>
          <p>
            Pilots earn 80% of the delivery fare. Platform commission is 20%. Commission rates may vary
            by vehicle type and are clearly displayed in the Pilot app.
          </p>

          <h2>4. Payment Terms</h2>
          <ul>
            <li>Earnings are credited to your wallet after each delivery</li>
            <li>Withdrawals processed weekly (every Monday)</li>
            <li>Minimum withdrawal amount: ₹500</li>
            <li>Bank transfers take 1-2 business days</li>
          </ul>

          <h2>5. Incentives & Bonuses</h2>
          <p>
            Pilots may earn additional incentives based on performance, including:
          </p>
          <ul>
            <li>Peak hour bonuses</li>
            <li>Delivery milestones</li>
            <li>High rating rewards</li>
            <li>Referral bonuses</li>
          </ul>

          <h2>6. Insurance</h2>
          <p>
            Pilots are responsible for maintaining their own vehicle insurance.
            {SITE_CONFIG.name} provides additional accident coverage during active deliveries.
          </p>

          <h2>7. Cancellation Penalties</h2>
          <ul>
            <li>₹50 penalty for cancelling after acceptance (within 3 mins)</li>
            <li>₹100 penalty for cancelling after 3 minutes</li>
            <li>₹200 penalty for cancelling after pickup</li>
            <li>High cancellation rates may result in account suspension</li>
          </ul>

          <h2>8. Account Termination</h2>
          <p>
            {SITE_CONFIG.name} may suspend or terminate accounts for:
          </p>
          <ul>
            <li>Fraudulent activity</li>
            <li>Consistently low ratings (below 3.5)</li>
            <li>High cancellation rates (above 40%)</li>
            <li>Violation of terms and conditions</li>
            <li>Criminal activity</li>
          </ul>

          <h2>9. Independent Contractor</h2>
          <p>
            Pilots are independent contractors, not employees. You are responsible for your own
            taxes and insurance. {SITE_CONFIG.name} does not provide employment benefits.
          </p>

          <h2>10. Modifications</h2>
          <p>
            We may modify these terms with 7 days notice. Continued use of the platform
            constitutes acceptance of modified terms.
          </p>

          <h2>11. Contact</h2>
          <p>
            For Pilot support, contact us at {SITE_CONFIG.email} or call {SITE_CONFIG.phone}.
          </p>
        </div>
      </Container>
    </section>
  )
}
