'use client'

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Search, MoreHorizontal, Plus, Pencil, Trash2, Copy } from 'lucide-react'
import { AdminLayout } from '@/components/layout/admin-layout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent } from '@/components/ui/card'
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
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Label } from '@/components/ui/label'
import { adminApi } from '@/lib/api'
import type { Coupon, CouponStats, PaginationMeta, CreateCouponDto, UpdateCouponDto } from '@/types'
import { format } from 'date-fns'
import { toast } from 'sonner'

const initialFormState: CreateCouponDto = {
  code: '',
  description: '',
  discountType: 'PERCENTAGE',
  discountValue: 0,
  minOrderAmount: undefined,
  maxDiscount: undefined,
  usageLimit: undefined,
  perUserLimit: 1,
  expiresAt: undefined,
}

export default function CouponsPage() {
  const queryClient = useQueryClient()
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [activeFilter, setActiveFilter] = useState<string>('all')
  const [isCreateOpen, setIsCreateOpen] = useState(false)
  const [isEditOpen, setIsEditOpen] = useState(false)
  const [isDeleteOpen, setIsDeleteOpen] = useState(false)
  const [selectedCoupon, setSelectedCoupon] = useState<Coupon | null>(null)
  const [form, setForm] = useState<CreateCouponDto>(initialFormState)

  // Fetch coupons
  const { data, isLoading } = useQuery({
    queryKey: ['coupons', page, search, activeFilter],
    queryFn: () =>
      adminApi.listCoupons({
        page,
        limit: 10,
        search: search || undefined,
        active: activeFilter === 'all' ? undefined : activeFilter === 'active',
      }),
  })

  // Fetch stats
  const { data: statsData } = useQuery({
    queryKey: ['coupon-stats'],
    queryFn: () => adminApi.getCouponStats(),
  })

  const coupons = (data?.data as { coupons: Coupon[] })?.coupons || []
  const meta = data?.meta as PaginationMeta
  const stats = statsData?.data as CouponStats

  // Create mutation
  const createMutation = useMutation({
    mutationFn: (data: CreateCouponDto) => adminApi.createCoupon(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['coupons'] })
      queryClient.invalidateQueries({ queryKey: ['coupon-stats'] })
      setIsCreateOpen(false)
      setForm(initialFormState)
      toast.success('Coupon created successfully')
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Failed to create coupon')
    },
  })

  // Update mutation
  const updateMutation = useMutation({
    mutationFn: ({ id, data }: { id: string; data: UpdateCouponDto }) =>
      adminApi.updateCoupon(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['coupons'] })
      queryClient.invalidateQueries({ queryKey: ['coupon-stats'] })
      setIsEditOpen(false)
      setSelectedCoupon(null)
      toast.success('Coupon updated successfully')
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Failed to update coupon')
    },
  })

  // Delete mutation
  const deleteMutation = useMutation({
    mutationFn: (id: string) => adminApi.deleteCoupon(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['coupons'] })
      queryClient.invalidateQueries({ queryKey: ['coupon-stats'] })
      setIsDeleteOpen(false)
      setSelectedCoupon(null)
      toast.success('Coupon deleted successfully')
    },
    onError: (error: Error) => {
      toast.error(error.message || 'Failed to delete coupon')
    },
  })

  const handleCreate = () => {
    if (!form.code || !form.discountValue) {
      toast.error('Code and discount value are required')
      return
    }
    createMutation.mutate({
      ...form,
      code: form.code.toUpperCase(),
    })
  }

  const handleEdit = (coupon: Coupon) => {
    setSelectedCoupon(coupon)
    setForm({
      code: coupon.code,
      description: coupon.description || '',
      discountType: coupon.discountType,
      discountValue: coupon.discountValue,
      minOrderAmount: coupon.minOrderAmount,
      maxDiscount: coupon.maxDiscount,
      usageLimit: coupon.usageLimit,
      perUserLimit: coupon.perUserLimit,
      expiresAt: coupon.expiresAt,
    })
    setIsEditOpen(true)
  }

  const handleUpdate = () => {
    if (!selectedCoupon) return
    const updates: UpdateCouponDto = {
      description: form.description,
      discountType: form.discountType,
      discountValue: form.discountValue,
      minOrderAmount: form.minOrderAmount,
      maxDiscount: form.maxDiscount,
      usageLimit: form.usageLimit,
      perUserLimit: form.perUserLimit,
      expiresAt: form.expiresAt,
    }
    updateMutation.mutate({ id: selectedCoupon.id, data: updates })
  }

  const handleToggleActive = (coupon: Coupon) => {
    updateMutation.mutate({
      id: coupon.id,
      data: { isActive: !coupon.isActive },
    })
  }

  const copyCode = (code: string) => {
    navigator.clipboard.writeText(code)
    toast.success('Code copied to clipboard')
  }

  const getDiscountDisplay = (coupon: Coupon) => {
    if (coupon.discountType === 'PERCENTAGE') {
      return `${coupon.discountValue}%`
    }
    return `₹${coupon.discountValue}`
  }

  const isExpired = (coupon: Coupon) => {
    if (!coupon.expiresAt) return false
    return new Date(coupon.expiresAt) < new Date()
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Coupons</h1>
            <p className="text-muted-foreground">Manage promotional coupons and offers</p>
          </div>
          <Button onClick={() => { setForm(initialFormState); setIsCreateOpen(true) }}>
            <Plus className="mr-2 h-4 w-4" />
            Create Coupon
          </Button>
        </div>

        {/* Stats Cards */}
        {stats && (
          <div className="grid gap-4 md:grid-cols-4">
            <Card>
              <CardContent className="pt-6">
                <div className="text-2xl font-bold">{stats.totalCoupons}</div>
                <p className="text-xs text-muted-foreground">Total Coupons</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <div className="text-2xl font-bold text-green-600">{stats.activeCoupons}</div>
                <p className="text-xs text-muted-foreground">Active Coupons</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <div className="text-2xl font-bold">{stats.totalRedemptions}</div>
                <p className="text-xs text-muted-foreground">Total Redemptions</p>
              </CardContent>
            </Card>
            <Card>
              <CardContent className="pt-6">
                <div className="text-2xl font-bold">₹{stats.totalDiscountGiven.toFixed(0)}</div>
                <p className="text-xs text-muted-foreground">Total Discount Given</p>
              </CardContent>
            </Card>
          </div>
        )}

        {/* Filters */}
        <div className="flex flex-col sm:flex-row gap-4">
          <div className="relative flex-1">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search by code..."
              value={search}
              onChange={(e) => { setSearch(e.target.value); setPage(1) }}
              className="pl-9"
            />
          </div>
          <Select value={activeFilter} onValueChange={(v) => { setActiveFilter(v); setPage(1) }}>
            <SelectTrigger className="w-[150px]">
              <SelectValue placeholder="Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All</SelectItem>
              <SelectItem value="active">Active</SelectItem>
              <SelectItem value="inactive">Inactive</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {/* Table */}
        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Code</TableHead>
                <TableHead>Discount</TableHead>
                <TableHead>Usage</TableHead>
                <TableHead>Min Order</TableHead>
                <TableHead>Expires</TableHead>
                <TableHead>Status</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8">
                    Loading...
                  </TableCell>
                </TableRow>
              ) : coupons.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={7} className="text-center py-8 text-muted-foreground">
                    No coupons found
                  </TableCell>
                </TableRow>
              ) : (
                coupons.map((coupon) => (
                  <TableRow key={coupon.id}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <code className="font-mono font-semibold">{coupon.code}</code>
                        <Button
                          variant="ghost"
                          size="icon"
                          className="h-6 w-6"
                          onClick={() => copyCode(coupon.code)}
                        >
                          <Copy className="h-3 w-3" />
                        </Button>
                      </div>
                      {coupon.description && (
                        <p className="text-xs text-muted-foreground mt-1">{coupon.description}</p>
                      )}
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{getDiscountDisplay(coupon)}</Badge>
                      {coupon.maxDiscount && coupon.discountType === 'PERCENTAGE' && (
                        <span className="text-xs text-muted-foreground ml-1">
                          (max ₹{coupon.maxDiscount})
                        </span>
                      )}
                    </TableCell>
                    <TableCell>
                      {coupon.usageCount}
                      {coupon.usageLimit && `/${coupon.usageLimit}`}
                    </TableCell>
                    <TableCell>
                      {coupon.minOrderAmount ? `₹${coupon.minOrderAmount}` : '-'}
                    </TableCell>
                    <TableCell>
                      {coupon.expiresAt
                        ? format(new Date(coupon.expiresAt), 'dd MMM yyyy')
                        : 'Never'}
                    </TableCell>
                    <TableCell>
                      {isExpired(coupon) ? (
                        <Badge variant="destructive">Expired</Badge>
                      ) : coupon.isActive ? (
                        <Badge variant="default">Active</Badge>
                      ) : (
                        <Badge variant="outline">Inactive</Badge>
                      )}
                    </TableCell>
                    <TableCell className="text-right">
                      <DropdownMenu>
                        <DropdownMenuTrigger asChild>
                          <Button variant="ghost" size="icon">
                            <MoreHorizontal className="h-4 w-4" />
                          </Button>
                        </DropdownMenuTrigger>
                        <DropdownMenuContent align="end">
                          <DropdownMenuItem onClick={() => handleEdit(coupon)}>
                            <Pencil className="mr-2 h-4 w-4" />
                            Edit
                          </DropdownMenuItem>
                          <DropdownMenuItem onClick={() => handleToggleActive(coupon)}>
                            {coupon.isActive ? 'Deactivate' : 'Activate'}
                          </DropdownMenuItem>
                          <DropdownMenuItem
                            className="text-destructive"
                            onClick={() => { setSelectedCoupon(coupon); setIsDeleteOpen(true) }}
                          >
                            <Trash2 className="mr-2 h-4 w-4" />
                            Delete
                          </DropdownMenuItem>
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
        {meta && meta.totalPages > 1 && (
          <div className="flex items-center justify-between">
            <p className="text-sm text-muted-foreground">
              Page {meta.page} of {meta.totalPages} ({meta.total} total)
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
                disabled={page === meta.totalPages}
                onClick={() => setPage(page + 1)}
              >
                Next
              </Button>
            </div>
          </div>
        )}

        {/* Create Dialog */}
        <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle>Create Coupon</DialogTitle>
              <DialogDescription>Add a new promotional coupon</DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="grid gap-2">
                <Label htmlFor="code">Code *</Label>
                <Input
                  id="code"
                  value={form.code}
                  onChange={(e) => setForm({ ...form, code: e.target.value.toUpperCase() })}
                  placeholder="WELCOME50"
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="description">Description</Label>
                <Input
                  id="description"
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                  placeholder="50% off on first order"
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label>Discount Type</Label>
                  <Select
                    value={form.discountType}
                    onValueChange={(v) => setForm({ ...form, discountType: v as 'PERCENTAGE' | 'FIXED' })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="PERCENTAGE">Percentage</SelectItem>
                      <SelectItem value="FIXED">Fixed Amount</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="discountValue">Value *</Label>
                  <Input
                    id="discountValue"
                    type="number"
                    value={form.discountValue || ''}
                    onChange={(e) => setForm({ ...form, discountValue: parseFloat(e.target.value) || 0 })}
                    placeholder={form.discountType === 'PERCENTAGE' ? '50' : '100'}
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="minOrderAmount">Min Order (₹)</Label>
                  <Input
                    id="minOrderAmount"
                    type="number"
                    value={form.minOrderAmount || ''}
                    onChange={(e) => setForm({ ...form, minOrderAmount: parseFloat(e.target.value) || undefined })}
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="maxDiscount">Max Discount (₹)</Label>
                  <Input
                    id="maxDiscount"
                    type="number"
                    value={form.maxDiscount || ''}
                    onChange={(e) => setForm({ ...form, maxDiscount: parseFloat(e.target.value) || undefined })}
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="usageLimit">Total Usage Limit</Label>
                  <Input
                    id="usageLimit"
                    type="number"
                    value={form.usageLimit || ''}
                    onChange={(e) => setForm({ ...form, usageLimit: parseInt(e.target.value) || undefined })}
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="perUserLimit">Per User Limit</Label>
                  <Input
                    id="perUserLimit"
                    type="number"
                    value={form.perUserLimit || ''}
                    onChange={(e) => setForm({ ...form, perUserLimit: parseInt(e.target.value) || 1 })}
                  />
                </div>
              </div>
              <div className="grid gap-2">
                <Label htmlFor="expiresAt">Expiry Date</Label>
                <Input
                  id="expiresAt"
                  type="date"
                  value={form.expiresAt ? form.expiresAt.split('T')[0] : ''}
                  onChange={(e) => setForm({ ...form, expiresAt: e.target.value ? new Date(e.target.value).toISOString() : undefined })}
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsCreateOpen(false)}>Cancel</Button>
              <Button onClick={handleCreate} disabled={createMutation.isPending}>
                {createMutation.isPending ? 'Creating...' : 'Create'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Edit Dialog */}
        <Dialog open={isEditOpen} onOpenChange={setIsEditOpen}>
          <DialogContent className="max-w-md">
            <DialogHeader>
              <DialogTitle>Edit Coupon</DialogTitle>
              <DialogDescription>Update coupon details</DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="grid gap-2">
                <Label>Code</Label>
                <Input value={selectedCoupon?.code || ''} disabled />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="edit-description">Description</Label>
                <Input
                  id="edit-description"
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                />
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label>Discount Type</Label>
                  <Select
                    value={form.discountType}
                    onValueChange={(v) => setForm({ ...form, discountType: v as 'PERCENTAGE' | 'FIXED' })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="PERCENTAGE">Percentage</SelectItem>
                      <SelectItem value="FIXED">Fixed Amount</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-discountValue">Value</Label>
                  <Input
                    id="edit-discountValue"
                    type="number"
                    value={form.discountValue || ''}
                    onChange={(e) => setForm({ ...form, discountValue: parseFloat(e.target.value) || 0 })}
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="edit-minOrderAmount">Min Order (₹)</Label>
                  <Input
                    id="edit-minOrderAmount"
                    type="number"
                    value={form.minOrderAmount || ''}
                    onChange={(e) => setForm({ ...form, minOrderAmount: parseFloat(e.target.value) || undefined })}
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-maxDiscount">Max Discount (₹)</Label>
                  <Input
                    id="edit-maxDiscount"
                    type="number"
                    value={form.maxDiscount || ''}
                    onChange={(e) => setForm({ ...form, maxDiscount: parseFloat(e.target.value) || undefined })}
                  />
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="grid gap-2">
                  <Label htmlFor="edit-usageLimit">Total Usage Limit</Label>
                  <Input
                    id="edit-usageLimit"
                    type="number"
                    value={form.usageLimit || ''}
                    onChange={(e) => setForm({ ...form, usageLimit: parseInt(e.target.value) || undefined })}
                  />
                </div>
                <div className="grid gap-2">
                  <Label htmlFor="edit-perUserLimit">Per User Limit</Label>
                  <Input
                    id="edit-perUserLimit"
                    type="number"
                    value={form.perUserLimit || ''}
                    onChange={(e) => setForm({ ...form, perUserLimit: parseInt(e.target.value) || 1 })}
                  />
                </div>
              </div>
              <div className="grid gap-2">
                <Label htmlFor="edit-expiresAt">Expiry Date</Label>
                <Input
                  id="edit-expiresAt"
                  type="date"
                  value={form.expiresAt ? form.expiresAt.split('T')[0] : ''}
                  onChange={(e) => setForm({ ...form, expiresAt: e.target.value ? new Date(e.target.value).toISOString() : undefined })}
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsEditOpen(false)}>Cancel</Button>
              <Button onClick={handleUpdate} disabled={updateMutation.isPending}>
                {updateMutation.isPending ? 'Saving...' : 'Save Changes'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>

        {/* Delete Dialog */}
        <Dialog open={isDeleteOpen} onOpenChange={setIsDeleteOpen}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Delete Coupon</DialogTitle>
              <DialogDescription>
                Are you sure you want to delete the coupon <strong>{selectedCoupon?.code}</strong>? This action cannot be undone.
              </DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button variant="outline" onClick={() => setIsDeleteOpen(false)}>Cancel</Button>
              <Button
                variant="destructive"
                onClick={() => selectedCoupon && deleteMutation.mutate(selectedCoupon.id)}
                disabled={deleteMutation.isPending}
              >
                {deleteMutation.isPending ? 'Deleting...' : 'Delete'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </div>
    </AdminLayout>
  )
}
