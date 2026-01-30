import { Metadata } from 'next'
import Link from 'next/link'
import Image from 'next/image'
import { Container, SectionHeading, Card, CardContent } from '@/components/ui'
import { Calendar, User, Clock, ArrowRight } from 'lucide-react'

export const metadata: Metadata = {
  title: 'Blog',
  description: 'Latest news, tips, and stories from SendIt. Learn about delivery tips, pilot stories, and company updates.',
}

// Mock blog posts - in production, these would come from MDX files
const blogPosts = [
  {
    slug: 'sendit-launches-in-ahmedabad',
    title: 'SendIt Launches in Ahmedabad: Revolutionizing Local Delivery',
    excerpt: 'We\'re excited to announce the official launch of SendIt in Ahmedabad, bringing fast, affordable, and reliable delivery services.',
    category: 'Company News',
    author: 'SendIt Team',
    date: '2026-01-15',
    readTime: '3 min read',
    image: '/images/blog/launch-ahmedabad.svg',
  },
  {
    slug: 'safe-packaging-tips',
    title: '5 Tips for Safe Package Delivery',
    excerpt: 'Learn how to properly package your items to ensure they arrive safely at their destination.',
    category: 'Delivery Tips',
    author: 'SendIt Team',
    date: '2026-01-05',
    readTime: '5 min read',
    image: '/images/blog/packaging-tips.svg',
  },
  {
    slug: 'become-a-pilot-guide',
    title: 'Complete Guide to Becoming a SendIt Pilot',
    excerpt: 'Everything you need to know about joining SendIt as a delivery pilot - requirements, earnings potential, and how to get started.',
    category: 'Pilot Stories',
    author: 'SendIt Team',
    date: '2026-01-10',
    readTime: '4 min read',
    image: '/images/blog/become-pilot.svg',
  },
  {
    slug: 'ev-delivery-sustainability',
    title: 'Going Green: How EV Deliveries are Reducing Carbon Footprint',
    excerpt: 'Learn how SendIt\'s EV delivery option is helping reduce carbon emissions and create a sustainable future.',
    category: 'Sustainability',
    author: 'SendIt Team',
    date: '2026-01-28',
    readTime: '4 min read',
    image: '/images/services/ev-delivery.svg',
  },
]

const categories = ['All', 'Company News', 'Delivery Tips', 'Pilot Stories', 'Sustainability', 'Technology']

export default function BlogPage() {
  return (
    <>
      {/* Hero */}
      <section className="py-16 lg:py-24 bg-gradient-to-b from-primary-50 to-white">
        <Container>
          <div className="max-w-3xl mx-auto text-center">
            <span className="inline-block px-4 py-2 bg-primary-100 text-primary-700 rounded-full text-sm font-semibold mb-6">
              Our Blog
            </span>
            <h1 className="text-4xl md:text-5xl font-bold text-secondary-900 mb-6">
              News, Tips & Stories
            </h1>
            <p className="text-xl text-secondary-500">
              Stay updated with the latest from SendIt - delivery tips, pilot stories, and company news.
            </p>
          </div>
        </Container>
      </section>

      {/* Categories */}
      <section className="py-8 bg-white border-b border-secondary-100">
        <Container>
          <div className="flex flex-wrap justify-center gap-3">
            {categories.map((category) => (
              <button
                key={category}
                className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                  category === 'All'
                    ? 'bg-primary-500 text-white'
                    : 'bg-secondary-100 text-secondary-600 hover:bg-secondary-200'
                }`}
              >
                {category}
              </button>
            ))}
          </div>
        </Container>
      </section>

      {/* Blog Posts */}
      <section className="section-padding bg-white">
        <Container>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
            {blogPosts.map((post) => (
              <Link key={post.slug} href={`/blog/${post.slug}`}>
                <Card className="h-full group cursor-pointer">
                  <div className="aspect-video bg-secondary-100 rounded-t-2xl -mx-6 -mt-6 mb-4 overflow-hidden">
                    <Image
                      src={post.image}
                      alt={post.title}
                      width={400}
                      height={225}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                  </div>
                  <CardContent>
                    <span className="inline-block px-3 py-1 bg-primary-100 text-primary-700 text-xs font-semibold rounded-full mb-3">
                      {post.category}
                    </span>
                    <h2 className="text-xl font-bold text-secondary-900 mb-2 group-hover:text-primary-600 transition-colors line-clamp-2">
                      {post.title}
                    </h2>
                    <p className="text-secondary-500 mb-4 line-clamp-2">
                      {post.excerpt}
                    </p>
                    <div className="flex items-center justify-between text-sm text-secondary-400">
                      <div className="flex items-center gap-4">
                        <span className="flex items-center gap-1">
                          <Calendar className="w-4 h-4" />
                          {new Date(post.date).toLocaleDateString('en-IN', {
                            day: 'numeric',
                            month: 'short',
                            year: 'numeric',
                          })}
                        </span>
                        <span className="flex items-center gap-1">
                          <Clock className="w-4 h-4" />
                          {post.readTime}
                        </span>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </Link>
            ))}
          </div>
        </Container>
      </section>
    </>
  )
}
