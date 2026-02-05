import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;

import '../models/job_model.dart';
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';

/// Repository for job-related API calls
class JobRepository {
  final ApiClient _api = Get.find<ApiClient>();

  // ============================================
  // JOB ACTIONS
  // ============================================

  /// Accept a job offer
  /// POST /bookings/:id/accept
  Future<JobModel> acceptJob(String bookingId) async {
    try {
      final response = await _api.post('/bookings/$bookingId/accept');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return JobModel.fromJson(
          _transformBookingToJob(response.data['data']['booking']),
        );
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to accept job',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to accept job',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Decline a job offer
  /// POST /bookings/:id/decline
  Future<void> declineJob(String bookingId, {String? reason}) async {
    try {
      final response = await _api.post(
        '/bookings/$bookingId/decline',
        data: {
          if (reason != null) 'reason': reason,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to decline job',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to decline job',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Update job status
  /// PATCH /bookings/:id/status
  Future<JobModel> updateJobStatus(
    String bookingId,
    JobStatus status, {
    double? lat,
    double? lng,
    String? note,
  }) async {
    try {
      final response = await _api.patch(
        '/bookings/$bookingId/status',
        data: {
          'status': _statusToApiValue(status),
          if (lat != null) 'lat': lat,
          if (lng != null) 'lng': lng,
          if (note != null) 'note': note,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return JobModel.fromJson(
          _transformBookingToJob(response.data['data']['booking']),
        );
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to update status',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to update status',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Cancel a job
  /// POST /bookings/:id/cancel
  Future<void> cancelJob(String bookingId, String reason) async {
    try {
      final response = await _api.post(
        '/bookings/$bookingId/cancel',
        data: {
          'reason': reason,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to cancel job',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to cancel job',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ============================================
  // JOB QUERIES
  // ============================================

  /// Get job details by ID
  /// GET /bookings/:id
  Future<JobModel> getJob(String bookingId) async {
    try {
      final response = await _api.get('/bookings/$bookingId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return JobModel.fromJson(
          _transformBookingToJob(response.data['data']['booking']),
        );
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to get job',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to get job',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get pilot's active jobs
  /// GET /pilots/bookings?status=active
  Future<List<JobModel>> getActiveJobs() async {
    try {
      final response = await _api.get(
        '/pilots/bookings',
        queryParameters: {'status': 'active'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bookings = response.data['data']['bookings'] as List? ?? [];

        // Filter only truly active jobs (not delivered/cancelled)
        // Active statuses: assigned, navigating_to_pickup, arrived_at_pickup,
        //                  package_collected, in_transit, arrived_at_drop
        const activeStatuses = [
          'ACCEPTED',
          'ARRIVED_PICKUP',
          'PICKED_UP',
          'IN_TRANSIT',
          'ARRIVED_DROP',
        ];

        return bookings
            .where((b) => activeStatuses.contains(b['status']))
            .map((b) => JobModel.fromJson(_transformBookingToJob(b)))
            .toList();
      }

      return [];
    } on DioException {
      return [];
    }
  }

  /// Get pilot's job history
  /// GET /pilots/bookings?status=completed
  Future<List<JobModel>> getJobHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '/pilots/bookings',
        queryParameters: {
          'status': 'completed',
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final bookings = response.data['data']['bookings'] as List? ?? [];
        return bookings
            .map((b) => JobModel.fromJson(_transformBookingToJob(b)))
            .toList();
      }

      return [];
    } on DioException {
      return [];
    }
  }

  /// Get available jobs near location
  /// GET /pilots/available-jobs
  Future<List<JobModel>> getAvailableJobs({
    required double lat,
    required double lng,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _api.get(
        '/pilots/available-jobs',
        queryParameters: {
          'lat': lat.toString(),
          'lng': lng.toString(),
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final jobs = response.data['data']['jobs'] as List? ?? [];
        return jobs
            .map((j) => JobModel.fromJson(_transformBookingToJob(j)))
            .toList();
      }

      return [];
    } on DioException {
      return [];
    }
  }

  // ============================================
  // PHOTO UPLOAD
  // ============================================

  /// Upload delivery photo
  /// POST /upload/document (with type: delivery_photo)
  Future<String> uploadDeliveryPhoto(
    String bookingId,
    File photoFile, {
    bool isPickup = false,
  }) async {
    try {
      final fileName = photoFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          photoFile.path,
          filename: fileName,
        ),
        'type': isPickup ? 'pickup_photo' : 'delivery_photo',
        'bookingId': bookingId,
      });

      final response = await _api.uploadFile(
        '/upload/document',
        formData: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['url'] as String;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to upload photo',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to upload photo',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Update job with photo URL
  /// PATCH /bookings/:id/photo
  Future<void> updateJobPhoto(
    String bookingId, {
    String? pickupPhotoUrl,
    String? deliveryPhotoUrl,
  }) async {
    try {
      final response = await _api.patch(
        '/bookings/$bookingId/photo',
        data: {
          if (pickupPhotoUrl != null) 'pickupPhotoUrl': pickupPhotoUrl,
          if (deliveryPhotoUrl != null) 'deliveryPhotoUrl': deliveryPhotoUrl,
        },
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ApiException(
          message: response.data['message'] ?? 'Failed to update photo',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] ?? 'Failed to update photo',
        statusCode: e.response?.statusCode,
      );
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Transform backend booking format to job format
  Map<String, dynamic> _transformBookingToJob(Map<String, dynamic> booking) {
    return {
      'id': booking['id'],
      'booking_id': booking['id'],
      'customer_id': booking['userId'],
      'customer_name': booking['user']?['name'],
      'customer_phone': booking['user']?['phone'],
      'pickup_address': {
        'id': booking['pickupAddress']?['id'],
        'label': booking['pickupAddress']?['label'] ?? 'Pickup',
        'address': booking['pickupAddress']?['address'] ?? '',
        'lat': booking['pickupAddress']?['lat'] ?? booking['pickupLat'],
        'lng': booking['pickupAddress']?['lng'] ?? booking['pickupLng'],
        'landmark': booking['pickupAddress']?['landmark'],
        'contact_name': booking['pickupAddress']?['contactName'],
        'contact_phone': booking['pickupAddress']?['contactPhone'],
      },
      'drop_address': {
        'id': booking['dropAddress']?['id'],
        'label': booking['dropAddress']?['label'] ?? 'Drop',
        'address': booking['dropAddress']?['address'] ?? '',
        'lat': booking['dropAddress']?['lat'] ?? booking['dropLat'],
        'lng': booking['dropAddress']?['lng'] ?? booking['dropLng'],
        'landmark': booking['dropAddress']?['landmark'],
        'contact_name': booking['dropAddress']?['contactName'],
        'contact_phone': booking['dropAddress']?['contactPhone'],
      },
      'fare': booking['totalAmount'] ?? booking['fare'] ?? 0,
      'distance': booking['distance'] ?? 0,
      'estimated_duration': booking['estimatedDuration'] ?? 30,
      'status': _apiStatusToJobStatus(booking['status']),
      'package_details': booking['packageType'] != null
          ? {
              'type': booking['packageType'],
              'description': booking['packageDescription'],
              'weight': booking['packageWeight'],
            }
          : null,
      'load_assist_needed': booking['loadAssistNeeded'] ?? false,
      'payment_method':
          (booking['paymentMethod'] ?? 'online').toString().toLowerCase(),
      'cod_amount': booking['codAmount'],
      'pickup_photo_url': booking['pickupPhotoUrl'],
      'delivery_photo_url': booking['deliveryPhotoUrl'],
      'created_at': booking['createdAt'] ?? DateTime.now().toIso8601String(),
      'accepted_at': booking['acceptedAt'],
      'picked_up_at': booking['pickedUpAt'],
      'delivered_at': booking['deliveredAt'],
      'cancelled_at': booking['cancelledAt'],
      'cancellation_reason': booking['cancellationReason'],
    };
  }

  /// Convert API status to JobStatus value
  String _apiStatusToJobStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return 'pending';
      case 'ACCEPTED':
        return 'assigned';
      case 'ARRIVED_PICKUP':
        return 'arrived_at_pickup';
      case 'PICKED_UP':
        return 'package_collected';
      case 'IN_TRANSIT':
        return 'in_transit';
      case 'ARRIVED_DROP':
        return 'arrived_at_drop';
      case 'DELIVERED':
        return 'delivered';
      case 'CANCELLED':
        return 'cancelled';
      default:
        return 'pending';
    }
  }

  /// Convert JobStatus to API status value
  String _statusToApiValue(JobStatus status) {
    switch (status) {
      case JobStatus.pending:
        return 'PENDING';
      case JobStatus.assigned:
        return 'ACCEPTED';
      case JobStatus.navigatingToPickup:
        return 'ACCEPTED'; // Same as assigned
      case JobStatus.arrivedAtPickup:
        return 'ARRIVED_PICKUP';
      case JobStatus.packageCollected:
        return 'PICKED_UP';
      case JobStatus.inTransit:
        return 'IN_TRANSIT';
      case JobStatus.arrivedAtDrop:
        return 'ARRIVED_DROP';
      case JobStatus.delivered:
        return 'DELIVERED';
      case JobStatus.cancelled:
        return 'CANCELLED';
    }
  }
}
