'use client'

import { useState, useMemo } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import {
  Save,
  Plus,
  Loader2,
  Search,
  DollarSign,
  Truck,
  Users,
  UserCheck,
  Wallet,
  Bell,
  Car,
  Tag,
  MapPin,
  Shield,
  Settings2,
  RotateCcw,
  ChevronRight,
} from 'lucide-react'
import { AdminLayout } from '@/components/layout/admin-layout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Switch } from '@/components/ui/switch'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog'
import { adminApi } from '@/lib/api'
import type { Setting } from '@/types'
import { toast } from 'sonner'
import { cn } from '@/lib/utils'

// Category definitions with icons, descriptions, and setting keys
const SETTING_CATEGORIES = {
  pricing: {
    title: 'Pricing & Fees',
    description: 'Platform fees, taxes, and pricing structure',
    icon: DollarSign,
    keys: [
      'platform_fee_percent',
      'gst_percent',
      'cancellation_fee_percent',
      'min_order_amount',
      'surge_pricing_multiplier',
      'peak_hours_start',
      'peak_hours_end',
      'night_charge_multiplier',
      'night_hours_start',
      'night_hours_end',
      'waiting_charge_per_minute',
      'free_waiting_minutes',
    ],
  },
  booking: {
    title: 'Booking & Delivery',
    description: 'Booking rules and delivery settings',
    icon: Truck,
    keys: [
      'max_booking_distance_km',
      'min_booking_distance_km',
      'max_scheduled_days_ahead',
      'booking_timeout_minutes',
      'auto_cancel_pending_minutes',
      'max_delivery_weight_kg',
      'fragile_item_surcharge',
      'oversized_item_surcharge',
      'express_delivery_multiplier',
      'same_day_cutoff_hour',
    ],
  },
  pilot: {
    title: 'Pilot Management',
    description: 'Pilot settings and requirements',
    icon: UserCheck,
    keys: [
      'pilot_min_age',
      'pilot_max_age',
      'pilot_commission_percent',
      'pilot_daily_earning_limit',
      'pilot_weekly_earning_limit',
      'pilot_rating_threshold',
      'pilot_auto_offline_hours',
      'pilot_document_expiry_reminder_days',
      'pilot_minimum_acceptance_rate',
      'pilot_max_cancellations_per_day',
      'pilot_payout_frequency',
      'pilot_minimum_payout_amount',
    ],
  },
  user: {
    title: 'User Management',
    description: 'User account settings and limits',
    icon: Users,
    keys: [
      'user_referral_bonus',
      'referee_bonus',
      'max_addresses_per_user',
      'user_rating_after_deliveries',
      'user_max_active_bookings',
      'user_cancellation_limit_per_day',
      'user_ban_after_cancellations',
      'inactive_user_reminder_days',
    ],
  },
  payment: {
    title: 'Payment & Wallet',
    description: 'Payment processing and wallet settings',
    icon: Wallet,
    keys: [
      'min_wallet_topup',
      'max_wallet_topup',
      'max_wallet_balance',
      'wallet_low_balance_alert',
      'enable_cash_payments',
      'enable_wallet_payments',
      'enable_online_payments',
      'payment_retry_attempts',
      'refund_processing_days',
      'partial_payment_allowed',
    ],
  },
  notifications: {
    title: 'Notifications',
    description: 'Notification preferences',
    icon: Bell,
    keys: [
      'enable_push_notifications',
      'enable_sms_notifications',
      'enable_email_notifications',
      'booking_reminder_minutes',
      'rating_prompt_delay_minutes',
      'promotional_notification_frequency',
    ],
  },
  vehicle: {
    title: 'Vehicle Config',
    description: 'Vehicle types and requirements',
    icon: Car,
    keys: [
      'vehicle_inspection_interval_days',
      'vehicle_document_expiry_reminder_days',
      'max_vehicle_age_years',
      'require_vehicle_insurance',
      'require_vehicle_fitness',
      'require_pollution_certificate',
    ],
  },
  coupon: {
    title: 'Coupons & Promos',
    description: 'Discounts and promotional settings',
    icon: Tag,
    keys: [
      'max_coupon_discount_percent',
      'max_coupon_discount_amount',
      'coupon_usage_limit_per_user',
      'first_order_discount_percent',
      'referral_coupon_validity_days',
      'enable_auto_apply_coupons',
    ],
  },
  serviceArea: {
    title: 'Service Area',
    description: 'Geographical service boundaries',
    icon: MapPin,
    keys: [
      'default_service_radius_km',
      'max_service_radius_km',
      'inter_city_delivery_enabled',
      'inter_city_surcharge_percent',
    ],
  },
  security: {
    title: 'Security & OTP',
    description: 'Security and verification settings',
    icon: Shield,
    keys: [
      'otp_validity_minutes',
      'otp_resend_cooldown_seconds',
      'max_otp_attempts',
      'session_timeout_hours',
      'require_delivery_otp',
      'require_pickup_otp',
    ],
  },
  platform: {
    title: 'Platform',
    description: 'General platform settings',
    icon: Settings2,
    keys: [
      'maintenance_mode',
      'maintenance_message',
      'support_email',
      'support_phone',
      'app_store_url',
      'play_store_url',
    ],
  },
}

// Setting metadata for type-specific rendering
const SETTING_METADATA: Record<string, { type: 'text' | 'number' | 'boolean' | 'time' | 'percent'; min?: number; max?: number; step?: number; unit?: string; description?: string }> = {
  // Pricing & Fees
  platform_fee_percent: { type: 'percent', min: 0, max: 50, description: 'Platform commission percentage taken from each delivery' },
  gst_percent: { type: 'percent', min: 0, max: 28, description: 'Goods and Services Tax percentage' },
  cancellation_fee_percent: { type: 'percent', min: 0, max: 100, description: 'Cancellation fee percentage charged to users' },
  min_order_amount: { type: 'number', min: 0, max: 1000, unit: '₹', description: 'Minimum order amount to process a booking' },
  surge_pricing_multiplier: { type: 'number', min: 1, max: 5, step: 0.1, unit: 'x', description: 'Multiplier for surge pricing during peak hours' },
  peak_hours_start: { type: 'time', description: 'Start hour for peak pricing (24h format)' },
  peak_hours_end: { type: 'time', description: 'End hour for peak pricing (24h format)' },
  night_charge_multiplier: { type: 'number', min: 1, max: 3, step: 0.1, unit: 'x', description: 'Multiplier for night deliveries' },
  night_hours_start: { type: 'time', description: 'Start hour for night charges (24h format)' },
  night_hours_end: { type: 'time', description: 'End hour for night charges (24h format)' },
  waiting_charge_per_minute: { type: 'number', min: 0, max: 50, unit: '₹', description: 'Charge per minute for pilot waiting time' },
  free_waiting_minutes: { type: 'number', min: 0, max: 30, unit: 'min', description: 'Free waiting time before charges apply' },

  // Booking & Delivery
  max_booking_distance_km: { type: 'number', min: 1, max: 500, unit: 'km', description: 'Maximum allowed delivery distance' },
  min_booking_distance_km: { type: 'number', min: 0, max: 10, step: 0.1, unit: 'km', description: 'Minimum delivery distance' },
  max_scheduled_days_ahead: { type: 'number', min: 1, max: 30, unit: 'days', description: 'How far in advance bookings can be scheduled' },
  booking_timeout_minutes: { type: 'number', min: 1, max: 60, unit: 'min', description: 'Time before unaccepted booking times out' },
  auto_cancel_pending_minutes: { type: 'number', min: 5, max: 120, unit: 'min', description: 'Auto-cancel pending bookings after this time' },
  max_delivery_weight_kg: { type: 'number', min: 1, max: 100, unit: 'kg', description: 'Maximum allowed package weight' },
  fragile_item_surcharge: { type: 'number', min: 0, max: 500, unit: '₹', description: 'Extra charge for fragile items' },
  oversized_item_surcharge: { type: 'number', min: 0, max: 500, unit: '₹', description: 'Extra charge for oversized items' },
  express_delivery_multiplier: { type: 'number', min: 1, max: 3, step: 0.1, unit: 'x', description: 'Price multiplier for express delivery' },
  same_day_cutoff_hour: { type: 'time', description: 'Cutoff hour for same-day delivery orders' },

  // Pilot Management
  pilot_min_age: { type: 'number', min: 18, max: 30, unit: 'years', description: 'Minimum age to become a pilot' },
  pilot_max_age: { type: 'number', min: 40, max: 70, unit: 'years', description: 'Maximum age for active pilots' },
  pilot_commission_percent: { type: 'percent', min: 50, max: 100, description: 'Percentage of fare that goes to pilot' },
  pilot_daily_earning_limit: { type: 'number', min: 0, max: 50000, unit: '₹', description: 'Maximum daily earnings (0 = no limit)' },
  pilot_weekly_earning_limit: { type: 'number', min: 0, max: 200000, unit: '₹', description: 'Maximum weekly earnings (0 = no limit)' },
  pilot_rating_threshold: { type: 'number', min: 1, max: 5, step: 0.1, description: 'Minimum rating to stay active' },
  pilot_auto_offline_hours: { type: 'number', min: 1, max: 24, unit: 'hours', description: 'Auto offline after hours of inactivity' },
  pilot_document_expiry_reminder_days: { type: 'number', min: 7, max: 90, unit: 'days', description: 'Days before document expiry to send reminder' },
  pilot_minimum_acceptance_rate: { type: 'percent', min: 0, max: 100, description: 'Minimum booking acceptance rate required' },
  pilot_max_cancellations_per_day: { type: 'number', min: 1, max: 20, description: 'Maximum cancellations allowed per day' },
  pilot_payout_frequency: { type: 'text', description: 'Payout frequency (daily, weekly, monthly)' },
  pilot_minimum_payout_amount: { type: 'number', min: 0, max: 5000, unit: '₹', description: 'Minimum amount for payout processing' },

  // User Management
  user_referral_bonus: { type: 'number', min: 0, max: 1000, unit: '₹', description: 'Bonus for referring a new user' },
  referee_bonus: { type: 'number', min: 0, max: 1000, unit: '₹', description: 'Bonus for the referred user' },
  max_addresses_per_user: { type: 'number', min: 1, max: 20, description: 'Maximum saved addresses per user' },
  user_rating_after_deliveries: { type: 'number', min: 1, max: 10, description: 'Prompt rating after N deliveries' },
  user_max_active_bookings: { type: 'number', min: 1, max: 10, description: 'Maximum simultaneous active bookings' },
  user_cancellation_limit_per_day: { type: 'number', min: 1, max: 10, description: 'Maximum cancellations per day' },
  user_ban_after_cancellations: { type: 'number', min: 3, max: 20, description: 'Ban user after N consecutive cancellations' },
  inactive_user_reminder_days: { type: 'number', min: 7, max: 90, unit: 'days', description: 'Days of inactivity before sending reminder' },

  // Payment & Wallet
  min_wallet_topup: { type: 'number', min: 10, max: 1000, unit: '₹', description: 'Minimum wallet top-up amount' },
  max_wallet_topup: { type: 'number', min: 1000, max: 100000, unit: '₹', description: 'Maximum single top-up amount' },
  max_wallet_balance: { type: 'number', min: 1000, max: 500000, unit: '₹', description: 'Maximum wallet balance allowed' },
  wallet_low_balance_alert: { type: 'number', min: 50, max: 1000, unit: '₹', description: 'Alert user when balance falls below this' },
  enable_cash_payments: { type: 'boolean', description: 'Allow cash on delivery payments' },
  enable_wallet_payments: { type: 'boolean', description: 'Allow wallet payments' },
  enable_online_payments: { type: 'boolean', description: 'Allow online/card payments' },
  payment_retry_attempts: { type: 'number', min: 1, max: 5, description: 'Number of payment retry attempts' },
  refund_processing_days: { type: 'number', min: 1, max: 15, unit: 'days', description: 'Days to process refunds' },
  partial_payment_allowed: { type: 'boolean', description: 'Allow partial wallet + cash payments' },

  // Notifications
  enable_push_notifications: { type: 'boolean', description: 'Enable push notifications' },
  enable_sms_notifications: { type: 'boolean', description: 'Enable SMS notifications' },
  enable_email_notifications: { type: 'boolean', description: 'Enable email notifications' },
  booking_reminder_minutes: { type: 'number', min: 5, max: 60, unit: 'min', description: 'Send reminder before scheduled booking' },
  rating_prompt_delay_minutes: { type: 'number', min: 1, max: 60, unit: 'min', description: 'Delay before showing rating prompt' },
  promotional_notification_frequency: { type: 'text', description: 'Frequency of promotional notifications' },

  // Vehicle Configuration
  vehicle_inspection_interval_days: { type: 'number', min: 30, max: 365, unit: 'days', description: 'Days between vehicle inspections' },
  vehicle_document_expiry_reminder_days: { type: 'number', min: 7, max: 90, unit: 'days', description: 'Days before expiry to remind about documents' },
  max_vehicle_age_years: { type: 'number', min: 5, max: 20, unit: 'years', description: 'Maximum age of vehicle allowed' },
  require_vehicle_insurance: { type: 'boolean', description: 'Require valid vehicle insurance' },
  require_vehicle_fitness: { type: 'boolean', description: 'Require vehicle fitness certificate' },
  require_pollution_certificate: { type: 'boolean', description: 'Require pollution under control certificate' },

  // Coupon & Promotions
  max_coupon_discount_percent: { type: 'percent', min: 0, max: 100, description: 'Maximum discount percentage for coupons' },
  max_coupon_discount_amount: { type: 'number', min: 0, max: 5000, unit: '₹', description: 'Maximum discount amount for coupons' },
  coupon_usage_limit_per_user: { type: 'number', min: 1, max: 100, description: 'How many times a user can use a coupon' },
  first_order_discount_percent: { type: 'percent', min: 0, max: 50, description: 'Discount for first-time users' },
  referral_coupon_validity_days: { type: 'number', min: 7, max: 365, unit: 'days', description: 'Days referral coupon remains valid' },
  enable_auto_apply_coupons: { type: 'boolean', description: 'Auto-apply best available coupon' },

  // Service Area
  default_service_radius_km: { type: 'number', min: 1, max: 50, unit: 'km', description: 'Default service area radius' },
  max_service_radius_km: { type: 'number', min: 10, max: 200, unit: 'km', description: 'Maximum service area radius' },
  inter_city_delivery_enabled: { type: 'boolean', description: 'Enable inter-city deliveries' },
  inter_city_surcharge_percent: { type: 'percent', min: 0, max: 100, description: 'Surcharge percentage for inter-city' },

  // Security & OTP
  otp_validity_minutes: { type: 'number', min: 1, max: 30, unit: 'min', description: 'How long OTP remains valid' },
  otp_resend_cooldown_seconds: { type: 'number', min: 30, max: 300, unit: 'sec', description: 'Cooldown before resending OTP' },
  max_otp_attempts: { type: 'number', min: 3, max: 10, description: 'Maximum OTP verification attempts' },
  session_timeout_hours: { type: 'number', min: 1, max: 168, unit: 'hours', description: 'User session timeout' },
  require_delivery_otp: { type: 'boolean', description: 'Require OTP for delivery completion' },
  require_pickup_otp: { type: 'boolean', description: 'Require OTP for pickup confirmation' },

  // Platform Operations
  maintenance_mode: { type: 'boolean', description: 'Enable platform maintenance mode' },
  maintenance_message: { type: 'text', description: 'Message shown during maintenance' },
  support_email: { type: 'text', description: 'Customer support email address' },
  support_phone: { type: 'text', description: 'Customer support phone number' },
  app_store_url: { type: 'text', description: 'iOS App Store URL' },
  play_store_url: { type: 'text', description: 'Android Play Store URL' },
}

export default function SettingsPage() {
  const queryClient = useQueryClient()
  const [editedSettings, setEditedSettings] = useState<Record<string, string>>({})
  const [newSetting, setNewSetting] = useState({ key: '', value: '', description: '' })
  const [isAddOpen, setIsAddOpen] = useState(false)
  const [searchQuery, setSearchQuery] = useState('')
  const [activeCategory, setActiveCategory] = useState('pricing')

  const { data, isLoading } = useQuery({
    queryKey: ['settings'],
    queryFn: () => adminApi.getSettings(),
  })

  const settingsObj = (data?.data as { settings: Record<string, string> })?.settings || {}
  const settings: Setting[] = Object.entries(settingsObj).map(([key, value]) => ({
    key,
    value,
    description: SETTING_METADATA[key]?.description,
  }))

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

  const handleSave = (setting: Setting) => {
    const newValue = editedSettings[setting.key]
    if (newValue !== undefined && newValue !== setting.value) {
      updateMutation.mutate({ key: setting.key, value: newValue, description: setting.description })
    }
  }

  const handleChange = (key: string, value: string) => {
    setEditedSettings((prev) => ({ ...prev, [key]: value }))
  }

  const handleReset = (setting: Setting) => {
    setEditedSettings((prev) => {
      const newState = { ...prev }
      delete newState[setting.key]
      return newState
    })
  }

  // Filter settings based on search query
  const filteredSettings = useMemo(() => {
    if (!searchQuery.trim()) return settings
    const query = searchQuery.toLowerCase()
    return settings.filter(
      (s) =>
        s.key.toLowerCase().includes(query) ||
        (s.description && s.description.toLowerCase().includes(query))
    )
  }, [settings, searchQuery])

  // Group settings by category
  const categorizedSettings = useMemo(() => {
    const result: Record<string, Setting[]> = {}
    const usedKeys = new Set<string>()

    Object.entries(SETTING_CATEGORIES).forEach(([categoryKey, category]) => {
      const categorySettings = filteredSettings.filter((s) => {
        if (category.keys.includes(s.key)) {
          usedKeys.add(s.key)
          return true
        }
        return false
      })
      if (categorySettings.length > 0) {
        result[categoryKey] = categorySettings
      }
    })

    // Add uncategorized settings
    const uncategorized = filteredSettings.filter((s) => !usedKeys.has(s.key))
    if (uncategorized.length > 0) {
      result['uncategorized'] = uncategorized
    }

    return result
  }, [filteredSettings])

  const renderSettingInput = (setting: Setting) => {
    const metadata = SETTING_METADATA[setting.key]
    const currentValue = editedSettings[setting.key] ?? setting.value
    const isModified = editedSettings[setting.key] !== undefined && editedSettings[setting.key] !== setting.value

    if (metadata?.type === 'boolean') {
      const isChecked = currentValue === 'true' || currentValue === '1'
      return (
        <div className="flex items-center gap-3">
          <Switch
            checked={isChecked}
            onCheckedChange={(checked) => {
              const newValue = checked ? 'true' : 'false'
              handleChange(setting.key, newValue)
              // Auto-save boolean settings
              updateMutation.mutate({ key: setting.key, value: newValue, description: setting.description })
            }}
          />
          <span className={cn("text-sm font-medium", isChecked ? "text-primary" : "text-muted-foreground")}>
            {isChecked ? 'Enabled' : 'Disabled'}
          </span>
        </div>
      )
    }

    return (
      <div className="flex items-center gap-2">
        <div className="relative flex items-center">
          {metadata?.unit && metadata.unit !== 'x' && metadata.unit !== '%' && (
            <span className="absolute left-3 text-sm text-muted-foreground">{metadata.unit}</span>
          )}
          <Input
            type={metadata?.type === 'number' || metadata?.type === 'percent' || metadata?.type === 'time' ? 'number' : 'text'}
            value={currentValue}
            onChange={(e) => handleChange(setting.key, e.target.value)}
            className={cn(
              "w-[160px]",
              metadata?.unit && metadata.unit !== 'x' && metadata.unit !== '%' && "pl-8"
            )}
            min={metadata?.min}
            max={metadata?.max}
            step={metadata?.step || 1}
          />
          {(metadata?.unit === 'x' || metadata?.type === 'percent') && (
            <span className="absolute right-3 text-sm text-muted-foreground">
              {metadata?.type === 'percent' ? '%' : 'x'}
            </span>
          )}
        </div>
        {isModified && (
          <div className="flex items-center gap-1">
            <Button
              size="icon-sm"
              variant="ghost"
              onClick={() => handleReset(setting)}
              title="Reset to saved value"
            >
              <RotateCcw className="h-4 w-4" />
            </Button>
            <Button
              size="icon-sm"
              onClick={() => handleSave(setting)}
              disabled={updateMutation.isPending}
            >
              {updateMutation.isPending ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Save className="h-4 w-4" />
              )}
            </Button>
          </div>
        )}
      </div>
    )
  }

  const renderSettingRow = (setting: Setting) => {
    const metadata = SETTING_METADATA[setting.key]
    const description = metadata?.description || setting.description

    return (
      <div
        key={setting.key}
        className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 py-4 border-b border-border/50 last:border-0"
      >
        <div className="flex-1 min-w-0">
          <Label className="text-sm font-medium block">
            {setting.key.split('_').map(word => word.charAt(0).toUpperCase() + word.slice(1)).join(' ')}
          </Label>
          {description && (
            <p className="text-xs text-muted-foreground mt-0.5">
              {description}
            </p>
          )}
        </div>
        <div className="flex-shrink-0">
          {renderSettingInput(setting)}
        </div>
      </div>
    )
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

  // Get all category keys including uncategorized
  const categoryKeys = Object.keys(SETTING_CATEGORIES)
  if (categorizedSettings['uncategorized']) {
    categoryKeys.push('uncategorized')
  }

  const currentCategory = SETTING_CATEGORIES[activeCategory as keyof typeof SETTING_CATEGORIES]
  const currentSettings = categorizedSettings[activeCategory] || []
  const CurrentIcon = currentCategory?.icon || Settings2

  return (
    <AdminLayout>
      <div className="space-y-6">
        {/* Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div>
            <h1 className="text-3xl font-bold">Settings</h1>
            <p className="text-muted-foreground">
              Configure platform settings ({settings.length} total)
            </p>
          </div>
          <div className="flex items-center gap-3">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search settings..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9 w-[220px]"
              />
            </div>
            <Dialog open={isAddOpen} onOpenChange={setIsAddOpen}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="mr-2 h-4 w-4" />
                  Add
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Add New Setting</DialogTitle>
                  <DialogDescription>Create a new system setting.</DialogDescription>
                </DialogHeader>
                <div className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="key">Key</Label>
                    <Input
                      id="key"
                      placeholder="e.g., new_setting_name"
                      value={newSetting.key}
                      onChange={(e) =>
                        setNewSetting({ ...newSetting, key: e.target.value.toLowerCase().replace(/\s/g, '_') })
                      }
                    />
                    <p className="text-xs text-muted-foreground">Lowercase with underscores only</p>
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="value">Value</Label>
                    <Input
                      id="value"
                      placeholder="Setting value"
                      value={newSetting.value}
                      onChange={(e) => setNewSetting({ ...newSetting, value: e.target.value })}
                    />
                  </div>
                  <div className="space-y-2">
                    <Label htmlFor="description">Description (optional)</Label>
                    <Input
                      id="description"
                      placeholder="What this setting does"
                      value={newSetting.description}
                      onChange={(e) => setNewSetting({ ...newSetting, description: e.target.value })}
                    />
                  </div>
                </div>
                <DialogFooter>
                  <Button variant="outline" onClick={() => setIsAddOpen(false)}>
                    Cancel
                  </Button>
                  <Button
                    onClick={() => {
                      if (newSetting.key && newSetting.value) {
                        addMutation.mutate(newSetting)
                      }
                    }}
                    disabled={!newSetting.key || !newSetting.value || addMutation.isPending}
                  >
                    {addMutation.isPending ? 'Adding...' : 'Add Setting'}
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          </div>
        </div>

        {/* Main Content - Sidebar Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          {/* Sidebar Navigation */}
          <Card className="lg:col-span-1 h-fit">
            <CardHeader className="pb-3">
              <CardTitle className="text-base">Categories</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="h-[calc(100vh-320px)] overflow-y-auto">
                <div className="space-y-1 p-3 pt-0">
                  {categoryKeys.map((categoryKey) => {
                    const category = SETTING_CATEGORIES[categoryKey as keyof typeof SETTING_CATEGORIES]
                    const Icon = category?.icon || Settings2
                    const count = categorizedSettings[categoryKey]?.length || 0
                    const isActive = activeCategory === categoryKey

                    if (count === 0) return null

                    return (
                      <button
                        key={categoryKey}
                        onClick={() => setActiveCategory(categoryKey)}
                        className={cn(
                          "w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-left transition-all",
                          isActive
                            ? "bg-primary text-primary-foreground shadow-sm"
                            : "hover:bg-muted/80 text-foreground"
                        )}
                      >
                        <Icon className={cn("h-4 w-4 flex-shrink-0", isActive ? "text-primary-foreground" : "text-muted-foreground")} />
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium truncate">
                            {category?.title || 'Other'}
                          </p>
                        </div>
                        <div className="flex items-center gap-1">
                          <span className={cn(
                            "text-xs px-1.5 py-0.5 rounded-full",
                            isActive ? "bg-primary-foreground/20 text-primary-foreground" : "bg-muted text-muted-foreground"
                          )}>
                            {count}
                          </span>
                          <ChevronRight className={cn(
                            "h-4 w-4 transition-transform",
                            isActive ? "text-primary-foreground rotate-90" : "text-muted-foreground"
                          )} />
                        </div>
                      </button>
                    )
                  })}
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Settings Content */}
          <Card className="lg:col-span-3">
            <CardHeader className="border-b">
              <div className="flex items-center gap-3">
                <div className="p-2 rounded-lg bg-primary/10">
                  <CurrentIcon className="h-5 w-5 text-primary" />
                </div>
                <div>
                  <CardTitle>{currentCategory?.title || 'Other Settings'}</CardTitle>
                  <CardDescription>
                    {currentCategory?.description || 'Additional configuration options'}
                  </CardDescription>
                </div>
              </div>
            </CardHeader>
            <CardContent className="p-0">
              <div className="h-[calc(100vh-380px)] overflow-y-auto">
                <div className="px-6 py-2">
                  {currentSettings.length > 0 ? (
                    currentSettings.map(renderSettingRow)
                  ) : (
                    <div className="py-12 text-center text-muted-foreground">
                      No settings in this category
                    </div>
                  )}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Empty States */}
        {filteredSettings.length === 0 && searchQuery && (
          <Card>
            <CardContent className="py-8 text-center text-muted-foreground">
              No settings found matching &quot;{searchQuery}&quot;
            </CardContent>
          </Card>
        )}

        {settings.length === 0 && !searchQuery && (
          <Card>
            <CardContent className="py-8 text-center text-muted-foreground">
              No settings configured yet. Click &quot;Add&quot; to create one.
            </CardContent>
          </Card>
        )}
      </div>
    </AdminLayout>
  )
}
