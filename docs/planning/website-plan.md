# Marketing Website - Detailed Planning Document

## 1. Overview

The marketing website serves as the public face of SendIt, providing information, lead generation, and app download links.

**Platform:** Next.js 14+ with SEO optimization

## 2. Technology Stack

- **Framework:** Next.js 14+ (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Animations:** Framer Motion
- **Forms:** React Hook Form
- **SEO:** Next SEO
- **Analytics:** Google Analytics / Mixpanel

## 3. Site Structure

```
website/
├── app/
│   ├── page.tsx                 # Homepage
│   ├── about/page.tsx
│   ├── services/page.tsx
│   ├── pricing/page.tsx
│   ├── become-pilot/page.tsx
│   ├── blog/
│   │   ├── page.tsx
│   │   └── [slug]/page.tsx
│   ├── contact/page.tsx
│   ├── legal/
│   │   ├── terms-user/page.tsx
│   │   ├── terms-pilot/page.tsx
│   │   ├── privacy-user/page.tsx
│   │   ├── privacy-pilot/page.tsx
│   │   └── refund-policy/page.tsx
│   └── layout.tsx
├── components/
│   ├── Header.tsx
│   ├── Footer.tsx
│   ├── Hero.tsx
│   ├── AppDownload.tsx
│   └── ...
└── public/
    ├── images/
    └── qr/
```

## 4. Page Specifications

### 4.1 Homepage (`/`)

**Hero Section:**
- Headline: "Swift, Simple & Secure Delivery at Your Fingertips"
- Subheadline: "On-demand courier delivery with real-time tracking"
- CTA Buttons:
  - "Download User App"
  - "Become a Pilot"
- Hero image/animation: Delivery person with package
- App download QR codes (iOS & Android)

**Stats Section:**
- 10,000+ Happy Customers
- 500+ Active Pilots
- 50,000+ Deliveries Completed
- 4.8★ Average Rating

**Services Overview:**
**Grid of service cards:**
1. **Goods Delivery**
   - Icon: Package
   - Description: Send parcels, documents, groceries
   - Vehicles: Cycle to Trucks

2. **Passenger Rides**
   - Icon: Person
   - Description: Quick 2-wheeler and auto rides
   
3. **Scheduled Pickup**
   - Icon: Calendar
   - Description: Book in advance for convenience

4. **EV Eco-Friendly**
   - Icon: Leaf
   - Description: Sustainable delivery with electric vehicles

**What Sets Us Apart:**
- ✓ Multiple Vehicle Options (Cycle, 2W, 3W, Trucks)
- ✓ Real-Time GPS Tracking
- ✓ Photo Proof of Delivery
- ✓ Upfront Pricing, No Hidden Charges
- ✓ Eco-Friendly EV Options
- ✓ Teen Earning Opportunities (16-18 with parental consent)
- ✓ Wallet & Referral Rewards

**How It Works (User):**
1. **Enter Locations** - Pickup and drop address
2. **Select Vehicle** - Choose based on package size
3. **Track Delivery** - Live GPS tracking
4. **Rate Experience** - Share your feedback

**How It Works (Pilot):**
1. **Register** - Quick signup with document verification
2. **Go Online** - Start receiving delivery requests
3. **Accept Jobs** - Choose jobs that suit you
4. **Earn Money** - Flexible earning opportunities

**Latest Offers Section:**
- Promotional banners (carousel)
- Current discount codes
- "Get WELCOME50 - 50% off on first ride!"

**Testimonials:**
- User reviews with photos
- Rating stars
- Name & location

**App Download Section:**
- "Download the App Now"
- QR codes for iOS & Android
- App Store badges
- Screenshots carousel

**Newsletter Signup:**
- "Stay Updated with SendIt"
- Mobile number input
- "Notify Me" button

### 4.2 About Us (`/about`)

**Our Story:**
- Company founding
- Mission statement
- Vision

**Our Team:**
- Founder/leadership photos
- Brief bios

**Our Values:**
- Customer First
- Innovation
- Sustainability
- Community

**Achievements:**
- Milestones
- Awards/recognitions
- Media coverage

### 4.3 Services (`/services`)

**Detailed Service Pages:**

**Goods Delivery:**
- What you can send
- Vehicle options with pricing
- Weight & distance limits
- Use cases (e-commerce, groceries, documents)

**Passenger Rides:**
- 2-wheeler rides
- Auto rides
- Affordable & quick

**Scheduled Deliveries:**
- Book in advance
- Operating hours (8 AM - 10 PM)
- Perfect for planned moves

**EV Cycle Delivery:**
- Eco-friendly
- Teen earning program
- Short distance (< 5 KM)

### 4.4 Pricing (`/pricing`)

**Fare Calculator:**
- Pickup location input
- Drop location input
- Vehicle type selector
- "Calculate Fare" button
- Estimated price display

**Pricing Table:**
| Vehicle | Base Fare | Per KM | Max Weight | Max Distance |
|---------|-----------|--------|------------|--------------|
| Cycle | ₹44 | Variable | 5 KG | 5 KM |
| EV Cycle | ₹54 | Variable | 5 KG | Flexible |
| 2 Wheeler | ₹54 | Variable | 10 KG | City-wide |
| 3 Wheeler | ₹154+ | Variable | 50-100 KG | City-wide |
| Truck | Custom | Variable | 500+ KG | City-wide |

**No Hidden Charges:**
- Transparent pricing
- Taxes included
- Discount coupons available

### 4.5 Become a Pilot (`/become-pilot`)

**Hero:**
- "Earn Money on Your Schedule"
- "Join 500+ pilots earning with SendIt"
- "Register Now" CTA

**Benefits:**
- Flexible working hours
- Competitive earnings
- Weekly payouts
- Reward programs
- Insurance coverage
- 24/7 support

**Requirements:**
- Age 18+ (or 16-18 for EV Cycle with consent)
- Valid driving license (for motorized)
- Vehicle documents
- Smartphone with GPS

**Registration Process:**
1. Download Pilot App
2. Complete registration form
3. Upload documents
4. Verification (24-48 hours)
5. Start earning!

**Earnings Calculator:**
- Hours per day slider
- Average rides estimate
- Potential monthly earnings display

**Pilot Testimonials:**
- Success stories
- Photos of pilots
- Earnings shared

**FAQ Section:**
- Common questions
- Expandable accordion

**CTA:**
- "Download Pilot App" buttons
- QR codes

### 4.6 Blog (`/blog`)

**Blog Listing:**
- Grid of blog post cards
- Thumbnail image
- Title, excerpt, date
- Category tags
- Author
- Read time

**Categories:**
- Delivery Tips
- Pilot Stories
- Company News
- Sustainability
- Technology

**Blog Post (`/blog/[slug]`):**
- Featured image
- Title, date, author
- Content (rich text)
- Social share buttons
- Related posts
- Comment section (optional)

**SEO Optimization:**
- Meta tags
- Open Graph tags
- Schema markup (Article)

### 4.7 Contact (`/contact`)

**Contact Form:**
- Name (required)
- Email (required)
- Phone (required)
- Category dropdown:
  - Inquiry
  - Support
  - Feedback
  - Partnership
- Message (required)
- "Submit" button

**Contact Information:**
- Email: support@drop-it.co
- Phone: +91 94847 07535
- Office address (if any)
- Operating hours

**Map:**
- Embedded Google Map (if office location)

**Social Media Links:**
- Facebook, Twitter, Instagram, LinkedIn

**API:**
```typescript
POST /api/v1/contact
{
  name: "John Doe",
  email: "john@example.com",
  phone: "9876543210",
  category: "inquiry",
  message: "I want to know about..."
}
```

### 4.8 Legal Pages

#### Terms & Conditions - User (`/legal/terms-user`)
- Service description
- User obligations
- Cancellation policy
- Refund policy
- Liability limitations
- Dispute resolution

#### Terms & Conditions - Pilot (`/legal/terms-pilot`)
- Pilot obligations
- Commission structure
- Payment terms
- Insurance requirements
- Account termination

#### Privacy Policy - User (`/legal/privacy-user`)
- Data collection
- Data usage
- Data sharing
- Cookies policy
- User rights
- GDPR compliance

#### Privacy Policy - Pilot (`/legal/privacy-pilot`)
- Similar to user privacy
- Additional pilot-specific data

#### Refund & Cancellation Policy (`/legal/refund-policy`)
- Cancellation rules
- Refund process
- Refund timeline
- Exceptions

## 5. Header & Footer

### Header (Sticky)
**Navigation:**
- Logo (links to home)
- Links:
  - Home
  - About
  - Services
  - Pricing
  - Become a Pilot
  - Blog
  - Contact
- "Download App" button (dropdown: User / Pilot)
- Mobile hamburger menu

### Footer
**Columns:**

**Column 1: About SendIt**
- Brief description
- Social media icons

**Column 2: Quick Links**
- About Us
- Services
- Pricing
- Blog
- Contact

**Column 3: For Partners**
- Become a Pilot
- Pilot Login
- Partner with Us

**Column 4: Legal**
- Terms & Conditions
- Privacy Policy
- Refund Policy

**Column 5: Download App**
- App Store badges
- QR codes

**Bottom Bar:**
- Copyright © 2026 Easyexpress Delivery Solutions LLP
- Developed with ❤️ in India

## 6. Components

### AppDownload Component
```typescript
<AppDownload
  title="Download the App"
  platforms={['ios', 'android']}
  showQR={true}
  variant="user" // or "pilot"
/>
```

### Hero Component
```typescript
<Hero
  headline="Swift Delivery"
  subheadline="At your fingertips"
  cta={[
    { text: 'Download App', href: '#download' },
    { text: 'Learn More', href: '/about' }
  ]}
  image="/hero.png"
/>
```

### StatsBar Component
```typescript
<StatsBar
  stats={[
    { label: 'Customers', value: '10,000+' },
    { label: 'Pilots', value: '500+' },
    { label: 'Deliveries', value: '50,000+' },
    { label: 'Rating', value: '4.8★' }
  ]}
/>
```

### ServiceCard Component
```typescript
<ServiceCard
  icon={<PackageIcon />}
  title="Goods Delivery"
  description="Send parcels..."
  link="/services/goods"
/>
```

## 7. SEO Optimization

### Meta Tags (Every Page)
- Title (unique, under 60 chars)
- Description (under 160 chars)
- Keywords
- Canonical URL
- Open Graph tags (og:title, og:description, og:image)
- Twitter Card tags

### Homepage SEO
```typescript
{
  title: "SendIt - On-Demand Courier Delivery | Ahmedabad",
  description: "Swift, simple & secure delivery service in Ahmedabad. Real-time tracking, multiple vehicles, eco-friendly options. Download now!",
  keywords: "courier delivery, Ahmedabad delivery, goods delivery, parcel service",
}
```

### Schema Markup
- Organization schema
- LocalBusiness schema
- Product schema (for services)
- Article schema (for blog)

### Performance
- Image optimization (Next.js Image)
- Lazy loading
- Code splitting
- CDN for static assets
- Lighthouse score > 90

## 8. Lead Generation

### Newsletter Signup Form
- Collect phone numbers
- Store in database
- Send welcome SMS
- Marketing automation

### App Download Tracking
- Track download clicks
- QR code scans (UTM parameters)
- Install attribution

### Contact Form Leads
- Store in CRM
- Auto-response email
- Notification to sales team

## 9. Development Checklist

### Phase 1: Setup
- [ ] Initialize Next.js project
- [ ] Setup Tailwind CSS
- [ ] Configure TypeScript
- [ ] Setup layout structure

### Phase 2: Core Pages
- [ ] Homepage with all sections
- [ ] About page
- [ ] Services page
- [ ] Pricing page
- [ ] Become a Pilot page

### Phase 3: Content
- [ ] Blog listing & posts
- [ ] Contact page with form
- [ ] Legal pages (5 pages)

### Phase 4: Components
- [ ] Header navigation
- [ ] Footer
- [ ] App download component
- [ ] Hero sections
- [ ] Forms

### Phase 5: SEO & Polish
- [ ] Meta tags all pages
- [ ] Schema markup
- [ ] Image optimization
- [ ] Mobile responsiveness
- [ ] Performance optimization
- [ ] Analytics integration

### Phase 6: Deployment
- [ ] Domain setup
- [ ] Vercel deployment
- [ ] SSL certificate
- [ ] Custom domain
- [ ] CDN configuration

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-29
