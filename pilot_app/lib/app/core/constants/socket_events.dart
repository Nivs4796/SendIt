/// Socket.IO event constants for pilot app
/// Matches backend socket/types.ts
class SocketEvents {
  SocketEvents._();

  // ============================================
  // CLIENT → SERVER (Emit)
  // ============================================
  
  /// Pilot goes online with a vehicle
  /// Data: { vehicleId: string }
  static const String pilotOnline = 'pilot:online';
  
  /// Pilot goes offline
  /// Data: none
  static const String pilotOffline = 'pilot:offline';
  
  /// Pilot location update
  /// Data: { lat, lng, heading?, speed? }
  static const String pilotLocation = 'pilot:location';

  // ============================================
  // SERVER → CLIENT (Listen)
  // ============================================
  
  /// New booking offer received
  /// Data: BookingOfferPayload
  static const String bookingOffer = 'booking:offer';
  
  /// Offer expired (timeout)
  /// Data: { bookingId: string }
  static const String offerExpired = 'offer:expired';
  
  /// Booking status changed
  /// Data: BookingStatusPayload
  static const String bookingStatus = 'booking:status';
  
  /// Live location update (for tracking)
  /// Data: LocationUpdatePayload
  static const String locationUpdate = 'location:update';
  
  /// General notification
  /// Data: NotificationPayload
  static const String notification = 'notification';
  
  /// Error from server
  /// Data: { code: string, message: string }
  static const String error = 'error';
}

/// Socket connection states
enum SocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// Offer timeout in seconds (must match backend)
const int jobOfferTimeoutSeconds = 30;

/// Location update interval in milliseconds
const int locationUpdateIntervalMs = 5000;

/// Reconnection settings
const int maxReconnectAttempts = 10;
const int initialReconnectDelayMs = 1000;
const int maxReconnectDelayMs = 30000;
