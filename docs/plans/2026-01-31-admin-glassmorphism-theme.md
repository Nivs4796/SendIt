# Admin Panel Glassmorphism Theme Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform the admin panel UI with a glassmorphism theme featuring collapsible icon sidebar, frosted glass cards, and dark/light mode toggle using the SendIt emerald green brand colors.

**Architecture:** CSS-first approach using CSS custom properties for theming. Theme provider with React context for dark/light mode state with localStorage persistence. Collapsible sidebar using CSS transitions and React state. All glass effects via backdrop-filter and semi-transparent backgrounds.

**Tech Stack:** Next.js 16, React 19, Tailwind CSS 4, shadcn/ui components, next-themes for dark mode, Lucide icons

---

## Task 1: Install next-themes Package

**Files:**
- Modify: `admin/package.json`

**Step 1: Install next-themes**

Run:
```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt/admin && npm install next-themes
```

**Step 2: Verify installation**

Run:
```bash
cat admin/package.json | grep next-themes
```
Expected: `"next-themes": "^0.x.x"`

**Step 3: Commit**

```bash
git add admin/package.json admin/package-lock.json
git commit -m "chore(admin): Add next-themes for dark/light mode support"
```

---

## Task 2: Create Theme Provider Component

**Files:**
- Create: `admin/src/components/theme-provider.tsx`

**Step 1: Create theme provider**

```tsx
'use client'

import * as React from 'react'
import { ThemeProvider as NextThemesProvider } from 'next-themes'

export function ThemeProvider({
  children,
  ...props
}: React.ComponentProps<typeof NextThemesProvider>) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
```

**Step 2: Verify file created**

Run:
```bash
cat admin/src/components/theme-provider.tsx
```

**Step 3: Commit**

```bash
git add admin/src/components/theme-provider.tsx
git commit -m "feat(admin): Add ThemeProvider component for dark/light mode"
```

---

## Task 3: Create Theme Toggle Component

**Files:**
- Create: `admin/src/components/theme-toggle.tsx`

**Step 1: Create theme toggle component**

```tsx
'use client'

import * as React from 'react'
import { Moon, Sun } from 'lucide-react'
import { useTheme } from 'next-themes'
import { Button } from '@/components/ui/button'

interface ThemeToggleProps {
  variant?: 'icon' | 'full'
  className?: string
}

export function ThemeToggle({ variant = 'icon', className }: ThemeToggleProps) {
  const { theme, setTheme } = useTheme()
  const [mounted, setMounted] = React.useState(false)

  React.useEffect(() => {
    setMounted(true)
  }, [])

  if (!mounted) {
    return (
      <Button variant="ghost" size={variant === 'icon' ? 'icon' : 'sm'} className={className}>
        <Sun className="h-4 w-4" />
      </Button>
    )
  }

  const toggleTheme = () => {
    setTheme(theme === 'dark' ? 'light' : 'dark')
  }

  if (variant === 'full') {
    return (
      <Button
        variant="ghost"
        size="sm"
        onClick={toggleTheme}
        className={className}
      >
        {theme === 'dark' ? (
          <>
            <Sun className="h-4 w-4 mr-2" />
            <span>Light Mode</span>
          </>
        ) : (
          <>
            <Moon className="h-4 w-4 mr-2" />
            <span>Dark Mode</span>
          </>
        )}
      </Button>
    )
  }

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={toggleTheme}
      className={className}
    >
      {theme === 'dark' ? (
        <Sun className="h-4 w-4" />
      ) : (
        <Moon className="h-4 w-4" />
      )}
      <span className="sr-only">Toggle theme</span>
    </Button>
  )
}
```

**Step 2: Verify file created**

Run:
```bash
cat admin/src/components/theme-toggle.tsx
```

**Step 3: Commit**

```bash
git add admin/src/components/theme-toggle.tsx
git commit -m "feat(admin): Add ThemeToggle component with icon and full variants"
```

---

## Task 4: Update Root Layout with Theme Provider

**Files:**
- Modify: `admin/src/app/layout.tsx`

**Step 1: Read current layout**

Run:
```bash
cat admin/src/app/layout.tsx
```

**Step 2: Update layout.tsx to wrap with ThemeProvider**

Add imports and wrap children:

```tsx
import { ThemeProvider } from '@/components/theme-provider'
```

Wrap the body content:
```tsx
<ThemeProvider
  attribute="class"
  defaultTheme="system"
  enableSystem
  disableTransitionOnChange
>
  {children}
</ThemeProvider>
```

**Step 3: Verify changes**

Run:
```bash
cat admin/src/app/layout.tsx | grep -A5 "ThemeProvider"
```

**Step 4: Commit**

```bash
git add admin/src/app/layout.tsx
git commit -m "feat(admin): Integrate ThemeProvider in root layout"
```

---

## Task 5: Update globals.css with Glassmorphism Theme

**Files:**
- Modify: `admin/src/app/globals.css`

**Step 1: Replace globals.css with glassmorphism theme**

```css
@import "tailwindcss";
@import "tw-animate-css";

@custom-variant dark (&:is(.dark *));

@theme inline {
  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --font-sans: var(--font-geist-sans);
  --font-mono: var(--font-geist-mono);
  --color-sidebar-ring: var(--sidebar-ring);
  --color-sidebar-border: var(--sidebar-border);
  --color-sidebar-accent-foreground: var(--sidebar-accent-foreground);
  --color-sidebar-accent: var(--sidebar-accent);
  --color-sidebar-primary-foreground: var(--sidebar-primary-foreground);
  --color-sidebar-primary: var(--sidebar-primary);
  --color-sidebar-foreground: var(--sidebar-foreground);
  --color-sidebar: var(--sidebar);
  --color-chart-5: var(--chart-5);
  --color-chart-4: var(--chart-4);
  --color-chart-3: var(--chart-3);
  --color-chart-2: var(--chart-2);
  --color-chart-1: var(--chart-1);
  --color-ring: var(--ring);
  --color-input: var(--input);
  --color-border: var(--border);
  --color-destructive: var(--destructive);
  --color-accent-foreground: var(--accent-foreground);
  --color-accent: var(--accent);
  --color-muted-foreground: var(--muted-foreground);
  --color-muted: var(--muted);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-secondary: var(--secondary);
  --color-primary-foreground: var(--primary-foreground);
  --color-primary: var(--primary);
  --color-popover-foreground: var(--popover-foreground);
  --color-popover: var(--popover);
  --color-card-foreground: var(--card-foreground);
  --color-card: var(--card);
  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
  --radius-2xl: calc(var(--radius) + 8px);
  --radius-3xl: calc(var(--radius) + 12px);
  --radius-4xl: calc(var(--radius) + 16px);
}

/* ============================================
   LIGHT MODE - Glassmorphism with Emerald
   ============================================ */
:root {
  --radius: 1rem;

  /* Base Colors */
  --background: linear-gradient(135deg, #ffffff 0%, #ecfdf5 50%, #f0fdf4 100%);
  --background-solid: #f8fdfb;
  --foreground: #1f2937;

  /* Glass Card */
  --card: rgba(255, 255, 255, 0.7);
  --card-foreground: #1f2937;
  --card-border: rgba(16, 185, 129, 0.2);

  /* Popover */
  --popover: rgba(255, 255, 255, 0.85);
  --popover-foreground: #1f2937;

  /* Primary - Emerald */
  --primary: #10b981;
  --primary-foreground: #ffffff;
  --primary-hover: #059669;
  --primary-glow: rgba(16, 185, 129, 0.4);

  /* Secondary */
  --secondary: rgba(243, 244, 246, 0.8);
  --secondary-foreground: #374151;

  /* Muted */
  --muted: rgba(243, 244, 246, 0.6);
  --muted-foreground: #6b7280;

  /* Accent - Amber */
  --accent: #f59e0b;
  --accent-foreground: #ffffff;

  /* Destructive */
  --destructive: #ef4444;
  --destructive-foreground: #ffffff;

  /* Borders & Inputs */
  --border: rgba(16, 185, 129, 0.15);
  --input: rgba(255, 255, 255, 0.8);
  --input-border: rgba(16, 185, 129, 0.2);
  --ring: rgba(16, 185, 129, 0.5);

  /* Charts - Emerald Palette */
  --chart-1: #10b981;
  --chart-2: #059669;
  --chart-3: #f59e0b;
  --chart-4: #6ee7b7;
  --chart-5: #34d399;

  /* Sidebar */
  --sidebar: rgba(255, 255, 255, 0.8);
  --sidebar-foreground: #374151;
  --sidebar-primary: #10b981;
  --sidebar-primary-foreground: #ffffff;
  --sidebar-accent: rgba(16, 185, 129, 0.1);
  --sidebar-accent-foreground: #10b981;
  --sidebar-border: rgba(16, 185, 129, 0.1);
  --sidebar-ring: rgba(16, 185, 129, 0.3);

  /* Glass Effect Variables */
  --glass-blur: 16px;
  --glass-card-bg: rgba(255, 255, 255, 0.7);
  --glass-sidebar-bg: rgba(255, 255, 255, 0.8);
  --glass-modal-bg: rgba(255, 255, 255, 0.85);
  --glass-border: rgba(255, 255, 255, 0.3);
  --glass-shadow: 0 8px 32px rgba(16, 185, 129, 0.1);
}

/* ============================================
   DARK MODE - Glassmorphism with Emerald
   ============================================ */
.dark {
  /* Base Colors */
  --background: linear-gradient(135deg, #0f172a 0%, #1e293b 50%, #0f172a 100%);
  --background-solid: #0f172a;
  --foreground: #f8fafc;

  /* Glass Card */
  --card: rgba(30, 41, 59, 0.6);
  --card-foreground: #f8fafc;
  --card-border: rgba(52, 211, 153, 0.15);

  /* Popover */
  --popover: rgba(30, 41, 59, 0.85);
  --popover-foreground: #f8fafc;

  /* Primary - Brighter Emerald for dark mode */
  --primary: #34d399;
  --primary-foreground: #0f172a;
  --primary-hover: #6ee7b7;
  --primary-glow: rgba(52, 211, 153, 0.4);

  /* Secondary */
  --secondary: rgba(51, 65, 85, 0.8);
  --secondary-foreground: #e2e8f0;

  /* Muted */
  --muted: rgba(51, 65, 85, 0.6);
  --muted-foreground: #94a3b8;

  /* Accent - Brighter Amber */
  --accent: #fbbf24;
  --accent-foreground: #0f172a;

  /* Destructive */
  --destructive: #f87171;
  --destructive-foreground: #0f172a;

  /* Borders & Inputs */
  --border: rgba(52, 211, 153, 0.1);
  --input: rgba(51, 65, 85, 0.6);
  --input-border: rgba(52, 211, 153, 0.2);
  --ring: rgba(52, 211, 153, 0.5);

  /* Charts - Brighter for dark mode */
  --chart-1: #34d399;
  --chart-2: #6ee7b7;
  --chart-3: #fbbf24;
  --chart-4: #10b981;
  --chart-5: #a7f3d0;

  /* Sidebar */
  --sidebar: rgba(15, 23, 42, 0.9);
  --sidebar-foreground: #e2e8f0;
  --sidebar-primary: #34d399;
  --sidebar-primary-foreground: #0f172a;
  --sidebar-accent: rgba(52, 211, 153, 0.15);
  --sidebar-accent-foreground: #34d399;
  --sidebar-border: rgba(52, 211, 153, 0.1);
  --sidebar-ring: rgba(52, 211, 153, 0.3);

  /* Glass Effect Variables */
  --glass-blur: 20px;
  --glass-card-bg: rgba(30, 41, 59, 0.6);
  --glass-sidebar-bg: rgba(15, 23, 42, 0.9);
  --glass-modal-bg: rgba(30, 41, 59, 0.85);
  --glass-border: rgba(52, 211, 153, 0.1);
  --glass-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

/* ============================================
   BASE STYLES
   ============================================ */
@layer base {
  * {
    @apply border-border;
  }

  html {
    scroll-behavior: smooth;
  }

  body {
    @apply text-foreground;
    background: var(--background);
    background-attachment: fixed;
    min-height: 100vh;
  }
}

/* ============================================
   GLASS UTILITY CLASSES
   ============================================ */
@layer utilities {
  .glass {
    background: var(--glass-card-bg);
    backdrop-filter: blur(var(--glass-blur));
    -webkit-backdrop-filter: blur(var(--glass-blur));
    border: 1px solid var(--glass-border);
    box-shadow: var(--glass-shadow);
  }

  .glass-card {
    background: var(--glass-card-bg);
    backdrop-filter: blur(16px);
    -webkit-backdrop-filter: blur(16px);
    border: 1px solid var(--card-border);
    box-shadow: var(--glass-shadow);
    transition: all 0.3s ease;
  }

  .glass-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 40px rgba(16, 185, 129, 0.15);
    border-color: var(--primary);
  }

  .glass-sidebar {
    background: var(--glass-sidebar-bg);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    border-right: 1px solid var(--sidebar-border);
  }

  .glass-modal {
    background: var(--glass-modal-bg);
    backdrop-filter: blur(24px);
    -webkit-backdrop-filter: blur(24px);
    border: 1px solid var(--glass-border);
    box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
  }

  .glass-input {
    background: var(--input);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    border: 1px solid var(--input-border);
    transition: all 0.2s ease;
  }

  .glass-input:focus {
    border-color: var(--primary);
    box-shadow: 0 0 0 3px var(--primary-glow);
  }

  .glass-button {
    position: relative;
    overflow: hidden;
  }

  .glass-button::before {
    content: '';
    position: absolute;
    top: 0;
    left: -100%;
    width: 100%;
    height: 100%;
    background: linear-gradient(
      90deg,
      transparent,
      rgba(255, 255, 255, 0.2),
      transparent
    );
    transition: left 0.5s ease;
  }

  .glass-button:hover::before {
    left: 100%;
  }

  .glow-emerald {
    box-shadow: 0 0 20px var(--primary-glow);
  }

  .text-gradient {
    background: linear-gradient(135deg, var(--primary) 0%, var(--accent) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
}

/* ============================================
   SCROLLBAR STYLING
   ============================================ */
::-webkit-scrollbar {
  width: 8px;
  height: 8px;
}

::-webkit-scrollbar-track {
  background: transparent;
}

::-webkit-scrollbar-thumb {
  background: var(--muted);
  border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
  background: var(--primary);
}

/* ============================================
   ANIMATION CLASSES
   ============================================ */
@layer utilities {
  .animate-glow {
    animation: glow 2s ease-in-out infinite alternate;
  }

  @keyframes glow {
    from {
      box-shadow: 0 0 10px var(--primary-glow);
    }
    to {
      box-shadow: 0 0 20px var(--primary-glow), 0 0 30px var(--primary-glow);
    }
  }

  .animate-float {
    animation: float 3s ease-in-out infinite;
  }

  @keyframes float {
    0%, 100% {
      transform: translateY(0);
    }
    50% {
      transform: translateY(-5px);
    }
  }
}
```

**Step 2: Verify file updated**

Run:
```bash
head -100 admin/src/app/globals.css
```

**Step 3: Commit**

```bash
git add admin/src/app/globals.css
git commit -m "feat(admin): Add glassmorphism theme with emerald palette and dark mode"
```

---

## Task 6: Update Card Component with Glass Effect

**Files:**
- Modify: `admin/src/components/ui/card.tsx`

**Step 1: Read current card component**

Run:
```bash
cat admin/src/components/ui/card.tsx
```

**Step 2: Update card.tsx with glass styling**

```tsx
import * as React from "react"

import { cn } from "@/lib/utils"

const Card = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      "rounded-2xl border text-card-foreground glass-card",
      className
    )}
    {...props}
  />
))
Card.displayName = "Card"

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex flex-col space-y-1.5 p-6", className)}
    {...props}
  />
))
CardHeader.displayName = "CardHeader"

const CardTitle = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      "text-xl font-semibold leading-none tracking-tight",
      className
    )}
    {...props}
  />
))
CardTitle.displayName = "CardTitle"

const CardDescription = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("text-sm text-muted-foreground", className)}
    {...props}
  />
))
CardDescription.displayName = "CardDescription"

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn("p-6 pt-0", className)} {...props} />
))
CardContent.displayName = "CardContent"

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn("flex items-center p-6 pt-0", className)}
    {...props}
  />
))
CardFooter.displayName = "CardFooter"

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent }
```

**Step 3: Commit**

```bash
git add admin/src/components/ui/card.tsx
git commit -m "feat(admin): Update Card component with glass styling"
```

---

## Task 7: Update Button Component with Glass Variants

**Files:**
- Modify: `admin/src/components/ui/button.tsx`

**Step 1: Read current button component**

Run:
```bash
cat admin/src/components/ui/button.tsx
```

**Step 2: Update button.tsx with glass variants**

```tsx
import * as React from "react"
import { Slot } from "@radix-ui/react-slot"
import { cva, type VariantProps } from "class-variance-authority"

import { cn } from "@/lib/utils"

const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-xl text-sm font-medium transition-all duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
  {
    variants: {
      variant: {
        default:
          "bg-primary text-primary-foreground shadow-lg hover:bg-primary/90 hover:shadow-xl hover:shadow-primary/25 glass-button",
        destructive:
          "bg-destructive text-destructive-foreground shadow-lg hover:bg-destructive/90 hover:shadow-xl hover:shadow-destructive/25",
        outline:
          "border border-primary/30 bg-transparent text-primary hover:bg-primary/10 hover:border-primary",
        secondary:
          "bg-secondary text-secondary-foreground shadow hover:bg-secondary/80",
        ghost:
          "hover:bg-primary/10 hover:text-primary",
        link:
          "text-primary underline-offset-4 hover:underline",
        glass:
          "glass-card border-primary/20 text-foreground hover:border-primary hover:bg-primary/5",
      },
      size: {
        default: "h-10 px-5 py-2",
        sm: "h-9 rounded-lg px-4",
        lg: "h-12 rounded-xl px-8 text-base",
        icon: "h-10 w-10",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
)

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button"
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
Button.displayName = "Button"

export { Button, buttonVariants }
```

**Step 3: Commit**

```bash
git add admin/src/components/ui/button.tsx
git commit -m "feat(admin): Update Button component with glass variants and emerald styling"
```

---

## Task 8: Update Input Component with Glass Styling

**Files:**
- Modify: `admin/src/components/ui/input.tsx`

**Step 1: Read current input component**

Run:
```bash
cat admin/src/components/ui/input.tsx
```

**Step 2: Update input.tsx with glass styling**

```tsx
import * as React from "react"

import { cn } from "@/lib/utils"

const Input = React.forwardRef<HTMLInputElement, React.ComponentProps<"input">>(
  ({ className, type, ...props }, ref) => {
    return (
      <input
        type={type}
        className={cn(
          "flex h-10 w-full rounded-xl border bg-background/50 px-4 py-2 text-sm backdrop-blur-sm transition-all duration-200",
          "border-input-border placeholder:text-muted-foreground",
          "focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary",
          "hover:border-primary/50",
          "disabled:cursor-not-allowed disabled:opacity-50",
          "file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-foreground",
          className
        )}
        ref={ref}
        {...props}
      />
    )
  }
)
Input.displayName = "Input"

export { Input }
```

**Step 3: Commit**

```bash
git add admin/src/components/ui/input.tsx
git commit -m "feat(admin): Update Input component with glass styling"
```

---

## Task 9: Create Collapsible Sidebar Layout

**Files:**
- Modify: `admin/src/components/layout/admin-layout.tsx`

**Step 1: Read current admin layout**

Run:
```bash
cat admin/src/components/layout/admin-layout.tsx
```

**Step 2: Replace admin-layout.tsx with collapsible glass sidebar**

```tsx
'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import {
  LayoutDashboard,
  Users,
  UserCheck,
  Car,
  Package,
  Wallet,
  BarChart3,
  Settings,
  LogOut,
  Menu,
  ChevronLeft,
  Send,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { ThemeToggle } from '@/components/theme-toggle'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: LayoutDashboard },
  { name: 'Users', href: '/users', icon: Users },
  { name: 'Pilots', href: '/pilots', icon: UserCheck },
  { name: 'Bookings', href: '/bookings', icon: Package },
  { name: 'Vehicles', href: '/vehicles', icon: Car },
  { name: 'Wallet', href: '/wallet', icon: Wallet },
  { name: 'Analytics', href: '/analytics', icon: BarChart3 },
  { name: 'Settings', href: '/settings', icon: Settings },
]

interface AdminLayoutProps {
  children: React.ReactNode
}

export function AdminLayout({ children }: AdminLayoutProps) {
  const pathname = usePathname()
  const [isExpanded, setIsExpanded] = useState(false)
  const [isMobileOpen, setIsMobileOpen] = useState(false)

  // Close mobile sidebar on route change
  useEffect(() => {
    setIsMobileOpen(false)
  }, [pathname])

  return (
    <TooltipProvider delayDuration={0}>
      <div className="min-h-screen">
        {/* Mobile Header */}
        <header className="lg:hidden fixed top-0 left-0 right-0 z-50 h-16 glass-sidebar flex items-center justify-between px-4">
          <div className="flex items-center gap-3">
            <Button
              variant="ghost"
              size="icon"
              onClick={() => setIsMobileOpen(!isMobileOpen)}
            >
              <Menu className="h-5 w-5" />
            </Button>
            <div className="flex items-center gap-2">
              <div className="h-8 w-8 rounded-lg bg-primary flex items-center justify-center">
                <Send className="h-4 w-4 text-primary-foreground" />
              </div>
              <span className="font-bold text-lg">SendIt</span>
            </div>
          </div>
          <ThemeToggle />
        </header>

        {/* Mobile Overlay */}
        {isMobileOpen && (
          <div
            className="lg:hidden fixed inset-0 z-40 bg-black/50 backdrop-blur-sm"
            onClick={() => setIsMobileOpen(false)}
          />
        )}

        {/* Sidebar */}
        <aside
          className={cn(
            "fixed top-0 left-0 z-50 h-full glass-sidebar transition-all duration-300 ease-in-out",
            // Desktop: expand on hover
            "hidden lg:flex lg:flex-col",
            isExpanded ? "lg:w-64" : "lg:w-20",
            // Mobile: slide in/out
            isMobileOpen ? "flex flex-col w-64" : "hidden"
          )}
          onMouseEnter={() => setIsExpanded(true)}
          onMouseLeave={() => setIsExpanded(false)}
        >
          {/* Logo */}
          <div className="h-16 flex items-center justify-center border-b border-sidebar-border px-4">
            <Link href="/dashboard" className="flex items-center gap-3">
              <div className="h-10 w-10 rounded-xl bg-primary flex items-center justify-center shadow-lg shadow-primary/25 flex-shrink-0">
                <Send className="h-5 w-5 text-primary-foreground" />
              </div>
              <span
                className={cn(
                  "font-bold text-xl transition-all duration-300 overflow-hidden whitespace-nowrap",
                  isExpanded || isMobileOpen ? "w-auto opacity-100" : "w-0 opacity-0"
                )}
              >
                SendIt
              </span>
            </Link>
          </div>

          {/* Navigation */}
          <nav className="flex-1 py-6 px-3 space-y-2 overflow-y-auto">
            {navigation.map((item) => {
              const isActive = pathname === item.href
              const Icon = item.icon

              return (
                <Tooltip key={item.name}>
                  <TooltipTrigger asChild>
                    <Link
                      href={item.href}
                      className={cn(
                        "flex items-center gap-3 px-3 py-3 rounded-xl transition-all duration-200 group",
                        isActive
                          ? "bg-primary text-primary-foreground shadow-lg shadow-primary/25"
                          : "text-sidebar-foreground hover:bg-sidebar-accent hover:text-sidebar-accent-foreground"
                      )}
                    >
                      <Icon
                        className={cn(
                          "h-5 w-5 flex-shrink-0 transition-transform duration-200",
                          !isActive && "group-hover:scale-110"
                        )}
                      />
                      <span
                        className={cn(
                          "transition-all duration-300 overflow-hidden whitespace-nowrap",
                          isExpanded || isMobileOpen ? "w-auto opacity-100" : "w-0 opacity-0"
                        )}
                      >
                        {item.name}
                      </span>
                    </Link>
                  </TooltipTrigger>
                  {!isExpanded && !isMobileOpen && (
                    <TooltipContent side="right" className="glass">
                      {item.name}
                    </TooltipContent>
                  )}
                </Tooltip>
              )
            })}
          </nav>

          {/* Bottom Section */}
          <div className="p-3 border-t border-sidebar-border space-y-2">
            {/* Theme Toggle */}
            <Tooltip>
              <TooltipTrigger asChild>
                <div
                  className={cn(
                    "flex items-center gap-3 px-3 py-3 rounded-xl transition-all duration-200",
                    "text-sidebar-foreground hover:bg-sidebar-accent"
                  )}
                >
                  <ThemeToggle variant={isExpanded || isMobileOpen ? "full" : "icon"} />
                </div>
              </TooltipTrigger>
              {!isExpanded && !isMobileOpen && (
                <TooltipContent side="right" className="glass">
                  Toggle Theme
                </TooltipContent>
              )}
            </Tooltip>

            {/* Logout */}
            <Tooltip>
              <TooltipTrigger asChild>
                <Link
                  href="/login"
                  className={cn(
                    "flex items-center gap-3 px-3 py-3 rounded-xl transition-all duration-200",
                    "text-sidebar-foreground hover:bg-destructive/10 hover:text-destructive"
                  )}
                >
                  <LogOut className="h-5 w-5 flex-shrink-0" />
                  <span
                    className={cn(
                      "transition-all duration-300 overflow-hidden whitespace-nowrap",
                      isExpanded || isMobileOpen ? "w-auto opacity-100" : "w-0 opacity-0"
                    )}
                  >
                    Logout
                  </span>
                </Link>
              </TooltipTrigger>
              {!isExpanded && !isMobileOpen && (
                <TooltipContent side="right" className="glass">
                  Logout
                </TooltipContent>
              )}
            </Tooltip>
          </div>
        </aside>

        {/* Main Content */}
        <main
          className={cn(
            "transition-all duration-300 ease-in-out min-h-screen",
            "pt-16 lg:pt-0", // Mobile header offset
            "lg:ml-20" // Sidebar offset (collapsed width)
          )}
        >
          {/* Desktop Header */}
          <header className="hidden lg:flex sticky top-0 z-40 h-16 items-center justify-between px-8 glass-sidebar">
            <div className="flex items-center gap-4">
              <h1 className="text-lg font-semibold capitalize">
                {pathname === '/dashboard' ? 'Dashboard' : pathname.slice(1)}
              </h1>
            </div>
            <div className="flex items-center gap-4">
              <ThemeToggle />
            </div>
          </header>

          {/* Page Content */}
          <div className="p-6 lg:p-8">{children}</div>
        </main>
      </div>
    </TooltipProvider>
  )
}
```

**Step 3: Verify changes**

Run:
```bash
head -50 admin/src/components/layout/admin-layout.tsx
```

**Step 4: Commit**

```bash
git add admin/src/components/layout/admin-layout.tsx
git commit -m "feat(admin): Add collapsible glass sidebar with hover expand"
```

---

## Task 10: Update Dialog Component with Glass Effect

**Files:**
- Modify: `admin/src/components/ui/dialog.tsx`

**Step 1: Read current dialog component**

Run:
```bash
cat admin/src/components/ui/dialog.tsx
```

**Step 2: Update dialog overlay and content with glass styling**

Update `DialogOverlay` className to:
```tsx
"fixed inset-0 z-50 bg-black/50 backdrop-blur-sm data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
```

Update `DialogContent` className to:
```tsx
"fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 p-6 shadow-2xl duration-200 data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%] data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%] rounded-2xl glass-modal"
```

**Step 3: Commit**

```bash
git add admin/src/components/ui/dialog.tsx
git commit -m "feat(admin): Update Dialog component with glass modal effect"
```

---

## Task 11: Update Table Component with Glass Styling

**Files:**
- Modify: `admin/src/components/ui/table.tsx`

**Step 1: Read current table component**

Run:
```bash
cat admin/src/components/ui/table.tsx
```

**Step 2: Update table with glass styling**

Update `Table` wrapper:
```tsx
<div className="relative w-full overflow-auto rounded-xl glass-card">
```

Update `TableHeader`:
```tsx
"[&_tr]:border-b [&_tr]:border-border/50 bg-muted/30 backdrop-blur-sm"
```

Update `TableRow`:
```tsx
"border-b border-border/30 transition-colors hover:bg-primary/5 data-[state=selected]:bg-primary/10"
```

**Step 3: Commit**

```bash
git add admin/src/components/ui/table.tsx
git commit -m "feat(admin): Update Table component with glass styling"
```

---

## Task 12: Build and Test

**Step 1: Run build to verify no errors**

Run:
```bash
cd /Users/sotsys386/Nirav/claude_projects/SendIt/admin && npm run build
```
Expected: Build completes successfully

**Step 2: Start dev server and visually verify**

Run:
```bash
npm run dev
```

**Step 3: Test checklist**
- [ ] Light mode displays correctly with emerald theme
- [ ] Dark mode displays correctly with emerald theme
- [ ] Theme toggle works in header
- [ ] Theme toggle works in sidebar
- [ ] Sidebar collapses to icons on desktop
- [ ] Sidebar expands on hover
- [ ] Cards have glass effect
- [ ] Buttons have glass shine effect
- [ ] Mobile sidebar works
- [ ] All pages render correctly

**Step 4: Commit final changes if any**

```bash
git add -A
git commit -m "feat(admin): Complete glassmorphism theme implementation"
```

---

## Task 13: Final Commit and Push

**Step 1: Review all changes**

Run:
```bash
git status
git log --oneline -10
```

**Step 2: Push to remote**

Run:
```bash
git push origin main
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Install next-themes | package.json |
| 2 | Create ThemeProvider | theme-provider.tsx |
| 3 | Create ThemeToggle | theme-toggle.tsx |
| 4 | Update root layout | layout.tsx |
| 5 | Glassmorphism CSS | globals.css |
| 6 | Glass Card component | card.tsx |
| 7 | Glass Button component | button.tsx |
| 8 | Glass Input component | input.tsx |
| 9 | Collapsible Sidebar | admin-layout.tsx |
| 10 | Glass Dialog | dialog.tsx |
| 11 | Glass Table | table.tsx |
| 12 | Build and Test | - |
| 13 | Push to remote | - |

**Total estimated tasks:** 13
**No data/API changes required**
