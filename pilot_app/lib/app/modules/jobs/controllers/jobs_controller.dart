import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/socket_events.dart';
import '../../../data/models/address_model.dart';
import '../../../data/models/job_model.dart';
import '../../../data/repositories/job_repository.dart';
import '../../../services/location_service.dart';
import '../../../services/socket_service.dart';
import '../widgets/job_offer_popup.dart';

/// Incoming job offer from WebSocket
class JobOffer {
  final String bookingId;
  final String bookingNumber;
  final AddressModel pickupAddress;
  final AddressModel dropAddress;
  final double distance;
  final double fare;
  final String? packageType;
  final DateTime expiresAt;
  
  JobOffer({
    required this.bookingId,
    required this.bookingNumber,
    required this.pickupAddress,
    required this.dropAddress,
    required this.distance,
    required this.fare,
    this.packageType,
    required this.expiresAt,
  });
  
  factory JobOffer.fromJson(Map<String, dynamic> json) {
    return JobOffer(
      bookingId: json['bookingId'] as String,
      bookingNumber: json['bookingNumber'] as String? ?? 'N/A',
      pickupAddress: AddressModel.fromJson({
        'address': json['pickupAddress']?['address'] ?? '',
        'lat': json['pickupAddress']?['lat'] ?? 0.0,
        'lng': json['pickupAddress']?['lng'] ?? 0.0,
      }),
      dropAddress: AddressModel.fromJson({
        'address': json['dropAddress']?['address'] ?? '',
        'lat': json['dropAddress']?['lat'] ?? 0.0,
        'lng': json['dropAddress']?['lng'] ?? 0.0,
      }),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      fare: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      packageType: json['packageType'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
  
  /// Remaining seconds until expiry
  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now());
    return diff.inSeconds > 0 ? diff.inSeconds : 0;
  }
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Global job state controller
/// Manages job offers, active jobs, and WebSocket events
class JobsController extends GetxController {
  final JobRepository _repository = JobRepository();
  late final SocketService _socketService;
  late final LocationService _locationService;
  
  // ============================================
  // STATE
  // ============================================
  
  /// Currently active job (only one at a time)
  final activeJob = Rxn<JobModel>();
  
  /// Incoming job offers queue
  final pendingOffers = <JobOffer>[].obs;
  
  /// Currently displayed offer
  final currentOffer = Rxn<JobOffer>();
  
  /// Loading states
  final isAccepting = false.obs;
  final isDeclining = false.obs;
  final isUpdatingStatus = false.obs;
  
  /// Error state
  final error = Rxn<String>();
  
  // Timer for location updates
  Timer? _locationTimer;
  
  // Currently shown popup
  bool _isPopupShowing = false;
  
  @override
  void onInit() {
    super.onInit();
    _initServices();
  }
  
  void _initServices() {
    // Get services
    _socketService = Get.find<SocketService>();
    _locationService = Get.find<LocationService>();
    
    // Setup socket callbacks
    _socketService.onBookingOffer = _handleBookingOffer;
    _socketService.onOfferExpired = _handleOfferExpired;
    _socketService.onBookingStatus = _handleBookingStatus;
    _socketService.onError = _handleSocketError;
    
    // Setup location callback
    _locationService.onLocationUpdate = _handleLocationUpdate;
    
    // Load any existing active job
    _loadActiveJob();
  }
  
  @override
  void onClose() {
    _locationTimer?.cancel();
    super.onClose();
  }
  
  // ============================================
  // SOCKET EVENT HANDLERS
  // ============================================
  
  void _handleBookingOffer(Map<String, dynamic> data) {
    try {
      final offer = JobOffer.fromJson(data);
      
      // Don't accept offers if already have active job
      if (activeJob.value != null) {
        print('Ignoring offer - already have active job');
        return;
      }
      
      // Add to queue
      pendingOffers.add(offer);
      
      // Show popup if not already showing
      if (!_isPopupShowing) {
        _showNextOffer();
      }
    } catch (e) {
      print('Error parsing job offer: $e');
    }
  }
  
  void _handleOfferExpired(String bookingId) {
    // Remove from queue
    pendingOffers.removeWhere((o) => o.bookingId == bookingId);
    
    // If current offer expired, show next
    if (currentOffer.value?.bookingId == bookingId) {
      currentOffer.value = null;
      _isPopupShowing = false;
      _showNextOffer();
    }
  }
  
  void _handleBookingStatus(Map<String, dynamic> data) {
    final bookingId = data['bookingId'] as String?;
    final status = data['status'] as String?;
    
    if (bookingId == null || status == null) return;
    
    // Update active job if it matches
    if (activeJob.value?.bookingId == bookingId) {
      // If cancelled by customer
      if (status == 'CANCELLED') {
        _handleJobCancelled();
      } else {
        // Refresh job data
        _refreshActiveJob();
      }
    }
  }
  
  void _handleSocketError(String code, String message) {
    error.value = message;
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
    );
  }
  
  void _handleLocationUpdate(LocationData location) {
    // Send to server if we have active job
    if (activeJob.value != null && _socketService.isConnected.value) {
      _socketService.emitLocation(
        lat: location.lat,
        lng: location.lng,
        heading: location.heading,
        speed: location.speed,
      );
    }
  }
  
  // ============================================
  // JOB OFFER ACTIONS
  // ============================================
  
  void _showNextOffer() {
    if (pendingOffers.isEmpty) {
      currentOffer.value = null;
      _isPopupShowing = false;
      return;
    }
    
    // Get next valid offer
    final offer = pendingOffers.firstWhereOrNull((o) => !o.isExpired);
    if (offer == null) {
      pendingOffers.clear();
      currentOffer.value = null;
      _isPopupShowing = false;
      return;
    }
    
    currentOffer.value = offer;
    _isPopupShowing = true;
    
    // Show popup
    Get.dialog(
      JobOfferPopup(offer: offer),
      barrierDismissible: false,
    );
  }
  
  /// Accept current job offer
  Future<bool> acceptOffer() async {
    final offer = currentOffer.value;
    if (offer == null) return false;
    
    isAccepting.value = true;
    error.value = null;
    
    try {
      final job = await _repository.acceptJob(offer.bookingId);
      
      // Set as active job
      activeJob.value = job;
      
      // Remove from queue
      pendingOffers.remove(offer);
      currentOffer.value = null;
      _isPopupShowing = false;
      
      // Close popup
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      // Start location tracking
      _startLocationTracking();
      
      // Navigate to active job screen
      Get.toNamed('/active-job');
      
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Failed to Accept',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isAccepting.value = false;
    }
  }
  
  /// Decline current job offer
  Future<void> declineOffer({String? reason}) async {
    final offer = currentOffer.value;
    if (offer == null) return;
    
    isDeclining.value = true;
    
    try {
      await _repository.declineJob(offer.bookingId, reason: reason);
    } catch (e) {
      print('Error declining offer: $e');
    } finally {
      isDeclining.value = false;
      
      // Remove from queue
      pendingOffers.remove(offer);
      currentOffer.value = null;
      
      // Close popup
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      
      _isPopupShowing = false;
      
      // Show next offer
      _showNextOffer();
    }
  }
  
  // ============================================
  // ACTIVE JOB ACTIONS
  // ============================================
  
  /// Load any existing active job on app start
  Future<void> _loadActiveJob() async {
    try {
      final jobs = await _repository.getActiveJobs();
      if (jobs.isNotEmpty) {
        activeJob.value = jobs.first;
        _startLocationTracking();
      }
    } catch (e) {
      print('Error loading active jobs: $e');
    }
  }
  
  /// Refresh active job data
  Future<void> _refreshActiveJob() async {
    final job = activeJob.value;
    if (job == null) return;
    
    try {
      final updated = await _repository.getJob(job.bookingId);
      activeJob.value = updated;
    } catch (e) {
      print('Error refreshing job: $e');
    }
  }
  
  /// Update job status (status progression)
  Future<bool> updateStatus(JobStatus newStatus) async {
    final job = activeJob.value;
    if (job == null) return false;
    
    isUpdatingStatus.value = true;
    error.value = null;
    
    try {
      final location = _locationService.currentLocation.value;
      
      final updated = await _repository.updateJobStatus(
        job.bookingId,
        newStatus,
        lat: location?.lat,
        lng: location?.lng,
      );
      
      activeJob.value = updated;
      
      // If delivered, clear active job
      if (newStatus == JobStatus.delivered) {
        _handleJobCompleted();
      }
      
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Update Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }
  
  /// Cancel active job
  Future<bool> cancelJob(String reason) async {
    final job = activeJob.value;
    if (job == null) return false;
    
    isUpdatingStatus.value = true;
    error.value = null;
    
    try {
      await _repository.cancelJob(job.bookingId, reason);
      _handleJobCancelled();
      return true;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Cancel Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }
  
  /// Upload delivery photo
  Future<String?> uploadPhoto(String filePath, {bool isPickup = false}) async {
    final job = activeJob.value;
    if (job == null) return null;
    
    try {
      final url = await _repository.uploadDeliveryPhoto(
        job.bookingId,
        File(filePath),
        isPickup: isPickup,
      );
      
      // Update job with photo URL
      await _repository.updateJobPhoto(
        job.bookingId,
        pickupPhotoUrl: isPickup ? url : null,
        deliveryPhotoUrl: isPickup ? null : url,
      );
      
      // Refresh job
      await _refreshActiveJob();
      
      return url;
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return null;
    }
  }
  
  // ============================================
  // HELPER METHODS
  // ============================================
  
  void _startLocationTracking() {
    _locationService.startTracking();
    
    // Also send location periodically via timer
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(
      const Duration(milliseconds: locationUpdateIntervalMs),
      (_) {
        final location = _locationService.currentLocation.value;
        if (location != null && activeJob.value != null) {
          _socketService.emitLocation(
            lat: location.lat,
            lng: location.lng,
            heading: location.heading,
            speed: location.speed,
          );
        }
      },
    );
  }
  
  void _stopLocationTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _locationService.stopTracking();
  }
  
  void _handleJobCompleted() {
    activeJob.value = null;
    _stopLocationTracking();
    
    // Navigate back to home
    Get.offAllNamed('/home');
    
    Get.snackbar(
      'Job Completed! 🎉',
      'Great job! Earnings have been added to your wallet.',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 3),
    );
  }
  
  void _handleJobCancelled() {
    activeJob.value = null;
    _stopLocationTracking();
    
    // Navigate back to home
    Get.offAllNamed('/home');
    
    Get.snackbar(
      'Job Cancelled',
      'This job has been cancelled.',
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
    );
  }
  
  /// Get next action text based on current status
  String getNextActionText() {
    final status = activeJob.value?.status;
    switch (status) {
      case JobStatus.assigned:
      case JobStatus.navigatingToPickup:
        return 'Arrived at Pickup';
      case JobStatus.arrivedAtPickup:
        return 'Package Collected';
      case JobStatus.packageCollected:
      case JobStatus.inTransit:
        return 'Arrived at Drop';
      case JobStatus.arrivedAtDrop:
        return 'Complete Delivery';
      default:
        return 'Update Status';
    }
  }
  
  /// Get next status based on current status
  JobStatus? getNextStatus() {
    final status = activeJob.value?.status;
    switch (status) {
      case JobStatus.assigned:
      case JobStatus.navigatingToPickup:
        return JobStatus.arrivedAtPickup;
      case JobStatus.arrivedAtPickup:
        return JobStatus.packageCollected;
      case JobStatus.packageCollected:
      case JobStatus.inTransit:
        return JobStatus.arrivedAtDrop;
      case JobStatus.arrivedAtDrop:
        return JobStatus.delivered;
      default:
        return null;
    }
  }
  
  /// Check if photo is required for current status
  bool isPhotoRequired() {
    final status = activeJob.value?.status;
    // Photo required at delivery
    return status == JobStatus.arrivedAtDrop;
  }
  
  /// Check if COD collection is required
  bool isCodRequired() {
    final job = activeJob.value;
    if (job == null) return false;
    return job.paymentMethod == PaymentMethod.cod && 
           job.status == JobStatus.arrivedAtDrop;
  }
}
