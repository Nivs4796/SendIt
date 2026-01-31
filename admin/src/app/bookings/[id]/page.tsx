'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { useQuery } from '@tanstack/react-query'
import dynamic from 'next/dynamic'
import { ArrowLeft, RefreshCw, UserPlus, XCircle } from 'lucide-react'
import { AdminLayout } from '@/components/layout/admin-layout'
import { Button } from '@/components/ui/button'
import {
  BookingStatusCard,
  BookingAddressCard,
  BookingPricingCard,
  BookingCustomerCard,
  BookingPilotCard,
  BookingCancellationCard,
} from '@/components/booking/booking-info'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Label } from '@/components/ui/label'
import { adminApi } from '@/lib/api'
import { useSocket } from '@/lib/socket'
import type { Booking, BookingStatus, Pilot, BookingAddress } from '@/types'
import { toast } from 'sonner'
import { useMutation, useQueryClient } from '@tanstack/react-query'

// Dynamically import the map component to avoid SSR issues with Leaflet
const TrackingMap = dynamic(
  () => import('@/components/booking/tracking-map').then((mod) => mod.TrackingMap),
  {
    ssr: false,
    loading: () => (
      <div className="w-full h-[400px] rounded-xl bg-muted/30 flex items-center justify-center">
        <div className="text-muted-foreground">Loading map...</div>
      </div>
    ),
  }
)

// Helper to get coordinates from address
const getCoordinates = (
  booking: Booking
): { pickupLat: number; pickupLng: number; dropoffLat: number; dropoffLng: number } => {
  let pickupLat = booking.pickupLat
  let pickupLng = booking.pickupLng
  let dropoffLat = booking.dropoffLat
  let dropoffLng = booking.dropoffLng

  // Try to get from address objects if direct coords not available
  if ((!pickupLat || !pickupLng) && booking.pickupAddress && typeof booking.pickupAddress === 'object') {
    const addr = booking.pickupAddress as BookingAddress
    pickupLat = addr.lat || 0
    pickupLng = addr.lng || 0
  }

  if ((!dropoffLat || !dropoffLng) && booking.dropoffAddress && typeof booking.dropoffAddress === 'object') {
    const addr = booking.dropoffAddress as BookingAddress
    dropoffLat = addr.lat || 0
    dropoffLng = addr.lng || 0
  }

  return { pickupLat, pickupLng, dropoffLat, dropoffLng }
}

export default function BookingDetailsPage() {
  const params = useParams()
  const router = useRouter()
  const queryClient = useQueryClient()
  const { socket, isConnected } = useSocket()
  const bookingId = params.id as string

  const [pilotLocation, setPilotLocation] = useState<{ lat: number; lng: number } | null>(null)
  const [isCancelOpen, setIsCancelOpen] = useState(false)
  const [isAssignOpen, setIsAssignOpen] = useState(false)
  const [cancelReason, setCancelReason] = useState('')
  const [selectedPilotId, setSelectedPilotId] = useState('')

  // Fetch booking details
  const { data, isLoading, error, refetch } = useQuery({
    queryKey: ['booking', bookingId],
    queryFn: () => adminApi.getBookingDetails(bookingId),
    refetchInterval: 30000, // Refresh every 30 seconds
  })

  const booking = (data?.data as { booking: Booking })?.booking

  // Fetch available pilots for assignment
  const { data: pilotsData } = useQuery({
    queryKey: ['pilots-available'],
    queryFn: () => adminApi.listPilots({ status: 'APPROVED', online: true, limit: 50 }),
    enabled: isAssignOpen,
  })

  const availablePilots = (pilotsData?.data as { pilots: Pilot[] })?.pilots || []

  // Cancel mutation
  const cancelMutation = useMutation({
    mutationFn: ({ bookingId, reason }: { bookingId: string; reason: string }) =>
      adminApi.cancelBooking(bookingId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['booking', bookingId] })
      setIsCancelOpen(false)
      setCancelReason('')
      toast.success('Booking cancelled')
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Failed to cancel booking')
    },
  })

  // Assign mutation
  const assignMutation = useMutation({
    mutationFn: ({ bookingId, pilotId }: { bookingId: string; pilotId: string }) =>
      adminApi.assignPilot(bookingId, pilotId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['booking', bookingId] })
      setIsAssignOpen(false)
      setSelectedPilotId('')
      toast.success('Pilot assigned successfully')
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Failed to assign pilot')
    },
  })

  // Subscribe to booking updates via socket
  useEffect(() => {
    if (!socket || !isConnected || !bookingId) return

    // Subscribe to this booking's updates
    socket.emit('admin:booking:subscribe', { bookingId })

    // Listen for location updates
    const handleLocationUpdate = (data: { bookingId: string; lat: number; lng: number }) => {
      if (data.bookingId === bookingId) {
        setPilotLocation({ lat: data.lat, lng: data.lng })
      }
    }

    // Listen for booking updates
    const handleBookingUpdate = (updatedBooking: Booking) => {
      if (updatedBooking.id === bookingId) {
        queryClient.setQueryData(['booking', bookingId], {
          ...data,
          data: { booking: updatedBooking },
        })
      }
    }

    socket.on('booking:location', handleLocationUpdate)
    socket.on('booking:updated', handleBookingUpdate)

    return () => {
      socket.emit('admin:booking:unsubscribe', { bookingId })
      socket.off('booking:location', handleLocationUpdate)
      socket.off('booking:updated', handleBookingUpdate)
    }
  }, [socket, isConnected, bookingId, queryClient, data])

  // Update pilot location from booking data
  useEffect(() => {
    if (booking?.pilot?.currentLat && booking?.pilot?.currentLng) {
      setPilotLocation({
        lat: booking.pilot.currentLat,
        lng: booking.pilot.currentLng,
      })
    }
  }, [booking?.pilot?.currentLat, booking?.pilot?.currentLng])

  const canCancel = (status: BookingStatus) =>
    ['PENDING', 'SEARCHING', 'ACCEPTED', 'CONFIRMED'].includes(status)

  const canAssign = (status: BookingStatus) => ['PENDING', 'SEARCHING'].includes(status)

  if (isLoading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center h-96">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        </div>
      </AdminLayout>
    )
  }

  if (error || !booking) {
    return (
      <AdminLayout>
        <div className="flex flex-col items-center justify-center h-96 gap-4">
          <p className="text-muted-foreground">Failed to load booking details</p>
          <Button variant="outline" onClick={() => router.push('/bookings')}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Bookings
          </Button>
        </div>
      </AdminLayout>
    )
  }

  const coords = getCoordinates(booking)
  const hasValidCoords = coords.pickupLat && coords.pickupLng && coords.dropoffLat && coords.dropoffLng
  const useDemoMode = !hasValidCoords

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => router.push('/bookings')}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-2xl font-bold">Booking Details</h1>
              <p className="text-muted-foreground font-mono">#{booking.id.slice(0, 8)}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm" onClick={() => refetch()}>
              <RefreshCw className="mr-2 h-4 w-4" />
              Refresh
            </Button>
            {canAssign(booking.status) && (
              <Button variant="outline" size="sm" onClick={() => setIsAssignOpen(true)}>
                <UserPlus className="mr-2 h-4 w-4" />
                Assign Pilot
              </Button>
            )}
            {canCancel(booking.status) && (
              <Button variant="destructive" size="sm" onClick={() => setIsCancelOpen(true)}>
                <XCircle className="mr-2 h-4 w-4" />
                Cancel
              </Button>
            )}
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Map Section */}
          <div className="lg:col-span-2 space-y-6">
            <div className="glass-card rounded-xl overflow-hidden">
              <div className="p-4 border-b border-border/50">
                <h2 className="font-semibold flex items-center gap-2">
                  Live Tracking
                  {useDemoMode ? (
                    <span className="flex items-center gap-1 text-xs text-amber-500 font-normal">
                      <span className="w-2 h-2 rounded-full bg-amber-500 animate-pulse" />
                      Demo
                    </span>
                  ) : isConnected && pilotLocation ? (
                    <span className="flex items-center gap-1 text-xs text-primary font-normal">
                      <span className="w-2 h-2 rounded-full bg-primary animate-pulse" />
                      Live
                    </span>
                  ) : null}
                </h2>
              </div>
              <div style={{ height: '500px' }} className="relative">
                <TrackingMap
                  pickupLat={coords.pickupLat}
                  pickupLng={coords.pickupLng}
                  dropoffLat={coords.dropoffLat}
                  dropoffLng={coords.dropoffLng}
                  pilotLat={pilotLocation?.lat}
                  pilotLng={pilotLocation?.lng}
                  demoMode={useDemoMode}
                />
              </div>
            </div>

            {/* Pilot Card on larger screens */}
            <div className="hidden lg:block">
              <BookingPilotCard booking={booking} />
            </div>
          </div>

          {/* Info Cards */}
          <div className="space-y-4">
            <BookingStatusCard booking={booking} />
            <BookingAddressCard booking={booking} />
            <BookingPricingCard booking={booking} />
            <BookingCustomerCard booking={booking} />
            {/* Pilot Card on mobile */}
            <div className="lg:hidden">
              <BookingPilotCard booking={booking} />
            </div>
            <BookingCancellationCard booking={booking} />
          </div>
        </div>

        {/* Cancel Dialog */}
        <Dialog open={isCancelOpen} onOpenChange={setIsCancelOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Cancel Booking</DialogTitle>
              <DialogDescription>
                Please provide a reason for cancelling this booking.
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-2">
              <Label htmlFor="cancelReason">Reason</Label>
              <textarea
                id="cancelReason"
                className="w-full min-h-[100px] rounded-xl border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary/50 focus-visible:ring-offset-2"
                placeholder="Enter cancellation reason (min 10 characters)..."
                value={cancelReason}
                onChange={(e) => setCancelReason(e.target.value)}
              />
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsCancelOpen(false)}>
                Keep Booking
              </Button>
              <Button
                variant="destructive"
                onClick={() => {
                  if (cancelReason.length >= 10) {
                    cancelMutation.mutate({ bookingId: booking.id, reason: cancelReason })
                  }
                }}
                disabled={cancelReason.length < 10 || cancelMutation.isPending}
              >
                {cancelMutation.isPending ? 'Cancelling...' : 'Cancel Booking'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Assign Pilot Dialog */}
        <Dialog open={isAssignOpen} onOpenChange={setIsAssignOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Assign Pilot</DialogTitle>
              <DialogDescription>Select an available pilot for this booking.</DialogDescription>
            </DialogHeader>
            <div className="space-y-2">
              <Label>Available Pilots</Label>
              <div className="max-h-[300px] overflow-y-auto space-y-2">
                {availablePilots.length === 0 ? (
                  <p className="text-muted-foreground text-center py-4">No pilots available</p>
                ) : (
                  availablePilots.map((pilot) => (
                    <div
                      key={pilot.id}
                      className={`p-3 border rounded-xl cursor-pointer transition-colors ${
                        selectedPilotId === pilot.id
                          ? 'border-primary bg-primary/5'
                          : 'hover:bg-muted/50'
                      }`}
                      onClick={() => setSelectedPilotId(pilot.id)}
                    >
                      <p className="font-medium">{pilot.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {pilot.rating.toFixed(1)} ⭐ • {pilot.totalDeliveries ?? pilot.totalRides ?? 0}{' '}
                        deliveries
                      </p>
                    </div>
                  ))
                )}
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsAssignOpen(false)}>
                Cancel
              </Button>
              <Button
                onClick={() => {
                  if (selectedPilotId) {
                    assignMutation.mutate({ bookingId: booking.id, pilotId: selectedPilotId })
                  }
                }}
                disabled={!selectedPilotId || assignMutation.isPending}
              >
                {assignMutation.isPending ? 'Assigning...' : 'Assign Pilot'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  )
}
