'use client'

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, MoreHorizontal, Eye, CheckCircle, XCircle, Car } from 'lucide-react'
import { AdminLayout } from '@/components/layout/admin-layout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
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
import type { Vehicle, PaginationMeta } from '@/types'

export default function VehiclesPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [verifiedFilter, setVerifiedFilter] = useState<string>('all')
  const [selectedVehicle, setSelectedVehicle] = useState<Vehicle | null>(null)
  const [isViewOpen, setIsViewOpen] = useState(false)
  const [isVerifyOpen, setIsVerifyOpen] = useState(false)
  const [verifyAction, setVerifyAction] = useState<{ isVerified: boolean; reason: string }>({
    isVerified: true,
    reason: '',
  })

  const { data, isLoading } = useQuery({
    queryKey: ['vehicles', page, search, verifiedFilter],
    queryFn: () =>
      adminApi.listVehicles({
        page,
        limit: 10,
        search: search || undefined,
        verified: verifiedFilter === 'all' ? undefined : verifiedFilter === 'verified',
      }),
  })

  const vehicles = (data?.data as { vehicles: Vehicle[] })?.vehicles || []
  const meta = data?.meta as PaginationMeta

  const verifyMutation = useMutation({
    mutationFn: ({ vehicleId, isVerified, reason }: { vehicleId: string; isVerified: boolean; reason?: string }) =>
      adminApi.verifyVehicle(vehicleId, isVerified, reason),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicles'] })
      setIsVerifyOpen(false)
      setVerifyAction({ isVerified: true, reason: '' })
    },
  })

  const handleView = async (vehicleId: string) => {
    const response = await adminApi.getVehicleDetails(vehicleId)
    setSelectedVehicle((response.data as { vehicle: Vehicle }).vehicle)
    setIsViewOpen(true)
  }

  const openVerifyDialog = (vehicle: Vehicle, isVerified: boolean) => {
    setSelectedVehicle(vehicle)
    setVerifyAction({ isVerified, reason: '' })
    setIsVerifyOpen(true)
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Vehicles</h1>
          <p className="text-muted-foreground">Manage pilot vehicles</p>
        </div>

        {/* Filters */}
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search by plate number or model..."
              value={search}
              onChange={(e) => {
                setSearch(e.target.value)
                setPage(1)
              }}
              className="pl-9"
            />
          </div>
          <Select value={verifiedFilter} onValueChange={(v) => { setVerifiedFilter(v); setPage(1) }}>
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Verification" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Vehicles</SelectItem>
              <SelectItem value="verified">Verified</SelectItem>
              <SelectItem value="unverified">Pending</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {/* Table */}
        <div className="border rounded-lg">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Plate Number</TableHead>
                <TableHead>Model</TableHead>
                <TableHead>Color</TableHead>
                <TableHead>Year</TableHead>
                <TableHead>Type</TableHead>
                <TableHead>Pilot</TableHead>
                <TableHead>Status</TableHead>
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
              ) : vehicles.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} className="text-center py-8">
                    No vehicles found
                  </TableCell>
                </TableRow>
              ) : (
                vehicles.map((vehicle) => (
                  <TableRow key={vehicle.id}>
                    <TableCell className="font-mono font-medium">
                      {vehicle.registrationNo || vehicle.plateNumber || '-'}
                    </TableCell>
                    <TableCell>{vehicle.model}</TableCell>
                    <TableCell>{vehicle.color}</TableCell>
                    <TableCell>{vehicle.year}</TableCell>
                    <TableCell>{vehicle.vehicleType?.name || '-'}</TableCell>
                    <TableCell>{vehicle.pilot?.name || '-'}</TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Badge variant={vehicle.isVerified ? 'default' : 'secondary'}>
                          {vehicle.isVerified ? 'Verified' : 'Pending'}
                        </Badge>
                        {!vehicle.isActive && (
                          <Badge variant="outline">Inactive</Badge>
                        )}
                      </div>
                    </TableCell>
                    <TableCell>
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleView(vehicle.id)}>
                            <Eye className="mr-2 h-4 w-4" />
                            View Details
                          </DropdownMenuItem>
                          <DropdownMenuSeparator />
                          {!vehicle.isVerified ? (
                            <>
                              <DropdownMenuItem onClick={() => openVerifyDialog(vehicle, true)}>
                                <CheckCircle className="mr-2 h-4 w-4 text-green-500" />
                                Verify
                              </DropdownMenuItem>
                              <DropdownMenuItem onClick={() => openVerifyDialog(vehicle, false)}>
                                <XCircle className="mr-2 h-4 w-4 text-red-500" />
                                Reject
                              </DropdownMenuItem>
                            </>
                          ) : (
                            <DropdownMenuItem onClick={() => openVerifyDialog(vehicle, false)}>
                              <XCircle className="mr-2 h-4 w-4 text-red-500" />
                              Revoke Verification
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
              Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, meta.total)} of {meta.total} vehicles
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
              <DialogTitle>Vehicle Details</DialogTitle>
            </DialogHeader>
            {selectedVehicle && (
              <div className="space-y-6">
                <div className="flex items-center gap-4 p-4 bg-muted rounded-lg">
                  <div className="p-3 bg-background rounded-full">
                    <Car className="h-8 w-8" />
                  </div>
                  <div>
                    <h3 className="font-bold text-lg">{selectedVehicle.model}</h3>
                    <p className="text-muted-foreground font-mono">
                      {selectedVehicle.registrationNo || selectedVehicle.plateNumber || '-'}
                    </p>
                  </div>
                </div>

                <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
                  <div>
                    <Label className="text-muted-foreground">Color</Label>
                    <p className="font-medium">{selectedVehicle.color}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Year</Label>
                    <p className="font-medium">{selectedVehicle.year}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Type</Label>
                    <p className="font-medium">{selectedVehicle.vehicleType?.name || '-'}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Verification</Label>
                    <p>
                      <Badge variant={selectedVehicle.isVerified ? 'default' : 'secondary'}>
                        {selectedVehicle.isVerified ? 'Verified' : 'Pending'}
                      </Badge>
                    </p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">Active</Label>
                    <p>
                      <Badge variant={selectedVehicle.isActive ? 'default' : 'outline'}>
                        {selectedVehicle.isActive ? 'Active' : 'Inactive'}
                      </Badge>
                    </p>
                  </div>
                </div>

                {selectedVehicle.pilot && (
                  <div>
                    <Label className="text-muted-foreground mb-2 block">Owner (Pilot)</Label>
                    <div className="p-3 bg-muted rounded-lg">
                      <p className="font-medium">{selectedVehicle.pilot.name}</p>
                      <p className="text-sm text-muted-foreground">{selectedVehicle.pilot.phone}</p>
                      <p className="text-sm text-muted-foreground">{selectedVehicle.pilot.email}</p>
                    </div>
                  </div>
                )}

                {selectedVehicle.vehicleType && (
                  <div>
                    <Label className="text-muted-foreground mb-2 block">Pricing</Label>
                    <div className="grid grid-cols-2 gap-4 p-3 bg-muted rounded-lg">
                      <div>
                        <p className="text-sm text-muted-foreground">Base Price</p>
                        <p className="font-medium">₹{selectedVehicle.vehicleType.basePrice}</p>
                      </div>
                      <div>
                        <p className="text-sm text-muted-foreground">Per KM</p>
                        <p className="font-medium">₹{selectedVehicle.vehicleType.pricePerKm}</p>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            )}
          </DialogContent>
        </Dialog>

        {/* Verify Dialog */}
        <Dialog open={isVerifyOpen} onOpenChange={setIsVerifyOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>
                {verifyAction.isVerified ? 'Verify Vehicle' : 'Reject Vehicle'}
              </DialogTitle>
              <DialogDescription>
                {verifyAction.isVerified
                  ? 'Are you sure you want to verify this vehicle?'
                  : 'Please provide a reason for rejecting this vehicle.'}
              </DialogDescription>
            </DialogHeader>
            {!verifyAction.isVerified && (
              <div className="space-y-2">
                <Label htmlFor="reason">Reason</Label>
                <textarea
                  id="reason"
                  className="w-full min-h-[100px] rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  placeholder="Enter reason for rejection..."
                  value={verifyAction.reason}
                  onChange={(e) => setVerifyAction({ ...verifyAction, reason: e.target.value })}
                />
              </div>
            )}
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsVerifyOpen(false)}>
                Cancel
              </Button>
              <Button
                onClick={() => {
                  if (selectedVehicle) {
                    verifyMutation.mutate({
                      vehicleId: selectedVehicle.id,
                      isVerified: verifyAction.isVerified,
                      reason: verifyAction.reason || undefined,
                    })
                  }
                }}
                disabled={(!verifyAction.isVerified && !verifyAction.reason) || verifyMutation.isPending}
                variant={verifyAction.isVerified ? 'default' : 'destructive'}
              >
                {verifyMutation.isPending ? 'Processing...' : 'Confirm'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  )
}
