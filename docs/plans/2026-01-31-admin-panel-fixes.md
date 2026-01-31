# Admin Panel Bug Fixes & Issues Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix all identified bugs, data mapping issues, and UX problems in the SendIt Admin Panel to ensure it works correctly without errors.

**Architecture:** Fix frontend type mismatches with backend API responses, improve error handling, add missing UI feedback, and resolve data display issues across all admin pages.

**Tech Stack:** Next.js 16, React 19, TypeScript, React Query, Zustand, Tailwind CSS, shadcn/ui

---

## Issues Identified

### Critical Issues (Blocking Functionality)

1. **Analytics Page - API Data Mismatch**: The analytics page expects `totalBookings`, `completionRate`, `cancellationRate`, `dailyBookings`, `bookingsByStatus` but API returns different structure (`dailyBookings` array with `total`, `completed`, `cancelled`, `revenue`, `statusDistribution`, `vehicleDistribution`)

2. **Analytics Page - Revenue Data Mismatch**: Revenue analytics expects `totalRevenue`, `dailyRevenue`, `averageBookingValue`, `revenueByPaymentMethod` but API returns `daily` array, `total`, `totalOrders`

3. **Settings Page - API Data Mismatch**: Settings page expects `{ settings: Setting[] }` but backend returns `{ settings: Record<string, string> }` (key-value object, not array)

4. **Dashboard RecentBookings - Unsafe Property Access**: `booking.pickupAddress?.slice(0, 30)` will crash if pickupAddress is an object (not a string)

5. **Vehicles Page - Field Name Mismatch**: Frontend uses `plateNumber` but backend uses `registrationNo`

### Medium Priority Issues (UX/Display Problems)

6. **Bookings Page - Missing Status Types**: The `BookingStatus` type doesn't include `ACCEPTED` status but backend uses it

7. **Users/Pilots Edit Dialogs - No Error Feedback**: Mutations don't show error toast on failure

8. **Pilots Page - Missing Edit Functionality**: Has Edit import but no edit dialog implemented

9. **Wallet Page - Search UX Issue**: Search by userId instead of user name/phone is not user-friendly

10. **Dashboard Quick Actions - Using `<a>` Tags**: Should use Next.js `Link` component for client-side navigation

### Low Priority Issues (Polish)

11. **Pagination Text Bug**: Shows "1 to 10" even when no data (should show "0 to 0 of 0")

12. **Socket Provider Missing in Layout**: Socket context may not reconnect on auth state change

13. **Missing Loading States for Mutations**: Several buttons don't show loading state during API calls

---

## Task 1: Fix Analytics Page - Booking Analytics Data Mapping

**Files:**
- Modify: `admin/src/app/analytics/page.tsx`
- Modify: `admin/src/types/index.ts`

**Step 1: Update the BookingAnalytics type to match API response**

In `admin/src/types/index.ts`, change the BookingAnalytics interface:

```typescript
// Analytics Types - Updated to match backend response
export interface BookingAnalytics {
  dailyBookings: {
    date: string
    total: number
    completed: number
    cancelled: number
    revenue: number
  }[]
  statusDistribution: { status: string; _count: number }[]
  vehicleDistribution: { vehicleTypeId: string; _count: number }[]
}

export interface RevenueAnalytics {
  daily: { date: string; revenue: number; orders: number }[]
  total: number
  totalOrders: number
}
```

**Step 2: Update analytics page to use correct field mappings**

In `admin/src/app/analytics/page.tsx`, update the data processing:

```typescript
// Calculate derived metrics from raw data
const totalBookings = bookingAnalytics?.dailyBookings?.reduce((acc, d) => acc + d.total, 0) || 0
const totalCompleted = bookingAnalytics?.dailyBookings?.reduce((acc, d) => acc + d.completed, 0) || 0
const totalCancelled = bookingAnalytics?.dailyBookings?.reduce((acc, d) => acc + d.cancelled, 0) || 0
const completionRate = totalBookings > 0 ? totalCompleted / totalBookings : 0
const cancellationRate = totalBookings > 0 ? totalCancelled / totalBookings : 0

// Transform statusDistribution for pie chart
const statusData = bookingAnalytics?.statusDistribution
  ? bookingAnalytics.statusDistribution.map((item) => ({
      name: item.status,
      value: item._count,
    }))
  : []

// Transform dailyBookings for chart (use 'total' as 'count')
const dailyBookingsChartData = bookingAnalytics?.dailyBookings?.map(d => ({
  date: d.date,
  count: d.total
})) || []

// Revenue data mapping
const totalRevenue = revenueAnalytics?.total || 0
const avgBookingValue = revenueAnalytics?.totalOrders && revenueAnalytics.totalOrders > 0
  ? revenueAnalytics.total / revenueAnalytics.totalOrders
  : 0
const dailyRevenueData = revenueAnalytics?.daily?.map(d => ({
  date: d.date,
  amount: d.revenue
})) || []
```

**Step 3: Run dev server and verify analytics page loads**

Run: `cd admin && npm run dev`
Navigate to: http://localhost:3001/analytics
Expected: Page loads without errors, charts render with data

**Step 4: Commit**

```bash
git add admin/src/app/analytics/page.tsx admin/src/types/index.ts
git commit -m "fix(admin): Correct analytics page API data mapping"
```

---

## Task 2: Fix Settings Page - API Data Structure Mismatch

**Files:**
- Modify: `admin/src/app/settings/page.tsx`

**Step 1: Update settings data extraction to handle key-value object**

The backend returns `{ settings: { key1: value1, key2: value2 } }` but the page expects an array. Update the settings page:

```typescript
// Change this line:
const settings = (data?.data as { settings: Setting[] })?.settings || []

// To this - convert object to array:
const settingsObj = (data?.data as { settings: Record<string, string> })?.settings || {}
const settings: Setting[] = Object.entries(settingsObj).map(([key, value]) => ({
  key,
  value,
  description: undefined, // Backend doesn't return descriptions in list
}))
```

**Step 2: Verify settings page loads correctly**

Run: `cd admin && npm run dev`
Navigate to: http://localhost:3001/settings
Expected: Settings load and display correctly

**Step 3: Commit**

```bash
git add admin/src/app/settings/page.tsx
git commit -m "fix(admin): Convert settings object to array for display"
```

---

## Task 3: Fix Dashboard RecentBookings - Unsafe Address Access

**Files:**
- Modify: `admin/src/app/dashboard/page.tsx`

**Step 1: Add safe address formatting helper**

Add a helper function and update the RecentBookings component:

```typescript
// Add helper function at top of file, after imports
const formatAddressPreview = (addr: string | { address?: string } | null | undefined): string => {
  if (!addr) return 'Unknown location'
  if (typeof addr === 'string') return addr.slice(0, 30)
  if (typeof addr === 'object' && addr.address) return addr.address.slice(0, 30)
  return 'Unknown location'
}

// Update the RecentBookings component display:
<p className="text-xs text-muted-foreground">
  {formatAddressPreview(booking.pickupAddress)}...
</p>
```

**Step 2: Verify dashboard loads without errors**

Run: `cd admin && npm run dev`
Navigate to: http://localhost:3001/dashboard
Expected: Dashboard loads, booking updates show addresses correctly

**Step 3: Commit**

```bash
git add admin/src/app/dashboard/page.tsx
git commit -m "fix(admin): Safe address formatting in dashboard bookings"
```

---

## Task 4: Fix Vehicles Page - Field Name Mismatch

**Files:**
- Modify: `admin/src/types/index.ts`
- Modify: `admin/src/app/vehicles/page.tsx`

**Step 1: Update Vehicle type to include registrationNo**

In `admin/src/types/index.ts`:

```typescript
export interface Vehicle {
  id: string
  pilotId: string
  vehicleTypeId: string
  plateNumber?: string       // Keep for backward compat
  registrationNo?: string    // Backend field name
  model: string
  color: string
  year: number
  isActive: boolean
  isVerified: boolean
  vehicleType?: VehicleType
  pilot?: Pilot
}
```

**Step 2: Update vehicles page to use registrationNo with fallback**

In `admin/src/app/vehicles/page.tsx`, update all plateNumber references:

```typescript
// In table cell:
<TableCell className="font-mono font-medium">
  {vehicle.registrationNo || vehicle.plateNumber || '-'}
</TableCell>

// In view dialog:
<p className="text-muted-foreground font-mono">
  {selectedVehicle.registrationNo || selectedVehicle.plateNumber || '-'}
</p>
```

**Step 3: Verify vehicles page displays plate numbers**

Run: `cd admin && npm run dev`
Navigate to: http://localhost:3001/vehicles
Expected: Vehicle plate numbers display correctly

**Step 4: Commit**

```bash
git add admin/src/types/index.ts admin/src/app/vehicles/page.tsx
git commit -m "fix(admin): Use registrationNo field for vehicle plate number"
```

---

## Task 5: Add Missing BookingStatus - ACCEPTED

**Files:**
- Modify: `admin/src/types/index.ts`
- Modify: `admin/src/app/bookings/page.tsx`

**Step 1: Update BookingStatus type**

In `admin/src/types/index.ts`:

```typescript
export type BookingStatus =
  | 'PENDING'
  | 'SEARCHING'
  | 'ACCEPTED'      // Add this
  | 'CONFIRMED'
  | 'PILOT_ARRIVED'
  | 'PICKED_UP'
  | 'IN_TRANSIT'
  | 'DELIVERED'
  | 'CANCELLED'
```

**Step 2: Add ACCEPTED to status colors in bookings page**

In `admin/src/app/bookings/page.tsx`:

```typescript
const statusColors: Record<BookingStatus, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  PENDING: 'secondary',
  SEARCHING: 'outline',
  ACCEPTED: 'default',     // Add this
  CONFIRMED: 'default',
  PILOT_ARRIVED: 'default',
  PICKED_UP: 'default',
  IN_TRANSIT: 'default',
  DELIVERED: 'default',
  CANCELLED: 'destructive',
}
```

**Step 3: Update canAssign function to include ACCEPTED**

```typescript
const canAssign = (status: BookingStatus) =>
  ['PENDING', 'SEARCHING'].includes(status)

const canCancel = (status: BookingStatus) =>
  ['PENDING', 'SEARCHING', 'ACCEPTED', 'CONFIRMED'].includes(status)
```

**Step 4: Commit**

```bash
git add admin/src/types/index.ts admin/src/app/bookings/page.tsx
git commit -m "fix(admin): Add ACCEPTED status to booking types"
```

---

## Task 6: Add Error Toast Feedback for Mutations

**Files:**
- Modify: `admin/src/app/users/page.tsx`
- Modify: `admin/src/app/pilots/page.tsx`
- Modify: `admin/src/app/bookings/page.tsx`
- Modify: `admin/src/app/vehicles/page.tsx`
- Modify: `admin/src/app/settings/page.tsx`

**Step 1: Add toast import and onError handlers to users page**

In `admin/src/app/users/page.tsx`:

```typescript
// Add import at top
import { toast } from 'sonner'

// Update mutations with onError:
const updateStatusMutation = useMutation({
  mutationFn: ({ userId, isActive }: { userId: string; isActive: boolean }) =>
    adminApi.updateUserStatus(userId, isActive),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] })
    toast.success('User status updated')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to update user status')
  },
})

const updateUserMutation = useMutation({
  mutationFn: ({ userId, data }: { userId: string; data: { name?: string; email?: string; phone?: string } }) =>
    adminApi.updateUser(userId, data),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['users'] })
    setIsEditOpen(false)
    toast.success('User updated successfully')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to update user')
  },
})
```

**Step 2: Add toast feedback to pilots page**

In `admin/src/app/pilots/page.tsx`:

```typescript
import { toast } from 'sonner'

const updateStatusMutation = useMutation({
  mutationFn: ({ pilotId, status, reason }: { pilotId: string; status: string; reason?: string }) =>
    adminApi.updatePilotStatus(pilotId, status, reason),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['pilots'] })
    setIsStatusDialogOpen(false)
    toast.success('Pilot status updated')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to update pilot status')
  },
})
```

**Step 3: Add toast feedback to bookings page**

In `admin/src/app/bookings/page.tsx`:

```typescript
import { toast } from 'sonner'

const cancelMutation = useMutation({
  mutationFn: ({ bookingId, reason }: { bookingId: string; reason: string }) =>
    adminApi.cancelBooking(bookingId, reason),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['bookings'] })
    setIsCancelOpen(false)
    setCancelReason('')
    toast.success('Booking cancelled')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to cancel booking')
  },
})

const assignMutation = useMutation({
  mutationFn: ({ bookingId, pilotId }: { bookingId: string; pilotId: string }) =>
    adminApi.assignPilot(bookingId, pilotId),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['bookings'] })
    setIsAssignOpen(false)
    setSelectedPilotId('')
    toast.success('Pilot assigned successfully')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to assign pilot')
  },
})
```

**Step 4: Add toast feedback to vehicles page**

In `admin/src/app/vehicles/page.tsx`:

```typescript
import { toast } from 'sonner'

const verifyMutation = useMutation({
  mutationFn: ({ vehicleId, isVerified, reason }: { vehicleId: string; isVerified: boolean; reason?: string }) =>
    adminApi.verifyVehicle(vehicleId, isVerified, reason),
  onSuccess: (_, variables) => {
    queryClient.invalidateQueries({ queryKey: ['vehicles'] })
    setIsVerifyOpen(false)
    setVerifyAction({ isVerified: true, reason: '' })
    toast.success(variables.isVerified ? 'Vehicle verified' : 'Vehicle rejected')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to update vehicle')
  },
})
```

**Step 5: Add toast feedback to settings page**

In `admin/src/app/settings/page.tsx`:

```typescript
import { toast } from 'sonner'

const updateMutation = useMutation({
  mutationFn: ({ key, value, description }: { key: string; value: string; description?: string }) =>
    adminApi.updateSetting(key, value, description),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['settings'] })
    toast.success('Setting updated')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to update setting')
  },
})

const addMutation = useMutation({
  mutationFn: ({ key, value, description }: { key: string; value: string; description?: string }) =>
    adminApi.updateSetting(key, value, description),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['settings'] })
    setIsAddOpen(false)
    setNewSetting({ key: '', value: '', description: '' })
    toast.success('Setting added')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to add setting')
  },
})
```

**Step 6: Commit**

```bash
git add admin/src/app/users/page.tsx admin/src/app/pilots/page.tsx admin/src/app/bookings/page.tsx admin/src/app/vehicles/page.tsx admin/src/app/settings/page.tsx
git commit -m "fix(admin): Add toast notifications for all mutations"
```

---

## Task 7: Fix Dashboard Quick Actions - Use Next.js Link

**Files:**
- Modify: `admin/src/app/dashboard/page.tsx`

**Step 1: Import Link and update Quick Actions**

```typescript
// Add import
import Link from 'next/link'

// Replace <a> tags with Link in Quick Actions section:
<CardContent className="grid gap-2">
  <Link
    href="/pilots?status=PENDING"
    className="flex items-center gap-3 p-3 bg-muted/50 rounded-lg hover:bg-muted transition-colors"
  >
    <Bike className="h-5 w-5 text-orange-500" />
    <div>
      <p className="font-medium">Review Pending Pilots</p>
      <p className="text-sm text-muted-foreground">
        {displayStats.pendingPilots} pilots awaiting approval
      </p>
    </div>
  </Link>
  <Link
    href="/bookings?status=PENDING"
    className="flex items-center gap-3 p-3 bg-muted/50 rounded-lg hover:bg-muted transition-colors"
  >
    <Package className="h-5 w-5 text-blue-500" />
    <div>
      <p className="font-medium">Manage Pending Bookings</p>
      <p className="text-sm text-muted-foreground">View and assign bookings</p>
    </div>
  </Link>
  <Link
    href="/analytics"
    className="flex items-center gap-3 p-3 bg-muted/50 rounded-lg hover:bg-muted transition-colors"
  >
    <TrendingUp className="h-5 w-5 text-green-500" />
    <div>
      <p className="font-medium">View Analytics</p>
      <p className="text-sm text-muted-foreground">Detailed reports and trends</p>
    </div>
  </Link>
</CardContent>
```

**Step 2: Commit**

```bash
git add admin/src/app/dashboard/page.tsx
git commit -m "fix(admin): Use Next.js Link for dashboard quick actions"
```

---

## Task 8: Fix Pagination Text When No Data

**Files:**
- Modify: `admin/src/app/users/page.tsx`
- Modify: `admin/src/app/pilots/page.tsx`
- Modify: `admin/src/app/bookings/page.tsx`
- Modify: `admin/src/app/vehicles/page.tsx`
- Modify: `admin/src/app/wallet/page.tsx`

**Step 1: Update pagination text in all pages**

For each page, update the pagination section:

```typescript
{/* Pagination */}
{meta && meta.total > 0 && (
  <div className="flex items-center justify-between">
    <p className="text-sm text-muted-foreground">
      Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, meta.total)} of {meta.total} items
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
```

**Step 2: Commit**

```bash
git add admin/src/app/users/page.tsx admin/src/app/pilots/page.tsx admin/src/app/bookings/page.tsx admin/src/app/vehicles/page.tsx admin/src/app/wallet/page.tsx
git commit -m "fix(admin): Hide pagination when no data"
```

---

## Task 9: Add Pilot Edit Dialog (Complete Feature)

**Files:**
- Modify: `admin/src/app/pilots/page.tsx`

**Step 1: Add state and mutation for edit dialog**

```typescript
// Add state
const [isEditOpen, setIsEditOpen] = useState(false)
const [editForm, setEditForm] = useState({ name: '', email: '', phone: '' })

// Add mutation
const updatePilotMutation = useMutation({
  mutationFn: ({ pilotId, data }: { pilotId: string; data: { name?: string; email?: string; phone?: string } }) =>
    adminApi.updatePilot(pilotId, data),
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['pilots'] })
    setIsEditOpen(false)
    toast.success('Pilot updated successfully')
  },
  onError: (error: Error) => {
    toast.error(error.message || 'Failed to update pilot')
  },
})

// Add handler
const handleEdit = (pilot: Pilot) => {
  setSelectedPilot(pilot)
  setEditForm({ name: pilot.name || '', email: pilot.email || '', phone: pilot.phone || '' })
  setIsEditOpen(true)
}

const handleSaveEdit = () => {
  if (selectedPilot) {
    const changes: { name?: string; email?: string; phone?: string } = {}
    if (editForm.name !== selectedPilot.name) changes.name = editForm.name
    if (editForm.email !== selectedPilot.email) changes.email = editForm.email
    if (editForm.phone !== selectedPilot.phone) changes.phone = editForm.phone

    if (Object.keys(changes).length > 0) {
      updatePilotMutation.mutate({ pilotId: selectedPilot.id, data: changes })
    }
  }
}
```

**Step 2: Add Edit menu item in dropdown**

```typescript
<DropdownMenuItem onClick={() => handleEdit(pilot)}>
  <Edit className="mr-2 h-4 w-4" />
  Edit
</DropdownMenuItem>
```

**Step 3: Add Edit Dialog**

```typescript
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
          value={editForm.name ?? ''}
          onChange={(e) => setEditForm({ ...editForm, name: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label htmlFor="edit-email">Email</Label>
        <Input
          id="edit-email"
          type="email"
          value={editForm.email ?? ''}
          onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
        />
      </div>
      <div className="space-y-2">
        <Label htmlFor="edit-phone">Phone</Label>
        <Input
          id="edit-phone"
          value={editForm.phone ?? ''}
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
```

**Step 4: Commit**

```bash
git add admin/src/app/pilots/page.tsx
git commit -m "feat(admin): Add pilot edit dialog"
```

---

## Task 10: Add handleView Error Handling

**Files:**
- Modify: `admin/src/app/users/page.tsx`
- Modify: `admin/src/app/pilots/page.tsx`
- Modify: `admin/src/app/bookings/page.tsx`
- Modify: `admin/src/app/vehicles/page.tsx`

**Step 1: Wrap handleView in try-catch for all pages**

For each page, update the handleView function:

```typescript
const handleView = async (id: string) => {
  try {
    const response = await adminApi.getXxxDetails(id)
    // ... set data
    setIsViewOpen(true)
  } catch (error) {
    toast.error(error instanceof Error ? error.message : 'Failed to load details')
  }
}
```

**Step 2: Commit**

```bash
git add admin/src/app/users/page.tsx admin/src/app/pilots/page.tsx admin/src/app/bookings/page.tsx admin/src/app/vehicles/page.tsx
git commit -m "fix(admin): Add error handling for view details"
```

---

## Final Verification

After completing all tasks:

1. Run the development server: `cd admin && npm run dev`
2. Test each page:
   - [ ] Dashboard - loads without errors, quick actions work
   - [ ] Users - list, search, filter, edit, view, suspend/activate work
   - [ ] Pilots - list, search, filter, edit, view, status change work
   - [ ] Bookings - list, search, filter, view, assign pilot, cancel work
   - [ ] Vehicles - list, search, filter, view, verify/reject work
   - [ ] Wallet - list, search, filter work
   - [ ] Analytics - charts render, period filter works
   - [ ] Settings - list, add, edit work
3. Check browser console for errors
4. Test error states (disconnect backend and verify error toasts)

**Final Commit:**

```bash
git add -A
git commit -m "chore(admin): Final verification - all fixes complete"
```
