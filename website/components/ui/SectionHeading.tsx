import { cn } from '@/lib/utils'

interface SectionHeadingProps {
  title: string
  subtitle?: string
  badge?: string
  align?: 'left' | 'center'
  className?: string
}

function SectionHeading({
  title,
  subtitle,
  badge,
  align = 'center',
  className
}: SectionHeadingProps) {
  return (
    <div className={cn(
      'mb-12',
      align === 'center' && 'text-center',
      className
    )}>
      {badge && (
        <span className="inline-block px-4 py-1.5 bg-primary-100 text-primary-700 text-sm font-semibold rounded-full mb-4">
          {badge}
        </span>
      )}
      <h2 className="text-3xl md:text-4xl lg:text-5xl font-bold text-secondary-900 tracking-tight">
        {title}
      </h2>
      {subtitle && (
        <p className="mt-4 text-lg text-secondary-500 max-w-2xl mx-auto">
          {subtitle}
        </p>
      )}
    </div>
  )
}

export { SectionHeading }
