'use client'

import { useState } from 'react'
import { useQuery } from '@tanstack/react-query'
import { AdminLayout } from '@/components/layout/admin-layout'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Bar, BarChart, Line, LineChart, XAxis, YAxis, ResponsiveContainer, Pie, PieChart, Cell, Tooltip } from 'recharts'
import { adminApi } from '@/lib/api'
import type { BookingAnalytics, RevenueAnalytics } from '@/types'

const COLORS = ['#0088FE', '#00C49F', '#FFBB28', '#FF8042', '#8884D8', '#82CA9D', '#FFC658', '#FF6B6B']

export default function AnalyticsPage() {
  const [days, setDays] = useState('30')

  const { data: bookingData, isLoading: loadingBookings } = useQuery({
    queryKey: ['analytics-bookings', days],
    queryFn: () => adminApi.getBookingAnalytics(parseInt(days)),
  })

  const { data: revenueData, isLoading: loadingRevenue } = useQuery({
    queryKey: ['analytics-revenue', days],
    queryFn: () => adminApi.getRevenueAnalytics(parseInt(days)),
  })

  const bookingAnalytics = bookingData?.data as BookingAnalytics | undefined
  const revenueAnalytics = revenueData?.data as RevenueAnalytics | undefined

  const isLoading = loadingBookings || loadingRevenue

  // Calculate derived booking metrics from dailyBookings array
  const totalBookings = bookingAnalytics?.dailyBookings?.reduce((acc, d) => acc + d.total, 0) || 0
  const totalCompleted = bookingAnalytics?.dailyBookings?.reduce((acc, d) => acc + d.completed, 0) || 0
  const totalCancelled = bookingAnalytics?.dailyBookings?.reduce((acc, d) => acc + d.cancelled, 0) || 0
  const completionRate = totalBookings > 0 ? totalCompleted / totalBookings : 0
  const cancellationRate = totalBookings > 0 ? totalCancelled / totalBookings : 0

  // Transform dailyBookings for bar chart (use total as count)
  const dailyBookingsChartData = bookingAnalytics?.dailyBookings?.map((d) => ({
    date: d.date,
    count: d.total,
  })) || []

  // Transform statusDistribution for pie chart (map _count to value)
  const statusData = bookingAnalytics?.statusDistribution?.map((item) => ({
    name: item.status,
    value: item._count,
  })) || []

  // Calculate revenue metrics
  const totalRevenue = revenueAnalytics?.total || 0
  const totalOrders = revenueAnalytics?.totalOrders || 0
  const avgBookingValue = totalOrders > 0 ? totalRevenue / totalOrders : 0

  // Transform daily revenue array for line chart
  const dailyRevenueChartData = revenueAnalytics?.daily?.map((d) => ({
    date: d.date,
    amount: d.revenue,
  })) || []

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Analytics</h1>
            <p className="text-muted-foreground">Business insights and trends</p>
          </div>
          <Select value={days} onValueChange={setDays}>
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Select period" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="7">Last 7 days</SelectItem>
              <SelectItem value="30">Last 30 days</SelectItem>
              <SelectItem value="90">Last 90 days</SelectItem>
              <SelectItem value="365">Last year</SelectItem>
            </SelectContent>
          </Select>
        </div>

        {isLoading ? (
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
          </div>
        ) : (
          <Tabs defaultValue="bookings" className="space-y-6">
            <TabsList>
              <TabsTrigger value="bookings">Bookings</TabsTrigger>
              <TabsTrigger value="revenue">Revenue</TabsTrigger>
            </TabsList>

            <TabsContent value="bookings" className="space-y-6">
              {/* Summary Cards */}
              <div className="grid gap-4 md:grid-cols-4">
                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm font-medium">Total Bookings</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold">
                      {totalBookings.toLocaleString()}
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm font-medium">Completion Rate</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold text-green-600">
                      {(completionRate * 100).toFixed(1)}%
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm font-medium">Cancellation Rate</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold text-red-600">
                      {(cancellationRate * 100).toFixed(1)}%
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm font-medium">Avg Daily Bookings</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold">
                      {dailyBookingsChartData.length > 0
                        ? Math.round(totalBookings / dailyBookingsChartData.length)
                        : 0}
                    </div>
                  </CardContent>
                </Card>
              </div>

              {/* Charts */}
              <div className="grid gap-6 lg:grid-cols-2">
                <Card>
                  <CardHeader>
                    <CardTitle>Daily Bookings</CardTitle>
                    <CardDescription>Number of bookings per day</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-[300px]">
                      <ResponsiveContainer width="100%" height="100%">
                        <BarChart data={dailyBookingsChartData}>
                          <XAxis
                            dataKey="date"
                            tickFormatter={(value) => {
                              const date = new Date(value)
                              return `${date.getMonth() + 1}/${date.getDate()}`
                            }}
                          />
                          <YAxis />
                          <Tooltip />
                          <Bar dataKey="count" fill="hsl(var(--primary))" radius={[4, 4, 0, 0]} />
                        </BarChart>
                      </ResponsiveContainer>
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle>Bookings by Status</CardTitle>
                    <CardDescription>Distribution of booking statuses</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-[300px]">
                      <ResponsiveContainer width="100%" height="100%">
                        <PieChart>
                          <Pie
                            data={statusData}
                            cx="50%"
                            cy="50%"
                            labelLine={false}
                            label={({ name, percent }) =>
                              `${name} ${(percent * 100).toFixed(0)}%`
                            }
                            outerRadius={80}
                            fill="#8884d8"
                            dataKey="value"
                          >
                            {statusData.map((_, index) => (
                              <Cell
                                key={`cell-${index}`}
                                fill={COLORS[index % COLORS.length]}
                              />
                            ))}
                          </Pie>
                          <Tooltip />
                        </PieChart>
                      </ResponsiveContainer>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>

            <TabsContent value="revenue" className="space-y-6">
              {/* Summary Cards */}
              <div className="grid gap-4 md:grid-cols-3">
                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold">
                      ₹{totalRevenue.toLocaleString()}
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm font-medium">Avg Booking Value</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold">
                      ₹{avgBookingValue.toFixed(2)}
                    </div>
                  </CardContent>
                </Card>
                <Card>
                  <CardHeader className="pb-2">
                    <CardTitle className="text-sm font-medium">Avg Daily Revenue</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="text-2xl font-bold">
                      ₹
                      {dailyRevenueChartData.length > 0
                        ? Math.round(totalRevenue / dailyRevenueChartData.length).toLocaleString()
                        : 0}
                    </div>
                  </CardContent>
                </Card>
              </div>

              {/* Charts */}
              <div className="grid gap-6 lg:grid-cols-2">
                <Card>
                  <CardHeader>
                    <CardTitle>Daily Revenue</CardTitle>
                    <CardDescription>Revenue trend over time</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-[300px]">
                      <ResponsiveContainer width="100%" height="100%">
                        <LineChart data={dailyRevenueChartData}>
                          <XAxis
                            dataKey="date"
                            tickFormatter={(value) => {
                              const date = new Date(value)
                              return `${date.getMonth() + 1}/${date.getDate()}`
                            }}
                          />
                          <YAxis />
                          <Tooltip />
                          <Line
                            type="monotone"
                            dataKey="amount"
                            stroke="hsl(var(--primary))"
                            strokeWidth={2}
                            dot={false}
                          />
                        </LineChart>
                      </ResponsiveContainer>
                    </div>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle>Revenue Summary</CardTitle>
                    <CardDescription>Key revenue metrics</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="h-[300px] flex flex-col justify-center space-y-6">
                      <div className="text-center">
                        <p className="text-sm text-muted-foreground">Total Orders</p>
                        <p className="text-3xl font-bold">{totalOrders.toLocaleString()}</p>
                      </div>
                      <div className="text-center">
                        <p className="text-sm text-muted-foreground">Average Order Value</p>
                        <p className="text-3xl font-bold">₹{avgBookingValue.toFixed(2)}</p>
                      </div>
                      <div className="text-center">
                        <p className="text-sm text-muted-foreground">Total Revenue</p>
                        <p className="text-3xl font-bold text-green-600">₹{totalRevenue.toLocaleString()}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </div>
            </TabsContent>
          </Tabs>
        )}
      </div>
    </AdminLayout>
  )
}
