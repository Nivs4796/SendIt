import type { Metadata } from 'next'
import { Header, Footer } from '@/components/layout'
import { SITE_CONFIG } from '@/lib/constants'
import '@/styles/globals.css'

export const metadata: Metadata = {
  title: {
    default: `${SITE_CONFIG.name} - On-Demand Courier Delivery | ${SITE_CONFIG.location.split(',')[0]}`,
    template: `%s | ${SITE_CONFIG.name}`,
  },
  description: SITE_CONFIG.description,
  keywords: ['courier delivery', 'Ahmedabad delivery', 'goods delivery', 'parcel service', 'package delivery', 'same day delivery'],
  authors: [{ name: SITE_CONFIG.company }],
  openGraph: {
    type: 'website',
    locale: 'en_IN',
    url: SITE_CONFIG.url,
    siteName: SITE_CONFIG.name,
    title: `${SITE_CONFIG.name} - ${SITE_CONFIG.tagline}`,
    description: SITE_CONFIG.description,
  },
  twitter: {
    card: 'summary_large_image',
    title: `${SITE_CONFIG.name} - ${SITE_CONFIG.tagline}`,
    description: SITE_CONFIG.description,
  },
  robots: {
    index: true,
    follow: true,
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>
        <Header />
        <main className="pt-16 lg:pt-20">
          {children}
        </main>
        <Footer />
      </body>
    </html>
  )
}
