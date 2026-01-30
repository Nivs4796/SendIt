'use client'

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, MoreHorizontal, CheckCircle, XCircle, Ban, Edit, Eye, FileText } from 'lucide-react'
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
import type { Pilot, PilotStatus, PaginationMeta } from '@/types'
import { format } from 'date-fns'

const statusColors: Record<PilotStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  PENDING: 'secondary',
  APPROVED: 'default',
  REJECTED: 'destructive',
  SUSPENDED: 'outline',
}

export default function PilotsPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [selectedPilot, setSelectedPilot] = useState<Pilot | null>(null)
  const [isViewOpen, setIsViewOpen] = useState(false)
  const [isStatusDialogOpen, setIsStatusDialogOpen] = useState(false)
  const [statusAction, setStatusAction] = useState<{ status: PilotStatus; reason: string }>({
    status: 'APPROVED',
    reason: '',
  })

  const { data, isLoading } = useQuery({
    queryKey: ['pilots', page, search, statusFilter],
    queryFn: () =>
      adminApi.listPilots({
        page,
        limit: 10,
        search: search || undefined,
        status: statusFilter === 'all' ? undefined : statusFilter,
      }),
  })

  const pilots = (data?.data as { pilots: Pilot[] })?.pilots || []
  const meta = data?.meta as PaginationMeta

  const updateStatusMutation = useMutation({
    mutationFn: ({ pilotId, status, reason }: { pilotId: string; status: string; reason?: string }) =>
      adminApi.updatePilotStatus(pilotId, status, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['pilots'] })
      setIsStatusDialogOpen(false)
    },
  })

  const handleView = async (pilotId: string) => {
    const response = await adminApi.getPilotDetails(pilotId)
    // API returns { pilot: {...}, bookingStats: [...], totalEarnings: ... }
    const pilotData = (response.data as { pilot: Pilot }).pilot
    setSelectedPilot(pilotData)
    setIsViewOpen(true)
  }

  const openStatusDialog = (pilot: Pilot, status: PilotStatus) => {
    setSelectedPilot(pilot)
    setStatusAction({ status, reason: '' })
    setIsStatusDialogOpen(true)
  }

  const handleStatusUpdate = () => {
    if (selectedPilot) {
      updateStatusMutation.mutate({
        pilotId: selectedPilot.id,
        status: statusAction.status,
        reason: statusAction.reason || undefined,
      })
    }
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Pilots</h1>
          <p className="text-muted-foreground">Manage delivery pilots</p>
        </div>

        {/* Filters */}
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search by name, email, or phone..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value)
                setPage(1)
              }}
              className="pl-9"
            />
          </div>
          <Tabs value={statusFilter} onValueChange={(v) => { setStatusFilter(v); setPage(1) }}>
            <TabsList>
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="PENDING">Pending</TabsTrigger>
              <TabsTrigger value="APPROVED">Approved</TabsTrigger>
              <TabsTrigger value="REJECTED">Rejected</TabsTrigger>
              <TabsTrigger value="SUSPENDED">Suspended</TabsTrigger>
            </TabsList>
          </Tabs>
        </div>

        {/* Table */}
        <div className="border rounded-lg">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Name</TableHead>
                <TableHead>Contact</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Online</TableHead>
                <TableHead>Rating</TableHead>
                <TableHead>Rides</TableHead>
                <TableHead>Joined</TableHead>
                <TableHead className="w-[80px]">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={8} className="text-center py-8">
                    Loading...
                  </TableCell>
                </TableRow>
              ) : pilots.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} className="text-center py-8">
                    No pilots found
                  </TableCell>
                </TableRow>
              ) : (
                pilots.map((pilot) => (
                  <TableRow key={pilot.id}>
                    <TableCell className="font-medium">{pilot.name}</TableCell>
                    <TableCell>
                      <div>
                        <p className="text-sm">{pilot.email}</p>
                        <p className="text-xs text-muted-foreground">{pilot.phone}</p>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant={statusColors[pilot.status]}>{pilot.status}</Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant={pilot.isOnline ? 'default' : 'outline'}>
                        {pilot.isOnline ? 'Online' : 'Offline'}
                      </Badge>
                    </TableCell>
                    <TableCell>{pilot.rating.toFixed(1)} ⭐</TableCell>
                    <TableCell>{pilot.totalDeliveries ?? pilot.totalRides ?? 0}</TableCell>
                    <TableCell>{format(new Date(pilot.createdAt), 'MMM d, yyyy')}</TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleView(pilot.id)}>
                            <Eye className="mr-2 h-4 w-4" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          {pilot.status === 'PENDING' && (
                            <>
                              <DropdownMenuItem onClick={() => openStatusDialog(pilot, 'APPROVED')}>
                                <CheckCircle className="mr-2 h-4 w-4 text-green-500" />
                                Approve
                              </DropdownMenuItem>
                              <DropdownMenuItem onClick={() => openStatusDialog(pilot, 'REJECTED')}>
                                <XCircle className="mr-2 h-4 w-4 text-red-500" />
                                Reject
                              </DropdownMenuItem>
                            </>
                          )}
                          {pilot.status === 'APPROVED' && (
                            <DropdownMenuItem onClick={() => openStatusDialog(pilot, 'SUSPENDED')}>
                              <Ban className="mr-2 h-4 w-4 text-orange-500" />
                              Suspend
                            </DropdownMenuItem>
                          )}
                          {(pilot.status === 'REJECTED' || pilot.status === 'SUSPENDED') && (
                            <DropdownMenuItem onClick={() => openStatusDialog(pilot, 'APPROVED')}>
                              <CheckCircle className="mr-2 h-4 w-4 text-green-500" />
                              Reactivate
                            </DropdownMenuItem>
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
              Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, meta.total)} of {meta.total} pilots
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
                  ? `Are you sure you want to approve ${selectedPilot?.name}?`
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

        {/* View Dialog */}
        <Dialog open={isViewOpen} onOpenChange={setIsViewOpen}>
          <DialogContent className="max-w-3xl max-h-[85vh] flex flex-col">
            <DialogHeader>
              <DialogTitle>Pilot Details</DialogTitle>
              <DialogDescription>View pilot information, documents, and vehicles</DialogDescription>
            </DialogHeader>
            {selectedPilot && (
              <div className="space-y-6 overflow-y-auto flex-1 pr-2">
                <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                  <div className="min-w-0">
                    <Label className="text-muted-foreground">Name</Label>
                    <p className="font-medium truncate">{selectedPilot.name}</p>
                  </div>
                  <div className="min-w-0">
                    <Label className="text-muted-foreground">Email</Label>
                    <p className="font-medium truncate" title={selectedPilot.email || ''}>
                      {selectedPilot.email || 'N/A'}
                    </p>
                  </div>
                  <div className="min-w-0">
                    <Label className="text-muted-foreground">Phone</Label>
                    <p className="font-medium truncate">{selectedPilot.phone}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Status</Label>
                    <p>
                      <Badge variant={statusColors[selectedPilot.status]}>{selectedPilot.status}</Badge>
                    </p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Rating</Label>
                    <p className="font-medium">{selectedPilot.rating.toFixed(1)} ⭐</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Total Deliveries</Label>
                    <p className="font-medium">{selectedPilot.totalDeliveries ?? selectedPilot.totalRides ?? 0}</p>
                  </div>
                </div>

                {selectedPilot.documents && selectedPilot.documents.length > 0 && (
                  <div>
                    <Label className="text-muted-foreground mb-2 block">Documents ({selectedPilot.documents.length})</Label>
                    <div className="space-y-2">
                      {selectedPilot.documents.map((doc) => (
                        <div key={doc.id} className="flex items-center justify-between p-3 bg-muted rounded-lg">
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
                                : 'secondary'
                            }
                          >
                            {doc.status}
                          </Badge>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {selectedPilot.vehicles && selectedPilot.vehicles.length > 0 && (
                  <div>
                    <Label className="text-muted-foreground mb-2 block">Vehicles ({selectedPilot.vehicles.length})</Label>
                    <div className="space-y-2">
                      {selectedPilot.vehicles.map((vehicle) => (
                        <div key={vehicle.id} className="flex items-center justify-between p-3 bg-muted rounded-lg">
                          <div>
                            <p className="font-medium">
                              {vehicle.model} ({vehicle.color})
                            </p>
                            <p className="text-sm text-muted-foreground">{vehicle.plateNumber}</p>
                          </div>
                          <Badge variant={vehicle.isVerified ? 'default' : 'secondary'}>
                            {vehicle.isVerified ? 'Verified' : 'Pending'}
                          </Badge>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            )}
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  )
}
