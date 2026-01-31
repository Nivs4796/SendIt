'use client'

import { useEffect, useRef } from 'react'
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

export function TrackingMap({
  pickupLat,
  pickupLng,
  dropoffLat,
  dropoffLng,
  pilotLat,
  pilotLng,
  className = '',
}: TrackingMapProps) {
  const mapRef = useRef<L.Map | null>(null)
  const mapContainerRef = useRef<HTMLDivElement>(null)
  const pickupMarkerRef = useRef<L.Marker | null>(null)
  const dropoffMarkerRef = useRef<L.Marker | null>(null)
  const pilotMarkerRef = useRef<L.Marker | null>(null)
  const routeLineRef = useRef<L.Polyline | null>(null)

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

    // Add pickup marker (green)
    pickupMarkerRef.current = L.marker([pickupLat, pickupLng], {
      icon: createIcon('#10b981', 28),
    })
      .addTo(map)
      .bindPopup('<strong>Pickup Location</strong>')

    // Add dropoff marker (red)
    dropoffMarkerRef.current = L.marker([dropoffLat, dropoffLng], {
      icon: createIcon('#ef4444', 28),
    })
      .addTo(map)
      .bindPopup('<strong>Dropoff Location</strong>')

    // Add route line
    routeLineRef.current = L.polyline(
      [
        [pickupLat, pickupLng],
        [dropoffLat, dropoffLng],
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
      [pickupLat, pickupLng],
      [dropoffLat, dropoffLng],
    ])

    if (pilotLat && pilotLng) {
      bounds.extend([pilotLat, pilotLng])
    }

    map.fitBounds(bounds, { padding: [50, 50] })
  }, [pickupLat, pickupLng, dropoffLat, dropoffLng])

  // Update pilot marker
  useEffect(() => {
    const map = mapRef.current
    if (!map) return

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
  }, [pilotLat, pilotLng])

  return (
    <div
      ref={mapContainerRef}
      className={`w-full h-full min-h-[400px] rounded-xl overflow-hidden ${className}`}
      style={{ background: '#1a1a2e' }}
    />
  )
}
