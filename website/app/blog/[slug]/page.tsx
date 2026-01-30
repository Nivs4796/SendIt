import { Metadata } from 'next'
import Link from 'next/link'
import Image from 'next/image'
import { Container } from '@/components/ui'
import { Calendar, User, Clock, ArrowLeft, Share2, Facebook, Twitter, Linkedin } from 'lucide-react'
import { notFound } from 'next/navigation'

// Mock blog posts - in production, use MDX
const blogPosts: Record<string, {
  title: string
  excerpt: string
  content: string
  category: string
  author: string
  date: string
  readTime: string
  image: string
}> = {
  'sendit-launches-in-ahmedabad': {
    title: 'SendIt Launches in Ahmedabad: Revolutionizing Local Delivery',
    excerpt: 'We\'re excited to announce the official launch of SendIt in Ahmedabad, bringing fast, affordable, and reliable delivery services.',
    category: 'Company News',
    author: 'SendIt Team',
    date: '2026-01-15',
    readTime: '3 min read',
    image: '/images/blog/launch-ahmedabad.svg',
    content: `
## SendIt is Now Live in Ahmedabad!

We're thrilled to announce that SendIt is officially live in Ahmedabad! After months of preparation and testing, we're ready to serve the vibrant city with our on-demand delivery platform.

## Why Ahmedabad?

Ahmedabad is a bustling city with over 8 million residents, known for its entrepreneurial spirit and growing e-commerce ecosystem. The city's unique blend of traditional businesses and modern startups makes it the perfect place for SendIt to begin its journey.

## What We Offer

**Express Delivery** - Get your packages delivered within 60 minutes across the city.

**Same-Day Delivery** - Affordable same-day delivery for when you need it fast but not urgent.

**Multiple Vehicle Options** - From bikes for small packages to tempos for larger items, we've got you covered.

**Real-Time Tracking** - Track your delivery every step of the way with live GPS updates.

## Our Vehicle Fleet

- **Cycle** - Perfect for documents and small packages (up to 5 KG)
- **EV Cycle** - Eco-friendly option for short distances
- **2 Wheeler** - Quick delivery for medium packages (up to 10 KG)
- **3 Wheeler** - Ideal for bulk items (up to 100 KG)
- **Truck** - Heavy goods and commercial deliveries (500+ KG)

## Join Us

Whether you're a business looking for reliable delivery partners or an individual who needs to send packages across the city, SendIt is here for you.

**Download our app today and experience the future of local delivery!**

*- The SendIt Team*
    `,
  },
  'safe-packaging-tips': {
    title: '5 Tips for Safe Package Delivery',
    excerpt: 'Learn how to properly package your items to ensure they arrive safely at their destination.',
    category: 'Delivery Tips',
    author: 'SendIt Team',
    date: '2026-01-05',
    readTime: '5 min read',
    image: '/images/blog/packaging-tips.svg',
    content: `
## 5 Tips for Safe Package Delivery

Proper packaging is crucial for ensuring your items arrive safely. Here are our top tips for packaging your deliveries with SendIt.

## 1. Choose the Right Box Size

Select a box that's slightly larger than your item, allowing room for cushioning material. A box that's too small won't provide adequate protection, while one that's too large may allow items to shift during transit.

**Pro Tip:** Keep a variety of box sizes at home for different delivery needs.

## 2. Use Quality Cushioning

Fill empty spaces with protective materials:
- Bubble wrap for fragile items
- Packing peanuts for filling gaps
- Crumpled newspaper as an economical option
- Air pillows for lightweight protection

This prevents items from moving and absorbs shock during handling.

## 3. Secure Fragile Items Properly

For fragile items like electronics, glassware, or ceramics:
- Wrap each item individually in bubble wrap
- Use "FRAGILE" labels clearly visible on all sides
- Consider double-boxing valuable items
- Add extra cushioning on all sides, top, and bottom

## 4. Seal Your Package Correctly

Use strong packing tape to seal all openings:
- Apply tape along all seams
- Use the "H" taping method for extra security
- Reinforce corners and edges
- Avoid using string, paper tape, or cellophane tape

## 5. Label Clearly and Completely

Ensure your package has:
- Clear, legible address labels
- Return address information
- Contact phone numbers for both sender and receiver
- Any special handling instructions

**Remember:** Good packaging protects your items and helps our pilots deliver them safely!

*- The SendIt Team*
    `,
  },
  'become-a-pilot-guide': {
    title: 'Complete Guide to Becoming a SendIt Pilot',
    excerpt: 'Everything you need to know about joining SendIt as a delivery pilot - requirements, earnings potential, and how to get started.',
    category: 'Pilot Stories',
    author: 'SendIt Team',
    date: '2026-01-10',
    readTime: '4 min read',
    image: '/images/blog/become-pilot.svg',
    content: `
## Complete Guide to Becoming a SendIt Pilot

Are you looking for a flexible way to earn money? Becoming a SendIt Pilot might be the perfect opportunity for you. Here's everything you need to know.

## What is a SendIt Pilot?

SendIt Pilots are our delivery partners who pick up and deliver packages across the city. As a pilot, you'll enjoy the freedom to work on your own schedule while earning competitive rates.

## Requirements

To become a SendIt Pilot, you need:

**1. Valid ID Proof** - Aadhaar card or any government-issued ID

**2. Driving License** - Valid license for your vehicle type (not required for cycles)

**3. Vehicle** - Bike, auto, or commercial vehicle with valid RC and insurance

**4. Smartphone** - Android or iOS device for the Pilot app

**5. Bank Account** - For receiving your weekly earnings

## Earnings Potential

Our pilots earn an average of ₹15,000 - ₹25,000+ per month, depending on:

- Number of deliveries completed
- Vehicle type used
- Peak hour bonuses
- Performance incentives
- Referral bonuses

## Vehicle-wise Daily Earnings

| Vehicle | Average Daily Earning |
|---------|----------------------|
| Cycle | ₹300-500 |
| EV Cycle | ₹400-600 |
| 2 Wheeler | ₹600-1000 |
| 3 Wheeler | ₹800-1200 |
| Truck | ₹1500-2500 |

## How to Get Started

**Step 1:** Download the SendIt Pilot app from Play Store or App Store

**Step 2:** Complete the registration form with your details

**Step 3:** Upload required documents (ID, license, vehicle papers)

**Step 4:** Attend a brief online training session

**Step 5:** Get verified and start accepting deliveries!

## Benefits of Being a SendIt Pilot

- **Flexible Hours** - Work when you want
- **Weekly Payouts** - Get paid every Monday
- **Insurance Coverage** - Stay protected while delivering
- **Incentives & Bonuses** - Earn extra through referrals and milestones
- **24/7 Support** - We're always here to help

**Join thousands of pilots who are already earning with SendIt!**

*- The SendIt Team*
    `,
  },
  'ev-delivery-sustainability': {
    title: 'Going Green: How EV Deliveries are Reducing Carbon Footprint',
    excerpt: 'Learn how SendIt\'s EV delivery option is helping reduce carbon emissions and create a sustainable future.',
    category: 'Sustainability',
    author: 'SendIt Team',
    date: '2026-01-28',
    readTime: '4 min read',
    image: '/images/services/ev-delivery.svg',
    content: `
## Going Green: How EV Deliveries are Reducing Carbon Footprint

At SendIt, we believe that sustainable delivery is the future. Our EV (Electric Vehicle) delivery option is helping reduce carbon emissions while providing fast, reliable service.

## The Environmental Impact of Delivery

Traditional delivery vehicles contribute significantly to urban air pollution. With the rise of e-commerce and on-demand delivery, this impact is only growing. That's why we've made sustainability a core part of our mission.

## SendIt's Green Initiative

**Zero Emissions** - Our EV fleet produces no direct emissions, helping keep Ahmedabad's air cleaner.

**Reduced Noise Pollution** - Electric vehicles are quieter, making deliveries less disruptive to neighborhoods.

**Lower Carbon Footprint** - Each EV delivery saves approximately 0.5 kg of CO2 compared to traditional vehicles.

## Our EV Fleet

**EV Cycles** - Perfect for short-distance deliveries
- Range: Up to 50 km per charge
- Capacity: Up to 5 KG
- Best for: Documents, small packages

**EV 2 Wheelers** - For medium-distance urban deliveries
- Range: Up to 80 km per charge
- Capacity: Up to 10 KG
- Best for: Quick deliveries across the city

## Teen Pilot Program

One unique aspect of our EV program is the opportunity for teens aged 16-18 to become pilots (with parental consent). This:
- Provides earning opportunities for young people
- Teaches responsibility and work ethics
- Promotes eco-friendly transportation habits early

## The Numbers

Since launching our EV program:
- **500+ tons** of CO2 emissions saved
- **100+ EV pilots** active in Ahmedabad
- **30%** of our deliveries now use EVs
- **₹2 lakhs+** saved in fuel costs monthly

## How You Can Help

**Choose EV Delivery** - When booking, select the EV option for shorter distances.

**Support Green Pilots** - Our EV pilots are committed to sustainability.

**Spread the Word** - Tell friends and family about eco-friendly delivery options.

## Our Commitment

By 2027, we aim to have 50% of our fleet running on electric power. Together, we can make local delivery sustainable and help build a greener future for Ahmedabad.

**Choose green. Choose SendIt EV.**

*- The SendIt Team*
    `,
  },
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const { slug } = await params
  const post = blogPosts[slug]
  if (!post) {
    return { title: 'Post Not Found' }
  }
  return {
    title: post.title,
    description: post.excerpt,
  }
}

export default async function BlogPostPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params
  const post = blogPosts[slug]

  if (!post) {
    notFound()
  }

  return (
    <>
      {/* Header */}
      <section className="py-16 lg:py-24 bg-gradient-to-b from-primary-50 to-white">
        <Container size="sm">
          <Link
            href="/blog"
            className="inline-flex items-center gap-2 text-primary-600 hover:text-primary-700 mb-6"
          >
            <ArrowLeft className="w-4 h-4" />
            Back to Blog
          </Link>

          <span className="inline-block px-3 py-1 bg-primary-100 text-primary-700 text-sm font-semibold rounded-full mb-4">
            {post.category}
          </span>

          <h1 className="text-3xl md:text-4xl lg:text-5xl font-bold text-secondary-900 mb-6">
            {post.title}
          </h1>

          <div className="flex flex-wrap items-center gap-4 text-secondary-500">
            <span className="flex items-center gap-2">
              <User className="w-4 h-4" />
              {post.author}
            </span>
            <span className="flex items-center gap-2">
              <Calendar className="w-4 h-4" />
              {new Date(post.date).toLocaleDateString('en-IN', {
                day: 'numeric',
                month: 'long',
                year: 'numeric',
              })}
            </span>
            <span className="flex items-center gap-2">
              <Clock className="w-4 h-4" />
              {post.readTime}
            </span>
          </div>
        </Container>
      </section>

      {/* Featured Image */}
      <section className="bg-white">
        <Container size="sm">
          <div className="aspect-video rounded-2xl -mt-8 relative z-10 shadow-xl overflow-hidden">
            <Image
              src={post.image}
              alt={post.title}
              width={800}
              height={450}
              className="w-full h-full object-cover"
            />
          </div>
        </Container>
      </section>

      {/* Content */}
      <section className="section-padding bg-white">
        <Container size="sm">
          <article className="prose prose-lg max-w-none prose-headings:text-secondary-900 prose-p:text-secondary-600 prose-a:text-primary-600 prose-strong:text-secondary-900">
            <div dangerouslySetInnerHTML={{ __html: post.content.replace(/\n/g, '<br/>').replace(/#{1,6}\s(.+)/g, '<h2 class="text-2xl font-bold mt-8 mb-4">$1</h2>').replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>').replace(/\*(.+?)\*/g, '<em>$1</em>') }} />
          </article>

          {/* Share */}
          <div className="mt-12 pt-8 border-t border-secondary-200">
            <div className="flex items-center justify-between">
              <span className="font-semibold text-secondary-900">Share this article</span>
              <div className="flex gap-3">
                <a
                  href="#"
                  className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center text-blue-600 hover:bg-blue-200 transition-colors"
                >
                  <span className="text-sm font-bold">f</span>
                </a>
                <a
                  href="#"
                  className="w-10 h-10 bg-sky-100 rounded-full flex items-center justify-center text-sky-600 hover:bg-sky-200 transition-colors"
                >
                  <span className="text-sm font-bold">X</span>
                </a>
                <a
                  href="#"
                  className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center text-blue-700 hover:bg-blue-200 transition-colors"
                >
                  <span className="text-sm font-bold">in</span>
                </a>
              </div>
            </div>
          </div>
        </Container>
      </section>
    </>
  )
}
