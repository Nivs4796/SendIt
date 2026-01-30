export const SITE_CONFIG = {
  name: 'SendIt',
  tagline: 'Swift, Simple & Secure Delivery',
  description: 'On-demand courier delivery with real-time tracking. Multiple vehicle options from cycles to trucks.',
  url: 'https://sendit.co.in',
  email: 'support@sendit.co.in',
  phone: '+91 94847 07535',
  company: 'Easyexpress Delivery Solutions LLP',
  location: 'Ahmedabad, Gujarat, India',
}

export const NAV_LINKS = [
  { label: 'Home', href: '/' },
  { label: 'About', href: '/about' },
  { label: 'Services', href: '/services' },
  { label: 'Pricing', href: '/pricing' },
  { label: 'Become a Pilot', href: '/become-pilot' },
  { label: 'Blog', href: '/blog' },
  { label: 'Contact', href: '/contact' },
]

export const SOCIAL_LINKS = {
  facebook: 'https://facebook.com/senditdelivery',
  twitter: 'https://twitter.com/senditdelivery',
  instagram: 'https://instagram.com/senditdelivery',
  linkedin: 'https://linkedin.com/company/senditdelivery',
}

export const APP_LINKS = {
  userApp: {
    ios: '#',
    android: '#',
  },
  pilotApp: {
    ios: '#',
    android: '#',
  },
}

export const STATS = [
  { value: 10000, label: 'Happy Customers', suffix: '+' },
  { value: 500, label: 'Active Pilots', suffix: '+' },
  { value: 50000, label: 'Deliveries Completed', suffix: '+' },
  { value: 4.8, label: 'Average Rating', suffix: '★' },
]

export const VEHICLE_PRICING = [
  {
    type: 'Cycle',
    baseFare: 44,
    perKm: 'Variable',
    maxWeight: '5 KG',
    maxDistance: '5 KM',
    icon: 'bike',
  },
  {
    type: 'EV Cycle',
    baseFare: 54,
    perKm: 'Variable',
    maxWeight: '5 KG',
    maxDistance: 'Flexible',
    icon: 'zap',
  },
  {
    type: '2 Wheeler',
    baseFare: 54,
    perKm: 'Variable',
    maxWeight: '10 KG',
    maxDistance: 'City-wide',
    icon: 'bike',
  },
  {
    type: '3 Wheeler',
    baseFare: 154,
    perKm: 'Variable',
    maxWeight: '50-100 KG',
    maxDistance: 'City-wide',
    icon: 'car',
  },
  {
    type: 'Truck',
    baseFare: 'Custom',
    perKm: 'Variable',
    maxWeight: '500+ KG',
    maxDistance: 'City-wide',
    icon: 'truck',
  },
]

export const SERVICES = [
  {
    title: 'Goods Delivery',
    description: 'Send parcels, documents, groceries and more with our reliable delivery network.',
    icon: 'package',
    href: '/services#goods',
  },
  {
    title: 'Passenger Rides',
    description: 'Quick 2-wheeler and auto rides for affordable and fast transportation.',
    icon: 'users',
    href: '/services#passenger',
  },
  {
    title: 'Scheduled Pickup',
    description: 'Book in advance for planned deliveries. Perfect for business needs.',
    icon: 'calendar',
    href: '/services#scheduled',
  },
  {
    title: 'EV Eco-Friendly',
    description: 'Sustainable delivery with electric vehicles. Good for the planet.',
    icon: 'leaf',
    href: '/services#ev',
  },
]

export const FEATURES = [
  'Multiple Vehicle Options (Cycle, 2W, 3W, Trucks)',
  'Real-Time GPS Tracking',
  'Photo Proof of Delivery',
  'Upfront Pricing, No Hidden Charges',
  'Eco-Friendly EV Options',
  'Teen Earning Opportunities (16-18 with consent)',
  'Wallet & Referral Rewards',
  '24/7 Customer Support',
]

export const HOW_IT_WORKS_USER = [
  {
    step: 1,
    title: 'Enter Locations',
    description: 'Add pickup and drop address',
    icon: 'map-pin',
  },
  {
    step: 2,
    title: 'Select Vehicle',
    description: 'Choose based on package size',
    icon: 'car',
  },
  {
    step: 3,
    title: 'Track Delivery',
    description: 'Live GPS tracking of your package',
    icon: 'navigation',
  },
  {
    step: 4,
    title: 'Rate Experience',
    description: 'Share your feedback',
    icon: 'star',
  },
]

export const HOW_IT_WORKS_PILOT = [
  {
    step: 1,
    title: 'Register',
    description: 'Quick signup with document verification',
    icon: 'user-plus',
  },
  {
    step: 2,
    title: 'Go Online',
    description: 'Start receiving delivery requests',
    icon: 'wifi',
  },
  {
    step: 3,
    title: 'Accept Jobs',
    description: 'Choose jobs that suit you',
    icon: 'check-circle',
  },
  {
    step: 4,
    title: 'Earn Money',
    description: 'Flexible earning opportunities',
    icon: 'wallet',
  },
]

export const PILOT_BENEFITS = [
  { title: 'Flexible Hours', description: 'Work when you want, as much as you want', icon: 'clock' },
  { title: 'Competitive Earnings', description: 'Earn up to ₹25,000+ per month', icon: 'trending-up' },
  { title: 'Weekly Payouts', description: 'Get paid every week to your bank account', icon: 'credit-card' },
  { title: 'Reward Programs', description: 'Earn bonus through referrals and milestones', icon: 'gift' },
  { title: 'Insurance Coverage', description: 'Stay protected while you deliver', icon: 'shield' },
  { title: '24/7 Support', description: 'We are always here to help you', icon: 'headphones' },
]

export const TESTIMONIALS = [
  {
    name: 'Rahul Sharma',
    location: 'Ahmedabad',
    rating: 5,
    text: 'Super fast delivery! My documents reached in just 30 minutes. The tracking feature is amazing.',
    avatar: '/images/testimonials/user1.jpg',
    type: 'user',
  },
  {
    name: 'Priya Patel',
    location: 'Gandhinagar',
    rating: 5,
    text: 'I use SendIt for my small business deliveries daily. Reliable and affordable!',
    avatar: '/images/testimonials/user2.jpg',
    type: 'user',
  },
  {
    name: 'Ankit Kothiya',
    location: 'Ahmedabad',
    rating: 5,
    text: 'Earning ₹20,000+ monthly with flexible hours. Best decision to join as a pilot!',
    avatar: '/images/testimonials/pilot1.jpg',
    type: 'pilot',
  },
]
