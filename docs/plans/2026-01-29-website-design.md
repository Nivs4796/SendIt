# SendIt Marketing Website - Implementation Design

**Date:** 2026-01-29
**Status:** Ready for Implementation

---

## 1. Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Next.js 14+ (App Router) |
| Language | TypeScript (strict) |
| Styling | Tailwind CSS v3.4+ |
| Animations | Framer Motion |
| Blog | MDX with next-mdx-remote |
| Forms | React Hook Form + Zod |
| Icons | Lucide React |
| Utilities | clsx, tailwind-merge |

---

## 2. Design System

### Color Palette
```css
/* Primary - Eco Green */
--primary-50: #ECFDF5
--primary-100: #D1FAE5
--primary-500: #10B981
--primary-600: #059669
--primary-700: #047857

/* Secondary - Dark */
--secondary-900: #111827
--secondary-800: #1F2937
--secondary-700: #374151

/* Accent - Amber */
--accent-500: #F59E0B
--accent-600: #D97706

/* Neutrals */
--gray-50: #F9FAFB
--gray-100: #F3F4F6
--gray-500: #6B7280
--gray-900: #111827
```

### Typography
- **Font Family:** Inter (Google Fonts)
- **Headings:** Bold (700), tracking tight
- **Body:** Regular (400), leading relaxed
- **Scale:** 14px base, responsive clamp()

### Spacing
- Container: max-w-7xl, px-4 sm:px-6 lg:px-8
- Section padding: py-16 lg:py-24
- Component gaps: space-y-8, gap-6

### Components Style
- Buttons: Rounded-full, bold shadows, hover scale
- Cards: Rounded-2xl, subtle shadows, hover lift
- Inputs: Rounded-xl, focus ring primary

---

## 3. Folder Structure

```
website/
├── app/
│   ├── layout.tsx
│   ├── page.tsx                    # Homepage
│   ├── about/page.tsx
│   ├── services/page.tsx
│   ├── pricing/page.tsx
│   ├── become-pilot/page.tsx
│   ├── contact/page.tsx
│   ├── blog/
│   │   ├── page.tsx
│   │   └── [slug]/page.tsx
│   └── legal/
│       ├── terms-user/page.tsx
│       ├── terms-pilot/page.tsx
│       ├── privacy-user/page.tsx
│       ├── privacy-pilot/page.tsx
│       └── refund-policy/page.tsx
├── components/
│   ├── layout/
│   │   ├── Header.tsx
│   │   ├── Footer.tsx
│   │   └── MobileMenu.tsx
│   ├── ui/
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Input.tsx
│   │   ├── Container.tsx
│   │   └── SectionHeading.tsx
│   └── sections/
│       ├── Hero.tsx
│       ├── Stats.tsx
│       ├── Services.tsx
│       ├── HowItWorks.tsx
│       ├── Features.tsx
│       ├── Testimonials.tsx
│       ├── AppDownload.tsx
│       ├── Newsletter.tsx
│       ├── PricingTable.tsx
│       ├── FareCalculator.tsx
│       ├── EarningsCalculator.tsx
│       ├── FAQ.tsx
│       └── ContactForm.tsx
├── content/
│   └── blog/
│       └── *.mdx
├── lib/
│   ├── utils.ts
│   ├── mdx.ts
│   └── constants.ts
├── public/
│   ├── images/
│   ├── icons/
│   └── qr/
├── styles/
│   └── globals.css
├── tailwind.config.ts
├── next.config.mjs
└── package.json
```

---

## 4. Page Specifications

### Homepage (/)
1. **Hero** - Bold headline, 2 CTAs, gradient background, delivery illustration
2. **Stats** - 4 animated counters (customers, pilots, deliveries, rating)
3. **Services** - 4-card grid with icons and hover effects
4. **Features** - Checkmark list of differentiators
5. **How It Works** - 4-step visual flow (User + Pilot tabs)
6. **Testimonials** - Carousel with user reviews
7. **App Download** - QR codes, app store badges, phone mockup
8. **Newsletter** - Phone number capture form

### About (/about)
- Company story, mission, vision
- Team section (placeholder)
- Values grid
- Achievements timeline

### Services (/services)
- Service cards with details
- Vehicle comparison
- Use cases

### Pricing (/pricing)
- Interactive fare calculator (location inputs)
- Pricing table by vehicle type
- "No hidden charges" callout

### Become a Pilot (/become-pilot)
- Hero with earnings hook
- Benefits grid (6 items)
- Requirements checklist
- Earnings calculator slider
- Registration steps
- Pilot testimonials
- FAQ accordion
- Download CTA

### Blog (/blog)
- Grid of post cards
- Category filter
- Individual post with MDX rendering

### Contact (/contact)
- Contact form (name, email, phone, category, message)
- Contact info sidebar
- Social links

### Legal Pages (5)
- Static content pages
- Consistent layout with sidebar navigation

---

## 5. Key Components

### Header
- Sticky, blur backdrop
- Logo + nav links
- "Download App" dropdown button
- Mobile hamburger → slide-out menu

### Footer
- 5 columns: About, Quick Links, Partners, Legal, Download
- Social icons
- Copyright bar

### Hero
- Split layout: content left, illustration right
- Gradient mesh background
- Animated entrance (Framer Motion)

### Stats
- useInView trigger
- Animated number counting
- Icon + label + value

### Service Cards
- Icon, title, description
- Hover: lift + shadow
- Link to services page

### Testimonials
- Auto-play carousel
- Avatar, name, location, rating, quote
- Navigation dots

### App Download
- Phone mockup with app screenshot
- QR codes (user + pilot)
- App Store + Play Store badges

### Fare Calculator
- Two location inputs (text for now, maps later)
- Vehicle type selector
- Calculate button → show estimate
- Client component with local state

### Earnings Calculator
- Hours/day slider (4-12)
- Rides estimate calculation
- Monthly earnings display

---

## 6. SEO Strategy

### Meta Tags (per page)
- Unique title (under 60 chars)
- Description (under 160 chars)
- Open Graph image
- Twitter card

### Schema Markup
- Organization (homepage)
- LocalBusiness (contact)
- Article (blog posts)
- FAQPage (become-pilot)

### Performance Targets
- Lighthouse: 90+ all categories
- LCP < 2.5s
- CLS < 0.1
- FID < 100ms

---

## 7. Implementation Order

### Phase 1: Foundation
1. Initialize Next.js project
2. Configure Tailwind + design tokens
3. Setup folder structure
4. Create base UI components (Button, Card, Input, Container)
5. Build Header + Footer
6. Create root layout

### Phase 2: Homepage
7. Hero section
8. Stats section
9. Services section
10. Features section
11. How It Works section
12. Testimonials section
13. App Download section
14. Newsletter section

### Phase 3: Core Pages
15. About page
16. Services page
17. Pricing page (with calculator)
18. Become a Pilot page (with earnings calculator)
19. Contact page (with form)

### Phase 4: Blog
20. MDX setup
21. Blog listing page
22. Blog post template
23. Sample posts

### Phase 5: Legal & Polish
24. Legal pages (5)
25. SEO meta tags
26. Schema markup
27. Performance optimization
28. Mobile testing

---

## 8. Assets Needed

### Images (placeholder initially)
- Hero illustration (delivery person)
- Phone mockups (user + pilot apps)
- Team photos
- Testimonial avatars
- Blog thumbnails
- Vehicle icons

### QR Codes
- User app (iOS)
- User app (Android)
- Pilot app (iOS)
- Pilot app (Android)

### App Store Badges
- Download on App Store
- Get it on Google Play

---

**Ready for implementation.**
