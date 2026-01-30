'use client'

import { useQuery } from '@tanstack/react-query'
import { Users, Bike, Package, DollarSign, Clock, CheckCircle, TrendingUp, Activity } from 'lucide-react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { AdminLayout } from '@/components/layout/admin-layout'
import { adminApi } from '@/lib/api'
import { useSocket } from '@/lib/socket'
import type { DashboardStats, Booking } from '@/types'

function StatCard({
  title,
  value,
  description,
  icon: Icon,
  trend,
}: {
  title: string
  value: string | number
  description?: string
  icon: React.ElementType
  trend?: 'up' | 'down' | 'neutral'
}) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">{title}</CardTitle>
        <Icon className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">{value}</div>
        {description && (
          <p className="text-xs text-muted-foreground flex items-center gap-1">
            {trend === 'up' && <TrendingUp className="h-3 w-3 text-green-500" />}
            {description}
          </p>
        )}
      </CardContent>
    </Card>
  )
}

function RecentBookings({ bookings }: { bookings: Booking[] }) {
  const statusColors: Record<string, string> = {
    PENDING: 'bg-yellow-500',
    SEARCHING: 'bg-blue-500',
    CONFIRMED: 'bg-purple-500',
    PILOT_ARRIVED: 'bg-indigo-500',
    PICKED_UP: 'bg-cyan-500',
    IN_TRANSIT: 'bg-orange-500',
    DELIVERED: 'bg-green-500',
    CANCELLED: 'bg-red-500',
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Activity className="h-5 w-5" />
          Live Booking Updates
        </CardTitle>
        <CardDescription>Real-time booking activity</CardDescription>
      </CardHeader>
      <CardContent>
        {bookings.length === 0 ? (
          <p className="text-muted-foreground text-sm text-center py-4">No recent updates</p>
        ) : (
          <div className="space-y-3">
            {bookings.map((booking) => (
              <div
                key={booking.id}
                className="flex items-center justify-between p-3 bg-muted/50 rounded-lg"
              >
                <div className="flex items-center gap-3">
                  <div className={`w-2 h-2 rounded-full ${statusColors[booking.status]}`} />
                  <div>
                    <p className="text-sm font-medium">#{booking.id.slice(0, 8)}</p>
                    <p className="text-xs text-muted-foreground">
                      {booking.pickupAddress?.slice(0, 30)}...
                    </p>
                  </div>
                </div>
                <Badge variant="outline">{booking.status}</Badge>
              </div>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  )
}

export default function DashboardPage() {
  const { realtimeStats, bookingUpdates } = useSocket()

  const { data, isLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => adminApi.getDashboard(),
    refetchInterval: 30000, // Refresh every 30 seconds
  })

  const stats = (data?.data as DashboardStats) || {}

  // Merge real-time stats with API data
  const displayStats = {
    totalUsers: stats.totalUsers || 0,
    totalPilots: stats.totalPilots || 0,
    totalBookings: stats.totalBookings || 0,
    totalRevenue: stats.totalRevenue || 0,
    pendingPilots: stats.pendingPilots || 0,
    activeBookings: realtimeStats?.activeBookings ?? stats.activeBookings ?? 0,
    onlinePilots: realtimeStats?.onlinePilots ?? stats.onlinePilots ?? 0,
    todayDeliveries: realtimeStats?.todayDeliveries ?? stats.todayBookings ?? 0,
    todayRevenue: realtimeStats?.todayRevenue ?? stats.todayRevenue ?? 0,
  }

  if (isLoading) {
    return (
      <AdminLayout>
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
        </div>
      </AdminLayout>
    )
  }

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">Dashboard</h1>
          <p className="text-muted-foreground">Welcome to SendIt Admin Panel</p>
        </div>

        {/* Overview Stats */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <StatCard
            title="Total Users"
            value={displayStats.totalUsers.toLocaleString()}
            icon={Users}
          />
          <StatCard
            title="Total Pilots"
            value={displayStats.totalPilots.toLocaleString()}
            description={`${displayStats.pendingPilots} pending approval`}
            icon={Bike}
          />
          <StatCard
            title="Total Bookings"
            value={displayStats.totalBookings.toLocaleString()}
            icon={Package}
          />
          <StatCard
            title="Total Revenue"
            value={`₹${displayStats.totalRevenue.toLocaleString()}`}
            icon={DollarSign}
          />
        </div>

        {/* Real-time Stats */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <StatCard
            title="Active Bookings"
            value={displayStats.activeBookings}
            description="Currently in progress"
            icon={Clock}
          />
          <StatCard
            title="Online Pilots"
            value={displayStats.onlinePilots}
            description="Available for pickup"
            icon={Activity}
          />
          <StatCard
            title="Today's Deliveries"
            value={displayStats.todayDeliveries}
            description="Completed today"
            icon={CheckCircle}
            trend="up"
          />
          <StatCard
            title="Today's Revenue"
            value={`₹${displayStats.todayRevenue.toLocaleString()}`}
            description="Earned today"
            icon={TrendingUp}
            trend="up"
          />
        </div>

        {/* Live Updates */}
        <div className="grid gap-4 lg:grid-cols-2">
          <RecentBookings bookings={bookingUpdates} />
          <Card>
            <CardHeader>
              <CardTitle>Quick Actions</CardTitle>
              <CardDescription>Common administrative tasks</CardDescription>
            </CardHeader>
            <CardContent className="grid gap-2">
              <a
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
              </a>
              <a
                href="/bookings?status=PENDING"
                className="flex items-center gap-3 p-3 bg-muted/50 rounded-lg hover:bg-muted transition-colors"
              >
                <Package className="h-5 w-5 text-blue-500" />
                <div>
                  <p className="font-medium">Manage Pending Bookings</p>
                  <p className="text-sm text-muted-foreground">View and assign bookings</p>
                </div>
              </a>
              <a
                href="/analytics"
                className="flex items-center gap-3 p-3 bg-muted/50 rounded-lg hover:bg-muted transition-colors"
              >
                <TrendingUp className="h-5 w-5 text-green-500" />
                <div>
                  <p className="font-medium">View Analytics</p>
                  <p className="text-sm text-muted-foreground">Detailed reports and trends</p>
                </div>
              </a>
            </CardContent>
          </Card>
        </div>
      </div>
    </AdminLayout>
  )
}
