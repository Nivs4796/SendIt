import 'dart:async';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/constants/api_constants.dart';
import '../core/constants/app_constants.dart';
import 'storage_service.dart';

/// Data class for driver location updates
class DriverLocationData {
  final String bookingId;
  final LatLng location;
  final double heading;
  final DateTime timestamp;

  DriverLocationData({
    required this.bookingId,
    required this.location,
    required this.heading,
    required this.timestamp,
  });

  factory DriverLocationData.fromJson(Map<String, dynamic> json) {
    return DriverLocationData(
      bookingId: json['bookingId'] ?? '',
      location: LatLng(
        (json['latitude'] ?? json['lat'] ?? 0.0).toDouble(),
        (json['longitude'] ?? json['lng'] ?? 0.0).toDouble(),
      ),
      heading: (json['heading'] ?? json['bearing'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  @override
  String toString() =>
      'DriverLocationData(bookingId: $bookingId, location: $location, heading: $heading)';
}

/// Data class for ETA updates
class EtaUpdateData {
  final String bookingId;
  final int etaMinutes;
  final double distanceKm;

  EtaUpdateData({
    required this.bookingId,
    required this.etaMinutes,
    required this.distanceKm,
  });

  factory EtaUpdateData.fromJson(Map<String, dynamic> json) {
    return EtaUpdateData(
      bookingId: json['bookingId'] ?? '',
      etaMinutes: (json['etaMinutes'] ?? json['eta'] ?? 0).toInt(),
      distanceKm: (json['distanceKm'] ?? json['distance'] ?? 0.0).toDouble(),
    );
  }

  String get formattedEta {
    if (etaMinutes < 1) return 'Arriving now';
    if (etaMinutes == 1) return '1 min';
    return '$etaMinutes mins';
  }

  String get formattedDistance {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).toInt()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  @override
  String toString() =>
      'EtaUpdateData(bookingId: $bookingId, eta: $etaMinutes mins, distance: $distanceKm km)';
}

/// Data class for booking status updates
class StatusUpdateData {
  final String bookingId;
  final BookingStatus status;
  final DateTime timestamp;

  StatusUpdateData({
    required this.bookingId,
    required this.status,
    required this.timestamp,
  });

  factory StatusUpdateData.fromJson(Map<String, dynamic> json) {
    return StatusUpdateData(
      bookingId: json['bookingId'] ?? '',
      status: _parseBookingStatus(json['status']),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  static BookingStatus _parseBookingStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACCEPTED':
        return BookingStatus.accepted;
      case 'ARRIVED_PICKUP':
        return BookingStatus.arrivedPickup;
      case 'PICKED_UP':
        return BookingStatus.pickedUp;
      case 'IN_TRANSIT':
        return BookingStatus.inTransit;
      case 'ARRIVED_DROP':
        return BookingStatus.arrivedDrop;
      case 'DELIVERED':
        return BookingStatus.delivered;
      case 'CANCELLED':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  @override
  String toString() =>
      'StatusUpdateData(bookingId: $bookingId, status: $status)';
}

/// Data class for driver assignment
class DriverAssignedData {
  final String bookingId;
  final String pilotId;
  final String pilotName;
  final String pilotPhone;
  final String? pilotAvatar;
  final double pilotRating;
  final String? vehicleNumber;
  final String? vehicleModel;

  DriverAssignedData({
    required this.bookingId,
    required this.pilotId,
    required this.pilotName,
    required this.pilotPhone,
    this.pilotAvatar,
    this.pilotRating = 0.0,
    this.vehicleNumber,
    this.vehicleModel,
  });

  factory DriverAssignedData.fromJson(Map<String, dynamic> json) {
    final pilot = json['pilot'] ?? json;
    final vehicle = json['vehicle'] ?? pilot['vehicle'];

    return DriverAssignedData(
      bookingId: json['bookingId'] ?? '',
      pilotId: pilot['id'] ?? pilot['pilotId'] ?? '',
      pilotName: pilot['name'] ?? '',
      pilotPhone: pilot['phone'] ?? '',
      pilotAvatar: pilot['avatar'],
      pilotRating: (pilot['rating'] ?? 0.0).toDouble(),
      vehicleNumber: vehicle?['registrationNo'] ?? vehicle?['number'],
      vehicleModel: vehicle?['model'],
    );
  }

  @override
  String toString() =>
      'DriverAssignedData(bookingId: $bookingId, pilot: $pilotName)';
}

/// Data class for booking cancellation
class BookingCancelledData {
  final String bookingId;
  final String? reason;
  final String? cancelledBy;
  final DateTime timestamp;

  BookingCancelledData({
    required this.bookingId,
    this.reason,
    this.cancelledBy,
    required this.timestamp,
  });

  factory BookingCancelledData.fromJson(Map<String, dynamic> json) {
    return BookingCancelledData(
      bookingId: json['bookingId'] ?? '',
      reason: json['reason'] ?? json['cancelReason'],
      cancelledBy: json['cancelledBy'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  @override
  String toString() =>
      'BookingCancelledData(bookingId: $bookingId, reason: $reason)';
}

/// Data class for search started event
class SearchStartedData {
  final String bookingId;
  final String message;

  SearchStartedData({
    required this.bookingId,
    required this.message,
  });

  factory SearchStartedData.fromJson(Map<String, dynamic> json) {
    return SearchStartedData(
      bookingId: json['bookingId'] ?? '',
      message: json['message'] ?? 'Searching for drivers...',
    );
  }

  @override
  String toString() => 'SearchStartedData(bookingId: $bookingId)';
}

/// Data class for offer sent to pilot event
class OfferSentData {
  final String bookingId;
  final int pilotNumber;
  final String message;

  OfferSentData({
    required this.bookingId,
    required this.pilotNumber,
    required this.message,
  });

  factory OfferSentData.fromJson(Map<String, dynamic> json) {
    return OfferSentData(
      bookingId: json['bookingId'] ?? '',
      pilotNumber: json['pilotNumber'] ?? 1,
      message: json['message'] ?? 'Contacting driver...',
    );
  }

  @override
  String toString() =>
      'OfferSentData(bookingId: $bookingId, pilotNumber: $pilotNumber)';
}

/// Data class for no pilots available event
class NoPilotsData {
  final String bookingId;
  final String message;
  final bool canRetry;
  final bool canCancel;

  NoPilotsData({
    required this.bookingId,
    required this.message,
    this.canRetry = true,
    this.canCancel = true,
  });

  factory NoPilotsData.fromJson(Map<String, dynamic> json) {
    return NoPilotsData(
      bookingId: json['bookingId'] ?? '',
      message: json['message'] ?? 'No drivers available in your area',
      canRetry: json['canRetry'] ?? true,
      canCancel: json['canCancel'] ?? true,
    );
  }

  @override
  String toString() => 'NoPilotsData(bookingId: $bookingId, canRetry: $canRetry)';
}

/// Data class for search timeout event
class SearchTimeoutData {
  final String bookingId;
  final String message;
  final bool canRetry;
  final bool canCancel;

  SearchTimeoutData({
    required this.bookingId,
    required this.message,
    this.canRetry = true,
    this.canCancel = true,
  });

  factory SearchTimeoutData.fromJson(Map<String, dynamic> json) {
    return SearchTimeoutData(
      bookingId: json['bookingId'] ?? '',
      message: json['message'] ?? 'Search timed out. All drivers are busy.',
      canRetry: json['canRetry'] ?? true,
      canCancel: json['canCancel'] ?? true,
    );
  }

  @override
  String toString() =>
      'SearchTimeoutData(bookingId: $bookingId, canRetry: $canRetry)';
}

/// SocketService for real-time tracking and booking updates
class SocketService extends GetxService {
  io.Socket? _socket;
  final StorageService _storageService = Get.find<StorageService>();

  // Connection state observables
  final RxBool isConnected = false.obs;
  final Rx<String?> connectionError = Rx<String?>(null);

  // Stream controllers for different event types
  final StreamController<DriverLocationData> _driverLocationController =
      StreamController<DriverLocationData>.broadcast();
  final StreamController<StatusUpdateData> _statusUpdateController =
      StreamController<StatusUpdateData>.broadcast();
  final StreamController<EtaUpdateData> _etaUpdateController =
      StreamController<EtaUpdateData>.broadcast();
  final StreamController<DriverAssignedData> _driverAssignedController =
      StreamController<DriverAssignedData>.broadcast();
  final StreamController<String> _bookingCompletedController =
      StreamController<String>.broadcast();
  final StreamController<BookingCancelledData> _bookingCancelledController =
      StreamController<BookingCancelledData>.broadcast();

  // Assignment flow stream controllers
  final StreamController<SearchStartedData> _searchStartedController =
      StreamController<SearchStartedData>.broadcast();
  final StreamController<OfferSentData> _offerSentController =
      StreamController<OfferSentData>.broadcast();
  final StreamController<NoPilotsData> _noPilotsController =
      StreamController<NoPilotsData>.broadcast();
  final StreamController<SearchTimeoutData> _searchTimeoutController =
      StreamController<SearchTimeoutData>.broadcast();

  // Track joined rooms for reconnection
  final Set<String> _joinedRooms = {};

  // Public streams
  Stream<DriverLocationData> get driverLocationStream =>
      _driverLocationController.stream;
  Stream<StatusUpdateData> get statusUpdateStream =>
      _statusUpdateController.stream;
  Stream<EtaUpdateData> get etaUpdateStream => _etaUpdateController.stream;
  Stream<DriverAssignedData> get driverAssignedStream =>
      _driverAssignedController.stream;
  Stream<String> get bookingCompletedStream =>
      _bookingCompletedController.stream;
  Stream<BookingCancelledData> get bookingCancelledStream =>
      _bookingCancelledController.stream;

  // Assignment flow streams
  Stream<SearchStartedData> get searchStartedStream =>
      _searchStartedController.stream;
  Stream<OfferSentData> get offerSentStream => _offerSentController.stream;
  Stream<NoPilotsData> get noPilotsStream => _noPilotsController.stream;
  Stream<SearchTimeoutData> get searchTimeoutStream =>
      _searchTimeoutController.stream;

  /// Connect to the socket server with authentication
  Future<void> connect() async {
    if (_socket?.connected == true) {
      print('[SocketService] Already connected');
      return;
    }

    final token = _storageService.token;
    if (token == null) {
      connectionError.value = 'No authentication token available';
      print('[SocketService] Cannot connect: No auth token');
      return;
    }

    try {
      print('[SocketService] Connecting to ${ApiConstants.socketUrl}');

      _socket = io.io(
        ApiConstants.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _setupEventListeners();
      _socket?.connect();
    } catch (e) {
      connectionError.value = 'Failed to initialize socket: $e';
      print('[SocketService] Connection error: $e');
    }
  }

  /// Set up socket event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('[SocketService] Connected');
      isConnected.value = true;
      connectionError.value = null;
      _rejoinRooms();
    });

    _socket!.onDisconnect((_) {
      print('[SocketService] Disconnected');
      isConnected.value = false;
    });

    _socket!.onConnectError((error) {
      print('[SocketService] Connection error: $error');
      connectionError.value = 'Connection failed: $error';
      isConnected.value = false;
    });

    _socket!.onError((error) {
      print('[SocketService] Socket error: $error');
      connectionError.value = 'Socket error: $error';
    });

    _socket!.onReconnect((_) {
      print('[SocketService] Reconnected');
      isConnected.value = true;
      connectionError.value = null;
      _rejoinRooms();
    });

    _socket!.onReconnectAttempt((attempt) {
      print('[SocketService] Reconnection attempt: $attempt');
    });

    _socket!.onReconnectFailed((_) {
      print('[SocketService] Reconnection failed');
      connectionError.value = 'Failed to reconnect to server';
    });

    // Booking events
    _socket!.on('driver:location', _handleDriverLocation);
    _socket!.on('booking:status', _handleStatusUpdate);
    _socket!.on('booking:eta', _handleEtaUpdate);
    _socket!.on('booking:driver-assigned', _handleDriverAssigned);
    _socket!.on('booking:driver_assigned', _handleDriverAssigned); // Also handle underscore version
    _socket!.on('booking:completed', _handleBookingCompleted);
    _socket!.on('booking:cancelled', _handleBookingCancelled);

    // Assignment flow events
    _socket!.on('booking:search_started', _handleSearchStarted);
    _socket!.on('booking:offer_sent', _handleOfferSent);
    _socket!.on('booking:offer_expired', _handleOfferExpired);
    _socket!.on('booking:offer_declined', _handleOfferDeclined);
    _socket!.on('booking:no_pilots', _handleNoPilots);
    _socket!.on('booking:search_timeout', _handleSearchTimeout);

    // Acknowledgement events
    _socket!.on('room:joined', (data) {
      print('[SocketService] Joined room: $data');
    });

    _socket!.on('room:left', (data) {
      print('[SocketService] Left room: $data');
    });
  }

  /// Handle driver location updates
  void _handleDriverLocation(dynamic data) {
    try {
      print('[SocketService] Driver location update: $data');
      final locationData = DriverLocationData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _driverLocationController.add(locationData);
    } catch (e) {
      print('[SocketService] Error parsing driver location: $e');
    }
  }

  /// Handle booking status updates
  void _handleStatusUpdate(dynamic data) {
    try {
      print('[SocketService] Status update: $data');
      final statusData = StatusUpdateData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _statusUpdateController.add(statusData);
    } catch (e) {
      print('[SocketService] Error parsing status update: $e');
    }
  }

  /// Handle ETA updates
  void _handleEtaUpdate(dynamic data) {
    try {
      print('[SocketService] ETA update: $data');
      final etaData = EtaUpdateData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _etaUpdateController.add(etaData);
    } catch (e) {
      print('[SocketService] Error parsing ETA update: $e');
    }
  }

  /// Handle driver assignment
  void _handleDriverAssigned(dynamic data) {
    try {
      print('[SocketService] Driver assigned: $data');
      final assignedData = DriverAssignedData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _driverAssignedController.add(assignedData);
    } catch (e) {
      print('[SocketService] Error parsing driver assignment: $e');
    }
  }

  /// Handle booking completion
  void _handleBookingCompleted(dynamic data) {
    try {
      print('[SocketService] Booking completed: $data');
      final bookingId = data is String
          ? data
          : (data is Map ? (data['bookingId'] ?? data['id'] ?? '') : '');
      if (bookingId.isNotEmpty) {
        _bookingCompletedController.add(bookingId);
      }
    } catch (e) {
      print('[SocketService] Error parsing booking completion: $e');
    }
  }

  /// Handle booking cancellation
  void _handleBookingCancelled(dynamic data) {
    try {
      print('[SocketService] Booking cancelled: $data');
      final cancelledData = BookingCancelledData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _bookingCancelledController.add(cancelledData);
    } catch (e) {
      print('[SocketService] Error parsing booking cancellation: $e');
    }
  }

  /// Handle search started event
  void _handleSearchStarted(dynamic data) {
    try {
      print('[SocketService] Search started: $data');
      final searchData = SearchStartedData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _searchStartedController.add(searchData);
    } catch (e) {
      print('[SocketService] Error parsing search started: $e');
    }
  }

  /// Handle offer sent event
  void _handleOfferSent(dynamic data) {
    try {
      print('[SocketService] Offer sent: $data');
      final offerData = OfferSentData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _offerSentController.add(offerData);
    } catch (e) {
      print('[SocketService] Error parsing offer sent: $e');
    }
  }

  /// Handle offer expired event (pilot didn't respond in time)
  void _handleOfferExpired(dynamic data) {
    try {
      print('[SocketService] Offer expired: $data');
      // Treat as implicit offer sent to next pilot - UI will show progress
      final jsonData =
          data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);
      final offerData = OfferSentData(
        bookingId: jsonData['bookingId'] ?? '',
        pilotNumber: (jsonData['pilotNumber'] ?? 1) + 1,
        message: 'Trying another driver...',
      );
      _offerSentController.add(offerData);
    } catch (e) {
      print('[SocketService] Error parsing offer expired: $e');
    }
  }

  /// Handle offer declined event
  void _handleOfferDeclined(dynamic data) {
    try {
      print('[SocketService] Offer declined: $data');
      // Treat as implicit offer sent to next pilot - UI will show progress
      final jsonData =
          data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data);
      final offerData = OfferSentData(
        bookingId: jsonData['bookingId'] ?? '',
        pilotNumber: (jsonData['pilotNumber'] ?? 1) + 1,
        message: 'Driver unavailable, trying another...',
      );
      _offerSentController.add(offerData);
    } catch (e) {
      print('[SocketService] Error parsing offer declined: $e');
    }
  }

  /// Handle no pilots available event
  void _handleNoPilots(dynamic data) {
    try {
      print('[SocketService] No pilots available: $data');
      final noPilotsData = NoPilotsData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _noPilotsController.add(noPilotsData);
    } catch (e) {
      print('[SocketService] Error parsing no pilots: $e');
    }
  }

  /// Handle search timeout event
  void _handleSearchTimeout(dynamic data) {
    try {
      print('[SocketService] Search timeout: $data');
      final timeoutData = SearchTimeoutData.fromJson(
        data is Map<String, dynamic> ? data : Map<String, dynamic>.from(data),
      );
      _searchTimeoutController.add(timeoutData);
    } catch (e) {
      print('[SocketService] Error parsing search timeout: $e');
    }
  }

  /// Join a booking room for updates
  void joinBookingRoom(String bookingId) {
    if (bookingId.isEmpty) {
      print('[SocketService] Cannot join room: empty bookingId');
      return;
    }

    _joinedRooms.add(bookingId);

    if (_socket?.connected == true) {
      print('[SocketService] Joining booking room: $bookingId');
      _socket!.emit('booking:join', {'bookingId': bookingId});
    } else {
      print('[SocketService] Not connected, room will be joined on connect');
    }
  }

  /// Leave a booking room
  void leaveBookingRoom(String bookingId) {
    if (bookingId.isEmpty) return;

    _joinedRooms.remove(bookingId);

    if (_socket?.connected == true) {
      print('[SocketService] Leaving booking room: $bookingId');
      _socket!.emit('booking:leave', {'bookingId': bookingId});
    }
  }

  /// Rejoin all rooms after reconnection
  void _rejoinRooms() {
    for (final bookingId in _joinedRooms) {
      print('[SocketService] Rejoining room: $bookingId');
      _socket?.emit('booking:join', {'bookingId': bookingId});
    }
  }

  /// Disconnect from the socket server
  void disconnect() {
    print('[SocketService] Disconnecting');

    // Leave all rooms before disconnecting
    for (final bookingId in _joinedRooms.toList()) {
      leaveBookingRoom(bookingId);
    }
    _joinedRooms.clear();

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
    connectionError.value = null;
  }

  /// Emit a custom event
  void emit(String event, dynamic data) {
    if (_socket?.connected == true) {
      _socket!.emit(event, data);
    } else {
      print('[SocketService] Cannot emit $event: not connected');
    }
  }

  /// Check if connected to socket server
  bool get connected => _socket?.connected ?? false;

  @override
  void onClose() {
    print('[SocketService] Closing service');
    disconnect();

    // Close all stream controllers
    _driverLocationController.close();
    _statusUpdateController.close();
    _etaUpdateController.close();
    _driverAssignedController.close();
    _bookingCompletedController.close();
    _bookingCancelledController.close();

    // Close assignment flow stream controllers
    _searchStartedController.close();
    _offerSentController.close();
    _noPilotsController.close();
    _searchTimeoutController.close();

    super.onClose();
  }
}
