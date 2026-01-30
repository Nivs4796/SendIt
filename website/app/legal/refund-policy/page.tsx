import { Metadata } from 'next'
import { Container } from '@/components/ui'
import { SITE_CONFIG } from '@/lib/constants'

export const metadata: Metadata = {
  title: 'Refund & Cancellation Policy',
  description: 'SendIt refund and cancellation policy. Understand our policies for order cancellations and refunds.',
}

export default function RefundPolicyPage() {
  return (
    <section className="section-padding bg-white">
      <Container size="sm">
        <h1 className="text-3xl md:text-4xl font-bold text-secondary-900 mb-2">
          Refund & Cancellation Policy
        </h1>
        <p className="text-secondary-500 mb-8">Last updated: January 2026</p>

        <div className="prose prose-lg max-w-none prose-headings:text-secondary-900 prose-p:text-secondary-600">
          <h2>1. Cancellation by User</h2>
          <h3>Before Driver Assignment</h3>
          <p>
            You may cancel your order free of charge at any time before a driver
            is assigned. Full refund will be processed within 24 hours.
          </p>

          <h3>After Driver Assignment</h3>
          <table className="w-full border-collapse">
            <thead>
              <tr>
                <th className="border p-2 text-left">Timing</th>
                <th className="border p-2 text-left">Cancellation Fee</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td className="border p-2">Within 2 minutes of booking</td>
                <td className="border p-2">No charge</td>
              </tr>
              <tr>
                <td className="border p-2">2-5 minutes after driver assigned</td>
                <td className="border p-2">20% of fare</td>
              </tr>
              <tr>
                <td className="border p-2">More than 5 minutes after assignment</td>
                <td className="border p-2">50% of fare</td>
              </tr>
            </tbody>
          </table>

          <h3>After Package Pickup</h3>
          <p>
            Once the package has been picked up, cancellation is not permitted.
            The full fare will be charged.
          </p>

          <h2>2. Cancellation by Driver</h2>
          <p>
            If a driver cancels your order, you will receive a full refund and
            we will automatically search for another driver.
          </p>

          <h2>3. Cancellation by {SITE_CONFIG.name}</h2>
          <p>
            We may cancel orders due to:
          </p>
          <ul>
            <li>No available drivers in your area</li>
            <li>Prohibited items detected</li>
            <li>Safety concerns</li>
            <li>Technical issues</li>
          </ul>
          <p>
            In such cases, you will receive a full refund.
          </p>

          <h2>4. Refund Process</h2>
          <h3>Wallet Payments</h3>
          <p>
            Refunds for wallet payments are instant and credited back to your
            {SITE_CONFIG.name} wallet.
          </p>

          <h3>Card/UPI Payments</h3>
          <p>
            Refunds to cards or UPI accounts are processed within 5-7 business days,
            depending on your bank.
          </p>

          <h3>Cash Payments</h3>
          <p>
            For COD orders cancelled after pickup, refunds will be credited to
            your {SITE_CONFIG.name} wallet.
          </p>

          <h2>5. Damage or Loss Claims</h2>
          <p>
            If your package is damaged or lost during delivery:
          </p>
          <ul>
            <li>Report within 24 hours of delivery</li>
            <li>Provide photos of damaged package</li>
            <li>Claims are investigated within 48 hours</li>
            <li>Compensation up to declared value (max ₹5,000 without insurance)</li>
          </ul>

          <h2>6. How to Request a Refund</h2>
          <ol>
            <li>Go to "Orders" in the app</li>
            <li>Select the order you want to cancel</li>
            <li>Tap "Cancel Order" and select a reason</li>
            <li>Confirm cancellation</li>
          </ol>
          <p>
            Alternatively, contact our support team at {SITE_CONFIG.email}.
          </p>

          <h2>7. Exceptions</h2>
          <p>
            Refunds are not applicable for:
          </p>
          <ul>
            <li>Completed deliveries</li>
            <li>Damage due to improper packaging by user</li>
            <li>Prohibited items</li>
            <li>Delays due to incorrect address provided by user</li>
          </ul>

          <h2>8. Disputes</h2>
          <p>
            If you disagree with a refund decision, contact our support team
            within 7 days. We will review your case and respond within 48 hours.
          </p>

          <h2>9. Contact Us</h2>
          <p>
            For refund queries: {SITE_CONFIG.email}<br />
            Phone: {SITE_CONFIG.phone}<br />
            Available 24/7
          </p>
        </div>
      </Container>
    </section>
  )
}
