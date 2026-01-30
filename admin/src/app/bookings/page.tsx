'use client'

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, MoreHorizontal, Eye, UserPlus, XCircle, MapPin } from 'lucide-react'
import { AdminLayout } from '@/components/layout/admin-layout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'
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
import type { Booking, BookingStatus, Pilot, PaginationMeta } from '@/types'
import { format } from 'date-fns'

const statusColors: Record<BookingStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  PENDING: 'secondary',
  SEARCHING: 'outline',
  CONFIRMED: 'default',
  PILOT_ARRIVED: 'default',
  PICKED_UP: 'default',
  IN_TRANSIT: 'default',
  DELIVERED: 'default',
  CANCELLED: 'destructive',
}

export default function BookingsPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null)
  const [isViewOpen, setIsViewOpen] = useState(false)
  const [isCancelOpen, setIsCancelOpen] = useState(false)
  const [isAssignOpen, setIsAssignOpen] = useState(false)
  const [cancelReason, setCancelReason] = useState('')
  const [selectedPilotId, setSelectedPilotId] = useState('')

  const { data, isLoading } = useQuery({
    queryKey: ['bookings', page, search, statusFilter],
    queryFn: () =>
      adminApi.listBookings({
        page,
        limit: 10,
        search: search || undefined,
        status: statusFilter === 'all' ? undefined : statusFilter,
      }),
  })

  const { data: pilotsData } = useQuery({
    queryKey: ['pilots-available'],
    queryFn: () => adminApi.listPilots({ status: 'APPROVED', online: true, limit: 50 }),
    enabled: isAssignOpen,
  })

  const bookings = (data?.data as { bookings: Booking[] })?.bookings || []
  const meta = data?.meta as PaginationMeta
  const availablePilots = (pilotsData?.data as { pilots: Pilot[] })?.pilots || []

  const cancelMutation = useMutation({
    mutationFn: ({ bookingId, reason }: { bookingId: string; reason: string }) =>
      adminApi.cancelBooking(bookingId, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['bookings'] })
      setIsCancelOpen(false)
      setCancelReason('')
    },
  })

  const assignMutation = useMutation({
    mutationFn: ({ bookingId, pilotId }: { bookingId: string; pilotId: string }) =>
      adminApi.assignPilot(bookingId, pilotId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['bookings'] })
      setIsAssignOpen(false)
      setSelectedPilotId('')
    },
  })

  const handleView = async (bookingId: string) => {
    const response = await adminApi.getBookingDetails(bookingId)
    setSelectedBooking((response.data as { booking: Booking }).booking)
    setIsViewOpen(true)
  }

  const openCancelDialog = (booking: Booking) => {
    setSelectedBooking(booking)
    setIsCancelOpen(true)
  }

  const openAssignDialog = (booking: Booking) => {
    setSelectedBooking(booking)
    setIsAssignOpen(true)
  }

  const canCancel = (status: BookingStatus) =>
    ['PENDING', 'SEARCHING', 'CONFIRMED'].includes(status)

  const canAssign = (status: BookingStatus) =>
    ['PENDING', 'SEARCHING'].includes(status)

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Bookings</h1>
          <p className="text-muted-foreground">Manage delivery bookings</p>
        </div>

        {/* Filters */}
        <div className="flex flex-col gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search by booking ID or address..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value)
                setPage(1)
              }}
              className="pl-9"
            />
          </div>
          <Tabs value={statusFilter} onValueChange={(v) => { setStatusFilter(v); setPage(1) }} className="overflow-x-auto">
            <TabsList className="inline-flex">
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="PENDING">Pending</TabsTrigger>
              <TabsTrigger value="SEARCHING">Searching</TabsTrigger>
              <TabsTrigger value="CONFIRMED">Confirmed</TabsTrigger>
              <TabsTrigger value="IN_TRANSIT">In Transit</TabsTrigger>
              <TabsTrigger value="DELIVERED">Delivered</TabsTrigger>
              <TabsTrigger value="CANCELLED">Cancelled</TabsTrigger>
            </TabsList>
          </Tabs>
        </div>

        {/* Table */}
        <div className="border rounded-lg overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>ID</TableHead>
                <TableHead>Pickup</TableHead>
                <TableHead>Dropoff</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Price</TableHead>
                <TableHead>Created</TableHead>
                <TableHead className="w-[80px]">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8">
                    Loading...
                  </TableCell>
                </TableRow>
              ) : bookings.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8">
                    No bookings found
                  </TableCell>
                </TableRow>
              ) : (
                bookings.map((booking) => (
                  <TableRow key={booking.id}>
                    <TableCell className="font-mono text-sm">
                      #{booking.id.slice(0, 8)}
                    </TableCell>
                    <TableCell>
                      <div className="max-w-[200px] truncate" title={booking.pickupAddress}>
                        {booking.pickupAddress}
                      </div>
                    </TableCell>
                    <TableCell>
                      <div className="max-w-[200px] truncate" title={booking.dropoffAddress}>
                        {booking.dropoffAddress}
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant={statusColors[booking.status]}>{booking.status}</Badge>
                    </TableCell>
                    <TableCell>₹{booking.finalPrice || booking.estimatedPrice}</TableCell>
                    <TableCell>{format(new Date(booking.createdAt), 'MMM d, HH:mm')}</TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleView(booking.id)}>
                            <Eye className="mr-2 h-4 w-4" />
                            View Details
                          </DropdownMenuItem>
                          {canAssign(booking.status) && (
                            <DropdownMenuItem onClick={() => openAssignDialog(booking)}>
                              <UserPlus className="mr-2 h-4 w-4" />
                              Assign Pilot
                            </DropdownMenuItem>
                          )}
                          {canCancel(booking.status) && (
                            <>
                              <DropdownMenuSeparator />
                              <DropdownMenuItem
                                onClick={() => openCancelDialog(booking)}
                                className="text-destructive"
                              >
                                <XCircle className="mr-2 h-4 w-4" />
                                Cancel Booking
                              </DropdownMenuItem>
                            </>
                          )}
                        </DropdownMenuContent>
                      </DropdownMenu>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </div>

        {/* Pagination */}
        {meta && (
          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, meta.total)} of {meta.total} bookings
            </p>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={page === 1}
                onClick={() => setPage(page - 1)}
              >
                Previous
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={page >= meta.totalPages}
                onClick={() => setPage(page + 1)}
              >
                Next
              </Button>
            </div>
          </div>
        )}

        {/* View Dialog */}
        <Dialog open={isViewOpen} onOpenChange={setIsViewOpen}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Booking Details</DialogTitle>
            </DialogHeader>
            {selectedBooking && (
              <div className="space-y-6">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label className="text-muted-foreground">Booking ID</Label>
                    <p className="font-mono">{selectedBooking.id}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Status</Label>
                    <p>
                      <Badge variant={statusColors[selectedBooking.status]}>
                        {selectedBooking.status}
                      </Badge>
                    </p>
                  </div>
                </div>

                <div className="space-y-3">
                  <div className="flex items-start gap-3 p-3 bg-green-50 dark:bg-green-950/30 rounded-lg">
                    <MapPin className="h-5 w-5 text-green-600 mt-0.5" />
                    <div>
                      <Label className="text-muted-foreground text-xs">Pickup</Label>
                      <p className="font-medium">{selectedBooking.pickupAddress}</p>
                    </div>
                  </div>
                  <div className="flex items-start gap-3 p-3 bg-red-50 dark:bg-red-950/30 rounded-lg">
                    <MapPin className="h-5 w-5 text-red-600 mt-0.5" />
                    <div>
                      <Label className="text-muted-foreground text-xs">Dropoff</Label>
                      <p className="font-medium">{selectedBooking.dropoffAddress}</p>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div>
                    <Label className="text-muted-foreground">Distance</Label>
                    <p className="font-medium">{selectedBooking.distance} km</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Duration</Label>
                    <p className="font-medium">{selectedBooking.duration} min</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Estimated Price</Label>
                    <p className="font-medium">₹{selectedBooking.estimatedPrice}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Final Price</Label>
                    <p className="font-medium">
                      {selectedBooking.finalPrice ? `₹${selectedBooking.finalPrice}` : '-'}
                    </p>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label className="text-muted-foreground">Payment Method</Label>
                    <p className="font-medium">{selectedBooking.paymentMethod}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Payment Status</Label>
                    <p>
                      <Badge
                        variant={
                          selectedBooking.paymentStatus === 'COMPLETED' ? 'default' : 'secondary'
                        }
                      >
                        {selectedBooking.paymentStatus}
                      </Badge>
                    </p>
                  </div>
                </div>

                {selectedBooking.user && (
                  <div>
                    <Label className="text-muted-foreground">Customer</Label>
                    <p className="font-medium">{selectedBooking.user.name}</p>
                    <p className="text-sm text-muted-foreground">{selectedBooking.user.phone}</p>
                  </div>
                )}

                {selectedBooking.pilot && (
                  <div>
                    <Label className="text-muted-foreground">Pilot</Label>
                    <p className="font-medium">{selectedBooking.pilot.name}</p>
                    <p className="text-sm text-muted-foreground">{selectedBooking.pilot.phone}</p>
                  </div>
                )}

                {selectedBooking.cancelReason && (
                  <div>
                    <Label className="text-muted-foreground">Cancellation Reason</Label>
                    <p className="text-destructive">{selectedBooking.cancelReason}</p>
                  </div>
                )}
              </div>
            )}
          </DialogContent>
        </Dialog>

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
                className="w-full min-h-[100px] rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
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
                  if (selectedBooking && cancelReason.length >= 10) {
                    cancelMutation.mutate({ bookingId: selectedBooking.id, reason: cancelReason })
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
                      className={`p-3 border rounded-lg cursor-pointer transition-colors ${
                        selectedPilotId === pilot.id
                          ? 'border-primary bg-primary/5'
                          : 'hover:bg-muted'
                      }`}
                      onClick={() => setSelectedPilotId(pilot.id)}
                    >
                      <p className="font-medium">{pilot.name}</p>
                      <p className="text-sm text-muted-foreground">
                        {pilot.rating.toFixed(1)} ⭐ • {pilot.totalDeliveries ?? pilot.totalRides ?? 0} deliveries
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
                  if (selectedBooking && selectedPilotId) {
                    assignMutation.mutate({ bookingId: selectedBooking.id, pilotId: selectedPilotId })
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
