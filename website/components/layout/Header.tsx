'use client'

import { useState } from 'react'
import Link from 'next/link'
import { Menu, X, ChevronDown } from 'lucide-react'
import { cn } from '@/lib/utils'
import { NAV_LINKS, SITE_CONFIG, APP_LINKS } from '@/lib/constants'
import { Button } from '@/components/ui'
import { Container } from '@/components/ui'

export function Header() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false)
  const [isAppDropdownOpen, setIsAppDropdownOpen] = useState(false)

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-white/80 backdrop-blur-lg border-b border-secondary-100">
      <Container>
        <nav className="flex items-center justify-between h-16 lg:h-20">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <div className="w-10 h-10 bg-primary-500 rounded-xl flex items-center justify-center">
              <span className="text-white font-bold text-xl">D</span>
            </div>
            <span className="text-2xl font-bold text-secondary-900">
              {SITE_CONFIG.name}
            </span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden lg:flex items-center gap-8">
            {NAV_LINKS.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="text-secondary-600 hover:text-primary-600 font-medium transition-colors"
              >
                {link.label}
              </Link>
            ))}
          </div>

          {/* Desktop CTA */}
          <div className="hidden lg:flex items-center gap-4">
            <div className="relative">
              <Button
                variant="primary"
                size="md"
                onClick={() => setIsAppDropdownOpen(!isAppDropdownOpen)}
                className="flex items-center gap-2"
              >
                Download App
                <ChevronDown className={cn(
                  'w-4 h-4 transition-transform',
                  isAppDropdownOpen && 'rotate-180'
                )} />
              </Button>

              {/* Dropdown */}
              {isAppDropdownOpen && (
                <div className="absolute top-full right-0 mt-2 w-48 bg-white rounded-xl shadow-xl border border-secondary-100 py-2 animate-slide-down">
                  <Link
                    href={APP_LINKS.userApp.android}
                    className="block px-4 py-2 text-secondary-700 hover:bg-secondary-50 hover:text-primary-600"
                  >
                    User App
                  </Link>
                  <Link
                    href={APP_LINKS.pilotApp.android}
                    className="block px-4 py-2 text-secondary-700 hover:bg-secondary-50 hover:text-primary-600"
                  >
                    Pilot App
                  </Link>
                </div>
              )}
            </div>
          </div>

          {/* Mobile Menu Button */}
          <button
            className="lg:hidden p-2 text-secondary-600"
            onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            aria-label="Toggle menu"
          >
            {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </nav>

        {/* Mobile Menu */}
        {isMobileMenuOpen && (
          <div className="lg:hidden py-4 border-t border-secondary-100 animate-slide-down">
            <div className="flex flex-col gap-4">
              {NAV_LINKS.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  className="text-secondary-600 hover:text-primary-600 font-medium py-2"
                  onClick={() => setIsMobileMenuOpen(false)}
                >
                  {link.label}
                </Link>
              ))}
              <div className="pt-4 flex flex-col gap-2">
                <Button variant="primary" size="md" className="w-full">
                  Download User App
                </Button>
                <Button variant="outline" size="md" className="w-full">
                  Download Pilot App
                </Button>
              </div>
            </div>
          </div>
        )}
      </Container>
    </header>
  )
}
