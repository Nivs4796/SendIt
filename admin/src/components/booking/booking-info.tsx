'use client'

import { MapPin, Clock, Route, CreditCard, User, Truck, Phone, Mail, Calendar, Package } from 'lucide-react'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import type { Booking, BookingStatus } from '@/types'
import { format } from 'date-fns'

const statusColors: Record<BookingStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  PENDING: 'secondary',
  SEARCHING: 'outline',
  ACCEPTED: 'default',
  CONFIRMED: 'default',
  PILOT_ARRIVED: 'default',
  PICKED_UP: 'default',
  IN_TRANSIT: 'default',
  DELIVERED: 'default',
  CANCELLED: 'destructive',
}

const statusLabels: Record<BookingStatus, string> = {
  PENDING: 'Pending',
  SEARCHING: 'Searching for Pilot',
  ACCEPTED: 'Pilot Accepted',
  CONFIRMED: 'Confirmed',
  PILOT_ARRIVED: 'Pilot Arrived',
  PICKED_UP: 'Picked Up',
  IN_TRANSIT: 'In Transit',
  DELIVERED: 'Delivered',
  CANCELLED: 'Cancelled',
}

interface BookingInfoProps {
  booking: Booking
}

// Helper to format address object to string
const formatAddress = (addr: { address?: string; city?: string; state?: string; pincode?: string } | string | null | undefined): string => {
  if (!addr) return 'N/A'
  if (typeof addr === 'string') return addr
  const parts = [addr.address, addr.city, addr.state, addr.pincode].filter(Boolean)
  return parts.join(', ') || 'N/A'
}

export function BookingStatusCard({ booking }: BookingInfoProps) {
  return (
    <Card className="glass-card">
      <CardHeader className="pb-3">
        <CardTitle className="text-lg flex items-center justify-between">
          <span>Status</span>
          <Badge variant={statusColors[booking.status]} className="text-sm">
            {statusLabels[booking.status]}
          </Badge>
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Package className="h-4 w-4" />
          <span>Booking ID:</span>
          <span className="font-mono text-foreground">#{booking.id.slice(0, 8)}</span>
        </div>
        <div className="flex items-center gap-2 text-sm text-muted-foreground">
          <Calendar className="h-4 w-4" />
          <span>Created:</span>
          <span className="text-foreground">{format(new Date(booking.createdAt), 'MMM d, yyyy HH:mm')}</span>
        </div>
      </CardContent>
    </Card>
  )
}

export function BookingAddressCard({ booking }: BookingInfoProps) {
  return (
    <Card className="glass-card">
      <CardHeader className="pb-3">
        <CardTitle className="text-lg">Route Details</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-start gap-3 p-3 bg-primary/5 rounded-lg border border-primary/20">
          <div className="w-8 h-8 rounded-full bg-primary/20 flex items-center justify-center flex-shrink-0">
            <MapPin className="h-4 w-4 text-primary" />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs text-muted-foreground uppercase tracking-wide">Pickup</p>
            <p className="font-medium text-sm mt-0.5">{formatAddress(booking.pickupAddress)}</p>
          </div>
        </div>

        <div className="flex items-start gap-3 p-3 bg-destructive/5 rounded-lg border border-destructive/20">
          <div className="w-8 h-8 rounded-full bg-destructive/20 flex items-center justify-center flex-shrink-0">
            <MapPin className="h-4 w-4 text-destructive" />
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-xs text-muted-foreground uppercase tracking-wide">Dropoff</p>
            <p className="font-medium text-sm mt-0.5">{formatAddress(booking.dropoffAddress)}</p>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-3 pt-2">
          <div className="flex items-center gap-2 text-sm">
            <Route className="h-4 w-4 text-muted-foreground" />
            <span className="text-muted-foreground">Distance:</span>
            <span className="font-medium">{booking.distance} km</span>
          </div>
          <div className="flex items-center gap-2 text-sm">
            <Clock className="h-4 w-4 text-muted-foreground" />
            <span className="text-muted-foreground">Duration:</span>
            <span className="font-medium">{booking.duration} min</span>
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

export function BookingPricingCard({ booking }: BookingInfoProps) {
  return (
    <Card className="glass-card">
      <CardHeader className="pb-3">
        <CardTitle className="text-lg">Pricing & Payment</CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <div className="flex items-center justify-between text-sm">
          <span className="text-muted-foreground">Estimated Price</span>
          <span className="font-medium">₹{booking.estimatedPrice}</span>
        </div>
        {booking.finalPrice && (
          <div className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">Final Price</span>
            <span className="font-semibold text-primary">₹{booking.finalPrice}</span>
          </div>
        )}
        <div className="h-px bg-border my-2" />
        <div className="flex items-center justify-between text-sm">
          <div className="flex items-center gap-2">
            <CreditCard className="h-4 w-4 text-muted-foreground" />
            <span className="text-muted-foreground">Payment Method</span>
          </div>
          <Badge variant="outline">{booking.paymentMethod}</Badge>
        </div>
        <div className="flex items-center justify-between text-sm">
          <span className="text-muted-foreground">Payment Status</span>
          <Badge variant={booking.paymentStatus === 'COMPLETED' ? 'default' : 'secondary'}>
            {booking.paymentStatus}
          </Badge>
        </div>
      </CardContent>
    </Card>
  )
}

export function BookingCustomerCard({ booking }: BookingInfoProps) {
  if (!booking.user) return null

  return (
    <Card className="glass-card">
      <CardHeader className="pb-3">
        <CardTitle className="text-lg flex items-center gap-2">
          <User className="h-5 w-5" />
          Customer
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center">
            <User className="h-5 w-5 text-primary" />
          </div>
          <div>
            <p className="font-medium">{booking.user.name || 'Unknown'}</p>
            <p className="text-sm text-muted-foreground">Customer</p>
          </div>
        </div>
        <div className="space-y-2 pt-2">
          <div className="flex items-center gap-2 text-sm">
            <Phone className="h-4 w-4 text-muted-foreground" />
            <span>{booking.user.phone}</span>
          </div>
          {booking.user.email && (
            <div className="flex items-center gap-2 text-sm">
              <Mail className="h-4 w-4 text-muted-foreground" />
              <span>{booking.user.email}</span>
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  )
}

export function BookingPilotCard({ booking }: BookingInfoProps) {
  if (!booking.pilot) {
    return (
      <Card className="glass-card">
        <CardHeader className="pb-3">
          <CardTitle className="text-lg flex items-center gap-2">
            <Truck className="h-5 w-5" />
            Pilot
          </CardTitle>
        </CardHeader>
        <CardContent>
          <p className="text-muted-foreground text-sm">No pilot assigned yet</p>
        </CardContent>
      </Card>
    )
  }

  return (
    <Card className="glass-card">
      <CardHeader className="pb-3">
        <CardTitle className="text-lg flex items-center gap-2">
          <Truck className="h-5 w-5" />
          Pilot
        </CardTitle>
      </CardHeader>
      <CardContent className="space-y-3">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-blue-500/20 flex items-center justify-center">
            <Truck className="h-5 w-5 text-blue-500" />
          </div>
          <div className="flex-1">
            <p className="font-medium">{booking.pilot.name}</p>
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <span>{booking.pilot.rating?.toFixed(1) || '0.0'} ⭐</span>
              <span>•</span>
              <span>{booking.pilot.totalDeliveries || booking.pilot.totalRides || 0} deliveries</span>
            </div>
          </div>
          {booking.pilot.isOnline && (
            <div className="w-3 h-3 rounded-full bg-green-500 animate-pulse" title="Online" />
          )}
        </div>
        <div className="space-y-2 pt-2">
          <div className="flex items-center gap-2 text-sm">
            <Phone className="h-4 w-4 text-muted-foreground" />
            <span>{booking.pilot.phone}</span>
          </div>
        </div>
        {booking.pilot.currentLat && booking.pilot.currentLng && (
          <div className="mt-3 p-2 bg-blue-500/10 rounded-lg border border-blue-500/20">
            <p className="text-xs text-blue-500 flex items-center gap-1">
              <span className="w-2 h-2 rounded-full bg-blue-500 animate-pulse" />
              Live tracking active
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export function BookingCancellationCard({ booking }: BookingInfoProps) {
  if (booking.status !== 'CANCELLED' || !booking.cancelReason) return null

  return (
    <Card className="glass-card border-destructive/30">
      <CardHeader className="pb-3">
        <CardTitle className="text-lg text-destructive">Cancellation Details</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-sm">{booking.cancelReason}</p>
      </CardContent>
    </Card>
  )
}
