import { cn } from '@/lib/utils'

interface ContainerProps extends React.HTMLAttributes<HTMLDivElement> {
  size?: 'default' | 'sm' | 'lg' | 'full'
}

function Container({ className, size = 'default', children, ...props }: ContainerProps) {
  const sizes = {
    sm: 'max-w-4xl',
    default: 'max-w-7xl',
    lg: 'max-w-[1400px]',
    full: 'max-w-full',
  }

  return (
    <div
      className={cn('mx-auto px-4 sm:px-6 lg:px-8', sizes[size], className)}
      {...props}
    >
      {children}
    </div>
  )
}

export { Container }
