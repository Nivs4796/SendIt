'use client'

import { useEffect, useRef, useState, useCallback } from 'react'
import L from 'leaflet'
import 'leaflet/dist/leaflet.css'

interface TrackingMapProps {
  pickupLat: number
  pickupLng: number
  dropoffLat: number
  dropoffLng: number
  pilotLat?: number
  pilotLng?: number
  className?: string
  demoMode?: boolean
}

// Custom marker icons
const createIcon = (color: string, size: number = 24) => {
  return L.divIcon({
    className: 'custom-marker',
    html: `
      <div style="
        width: ${size}px;
        height: ${size}px;
        background: ${color};
        border: 3px solid white;
        border-radius: 50%;
        box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      "></div>
    `,
    iconSize: [size, size],
    iconAnchor: [size / 2, size / 2],
  })
}

const createPilotIcon = () => {
  return L.divIcon({
    className: 'pilot-marker',
    html: `
      <div style="
        width: 36px;
        height: 36px;
        background: #3b82f6;
        border: 3px solid white;
        border-radius: 50%;
        box-shadow: 0 2px 12px rgba(59,130,246,0.5);
        display: flex;
        align-items: center;
        justify-content: center;
        animation: pulse 2s infinite;
      ">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="12" cy="12" r="10"/>
          <polygon points="16.24 7.76 14.12 14.12 7.76 16.24 9.88 9.88 16.24 7.76"/>
        </svg>
      </div>
      <style>
        @keyframes pulse {
          0% { box-shadow: 0 0 0 0 rgba(59,130,246,0.5); }
          70% { box-shadow: 0 0 0 15px rgba(59,130,246,0); }
          100% { box-shadow: 0 0 0 0 rgba(59,130,246,0); }
        }
      </style>
    `,
    iconSize: [36, 36],
    iconAnchor: [18, 18],
  })
}

// Demo coordinates for Ahmedabad, India
const DEMO_PICKUP = { lat: 23.0225, lng: 72.5714 } // Ahmedabad center
const DEMO_DROPOFF = { lat: 23.0396, lng: 72.5660 } // ~2km north

export function TrackingMap({
  pickupLat,
  pickupLng,
  dropoffLat,
  dropoffLng,
  pilotLat,
  pilotLng,
  className = '',
  demoMode = false,
}: TrackingMapProps) {
  const mapRef = useRef<L.Map | null>(null)
  const mapContainerRef = useRef<HTMLDivElement>(null)
  const pickupMarkerRef = useRef<L.Marker | null>(null)
  const dropoffMarkerRef = useRef<L.Marker | null>(null)
  const pilotMarkerRef = useRef<L.Marker | null>(null)
  const routeLineRef = useRef<L.Polyline | null>(null)
  const pilotPathRef = useRef<L.Polyline | null>(null)
  const animationRef = useRef<number | null>(null)
  const [demoProgress, setDemoProgress] = useState(0)

  // Use demo coordinates if in demo mode or coords are invalid
  const effectivePickupLat = demoMode || !pickupLat ? DEMO_PICKUP.lat : pickupLat
  const effectivePickupLng = demoMode || !pickupLng ? DEMO_PICKUP.lng : pickupLng
  const effectiveDropoffLat = demoMode || !dropoffLat ? DEMO_DROPOFF.lat : dropoffLat
  const effectiveDropoffLng = demoMode || !dropoffLng ? DEMO_DROPOFF.lng : dropoffLng

  // Calculate pilot position along the route based on progress
  const getDemoPilotPosition = useCallback((progress: number) => {
    const lat = effectivePickupLat + (effectiveDropoffLat - effectivePickupLat) * progress
    const lng = effectivePickupLng + (effectiveDropoffLng - effectivePickupLng) * progress
    return { lat, lng }
  }, [effectivePickupLat, effectivePickupLng, effectiveDropoffLat, effectiveDropoffLng])

  // Initialize map
  useEffect(() => {
    if (!mapContainerRef.current || mapRef.current) return

    // Create map
    const map = L.map(mapContainerRef.current, {
      zoomControl: true,
      attributionControl: true,
    })

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
    }).addTo(map)

    mapRef.current = map

    // Force map to recalculate size after render
    setTimeout(() => {
      map.invalidateSize()
    }, 100)

    return () => {
      map.remove()
      mapRef.current = null
    }
  }, [])

  // Update markers and route
  useEffect(() => {
    const map = mapRef.current
    if (!map) return

    // Clear existing markers
    if (pickupMarkerRef.current) {
      pickupMarkerRef.current.remove()
    }
    if (dropoffMarkerRef.current) {
      dropoffMarkerRef.current.remove()
    }
    if (routeLineRef.current) {
      routeLineRef.current.remove()
    }
    if (pilotPathRef.current) {
      pilotPathRef.current.remove()
    }

    // Add pickup marker (green)
    pickupMarkerRef.current = L.marker([effectivePickupLat, effectivePickupLng], {
      icon: createIcon('#10b981', 28),
    })
      .addTo(map)
      .bindPopup('<strong>Pickup Location</strong>')

    // Add dropoff marker (red)
    dropoffMarkerRef.current = L.marker([effectiveDropoffLat, effectiveDropoffLng], {
      icon: createIcon('#ef4444', 28),
    })
      .addTo(map)
      .bindPopup('<strong>Dropoff Location</strong>')

    // Add route line
    routeLineRef.current = L.polyline(
      [
        [effectivePickupLat, effectivePickupLng],
        [effectiveDropoffLat, effectiveDropoffLng],
      ],
      {
        color: '#10b981',
        weight: 4,
        opacity: 0.7,
        dashArray: '10, 10',
      }
    ).addTo(map)

    // Fit bounds to show all points
    const bounds = L.latLngBounds([
      [effectivePickupLat, effectivePickupLng],
      [effectiveDropoffLat, effectiveDropoffLng],
    ])

    if (pilotLat && pilotLng) {
      bounds.extend([pilotLat, pilotLng])
    }

    map.fitBounds(bounds, { padding: [50, 50] })
  }, [effectivePickupLat, effectivePickupLng, effectiveDropoffLat, effectiveDropoffLng, pilotLat, pilotLng])

  // Update pilot marker (real location)
  useEffect(() => {
    const map = mapRef.current
    if (!map || demoMode) return

    // Remove existing pilot marker
    if (pilotMarkerRef.current) {
      pilotMarkerRef.current.remove()
      pilotMarkerRef.current = null
    }

    // Add pilot marker if location available
    if (pilotLat && pilotLng) {
      pilotMarkerRef.current = L.marker([pilotLat, pilotLng], {
        icon: createPilotIcon(),
      })
        .addTo(map)
        .bindPopup('<strong>Pilot Location</strong><br/>Live tracking active')
    }
  }, [pilotLat, pilotLng, demoMode])

  // Demo mode animation
  useEffect(() => {
    if (!demoMode) return

    const map = mapRef.current
    if (!map) return

    // Start animation loop
    let startTime: number | null = null
    const duration = 15000 // 15 seconds for full journey

    const animate = (currentTime: number) => {
      if (!startTime) startTime = currentTime
      const elapsed = currentTime - startTime
      const progress = Math.min((elapsed % duration) / duration, 1)

      setDemoProgress(progress)

      // Update pilot marker position
      const pos = getDemoPilotPosition(progress)

      if (pilotMarkerRef.current) {
        pilotMarkerRef.current.setLatLng([pos.lat, pos.lng])
      } else {
        pilotMarkerRef.current = L.marker([pos.lat, pos.lng], {
          icon: createPilotIcon(),
        })
          .addTo(map)
          .bindPopup('<strong>Pilot Location</strong><br/>Demo tracking active')
      }

      // Update pilot path (trail showing where pilot has been)
      if (pilotPathRef.current) {
        pilotPathRef.current.remove()
      }

      const pathCoords: [number, number][] = []
      for (let p = 0; p <= progress; p += 0.05) {
        const pathPos = getDemoPilotPosition(p)
        pathCoords.push([pathPos.lat, pathPos.lng])
      }
      pathCoords.push([pos.lat, pos.lng])

      pilotPathRef.current = L.polyline(pathCoords, {
        color: '#3b82f6',
        weight: 3,
        opacity: 0.8,
      }).addTo(map)

      animationRef.current = requestAnimationFrame(animate)
    }

    animationRef.current = requestAnimationFrame(animate)

    return () => {
      if (animationRef.current) {
        cancelAnimationFrame(animationRef.current)
      }
    }
  }, [demoMode, getDemoPilotPosition])

  return (
    <div className={`relative w-full h-full min-h-[400px] ${className}`} style={{ height: '100%' }}>
      <div
        ref={mapContainerRef}
        className="w-full h-full"
        style={{ background: '#1a1a2e', position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 }}
      />
      {demoMode && (
        <div className="absolute bottom-4 left-4 right-4 glass-card rounded-lg p-3 z-[1000]">
          <div className="flex items-center justify-between text-sm">
            <span className="text-muted-foreground">Demo Mode - Simulated Tracking</span>
            <span className="font-medium text-primary">{Math.round(demoProgress * 100)}% Complete</span>
          </div>
          <div className="mt-2 h-1.5 bg-muted rounded-full overflow-hidden">
            <div
              className="h-full bg-primary transition-all duration-200 rounded-full"
              style={{ width: `${demoProgress * 100}%` }}
            />
          </div>
        </div>
      )}
    </div>
  )
}
