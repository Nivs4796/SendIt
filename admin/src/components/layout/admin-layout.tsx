'use client'

import { useEffect, useState } from 'react'
import { useRouter, usePathname } from 'next/navigation'
import Link from 'next/link'
import { useAuthStore } from '@/store/auth'
import { useSocket } from '@/lib/socket'
import { ThemeToggle } from '@/components/theme-toggle'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import {
  LayoutDashboard,
  Users,
  UserCog,
  CalendarCheck,
  Car,
  Wallet,
  BarChart3,
  Settings,
  Send,
  LogOut,
  Menu,
  X,
  Wifi,
  WifiOff,
} from 'lucide-react'
import { cn } from '@/lib/utils'

interface AdminLayoutProps {
  children: React.ReactNode
}

const navItems = [
  { href: '/', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/users', label: 'Users', icon: Users },
  { href: '/pilots', label: 'Pilots', icon: UserCog },
  { href: '/bookings', label: 'Bookings', icon: CalendarCheck },
  { href: '/vehicles', label: 'Vehicles', icon: Car },
  { href: '/wallet', label: 'Wallet', icon: Wallet },
  { href: '/analytics', label: 'Analytics', icon: BarChart3 },
  { href: '/settings', label: 'Settings', icon: Settings },
]

export function AdminLayout({ children }: AdminLayoutProps) {
  const router = useRouter()
  const pathname = usePathname()
  const { isAuthenticated, isLoading, setLoading, logout } = useAuthStore()
  const { isConnected } = useSocket()
  const [sidebarExpanded, setSidebarExpanded] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  useEffect(() => {
    setLoading(false)
  }, [setLoading])

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push('/login')
    }
  }, [isAuthenticated, isLoading, router])

  const closeMobileMenu = () => {
    setMobileMenuOpen(false)
  }

  const handleLogout = () => {
    logout()
    router.push('/login')
  }

  const getCurrentPageName = () => {
    const currentItem = navItems.find(
      (item) => item.href === pathname || (pathname !== '/' && pathname.startsWith(item.href) && item.href !== '/')
    )
    return currentItem?.label || 'Dashboard'
  }

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    )
  }

  if (!isAuthenticated) {
    return null
  }

  return (
    <TooltipProvider delayDuration={0}>
      <div className="flex min-h-screen">
        {/* Mobile Overlay */}
        {mobileMenuOpen && (
          <div
            className="fixed inset-0 bg-black/50 z-40 lg:hidden"
            onClick={() => setMobileMenuOpen(false)}
          />
        )}

        {/* Sidebar */}
        <aside
          className={cn(
            'fixed top-0 left-0 h-full z-50 glass-sidebar flex flex-col transition-all duration-300 ease-in-out',
            // Desktop: collapsed by default, expands on hover
            'hidden lg:flex',
            sidebarExpanded ? 'w-60' : 'w-16'
          )}
          onMouseEnter={() => setSidebarExpanded(true)}
          onMouseLeave={() => setSidebarExpanded(false)}
        >
          {/* Logo */}
          <div className="h-16 flex items-center px-3 border-b border-[var(--glass-sidebar-border)]">
            <div className="flex items-center gap-3 overflow-hidden">
              <div className="flex-shrink-0 w-10 h-10 rounded-xl bg-emerald-500 flex items-center justify-center shadow-lg">
                <Send className="h-5 w-5 text-white" />
              </div>
              <span
                className={cn(
                  'font-bold text-xl text-gradient whitespace-nowrap transition-opacity duration-300',
                  sidebarExpanded ? 'opacity-100' : 'opacity-0'
                )}
              >
                SendIt
              </span>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 py-4 px-2 space-y-1 overflow-y-auto">
            {navItems.map((item) => {
              const isActive = pathname === item.href || (pathname !== '/' && pathname.startsWith(item.href) && item.href !== '/')
              const Icon = item.icon

              return (
                <Tooltip key={item.href}>
                  <TooltipTrigger asChild>
                    <Link
                      href={item.href}
                      className={cn(
                        'flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200 group',
                        isActive
                          ? 'bg-emerald-500 text-white shadow-lg'
                          : 'text-muted-foreground hover:text-foreground hover:bg-[var(--sidebar-accent)]'
                      )}
                    >
                      <Icon
                        className={cn(
                          'h-5 w-5 flex-shrink-0 transition-transform duration-200',
                          !isActive && 'group-hover:scale-110 group-hover:text-emerald-500'
                        )}
                      />
                      <span
                        className={cn(
                          'whitespace-nowrap transition-opacity duration-300',
                          sidebarExpanded ? 'opacity-100' : 'opacity-0 w-0'
                        )}
                      >
                        {item.label}
                      </span>
                    </Link>
                  </TooltipTrigger>
                  {!sidebarExpanded && (
                    <TooltipContent side="right" sideOffset={10}>
                      {item.label}
                    </TooltipContent>
                  )}
                </Tooltip>
              )
            })}
          </nav>

          {/* Bottom Section */}
          <div className="p-2 border-t border-[var(--glass-sidebar-border)] space-y-1">
            <Tooltip>
              <TooltipTrigger asChild>
                <div
                  className={cn(
                    'flex items-center gap-3 px-3 py-2.5 rounded-xl',
                    sidebarExpanded ? 'justify-start' : 'justify-center'
                  )}
                >
                  <ThemeToggle variant={sidebarExpanded ? 'full' : 'icon'} />
                </div>
              </TooltipTrigger>
              {!sidebarExpanded && (
                <TooltipContent side="right" sideOffset={10}>
                  Toggle Theme
                </TooltipContent>
              )}
            </Tooltip>

            <Tooltip>
              <TooltipTrigger asChild>
                <button
                  onClick={handleLogout}
                  className={cn(
                    'flex items-center gap-3 px-3 py-2.5 rounded-xl w-full transition-all duration-200 group',
                    'text-muted-foreground hover:text-red-500 hover:bg-red-500/10'
                  )}
                >
                  <LogOut className="h-5 w-5 flex-shrink-0 transition-transform duration-200 group-hover:scale-110" />
                  <span
                    className={cn(
                      'whitespace-nowrap transition-opacity duration-300',
                      sidebarExpanded ? 'opacity-100' : 'opacity-0 w-0'
                    )}
                  >
                    Logout
                  </span>
                </button>
              </TooltipTrigger>
              {!sidebarExpanded && (
                <TooltipContent side="right" sideOffset={10}>
                  Logout
                </TooltipContent>
              )}
            </Tooltip>
          </div>
        </aside>

        {/* Mobile Sidebar */}
        <aside
          className={cn(
            'fixed top-0 left-0 h-full z-50 w-64 glass-sidebar flex flex-col transition-transform duration-300 ease-in-out lg:hidden',
            mobileMenuOpen ? 'translate-x-0' : '-translate-x-full'
          )}
        >
          {/* Mobile Logo */}
          <div className="h-16 flex items-center justify-between px-4 border-b border-[var(--glass-sidebar-border)]">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-emerald-500 flex items-center justify-center shadow-lg">
                <Send className="h-5 w-5 text-white" />
              </div>
              <span className="font-bold text-xl text-gradient">SendIt</span>
            </div>
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setMobileMenuOpen(false)}
            >
              <X className="h-5 w-5" />
            </Button>
          </div>

          {/* Mobile Navigation */}
          <nav className="flex-1 py-4 px-3 space-y-1 overflow-y-auto">
            {navItems.map((item) => {
              const isActive = pathname === item.href || (pathname !== '/' && pathname.startsWith(item.href) && item.href !== '/')
              const Icon = item.icon

              return (
                <Link
                  key={item.href}
                  href={item.href}
                  onClick={closeMobileMenu}
                  className={cn(
                    'flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all duration-200',
                    isActive
                      ? 'bg-emerald-500 text-white shadow-lg'
                      : 'text-muted-foreground hover:text-foreground hover:bg-[var(--sidebar-accent)]'
                  )}
                >
                  <Icon className="h-5 w-5" />
                  <span>{item.label}</span>
                </Link>
              )
            })}
          </nav>

          {/* Mobile Bottom Section */}
          <div className="p-3 border-t border-[var(--glass-sidebar-border)] space-y-1">
            <div className="flex items-center gap-3 px-3 py-2.5">
              <ThemeToggle variant="full" />
            </div>
            <button
              onClick={handleLogout}
              className="flex items-center gap-3 px-3 py-2.5 rounded-xl w-full text-muted-foreground hover:text-red-500 hover:bg-red-500/10 transition-all duration-200"
            >
              <LogOut className="h-5 w-5" />
              <span>Logout</span>
            </button>
          </div>
        </aside>

        {/* Main Content */}
        <div className="flex-1 flex flex-col lg:ml-16">
          {/* Desktop Header */}
          <header className="hidden lg:flex h-16 items-center gap-4 px-6 glass-sidebar sticky top-0 z-40 border-b-0 border-r-0">
            <h1 className="text-xl font-semibold">{getCurrentPageName()}</h1>
            <div className="flex-1" />
            <Badge
              variant={isConnected ? 'default' : 'secondary'}
              className={cn(
                'gap-1.5',
                isConnected && 'bg-emerald-500 hover:bg-emerald-600'
              )}
            >
              {isConnected ? (
                <>
                  <Wifi className="h-3 w-3" />
                  Live
                </>
              ) : (
                <>
                  <WifiOff className="h-3 w-3" />
                  Offline
                </>
              )}
            </Badge>
            <ThemeToggle />
          </header>

          {/* Mobile Header */}
          <header className="flex lg:hidden h-16 items-center gap-4 px-4 glass-sidebar sticky top-0 z-30 border-b-0 border-r-0">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setMobileMenuOpen(true)}
            >
              <Menu className="h-5 w-5" />
            </Button>
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-emerald-500 flex items-center justify-center">
                <Send className="h-4 w-4 text-white" />
              </div>
              <span className="font-semibold text-gradient">SendIt</span>
            </div>
            <div className="flex-1" />
            <Badge
              variant={isConnected ? 'default' : 'secondary'}
              className={cn(
                'gap-1',
                isConnected && 'bg-emerald-500 hover:bg-emerald-600'
              )}
            >
              {isConnected ? (
                <Wifi className="h-3 w-3" />
              ) : (
                <WifiOff className="h-3 w-3" />
              )}
            </Badge>
          </header>

          {/* Page Content */}
          <main className="flex-1 p-6">{children}</main>
        </div>
      </div>
    </TooltipProvider>
  )
}
