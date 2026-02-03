import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/constants/api_constants.dart';
import '../core/constants/socket_events.dart';
import 'storage_service.dart';

/// Service for managing WebSocket connection with backend
/// Handles connection, reconnection, and event dispatching
class SocketService extends GetxService {
  io.Socket? _socket;
  final StorageService _storage = Get.find<StorageService>();
  
  // Connection state
  final connectionState = SocketConnectionState.disconnected.obs;
  final isConnected = false.obs;
  
  // Reconnection tracking
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  
  // Event callbacks (set by JobsController)
  Function(Map<String, dynamic>)? onBookingOffer;
  Function(String)? onOfferExpired;
  Function(Map<String, dynamic>)? onBookingStatus;
  Function(Map<String, dynamic>)? onNotification;
  Function(String, String)? onError;

  /// Initialize and connect socket
  Future<SocketService> init() async {
    return this;
  }

  /// Connect to socket server (call when going online)
  void connect() {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final token = _storage.token;
    if (token == null) {
      connectionState.value = SocketConnectionState.error;
      return;
    }

    connectionState.value = SocketConnectionState.connecting;

    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer $token'})
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(maxReconnectAttempts)
          .setReconnectionDelay(initialReconnectDelayMs)
          .setReconnectionDelayMax(maxReconnectDelayMs)
          .build(),
    );

    _setupEventListeners();
    _socket!.connect();
  }

  /// Disconnect from socket server (call when going offline)
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    
    connectionState.value = SocketConnectionState.disconnected;
    isConnected.value = false;
  }

  /// Setup all event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      connectionState.value = SocketConnectionState.connected;
      isConnected.value = true;
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      print('Socket connected');
    });

    _socket!.onDisconnect((_) {
      connectionState.value = SocketConnectionState.disconnected;
      isConnected.value = false;
      print('Socket disconnected');
    });

    _socket!.onConnectError((error) {
      connectionState.value = SocketConnectionState.error;
      isConnected.value = false;
      print('Socket connect error: $error');
      _handleReconnect();
    });

    _socket!.onError((error) {
      print('Socket error: $error');
    });

    _socket!.on('reconnecting', (_) {
      connectionState.value = SocketConnectionState.reconnecting;
      print('Socket reconnecting...');
    });

    _socket!.on('reconnect', (_) {
      connectionState.value = SocketConnectionState.connected;
      isConnected.value = true;
      _reconnectAttempts = 0;
      print('Socket reconnected');
    });

    // Business events
    _socket!.on(SocketEvents.bookingOffer, (data) {
      print('Received booking offer: $data');
      if (data != null && onBookingOffer != null) {
        onBookingOffer!(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on(SocketEvents.offerExpired, (data) {
      print('Offer expired: $data');
      if (data != null && onOfferExpired != null) {
        final bookingId = data['bookingId'] as String?;
        if (bookingId != null) {
          onOfferExpired!(bookingId);
        }
      }
    });

    _socket!.on(SocketEvents.bookingStatus, (data) {
      print('Booking status update: $data');
      if (data != null && onBookingStatus != null) {
        onBookingStatus!(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on(SocketEvents.notification, (data) {
      print('Notification received: $data');
      if (data != null && onNotification != null) {
        onNotification!(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on(SocketEvents.error, (data) {
      print('Socket server error: $data');
      if (data != null && onError != null) {
        final code = data['code'] as String? ?? 'UNKNOWN';
        final message = data['message'] as String? ?? 'An error occurred';
        onError!(code, message);
      }
    });
  }

  /// Handle reconnection with exponential backoff
  void _handleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      connectionState.value = SocketConnectionState.error;
      return;
    }

    _reconnectAttempts++;
    final delay = _calculateBackoff(_reconnectAttempts);
    
    print('Reconnecting in ${delay}ms (attempt $_reconnectAttempts)');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      if (connectionState.value != SocketConnectionState.connected) {
        connect();
      }
    });
  }

  /// Calculate exponential backoff delay
  int _calculateBackoff(int attempt) {
    final delay = initialReconnectDelayMs * (1 << (attempt - 1));
    return delay > maxReconnectDelayMs ? maxReconnectDelayMs : delay;
  }

  // ============================================
  // EMIT METHODS
  // ============================================

  /// Notify server pilot is online
  void emitOnline(String vehicleId) {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit(SocketEvents.pilotOnline, {'vehicleId': vehicleId});
    print('Emitted pilot:online with vehicle $vehicleId');
  }

  /// Notify server pilot is offline
  void emitOffline() {
    if (_socket == null || !_socket!.connected) return;
    _socket!.emit(SocketEvents.pilotOffline);
    print('Emitted pilot:offline');
  }

  /// Send location update
  void emitLocation({
    required double lat,
    required double lng,
    double? heading,
    double? speed,
  }) {
    if (_socket == null || !_socket!.connected) return;
    
    _socket!.emit(SocketEvents.pilotLocation, {
      'lat': lat,
      'lng': lng,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
    });
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
