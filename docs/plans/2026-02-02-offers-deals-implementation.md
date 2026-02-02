# Offers & Deals Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Display dynamic promotional offers in the user app from the coupon database, with full admin panel management.

**Architecture:** User app fetches available coupons via existing API, auto-generates attractive banners, shows details in bottom sheet. Admin panel gets dedicated Coupons page for CRUD operations.

**Tech Stack:** Flutter/GetX (user app), Next.js/shadcn/React Query (admin), Express/Prisma (backend - mostly existing)

---

## Task 1: Backend - Add Coupon Stats Endpoint

**Files:**
- Modify: `backend/src/services/coupon.service.ts`
- Modify: `backend/src/controllers/coupon.controller.ts`
- Modify: `backend/src/routes/coupon.routes.ts`

**Step 1: Add getCouponStats to service**

Add at end of `backend/src/services/coupon.service.ts`:

```typescript
/**
 * Get coupon statistics for admin dashboard
 */
export const getCouponStats = async () => {
  const [totalCoupons, activeCoupons, usageStats] = await Promise.all([
    prisma.coupon.count(),
    prisma.coupon.count({
      where: {
        isActive: true,
        OR: [
          { expiresAt: null },
          { expiresAt: { gte: new Date() } },
        ],
      },
    }),
    prisma.couponUsage.aggregate({
      _count: { id: true },
      _sum: { discount: true },
    }),
  ])

  return {
    totalCoupons,
    activeCoupons,
    totalRedemptions: usageStats._count.id,
    totalDiscountGiven: usageStats._sum.discount || 0,
  }
}
```

**Step 2: Add getCouponStats to controller**

Add at end of `backend/src/controllers/coupon.controller.ts`:

```typescript
/**
 * Get coupon statistics (Admin)
 */
export const getCouponStats = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const stats = await couponService.getCouponStats()
    res.json(formatResponse(true, 'Coupon stats retrieved', stats))
  } catch (error) {
    next(error)
  }
}
```

**Step 3: Add stats route**

Add before the USER ROUTES comment in `backend/src/routes/coupon.routes.ts`:

```typescript
/**
 * @swagger
 * /coupons/stats:
 *   get:
 *     summary: Get coupon statistics
 *     tags: [Coupons]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Coupon statistics
 */
router.get(
  '/stats',
  authenticate,
  authorize('admin'),
  couponController.getCouponStats
)
```

**Step 4: Test the endpoint**

```bash
cd backend && npm run dev
# In another terminal, test with curl (replace TOKEN with valid admin token):
curl -H "Authorization: Bearer TOKEN" http://localhost:5000/api/v1/coupons/stats
```

Expected: `{"success":true,"message":"Coupon stats retrieved","data":{"totalCoupons":0,"activeCoupons":0,"totalRedemptions":0,"totalDiscountGiven":0}}`

**Step 5: Commit**

```bash
git add backend/src/services/coupon.service.ts backend/src/controllers/coupon.controller.ts backend/src/routes/coupon.routes.ts
git commit -m "feat(backend): add coupon stats endpoint for admin dashboard"
```

---

## Task 2: Admin Panel - Add Coupon Types and API Methods

**Files:**
- Modify: `admin/src/types/index.ts`
- Modify: `admin/src/lib/api.ts`

**Step 1: Add Coupon types**

Add at end of `admin/src/types/index.ts`:

```typescript
// Coupon Types
export type DiscountType = 'PERCENTAGE' | 'FIXED'

export interface Coupon {
  id: string
  code: string
  description?: string
  discountType: DiscountType
  discountValue: number
  minOrderAmount?: number
  maxDiscount?: number
  usageLimit?: number
  usageCount: number
  perUserLimit: number
  vehicleTypeIds: string[]
  isActive: boolean
  startsAt: string
  expiresAt?: string
  createdAt: string
  updatedAt: string
}

export interface CouponStats {
  totalCoupons: number
  activeCoupons: number
  totalRedemptions: number
  totalDiscountGiven: number
}

export interface CreateCouponDto {
  code: string
  description?: string
  discountType?: DiscountType
  discountValue: number
  minOrderAmount?: number
  maxDiscount?: number
  usageLimit?: number
  perUserLimit?: number
  vehicleTypeIds?: string[]
  startsAt?: string
  expiresAt?: string
}

export interface UpdateCouponDto {
  description?: string
  discountType?: DiscountType
  discountValue?: number
  minOrderAmount?: number
  maxDiscount?: number
  usageLimit?: number
  perUserLimit?: number
  vehicleTypeIds?: string[]
  isActive?: boolean
  startsAt?: string
  expiresAt?: string
}
```

**Step 2: Add Coupon API methods**

Add before `// Auth API` comment in `admin/src/lib/api.ts`:

```typescript
  // Coupons
  listCoupons: (params?: { page?: number; limit?: number; active?: boolean; search?: string }) =>
    api.get('/coupons', params),
  getCoupon: (id: string) => api.get(`/coupons/${id}`),
  createCoupon: (data: import('@/types').CreateCouponDto) => api.post('/coupons', data),
  updateCoupon: (id: string, data: import('@/types').UpdateCouponDto) =>
    api.put(`/coupons/${id}`, data),
  deleteCoupon: (id: string) => api.delete(`/coupons/${id}`),
  getCouponStats: () => api.get('/coupons/stats'),
```

**Step 3: Commit**

```bash
git add admin/src/types/index.ts admin/src/lib/api.ts
git commit -m "feat(admin): add coupon types and API methods"
```

---

## Task 3: Admin Panel - Add Coupons to Sidebar Navigation

**Files:**
- Modify: `admin/src/components/layout/admin-layout.tsx`

**Step 1: Add Ticket import**

Update the lucide-react import to include `Ticket`:

```typescript
import {
  LayoutDashboard,
  Users,
  UserCog,
  CalendarCheck,
  Car,
  Wallet,
  BarChart3,
  Settings,
  Send,
  LogOut,
  Menu,
  X,
  Wifi,
  WifiOff,
  Ticket,
} from 'lucide-react'
```

**Step 2: Add Coupons to navItems**

Update the `navItems` array to add Coupons between Bookings and Vehicles:

```typescript
const navItems = [
  { href: '/', label: 'Dashboard', icon: LayoutDashboard },
  { href: '/users', label: 'Users', icon: Users },
  { href: '/pilots', label: 'Pilots', icon: UserCog },
  { href: '/bookings', label: 'Bookings', icon: CalendarCheck },
  { href: '/coupons', label: 'Coupons', icon: Ticket },
  { href: '/vehicles', label: 'Vehicles', icon: Car },
  { href: '/wallet', label: 'Wallet', icon: Wallet },
  { href: '/analytics', label: 'Analytics', icon: BarChart3 },
  { href: '/settings', label: 'Settings', icon: Settings },
]
```

**Step 3: Commit**

```bash
git add admin/src/components/layout/admin-layout.tsx
git commit -m "feat(admin): add Coupons link to sidebar navigation"
```

---

## Task 4: Admin Panel - Create Coupons Page

**Files:**
- Create: `admin/src/app/coupons/page.tsx`

**Step 1: Create the Coupons page**

Create `admin/src/app/coupons/page.tsx`:

```typescript
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
import { Switch } from '@/components/ui/switch'
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
                      <Badge variant="secondary">{getDiscountDisplay(coupon)}</Badge>
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
                        <Badge variant="secondary">Inactive</Badge>
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
```

**Step 2: Test the page**

```bash
cd admin && npm run dev
# Open http://localhost:3001/coupons in browser
```

Expected: Coupons page loads with stats cards, empty table, and Create Coupon button works.

**Step 3: Commit**

```bash
git add admin/src/app/coupons/page.tsx
git commit -m "feat(admin): add Coupons management page with CRUD operations"
```

---

## Task 5: User App - Create Coupon Model

**Files:**
- Create: `user_app/lib/app/data/models/coupon_model.dart`

**Step 1: Create the Coupon model**

Create `user_app/lib/app/data/models/coupon_model.dart`:

```dart
import 'package:flutter/material.dart';

class CouponModel {
  final String id;
  final String code;
  final String? description;
  final DiscountType discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscount;
  final DateTime? expiresAt;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscount,
    this.expiresAt,
    this.isActive = true,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      discountType: json['discountType'] == 'FIXED'
          ? DiscountType.fixed
          : DiscountType.percentage,
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      maxDiscount: json['maxDiscount']?.toDouble(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  /// Auto-generated banner title based on discount type
  String get bannerTitle {
    if (discountType == DiscountType.percentage) {
      return '${discountValue.toInt()}% OFF';
    } else {
      return '₹${discountValue.toInt()} OFF';
    }
  }

  /// Auto-generated banner subtitle
  String get bannerSubtitle {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    if (minOrderAmount != null && minOrderAmount! > 0) {
      return 'Min order ₹${minOrderAmount!.toInt()}';
    }
    return 'Limited time offer';
  }

  /// Get banner icon based on discount type
  IconData get bannerIcon {
    if (discountType == DiscountType.percentage) {
      return Icons.percent;
    }
    return Icons.local_offer;
  }

  /// Check if coupon is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  /// Format expiry date for display
  String? get expiryDisplay {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 30) {
      return 'Valid till ${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays} days left';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} hours left';
    }
    return 'Expires soon';
  }

  /// Gradient colors palette for banners
  static const List<List<Color>> gradientPalette = [
    [Color(0xFF667eea), Color(0xFF764ba2)], // Purple
    [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue
    [Color(0xFF43e97b), Color(0xFF38f9d7)], // Green
    [Color(0xFFfa709a), Color(0xFFfee140)], // Orange
  ];

  /// Get gradient colors for banner based on index
  List<Color> getBannerGradient(int index) {
    return gradientPalette[index % gradientPalette.length];
  }
}

enum DiscountType { percentage, fixed }
```

**Step 2: Commit**

```bash
git add user_app/lib/app/data/models/coupon_model.dart
git commit -m "feat(user_app): add CouponModel with auto-generated banner properties"
```

---

## Task 6: User App - Create Coupon Repository

**Files:**
- Create: `user_app/lib/app/data/repositories/coupon_repository.dart`

**Step 1: Create the Coupon repository**

Create `user_app/lib/app/data/repositories/coupon_repository.dart`:

```dart
import '../models/api_response.dart';
import '../models/coupon_model.dart';
import '../providers/api_client.dart';
import '../../core/constants/api_constants.dart';

class CouponRepository {
  final ApiClient _apiClient = ApiClient();

  /// Get available coupons for user
  /// GET /coupons/available
  /// Response: { "success": true, "data": { "coupons": [...] } }
  Future<ApiResponse<List<CouponModel>>> getAvailableCoupons({
    double? orderAmount,
    String? vehicleTypeId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (orderAmount != null) {
        queryParams['orderAmount'] = orderAmount;
      }
      if (vehicleTypeId != null) {
        queryParams['vehicleTypeId'] = vehicleTypeId;
      }

      final response = await _apiClient.get(
        ApiConstants.availableCoupons,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final couponsData =
            apiResponse.data!['coupons'] as List<dynamic>? ?? [];
        final coupons =
            couponsData.map((json) => CouponModel.fromJson(json)).toList();

        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: coupons,
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Failed to get available coupons',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Validate a coupon code
  /// POST /coupons/validate
  /// Body: { "code": "...", "orderAmount": 500, "vehicleTypeId": "..." }
  /// Response: { "success": true, "data": { "coupon": {...}, "discount": 50 } }
  Future<ApiResponse<Map<String, dynamic>>> validateCoupon({
    required String code,
    required double orderAmount,
    required String vehicleTypeId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.validateCoupon,
        data: {
          'code': code,
          'orderAmount': orderAmount,
          'vehicleTypeId': vehicleTypeId,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        final couponData = apiResponse.data!['coupon'];
        final discount = (apiResponse.data!['discount'] ?? 0).toDouble();

        return ApiResponse(
          success: true,
          message: apiResponse.message,
          data: {
            'coupon': couponData != null ? CouponModel.fromJson(couponData) : null,
            'discount': discount,
          },
        );
      }

      return ApiResponse(
        success: false,
        message: apiResponse.message ?? 'Invalid coupon code',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    }
  }
}
```

**Step 2: Commit**

```bash
git add user_app/lib/app/data/repositories/coupon_repository.dart
git commit -m "feat(user_app): add CouponRepository for API calls"
```

---

## Task 7: User App - Integrate Coupons with Home Controller

**Files:**
- Modify: `user_app/lib/app/modules/home/controllers/home_controller.dart`

**Step 1: Add coupon imports and variables**

Add import at top of file:

```dart
import '../../../data/models/coupon_model.dart';
import '../../../data/repositories/coupon_repository.dart';
```

Add after `final BookingRepository _bookingRepository = BookingRepository();`:

```dart
  final CouponRepository _couponRepository = CouponRepository();
```

Add after `final isLoadingVehicles = false.obs;`:

```dart
  // Available coupons/offers
  final availableCoupons = <CouponModel>[].obs;
  final isLoadingCoupons = false.obs;
```

**Step 2: Add fetchAvailableCoupons method**

Add after `fetchVehicleTypes()` method:

```dart
  /// Fetch available coupons for offers section
  Future<void> fetchAvailableCoupons() async {
    try {
      isLoadingCoupons.value = true;
      final response = await _couponRepository.getAvailableCoupons();
      if (response.success && response.data != null) {
        availableCoupons.value = response.data!;
      }
    } catch (e) {
      // Silent fail for coupons
    } finally {
      isLoadingCoupons.value = false;
    }
  }
```

**Step 3: Call fetchAvailableCoupons in onInit**

Update `onInit()` to include `fetchAvailableCoupons();`:

```dart
  @override
  void onInit() {
    super.onInit();
    fetchVehicleTypes();
    fetchActiveDeliveries();
    fetchRecentOrders();
    fetchAvailableCoupons();
  }
```

**Step 4: Update refreshData to include coupons**

Update `refreshData()`:

```dart
  Future<void> refreshData() async {
    await Future.wait([
      fetchVehicleTypes(),
      fetchActiveDeliveries(),
      fetchRecentOrders(),
      fetchAvailableCoupons(),
    ]);
  }
```

**Step 5: Commit**

```bash
git add user_app/lib/app/modules/home/controllers/home_controller.dart
git commit -m "feat(user_app): integrate coupon fetching with home controller"
```

---

## Task 8: User App - Create Offer Details Bottom Sheet and Update Dashboard

**Files:**
- Create: `user_app/lib/app/modules/home/widgets/offer_details_sheet.dart`
- Modify: `user_app/lib/app/modules/home/views/main_view.dart`

**Step 1: Create the offer details bottom sheet**

Create `user_app/lib/app/modules/home/widgets/offer_details_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/coupon_model.dart';
import '../../../routes/app_routes.dart';

class OfferDetailsSheet extends StatelessWidget {
  final CouponModel coupon;
  final List<Color> gradientColors;

  const OfferDetailsSheet({
    super.key,
    required this.coupon,
    required this.gradientColors,
  });

  static void show(BuildContext context, CouponModel coupon, List<Color> colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OfferDetailsSheet(
        coupon: coupon,
        gradientColors: colors,
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    Get.snackbar(
      'Code Copied!',
      'Use code ${coupon.code} at checkout',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.primary,
      colorText: Theme.of(context).colorScheme.onPrimary,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _useNow() {
    Get.back(); // Close bottom sheet
    Get.toNamed(Routes.createBooking, arguments: {'couponCode': coupon.code});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Gradient header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    coupon.bannerIcon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coupon.bannerTitle,
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.bannerSubtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Coupon code
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.dividerColor,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Promo Code',
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        coupon.code,
                        style: AppTextStyles.h4.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _copyCode(context),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (coupon.minOrderAmount != null && coupon.minOrderAmount! > 0)
                  _buildDetailRow(
                    context,
                    icon: Icons.shopping_cart_outlined,
                    label: 'Minimum Order',
                    value: '₹${coupon.minOrderAmount!.toInt()}',
                  ),
                if (coupon.maxDiscount != null &&
                    coupon.discountType == DiscountType.percentage)
                  _buildDetailRow(
                    context,
                    icon: Icons.savings_outlined,
                    label: 'Maximum Discount',
                    value: '₹${coupon.maxDiscount!.toInt()}',
                  ),
                if (coupon.expiryDisplay != null)
                  _buildDetailRow(
                    context,
                    icon: Icons.schedule_outlined,
                    label: 'Validity',
                    value: coupon.expiryDisplay!,
                    valueColor: coupon.isExpired ? Colors.red : null,
                  ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Maybe Later'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _useNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Use Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Update main_view.dart to use dynamic coupons**

First, add import at top of `main_view.dart`:

```dart
import '../../../data/models/coupon_model.dart';
import '../widgets/offer_details_sheet.dart';
```

Then replace the entire `_buildOffersBanner` method:

```dart
  Widget _buildOffersBanner(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Offers & Deals',
            style: AppTextStyles.h4.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: Obx(() {
            if (controller.isLoadingCoupons.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.availableCoupons.isEmpty) {
              return Center(
                child: Text(
                  'No offers available',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.availableCoupons.length,
              itemBuilder: (context, index) {
                final coupon = controller.availableCoupons[index];
                return _buildDynamicOfferCard(context, coupon, index);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDynamicOfferCard(BuildContext context, CouponModel coupon, int index) {
    final gradientColors = coupon.getBannerGradient(index);

    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => OfferDetailsSheet.show(context, coupon, gradientColors),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        coupon.bannerIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        coupon.code,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coupon.bannerTitle,
                      style: AppTextStyles.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      coupon.bannerSubtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
```

**Step 3: Remove the old static _OfferData class and _buildOfferCard method**

Delete the `_buildOfferCard` method and the `_OfferData` class at the bottom of the file (they are no longer needed).

**Step 4: Test**

```bash
cd user_app && flutter run
```

Expected: Dashboard shows "No offers available" or dynamic coupons from API if any exist.

**Step 5: Commit**

```bash
git add user_app/lib/app/modules/home/widgets/offer_details_sheet.dart user_app/lib/app/modules/home/views/main_view.dart
git commit -m "feat(user_app): add dynamic offer banners with details bottom sheet"
```

---

## Testing Checklist

- [ ] Backend: `/coupons/stats` endpoint returns correct data
- [ ] Admin: Can create a new coupon
- [ ] Admin: Can edit an existing coupon
- [ ] Admin: Can delete/deactivate a coupon
- [ ] Admin: Stats cards show correct numbers
- [ ] User App: Offers section loads coupons from API
- [ ] User App: Tapping offer shows bottom sheet with details
- [ ] User App: Copy code button works
- [ ] User App: "Use Now" navigates to booking screen
- [ ] User App: Empty state shows when no coupons available

---

## Success Criteria

All items from the design document:
- [x] Admin can create, edit, delete coupons from admin panel
- [x] Admin can see coupon usage statistics
- [x] User app displays available coupons as offer banners
- [x] Banners auto-generate title/subtitle/colors from coupon data
- [x] Tapping banner shows details bottom sheet
- [x] User can copy promo code from bottom sheet
- [x] "Use Now" navigates to booking with code
- [x] Expired/inactive coupons don't appear in user app
