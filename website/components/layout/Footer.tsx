import Link from 'next/link'
import { Facebook, Twitter, Instagram, Linkedin, Mail, Phone, MapPin } from 'lucide-react'
import { Container } from '@/components/ui'
import { SITE_CONFIG, SOCIAL_LINKS, NAV_LINKS } from '@/lib/constants'

const footerLinks = {
  company: [
    { label: 'About Us', href: '/about' },
    { label: 'Services', href: '/services' },
    { label: 'Pricing', href: '/pricing' },
    { label: 'Blog', href: '/blog' },
    { label: 'Contact', href: '/contact' },
  ],
  partners: [
    { label: 'Become a Pilot', href: '/become-pilot' },
    { label: 'Pilot Login', href: '#' },
    { label: 'Partner with Us', href: '/contact' },
  ],
  legal: [
    { label: 'Terms (User)', href: '/legal/terms-user' },
    { label: 'Terms (Pilot)', href: '/legal/terms-pilot' },
    { label: 'Privacy Policy', href: '/legal/privacy-user' },
    { label: 'Refund Policy', href: '/legal/refund-policy' },
  ],
}

export function Footer() {
  return (
    <footer className="bg-secondary-900 text-white">
      <Container>
        <div className="py-16">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-8 lg:gap-12">
            {/* Brand Column */}
            <div className="lg:col-span-2">
              <Link href="/" className="flex items-center gap-2 mb-4">
                <div className="w-10 h-10 bg-primary-500 rounded-xl flex items-center justify-center">
                  <span className="text-white font-bold text-xl">D</span>
                </div>
                <span className="text-2xl font-bold">{SITE_CONFIG.name}</span>
              </Link>
              <p className="text-secondary-400 mb-6 max-w-sm">
                {SITE_CONFIG.description}
              </p>

              {/* Contact Info */}
              <div className="space-y-3 mb-6">
                <a href={`mailto:${SITE_CONFIG.email}`} className="flex items-center gap-3 text-secondary-400 hover:text-primary-400 transition-colors">
                  <Mail className="w-5 h-5" />
                  {SITE_CONFIG.email}
                </a>
                <a href={`tel:${SITE_CONFIG.phone}`} className="flex items-center gap-3 text-secondary-400 hover:text-primary-400 transition-colors">
                  <Phone className="w-5 h-5" />
                  {SITE_CONFIG.phone}
                </a>
                <p className="flex items-center gap-3 text-secondary-400">
                  <MapPin className="w-5 h-5" />
                  {SITE_CONFIG.location}
                </p>
              </div>

              {/* Social Links */}
              <div className="flex gap-4">
                <a href={SOCIAL_LINKS.facebook} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-secondary-800 flex items-center justify-center hover:bg-primary-500 transition-colors">
                  <Facebook className="w-5 h-5" />
                </a>
                <a href={SOCIAL_LINKS.twitter} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-secondary-800 flex items-center justify-center hover:bg-primary-500 transition-colors">
                  <Twitter className="w-5 h-5" />
                </a>
                <a href={SOCIAL_LINKS.instagram} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-secondary-800 flex items-center justify-center hover:bg-primary-500 transition-colors">
                  <Instagram className="w-5 h-5" />
                </a>
                <a href={SOCIAL_LINKS.linkedin} target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-secondary-800 flex items-center justify-center hover:bg-primary-500 transition-colors">
                  <Linkedin className="w-5 h-5" />
                </a>
              </div>
            </div>

            {/* Quick Links */}
            <div>
              <h3 className="font-semibold text-lg mb-4">Quick Links</h3>
              <ul className="space-y-3">
                {footerLinks.company.map((link) => (
                  <li key={link.href}>
                    <Link href={link.href} className="text-secondary-400 hover:text-primary-400 transition-colors">
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>

            {/* For Partners */}
            <div>
              <h3 className="font-semibold text-lg mb-4">For Partners</h3>
              <ul className="space-y-3">
                {footerLinks.partners.map((link) => (
                  <li key={link.href}>
                    <Link href={link.href} className="text-secondary-400 hover:text-primary-400 transition-colors">
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>

            {/* Legal */}
            <div>
              <h3 className="font-semibold text-lg mb-4">Legal</h3>
              <ul className="space-y-3">
                {footerLinks.legal.map((link) => (
                  <li key={link.href}>
                    <Link href={link.href} className="text-secondary-400 hover:text-primary-400 transition-colors">
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="border-t border-secondary-800 py-6">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4">
            <p className="text-secondary-400 text-sm">
              © {new Date().getFullYear()} {SITE_CONFIG.company}. All rights reserved.
            </p>
            <p className="text-secondary-400 text-sm">
              Made with ❤️ in India
            </p>
          </div>
        </div>
      </Container>
    </footer>
  )
}
