'use client'

import { useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { ArrowLeft, CheckCircle, XCircle, Edit, FileText, ExternalLink } from 'lucide-react'
import { AdminLayout } from '@/components/layout/admin-layout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@/components/ui/tabs'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
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
import type { Pilot, PilotStatus, Booking, BookingStatus } from '@/types'
import { format } from 'date-fns'
import { toast } from 'sonner'

const statusColors: Record<PilotStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  PENDING: 'outline',
  APPROVED: 'default',
  REJECTED: 'destructive',
  SUSPENDED: 'outline',
}

const pilotStatusClassName: Partial<Record<PilotStatus, string>> = {
  PENDING: 'border-yellow-500/50 bg-yellow-500/10 text-yellow-600 dark:text-yellow-400',
}

const bookingStatusVariant: Record<BookingStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  PENDING: 'outline',
  ACCEPTED: 'default',
  ARRIVED_PICKUP: 'default',
  PICKED_UP: 'default',
  IN_TRANSIT: 'default',
  ARRIVED_DROP: 'default',
  DELIVERED: 'default',
  CANCELLED: 'destructive',
}

const bookingStatusClassName: Partial<Record<BookingStatus, string>> = {
  PENDING: 'border-yellow-500/50 bg-yellow-500/10 text-yellow-600 dark:text-yellow-400',
}

export default function PilotDetailsPage() {
  const params = useParams()
  const router = useRouter()
  const queryClient = useQueryClient()
  const pilotId = params.id as string

  const [activeTab, setActiveTab] = useState('overview')
  const [docRejectReason, setDocRejectReason] = useState('')
  const [rejectingDocId, setRejectingDocId] = useState<string | null>(null)
  const [vehicleRejectReason, setVehicleRejectReason] = useState('')
  const [rejectingVehicleId, setRejectingVehicleId] = useState<string | null>(null)

  // Status dialog
  const [isStatusDialogOpen, setIsStatusDialogOpen] = useState(false)
  const [statusAction, setStatusAction] = useState<{ status: PilotStatus; reason: string }>({
    status: 'APPROVED',
    reason: '',
  })

  // Edit dialog
  const [isEditOpen, setIsEditOpen] = useState(false)
  const [editForm, setEditForm] = useState({ name: '', email: '', phone: '' })

  // Fetch pilot details
  const { data, isLoading, error } = useQuery({
    queryKey: ['pilot', pilotId],
    queryFn: () => adminApi.getPilotDetails(pilotId),
  })

  const pilot = (data?.data as { pilot: Pilot })?.pilot

  // Fetch pilot bookings
  const { data: pilotBookingsData } = useQuery({
    queryKey: ['pilot-bookings', pilotId],
    queryFn: () => adminApi.listBookings({ pilotId, limit: 10 }),
    enabled: activeTab === 'bookings',
  })
  const pilotBookings = (pilotBookingsData?.data as { bookings: Booking[] })?.bookings || []

  // Mutations
  const updateStatusMutation = useMutation({
    mutationFn: ({ pilotId, status, reason }: { pilotId: string; status: string; reason?: string }) =>
      adminApi.updatePilotStatus(pilotId, status, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pilot', pilotId] })
      queryClient.invalidateQueries({ queryKey: ['pilots'] })
      setIsStatusDialogOpen(false)
      toast.success('Pilot status updated')
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Failed to update pilot status')
    },
  })

  const updatePilotMutation = useMutation({
    mutationFn: ({ pilotId, data }: { pilotId: string; data: { name?: string; email?: string; phone?: string } }) =>
      adminApi.updatePilot(pilotId, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pilot', pilotId] })
      queryClient.invalidateQueries({ queryKey: ['pilots'] })
      setIsEditOpen(false)
      toast.success('Pilot updated successfully')
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Failed to update pilot')
    },
  })

  const verifyDocMutation = useMutation({
    mutationFn: ({ docId, status, reason }: { docId: string; status: 'APPROVED' | 'REJECTED'; reason?: string }) =>
      adminApi.verifyDocument(docId, status, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pilot', pilotId] })
      queryClient.invalidateQueries({ queryKey: ['pilots'] })
      setRejectingDocId(null)
      setDocRejectReason('')
      toast.success('Document verification updated')
    },
    onError: (e: Error) => toast.error(e.message),
  })

  const verifyVehicleMutation = useMutation({
    mutationFn: ({ vehicleId, isVerified, reason }: { vehicleId: string; isVerified: boolean; reason?: string }) =>
      adminApi.verifyVehicle(vehicleId, isVerified, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pilot', pilotId] })
      queryClient.invalidateQueries({ queryKey: ['pilots'] })
      setRejectingVehicleId(null)
      setVehicleRejectReason('')
      toast.success('Vehicle verification updated')
    },
    onError: (e: Error) => toast.error(e.message),
  })

  const openStatusDialog = (status: PilotStatus) => {
    setStatusAction({ status, reason: '' })
    setIsStatusDialogOpen(true)
  }

  const handleStatusUpdate = () => {
    if (pilot) {
      updateStatusMutation.mutate({
        pilotId: pilot.id,
        status: statusAction.status,
        reason: statusAction.reason || undefined,
      })
    }
  }

  const handleEdit = () => {
    if (pilot) {
      setEditForm({ name: pilot.name || '', email: pilot.email || '', phone: pilot.phone || '' })
      setIsEditOpen(true)
    }
  }

  const handleSaveEdit = () => {
    if (pilot) {
      const changes: { name?: string; email?: string; phone?: string } = {}
      if (editForm.name !== pilot.name) changes.name = editForm.name
      if (editForm.email !== pilot.email) changes.email = editForm.email
      if (editForm.phone !== pilot.phone) changes.phone = editForm.phone

      if (Object.keys(changes).length > 0) {
        updatePilotMutation.mutate({ pilotId: pilot.id, data: changes })
      } else {
        setIsEditOpen(false)
      }
    }
  }

  if (isLoading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center h-96">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        </div>
      </AdminLayout>
    )
  }

  if (error || !pilot) {
    return (
      <AdminLayout>
        <div className="flex flex-col items-center justify-center h-96 gap-4">
          <p className="text-muted-foreground">Failed to load pilot details</p>
          <Button variant="outline" onClick={() => router.push('/pilots')}>
            <ArrowLeft className="mr-2 h-4 w-4" />
            Back to Pilots
          </Button>
        </div>
      </AdminLayout>
    )
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <Button variant="ghost" size="icon" onClick={() => router.push('/pilots')}>
              <ArrowLeft className="h-5 w-5" />
            </Button>
            <div>
              <h1 className="text-2xl font-bold">{pilot.name}</h1>
              <p className="text-muted-foreground">{pilot.email || pilot.phone}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <Button variant="outline" size="sm" onClick={handleEdit}>
              <Edit className="mr-2 h-4 w-4" />
              Edit
            </Button>
            {pilot.status === 'PENDING' && (
              <>
                <Button size="sm" onClick={() => openStatusDialog('APPROVED')}>
                  <CheckCircle className="mr-2 h-4 w-4" />
                  Approve
                </Button>
                <Button variant="destructive" size="sm" onClick={() => openStatusDialog('REJECTED')}>
                  <XCircle className="mr-2 h-4 w-4" />
                  Reject
                </Button>
              </>
            )}
            {pilot.status === 'APPROVED' && (
              <Button variant="destructive" size="sm" onClick={() => openStatusDialog('SUSPENDED')}>
                Suspend
              </Button>
            )}
            {(pilot.status === 'REJECTED' || pilot.status === 'SUSPENDED') && (
              <Button size="sm" onClick={() => openStatusDialog('APPROVED')}>
                <CheckCircle className="mr-2 h-4 w-4" />
                Reactivate
              </Button>
            )}
          </div>
        </div>

        {/* Main Content */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Left Column — Tabbed Content */}
          <div className="lg:col-span-2">
            <Tabs value={activeTab} onValueChange={setActiveTab}>
              <TabsList className="w-full justify-start">
                <TabsTrigger value="overview">Overview</TabsTrigger>
                <TabsTrigger value="documents">
                  Documents {pilot.documents?.length ? `(${pilot.documents.length})` : ''}
                </TabsTrigger>
                <TabsTrigger value="vehicles">
                  Vehicles {pilot.vehicles?.length ? `(${pilot.vehicles.length})` : ''}
                </TabsTrigger>
                <TabsTrigger value="bookings">Bookings</TabsTrigger>
              </TabsList>

              {/* Tab 1: Overview */}
              <TabsContent value="overview" className="mt-4">
                <Card>
                  <CardHeader>
                    <CardTitle>Profile Information</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                      <div className="min-w-0">
                        <Label className="text-muted-foreground">Name</Label>
                        <p className="font-medium truncate">{pilot.name}</p>
                      </div>
                      <div className="min-w-0">
                        <Label className="text-muted-foreground">Email</Label>
                        <p className="font-medium truncate" title={pilot.email || ''}>
                          {pilot.email || 'N/A'}
                        </p>
                      </div>
                      <div className="min-w-0">
                        <Label className="text-muted-foreground">Phone</Label>
                        <p className="font-medium truncate">{pilot.phone}</p>
                      </div>
                      <div>
                        <Label className="text-muted-foreground">Status</Label>
                        <p>
                          <Badge variant={statusColors[pilot.status]} className={pilotStatusClassName[pilot.status] || ''}>{pilot.status}</Badge>
                        </p>
                      </div>
                      <div>
                        <Label className="text-muted-foreground">Online</Label>
                        <p>
                          <Badge variant={pilot.isOnline ? 'default' : 'outline'}>
                            {pilot.isOnline ? 'Online' : 'Offline'}
                          </Badge>
                        </p>
                      </div>
                      <div>
                        <Label className="text-muted-foreground">Rating</Label>
                        <p className="font-medium">{pilot.rating.toFixed(1)} ⭐</p>
                      </div>
                      <div>
                        <Label className="text-muted-foreground">Total Deliveries</Label>
                        <p className="font-medium">{pilot.totalDeliveries ?? pilot.totalRides ?? 0}</p>
                      </div>
                      {pilot.dateOfBirth && (
                        <div>
                          <Label className="text-muted-foreground">Date of Birth</Label>
                          <p className="font-medium">{format(new Date(pilot.dateOfBirth), 'MMM d, yyyy')}</p>
                        </div>
                      )}
                      {pilot.gender && (
                        <div>
                          <Label className="text-muted-foreground">Gender</Label>
                          <p className="font-medium">{pilot.gender}</p>
                        </div>
                      )}
                      <div>
                        <Label className="text-muted-foreground">Joined</Label>
                        <p className="font-medium">{format(new Date(pilot.createdAt), 'MMM d, yyyy')}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>

              {/* Tab 2: Documents */}
              <TabsContent value="documents" className="mt-4">
                {!pilot.documents || pilot.documents.length === 0 ? (
                  <Card>
                    <CardContent className="py-8">
                      <p className="text-muted-foreground text-center">No documents uploaded</p>
                    </CardContent>
                  </Card>
                ) : (
                  <div className="space-y-3">
                    {pilot.documents.map((doc) => (
                      <Card key={doc.id}>
                        <CardContent className="p-4 space-y-3">
                          <div className="flex items-center justify-between">
                            <div className="flex items-center gap-3">
                              <FileText className="h-5 w-5" />
                              <div>
                                <p className="font-medium">{doc.type}</p>
                                {doc.expiryDate && (
                                  <p className="text-xs text-muted-foreground">
                                    Expires: {format(new Date(doc.expiryDate), 'MMM d, yyyy')}
                                  </p>
                                )}
                              </div>
                            </div>
                            <Badge
                              variant={
                                doc.status === 'APPROVED'
                                  ? 'default'
                                  : doc.status === 'REJECTED'
                                  ? 'destructive'
                                  : 'outline'
                              }
                              className={doc.status === 'PENDING' ? 'border-yellow-500/50 bg-yellow-500/10 text-yellow-600 dark:text-yellow-400' : ''}
                            >
                              {doc.status}
                            </Badge>
                          </div>

                          {doc.url && (
                            <div className="space-y-2">
                              <a
                                href={doc.url}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="block rounded-lg overflow-hidden border border-border/50 hover:border-primary/50 transition-colors"
                              >
                                <img
                                  src={doc.url}
                                  alt={`${doc.type} document`}
                                  className="w-full max-h-48 object-contain bg-black/5 dark:bg-white/5"
                                  onError={(e) => {
                                    const target = e.currentTarget
                                    target.style.display = 'none'
                                    const fallback = target.nextElementSibling as HTMLElement
                                    if (fallback) fallback.style.display = 'flex'
                                  }}
                                />
                                <div
                                  className="hidden items-center justify-center gap-2 py-4 text-sm text-primary"
                                >
                                  <ExternalLink className="h-4 w-4" />
                                  Open Document
                                </div>
                              </a>
                            </div>
                          )}

                          {doc.rejectedReason && (
                            <p className="text-sm text-destructive">Reason: {doc.rejectedReason}</p>
                          )}

                          {doc.status === 'PENDING' && (
                            <div className="space-y-2">
                              {rejectingDocId === doc.id ? (
                                <div className="space-y-2">
                                  <textarea
                                    className="w-full min-h-[60px] rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                                    placeholder="Enter rejection reason..."
                                    value={docRejectReason}
                                    onChange={(e) => setDocRejectReason(e.target.value)}
                                  />
                                  <div className="flex gap-2">
                                    <Button
                                      size="sm"
                                      variant="destructive"
                                      disabled={!docRejectReason.trim() || verifyDocMutation.isPending}
                                      onClick={() => {
                                        verifyDocMutation.mutate({ docId: doc.id, status: 'REJECTED', reason: docRejectReason })
                                      }}
                                    >
                                      Confirm Reject
                                    </Button>
                                    <Button
                                      size="sm"
                                      variant="outline"
                                      onClick={() => { setRejectingDocId(null); setDocRejectReason('') }}
                                    >
                                      Cancel
                                    </Button>
                                  </div>
                                </div>
                              ) : (
                                <div className="flex gap-2">
                                  <Button
                                    size="sm"
                                    disabled={verifyDocMutation.isPending}
                                    onClick={() => verifyDocMutation.mutate({ docId: doc.id, status: 'APPROVED' })}
                                  >
                                    <CheckCircle className="mr-1 h-4 w-4" />
                                    Approve
                                  </Button>
                                  <Button
                                    size="sm"
                                    variant="destructive"
                                    onClick={() => setRejectingDocId(doc.id)}
                                  >
                                    <XCircle className="mr-1 h-4 w-4" />
                                    Reject
                                  </Button>
                                </div>
                              )}
                            </div>
                          )}
                        </CardContent>
                      </Card>
                    ))}
                  </div>
                )}
              </TabsContent>

              {/* Tab 3: Vehicles */}
              <TabsContent value="vehicles" className="mt-4">
                {!pilot.vehicles || pilot.vehicles.length === 0 ? (
                  <Card>
                    <CardContent className="py-8">
                      <p className="text-muted-foreground text-center">No vehicles registered</p>
                    </CardContent>
                  </Card>
                ) : (
                  <div className="space-y-3">
                    {pilot.vehicles.map((vehicle) => (
                      <Card key={vehicle.id}>
                        <CardContent className="p-4 space-y-3">
                          <div className="flex items-center justify-between">
                            <div>
                              <p className="font-medium">{vehicle.model} ({vehicle.color})</p>
                              <p className="text-sm text-muted-foreground">
                                {vehicle.plateNumber || vehicle.registrationNo || 'No plate'}
                              </p>
                              {vehicle.vehicleType && (
                                <p className="text-xs text-muted-foreground">Type: {vehicle.vehicleType.name}</p>
                              )}
                            </div>
                            <Badge
                              variant={vehicle.isVerified ? 'default' : 'outline'}
                              className={!vehicle.isVerified ? 'border-yellow-500/50 bg-yellow-500/10 text-yellow-600 dark:text-yellow-400' : ''}
                            >
                              {vehicle.isVerified ? 'Verified' : 'Pending'}
                            </Badge>
                          </div>

                          {!vehicle.isVerified && (
                            <div className="space-y-2">
                              {rejectingVehicleId === vehicle.id ? (
                                <div className="space-y-2">
                                  <textarea
                                    className="w-full min-h-[60px] rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                                    placeholder="Enter rejection reason..."
                                    value={vehicleRejectReason}
                                    onChange={(e) => setVehicleRejectReason(e.target.value)}
                                  />
                                  <div className="flex gap-2">
                                    <Button
                                      size="sm"
                                      variant="destructive"
                                      disabled={!vehicleRejectReason.trim() || verifyVehicleMutation.isPending}
                                      onClick={() => {
                                        verifyVehicleMutation.mutate({ vehicleId: vehicle.id, isVerified: false, reason: vehicleRejectReason })
                                      }}
                                    >
                                      Confirm Reject
                                    </Button>
                                    <Button
                                      size="sm"
                                      variant="outline"
                                      onClick={() => { setRejectingVehicleId(null); setVehicleRejectReason('') }}
                                    >
                                      Cancel
                                    </Button>
                                  </div>
                                </div>
                              ) : (
                                <div className="flex gap-2">
                                  <Button
                                    size="sm"
                                    disabled={verifyVehicleMutation.isPending}
                                    onClick={() => verifyVehicleMutation.mutate({ vehicleId: vehicle.id, isVerified: true })}
                                  >
                                    <CheckCircle className="mr-1 h-4 w-4" />
                                    Verify
                                  </Button>
                                  <Button
                                    size="sm"
                                    variant="destructive"
                                    onClick={() => setRejectingVehicleId(vehicle.id)}
                                  >
                                    <XCircle className="mr-1 h-4 w-4" />
                                    Reject
                                  </Button>
                                </div>
                              )}
                            </div>
                          )}
                        </CardContent>
                      </Card>
                    ))}
                  </div>
                )}
              </TabsContent>

              {/* Tab 4: Bookings */}
              <TabsContent value="bookings" className="mt-4">
                {pilotBookings.length === 0 ? (
                  <Card>
                    <CardContent className="py-8">
                      <p className="text-muted-foreground text-center">No bookings found</p>
                    </CardContent>
                  </Card>
                ) : (
                  <div className="border rounded-lg">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead>Booking ID</TableHead>
                          <TableHead>Status</TableHead>
                          <TableHead>Date</TableHead>
                          <TableHead>Customer</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {pilotBookings.map((booking) => (
                          <TableRow
                            key={booking.id}
                            className="cursor-pointer hover:bg-muted/50"
                            onClick={() => router.push(`/bookings/${booking.id}`)}
                          >
                            <TableCell className="font-mono text-xs">
                              {booking.id.slice(0, 8)}...
                            </TableCell>
                            <TableCell>
                              <Badge variant={bookingStatusVariant[booking.status]} className={bookingStatusClassName[booking.status] || ''}>
                                {booking.status.replace(/_/g, ' ')}
                              </Badge>
                            </TableCell>
                            <TableCell>
                              {format(new Date(booking.createdAt), 'MMM d, yyyy')}
                            </TableCell>
                            <TableCell>
                              {booking.user?.name || 'N/A'}
                            </TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </div>
                )}
              </TabsContent>
            </Tabs>
          </div>

          {/* Right Column — Info Cards */}
          <div className="space-y-4">
            {/* Quick Stats Card */}
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-lg">Quick Stats</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Status</span>
                  <Badge variant={statusColors[pilot.status]} className={pilotStatusClassName[pilot.status] || ''}>{pilot.status}</Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Online</span>
                  <Badge variant={pilot.isOnline ? 'default' : 'outline'}>
                    {pilot.isOnline ? 'Online' : 'Offline'}
                  </Badge>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Rating</span>
                  <span className="font-medium">{pilot.rating.toFixed(1)} ⭐</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Deliveries</span>
                  <span className="font-medium">{pilot.totalDeliveries ?? pilot.totalRides ?? 0}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">Joined</span>
                  <span className="text-sm">{format(new Date(pilot.createdAt), 'MMM d, yyyy')}</span>
                </div>
              </CardContent>
            </Card>

            {/* Status Management Card */}
            <Card>
              <CardHeader className="pb-3">
                <CardTitle className="text-lg">Status Management</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <p className="text-sm text-muted-foreground">
                  Current status: <Badge variant={statusColors[pilot.status]} className={pilotStatusClassName[pilot.status] || ''}>{pilot.status}</Badge>
                </p>
                <div className="flex flex-col gap-2">
                  {pilot.status === 'PENDING' && (
                    <>
                      <Button size="sm" className="w-full" onClick={() => openStatusDialog('APPROVED')}>
                        <CheckCircle className="mr-2 h-4 w-4" />
                        Approve Pilot
                      </Button>
                      <Button size="sm" variant="destructive" className="w-full" onClick={() => openStatusDialog('REJECTED')}>
                        <XCircle className="mr-2 h-4 w-4" />
                        Reject Pilot
                      </Button>
                    </>
                  )}
                  {pilot.status === 'APPROVED' && (
                    <Button size="sm" variant="destructive" className="w-full" onClick={() => openStatusDialog('SUSPENDED')}>
                      Suspend Pilot
                    </Button>
                  )}
                  {(pilot.status === 'REJECTED' || pilot.status === 'SUSPENDED') && (
                    <Button size="sm" className="w-full" onClick={() => openStatusDialog('APPROVED')}>
                      <CheckCircle className="mr-2 h-4 w-4" />
                      Reactivate Pilot
                    </Button>
                  )}
                </div>
              </CardContent>
            </Card>
          </div>
        </div>

        {/* Status Update Dialog */}
        <Dialog open={isStatusDialogOpen} onOpenChange={setIsStatusDialogOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>
                {statusAction.status === 'APPROVED'
                  ? 'Approve Pilot'
                  : statusAction.status === 'REJECTED'
                  ? 'Reject Pilot'
                  : 'Suspend Pilot'}
              </DialogTitle>
              <DialogDescription>
                {statusAction.status === 'APPROVED'
                  ? `Are you sure you want to approve ${pilot.name}?`
                  : `Please provide a reason for this action.`}
              </DialogDescription>
            </DialogHeader>
            {(statusAction.status === 'REJECTED' || statusAction.status === 'SUSPENDED') && (
              <div className="space-y-2">
                <Label htmlFor="reason">Reason</Label>
                <textarea
                  id="reason"
                  className="w-full min-h-[100px] rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  placeholder="Enter reason..."
                  value={statusAction.reason}
                  onChange={(e) => setStatusAction({ ...statusAction, reason: e.target.value })}
                />
              </div>
            )}
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsStatusDialogOpen(false)}>
                Cancel
              </Button>
              <Button
                onClick={handleStatusUpdate}
                disabled={updateStatusMutation.isPending}
                variant={statusAction.status === 'APPROVED' ? 'default' : 'destructive'}
              >
                {updateStatusMutation.isPending ? 'Processing...' : 'Confirm'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Edit Dialog */}
        <Dialog open={isEditOpen} onOpenChange={setIsEditOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Edit Pilot</DialogTitle>
              <DialogDescription>Update pilot information</DialogDescription>
            </DialogHeader>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="edit-name">Name</Label>
                <Input
                  id="edit-name"
                  value={editForm.name}
                  onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="edit-email">Email</Label>
                <Input
                  id="edit-email"
                  type="email"
                  value={editForm.email}
                  onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="edit-phone">Phone</Label>
                <Input
                  id="edit-phone"
                  value={editForm.phone}
                  onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsEditOpen(false)}>
                Cancel
              </Button>
              <Button onClick={handleSaveEdit} disabled={updatePilotMutation.isPending}>
                {updatePilotMutation.isPending ? 'Saving...' : 'Save Changes'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  )
}
