'use client'

import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { Save, Plus, Loader2 } from 'lucide-react'
import { AdminLayout } from '@/components/layout/admin-layout'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
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

export default function SettingsPage() {
  const queryClient = useQueryClient()
  const [editedSettings, setEditedSettings] = useState<Record<string, string>>({})
  const [newSetting, setNewSetting] = useState({ key: '', value: '', description: '' })
  const [isAddOpen, setIsAddOpen] = useState(false)

  const { data, isLoading } = useQuery({
    queryKey: ['settings'],
    queryFn: () => adminApi.getSettings(),
  })

  const settingsObj = (data?.data as { settings: Record<string, string> })?.settings || {}
  const settings: Setting[] = Object.entries(settingsObj).map(([key, value]) => ({
    key,
    value,
    description: undefined, // Backend doesn't return descriptions in list
  }))

  const updateMutation = useMutation({
    mutationFn: ({ key, value, description }: { key: string; value: string; description?: string }) =>
      adminApi.updateSetting(key, value, description),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings'] })
    },
  })

  const addMutation = useMutation({
    mutationFn: ({ key, value, description }: { key: string; value: string; description?: string }) =>
      adminApi.updateSetting(key, value, description),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['settings'] })
      setIsAddOpen(false)
      setNewSetting({ key: '', value: '', description: '' })
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

  const settingGroups = {
    pricing: settings.filter((s) => s.key.includes('price') || s.key.includes('fare') || s.key.includes('rate') || s.key.includes('fee')),
    limits: settings.filter((s) => s.key.includes('max') || s.key.includes('min') || s.key.includes('limit')),
    other: settings.filter(
      (s) =>
        !s.key.includes('price') &&
        !s.key.includes('fare') &&
        !s.key.includes('rate') &&
        !s.key.includes('fee') &&
        !s.key.includes('max') &&
        !s.key.includes('min') &&
        !s.key.includes('limit')
    ),
  }

  const renderSettingCard = (setting: Setting) => {
    const currentValue = editedSettings[setting.key] ?? setting.value
    const isModified = editedSettings[setting.key] !== undefined && editedSettings[setting.key] !== setting.value

    return (
      <div key={setting.key} className="flex items-center gap-4 p-4 border rounded-lg">
        <div className="flex-1">
          <Label className="font-mono text-sm">{setting.key}</Label>
          {setting.description && (
            <p className="text-xs text-muted-foreground mt-1">{setting.description}</p>
          )}
        </div>
        <div className="flex items-center gap-2">
          <Input
            value={currentValue}
            onChange={(e) => handleChange(setting.key, e.target.value)}
            className="w-[200px]"
          />
          {isModified && (
            <Button
              size="sm"
              onClick={() => handleSave(setting)}
              disabled={updateMutation.isPending}
            >
              {updateMutation.isPending ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                <Save className="h-4 w-4" />
              )}
            </Button>
          )}
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

  return (
    <AdminLayout>
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">Settings</h1>
            <p className="text-muted-foreground">Configure system settings</p>
          </div>
          <Dialog open={isAddOpen} onOpenChange={setIsAddOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="mr-2 h-4 w-4" />
                Add Setting
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

        {settingGroups.pricing.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Pricing Settings</CardTitle>
              <CardDescription>Configure pricing and fare settings</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {settingGroups.pricing.map(renderSettingCard)}
            </CardContent>
          </Card>
        )}

        {settingGroups.limits.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Limits & Thresholds</CardTitle>
              <CardDescription>Configure system limits and thresholds</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {settingGroups.limits.map(renderSettingCard)}
            </CardContent>
          </Card>
        )}

        {settingGroups.other.length > 0 && (
          <Card>
            <CardHeader>
              <CardTitle>Other Settings</CardTitle>
              <CardDescription>Additional system configuration</CardDescription>
            </CardHeader>
            <CardContent className="space-y-3">
              {settingGroups.other.map(renderSettingCard)}
            </CardContent>
          </Card>
        )}

        {settings.length === 0 && (
          <Card>
            <CardContent className="py-8 text-center text-muted-foreground">
              No settings configured yet. Click &quot;Add Setting&quot; to create one.
            </CardContent>
          </Card>
        )}
      </div>
    </AdminLayout>
  )
}
