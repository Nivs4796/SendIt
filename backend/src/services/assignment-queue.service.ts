import prisma from '../config/database'
import logger from '../config/logger'
import { emitToUser, emitToPilot, emitToAdmin } from '../socket'
import { findAvailablePilots, createJobOffer } from './matching.service'
import { BookingStatus } from '@prisma/client'

// Configuration
const ASSIGNMENT_CONFIG = {
  OFFER_TIMEOUT_MS: 30 * 1000,        // 30 seconds per pilot
  MAX_SEARCH_TIME_MS: 2 * 60 * 1000,  // 2 minutes total search
  MAX_RETRY_ATTEMPTS: 10,              // Max pilots to try
  SEARCH_RADIUS_KM: 5,                 // Initial search radius
  MAX_RADIUS_KM: 15,                   // Maximum search radius
}

// Types
interface AssignmentJob {
  bookingId: string
  userId: string
  pickupLat: number
  pickupLng: number
  vehicleTypeId: string
  startedAt: Date
  currentPilotIndex: number
  triedPilotIds: Set<string>
  offerTimer: NodeJS.Timeout | null
  searchTimer: NodeJS.Timeout | null
  status: 'searching' | 'offered' | 'assigned' | 'failed' | 'cancelled'
}

// In-memory queue (use Redis in production for multi-instance)
const assignmentQueue = new Map<string, AssignmentJob>()

/**
 * Start the assignment process for a booking
 */
export async function startAssignment(bookingId: string): Promise<void> {
  // Get booking details
  const booking = await prisma.booking.findUnique({
    where: { id: bookingId },
    include: {
      pickupAddress: true,
      user: { select: { id: true, name: true } },
    },
  })

  if (!booking) {
    logger.error(`Assignment failed: Booking ${bookingId} not found`)
    return
  }

  if (booking.status !== BookingStatus.PENDING) {
    logger.warn(`Assignment skipped: Booking ${bookingId} is not pending`)
    return
  }

  // Create assignment job
  const job: AssignmentJob = {
    bookingId,
    userId: booking.userId,
    pickupLat: booking.pickupAddress.lat,
    pickupLng: booking.pickupAddress.lng,
    vehicleTypeId: booking.vehicleTypeId,
    startedAt: new Date(),
    currentPilotIndex: 0,
    triedPilotIds: new Set(),
    offerTimer: null,
    searchTimer: null,
    status: 'searching',
  }

  assignmentQueue.set(bookingId, job)

  // Notify user that search has started
  emitToUser(booking.userId, 'booking:search_started', {
    bookingId,
    message: 'Finding a driver for you...',
  })

  // Start the 2-minute overall search timer
  job.searchTimer = setTimeout(() => {
    handleSearchTimeout(bookingId)
  }, ASSIGNMENT_CONFIG.MAX_SEARCH_TIME_MS)

  logger.info(`Assignment started for booking ${bookingId}`)

  // Start finding pilots
  await findAndOfferToNextPilot(bookingId)
}

/**
 * Find next available pilot and send offer
 */
async function findAndOfferToNextPilot(bookingId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'cancelled' || job.status === 'assigned') {
    return
  }

  // Check if max attempts reached
  if (job.triedPilotIds.size >= ASSIGNMENT_CONFIG.MAX_RETRY_ATTEMPTS) {
    handleNoPilotsAvailable(bookingId, 'Maximum retry attempts reached')
    return
  }

  // Find available pilots
  const pilots = await findAvailablePilots(
    job.pickupLat,
    job.pickupLng,
    job.vehicleTypeId,
    ASSIGNMENT_CONFIG.SEARCH_RADIUS_KM
  )

  // Filter out already tried pilots
  const availablePilots = pilots.filter(p => !job.triedPilotIds.has(p.id))

  if (availablePilots.length === 0) {
    // Try with larger radius
    const expandedPilots = await findAvailablePilots(
      job.pickupLat,
      job.pickupLng,
      job.vehicleTypeId,
      ASSIGNMENT_CONFIG.MAX_RADIUS_KM
    )

    const expandedAvailable = expandedPilots.filter(p => !job.triedPilotIds.has(p.id))

    if (expandedAvailable.length === 0) {
      handleNoPilotsAvailable(bookingId, 'No pilots available in your area')
      return
    }

    // Use first pilot from expanded search
    await sendOfferToPilot(bookingId, expandedAvailable[0].id)
    return
  }

  // Send offer to best available pilot
  await sendOfferToPilot(bookingId, availablePilots[0].id)
}

/**
 * Send job offer to specific pilot
 */
async function sendOfferToPilot(bookingId: string, pilotId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'cancelled') return

  try {
    // Mark pilot as tried
    job.triedPilotIds.add(pilotId)
    job.status = 'offered'

    // Create the offer (this sends socket event to pilot)
    await createJobOffer(bookingId, pilotId)

    // Notify user about which pilot received the offer
    emitToUser(job.userId, 'booking:offer_sent', {
      bookingId,
      pilotNumber: job.triedPilotIds.size,
      message: `Offer sent to driver ${job.triedPilotIds.size}...`,
    })

    // Start 30-second timeout for this offer
    job.offerTimer = setTimeout(() => {
      handleOfferTimeout(bookingId, pilotId)
    }, ASSIGNMENT_CONFIG.OFFER_TIMEOUT_MS)

    logger.info(`Offer sent to pilot ${pilotId} for booking ${bookingId}`)
  } catch (error) {
    logger.error(`Failed to send offer to pilot ${pilotId}:`, error)
    // Try next pilot
    job.status = 'searching'
    await findAndOfferToNextPilot(bookingId)
  }
}

/**
 * Handle offer timeout (pilot didn't respond in 30 seconds)
 */
async function handleOfferTimeout(bookingId: string, pilotId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'assigned' || job.status === 'cancelled') return

  logger.info(`Offer timeout for pilot ${pilotId} on booking ${bookingId}`)

  // Notify the pilot that their offer expired
  emitToPilot(pilotId, 'offer:expired', { bookingId })

  // Notify user
  emitToUser(job.userId, 'booking:offer_expired', {
    bookingId,
    message: 'Driver did not respond. Finding another driver...',
  })

  // Clear offer timer
  if (job.offerTimer) {
    clearTimeout(job.offerTimer)
    job.offerTimer = null
  }

  job.status = 'searching'

  // Find and offer to next pilot
  await findAndOfferToNextPilot(bookingId)
}

/**
 * Handle pilot accepting the job
 */
export async function handlePilotAccepted(bookingId: string, pilotId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job) return

  // Clear all timers
  if (job.offerTimer) clearTimeout(job.offerTimer)
  if (job.searchTimer) clearTimeout(job.searchTimer)

  job.status = 'assigned'

  // Get pilot details for notification
  const pilot = await prisma.pilot.findUnique({
    where: { id: pilotId },
    select: { id: true, name: true, phone: true, avatar: true, rating: true },
  })

  // Notify user
  emitToUser(job.userId, 'booking:driver_assigned', {
    bookingId,
    pilot: {
      id: pilot?.id,
      name: pilot?.name,
      phone: pilot?.phone,
      avatar: pilot?.avatar,
      rating: pilot?.rating,
    },
    message: `${pilot?.name} has accepted your booking!`,
  })

  // Notify admin dashboard
  emitToAdmin('booking:assigned', {
    bookingId,
    pilotId,
    pilotName: pilot?.name,
  })

  // Clean up
  assignmentQueue.delete(bookingId)

  logger.info(`Booking ${bookingId} assigned to pilot ${pilotId}`)
}

/**
 * Handle pilot declining the job
 */
export async function handlePilotDeclined(bookingId: string, pilotId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'assigned' || job.status === 'cancelled') return

  logger.info(`Pilot ${pilotId} declined booking ${bookingId}`)

  // Clear offer timer
  if (job.offerTimer) {
    clearTimeout(job.offerTimer)
    job.offerTimer = null
  }

  // Notify user
  emitToUser(job.userId, 'booking:offer_declined', {
    bookingId,
    message: 'Driver declined. Finding another driver...',
  })

  job.status = 'searching'

  // Find and offer to next pilot
  await findAndOfferToNextPilot(bookingId)
}

/**
 * Handle 2-minute search timeout
 */
function handleSearchTimeout(bookingId: string): void {
  const job = assignmentQueue.get(bookingId)
  if (!job || job.status === 'assigned') return

  logger.warn(`Search timeout for booking ${bookingId}`)

  // Clear offer timer if exists
  if (job.offerTimer) clearTimeout(job.offerTimer)

  job.status = 'failed'

  // Notify user with retry option
  emitToUser(job.userId, 'booking:search_timeout', {
    bookingId,
    message: 'No drivers available at the moment. Would you like to try again?',
    canRetry: true,
    canCancel: true,
  })

  // Notify admin
  emitToAdmin('booking:search_timeout', {
    bookingId,
    triedPilots: job.triedPilotIds.size,
  })

  // Don't delete from queue yet - user might retry
}

/**
 * Handle no pilots available
 */
function handleNoPilotsAvailable(bookingId: string, reason: string): void {
  const job = assignmentQueue.get(bookingId)
  if (!job) return

  logger.warn(`No pilots available for booking ${bookingId}: ${reason}`)

  // Clear timers
  if (job.offerTimer) clearTimeout(job.offerTimer)
  if (job.searchTimer) clearTimeout(job.searchTimer)

  job.status = 'failed'

  // Notify user
  emitToUser(job.userId, 'booking:no_pilots', {
    bookingId,
    message: reason,
    canRetry: true,
    canCancel: true,
  })

  // Notify admin
  emitToAdmin('booking:no_pilots', {
    bookingId,
    reason,
    triedPilots: job.triedPilotIds.size,
  })
}

/**
 * User requests retry after timeout/failure
 */
export async function retryAssignment(bookingId: string): Promise<void> {
  const job = assignmentQueue.get(bookingId)

  if (job) {
    // Reset the job
    job.startedAt = new Date()
    job.triedPilotIds.clear()
    job.currentPilotIndex = 0
    job.status = 'searching'

    // Start new search timer
    job.searchTimer = setTimeout(() => {
      handleSearchTimeout(bookingId)
    }, ASSIGNMENT_CONFIG.MAX_SEARCH_TIME_MS)

    // Notify user
    emitToUser(job.userId, 'booking:search_started', {
      bookingId,
      message: 'Searching for drivers again...',
    })

    await findAndOfferToNextPilot(bookingId)
  } else {
    // Job was cleaned up, restart fresh
    await startAssignment(bookingId)
  }
}

/**
 * Cancel assignment (user cancelled booking)
 */
export function cancelAssignment(bookingId: string): void {
  const job = assignmentQueue.get(bookingId)
  if (!job) return

  logger.info(`Assignment cancelled for booking ${bookingId}`)

  // Clear all timers
  if (job.offerTimer) clearTimeout(job.offerTimer)
  if (job.searchTimer) clearTimeout(job.searchTimer)

  job.status = 'cancelled'

  // Clean up
  assignmentQueue.delete(bookingId)
}

/**
 * Get current assignment status for a booking
 */
export function getAssignmentStatus(bookingId: string): {
  isSearching: boolean
  triedPilots: number
  status: string
  elapsedMs: number
} | null {
  const job = assignmentQueue.get(bookingId)
  if (!job) return null

  return {
    isSearching: job.status === 'searching' || job.status === 'offered',
    triedPilots: job.triedPilotIds.size,
    status: job.status,
    elapsedMs: Date.now() - job.startedAt.getTime(),
  }
}
