import 'package:get/get.dart' hide Response;
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';

class HistoryRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get job history with filters
  /// GET /pilots/bookings with query params (status, dateFrom, dateTo, page, limit)
  Future<JobHistoryResponse> getJobHistory({
    int page = 1,
    int limit = 20,
    String? status, // 'completed', 'cancelled'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      // Map status to API expected values
      if (status != null) {
        params['status'] = status.toUpperCase();
      }
      if (startDate != null) {
        params['dateFrom'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        params['dateTo'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _api.get(
        ApiConstants.pilotBookings,
        queryParameters: params,
      );
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return JobHistoryResponse.fromJson(response.data);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load job history',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      // Return mock data for development when network fails
      return _getMockJobHistory(page, limit);
    } on TimeoutException {
      return _getMockJobHistory(page, limit);
    } catch (e) {
      // Fallback to mock data for development
      return _getMockJobHistory(page, limit);
    }
  }

  /// Get single job details
  /// GET /bookings/:id
  Future<JobHistoryItem> getJobDetails(String jobId) async {
    try {
      final response = await _api.get(ApiConstants.jobDetails(jobId));
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final bookingData = data['booking'] ?? data;
        return JobHistoryItem.fromJson(_transformBookingToHistoryItem(bookingData));
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load job details',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Failed to load job details: $e');
    }
  }

  /// Transform backend booking format to history item format
  Map<String, dynamic> _transformBookingToHistoryItem(Map<String, dynamic> booking) {
    // Extract addresses
    final pickupAddress = booking['pickupAddress'] as Map<String, dynamic>?;
    final dropAddress = booking['dropAddress'] as Map<String, dynamic>?;
    
    // Calculate earnings
    final totalAmount = (booking['totalAmount'] as num?)?.toDouble() ?? 
        (booking['fare'] as num?)?.toDouble() ?? 0;
    final tip = (booking['tip'] as num?)?.toDouble() ?? 0;
    
    // Map status
    String statusStr = 'completed';
    final apiStatus = booking['status']?.toString().toUpperCase();
    if (apiStatus == 'CANCELLED') {
      statusStr = 'cancelled';
    } else if (apiStatus == 'DELIVERED' || apiStatus == 'COMPLETED') {
      statusStr = 'completed';
    }

    return {
      'id': booking['id'] ?? booking['_id'],
      'bookingNumber': booking['bookingNumber'] ?? booking['orderNumber'] ?? 
          'SND-${(booking['id'] ?? '').toString().substring(0, 6).toUpperCase()}',
      'status': statusStr,
      'pickupAddress': pickupAddress?['address'] ?? booking['pickupAddressText'] ?? '',
      'pickupArea': pickupAddress?['area'] ?? pickupAddress?['locality'] ?? 
          _extractArea(pickupAddress?['address'] ?? ''),
      'deliveryAddress': dropAddress?['address'] ?? booking['dropAddressText'] ?? '',
      'deliveryArea': dropAddress?['area'] ?? dropAddress?['locality'] ?? 
          _extractArea(dropAddress?['address'] ?? ''),
      'distance': booking['distance'] ?? 0,
      'duration': booking['duration'] ?? booking['estimatedDuration'] ?? 0,
      'fare': totalAmount,
      'tip': tip,
      'earnings': totalAmount + tip,
      'customerName': booking['user']?['name'] ?? booking['customerName'] ?? 'Customer',
      'packageType': booking['packageType'] ?? 'Parcel',
      'createdAt': booking['createdAt'],
      'completedAt': booking['deliveredAt'] ?? booking['completedAt'],
      'cancelledAt': booking['cancelledAt'],
      'cancellationReason': booking['cancellationReason'],
      'rating': booking['pilotRating'] ?? booking['rating'],
    };
  }

  /// Extract area from full address
  String _extractArea(String address) {
    if (address.isEmpty) return '';
    final parts = address.split(',');
    if (parts.length >= 2) {
      return parts[1].trim();
    }
    return parts.first.trim();
  }

  JobHistoryResponse _getMockJobHistory(int page, int limit) {
    final now = DateTime.now();
    final jobs = <JobHistoryItem>[
      JobHistoryItem(
        id: '1',
        bookingNumber: 'SND-001234',
        status: JobStatus.completed,
        pickupAddress: '123, MG Road, Koramangala',
        pickupArea: 'Koramangala',
        deliveryAddress: '456, HSR Layout, Sector 2',
        deliveryArea: 'HSR Layout',
        distance: 5.2,
        duration: 25,
        fare: 149.0,
        tip: 20.0,
        earnings: 169.0,
        customerName: 'John Doe',
        packageType: 'Document',
        createdAt: now.subtract(const Duration(hours: 2)),
        completedAt: now.subtract(const Duration(hours: 1, minutes: 30)),
        rating: 5.0,
      ),
      JobHistoryItem(
        id: '2',
        bookingNumber: 'SND-001233',
        status: JobStatus.completed,
        pickupAddress: '789, Indiranagar, 100 Feet Road',
        pickupArea: 'Indiranagar',
        deliveryAddress: '321, Whitefield, Main Road',
        deliveryArea: 'Whitefield',
        distance: 12.5,
        duration: 45,
        fare: 289.0,
        tip: 0.0,
        earnings: 289.0,
        customerName: 'Jane Smith',
        packageType: 'Parcel',
        createdAt: now.subtract(const Duration(hours: 5)),
        completedAt: now.subtract(const Duration(hours: 4)),
        rating: 4.5,
      ),
      JobHistoryItem(
        id: '3',
        bookingNumber: 'SND-001232',
        status: JobStatus.cancelled,
        pickupAddress: '555, Electronic City',
        pickupArea: 'Electronic City',
        deliveryAddress: '777, Marathahalli',
        deliveryArea: 'Marathahalli',
        distance: 8.0,
        duration: 0,
        fare: 199.0,
        tip: 0.0,
        earnings: 25.0, // Cancellation compensation
        customerName: 'Bob Wilson',
        packageType: 'Food',
        createdAt: now.subtract(const Duration(days: 1)),
        cancelledAt: now.subtract(const Duration(days: 1)),
        cancellationReason: 'Customer cancelled',
      ),
      JobHistoryItem(
        id: '4',
        bookingNumber: 'SND-001231',
        status: JobStatus.completed,
        pickupAddress: '999, BTM Layout, 2nd Stage',
        pickupArea: 'BTM Layout',
        deliveryAddress: '111, Jayanagar, 4th Block',
        deliveryArea: 'Jayanagar',
        distance: 4.0,
        duration: 18,
        fare: 99.0,
        tip: 10.0,
        earnings: 109.0,
        customerName: 'Alice Johnson',
        packageType: 'Document',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        completedAt: now.subtract(const Duration(days: 1, hours: 2)),
        rating: 5.0,
      ),
      JobHistoryItem(
        id: '5',
        bookingNumber: 'SND-001230',
        status: JobStatus.completed,
        pickupAddress: '222, Malleshwaram',
        pickupArea: 'Malleshwaram',
        deliveryAddress: '333, Rajajinagar',
        deliveryArea: 'Rajajinagar',
        distance: 3.5,
        duration: 15,
        fare: 79.0,
        tip: 0.0,
        earnings: 79.0,
        customerName: 'Charlie Brown',
        packageType: 'Parcel',
        createdAt: now.subtract(const Duration(days: 2)),
        completedAt: now.subtract(const Duration(days: 2)),
        rating: 4.0,
      ),
    ];

    return JobHistoryResponse(
      jobs: jobs,
      totalCount: jobs.length,
      currentPage: page,
      totalPages: 1,
      hasMore: false,
    );
  }
}

/// Job history response with pagination
class JobHistoryResponse {
  final List<JobHistoryItem> jobs;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  JobHistoryResponse({
    required this.jobs,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasMore,
  });

  factory JobHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    List<dynamic> bookingsList;
    
    // Handle different response formats
    if (data is List) {
      bookingsList = data;
    } else if (data is Map) {
      bookingsList = data['bookings'] ?? data['jobs'] ?? data['history'] ?? [];
    } else {
      bookingsList = [];
    }

    // Parse bookings with transformation
    final jobs = bookingsList.map((b) {
      final transformed = _transformBooking(b);
      return JobHistoryItem.fromJson(transformed);
    }).toList();

    // Get pagination info from meta
    final meta = json['meta'] as Map<String, dynamic>?;
    final page = meta?['page'] as int? ?? json['currentPage'] as int? ?? 1;
    final totalPages = meta?['totalPages'] as int? ?? json['totalPages'] as int? ?? 1;
    final total = meta?['total'] as int? ?? json['totalCount'] as int? ?? jobs.length;

    return JobHistoryResponse(
      jobs: jobs,
      totalCount: total,
      currentPage: page,
      totalPages: totalPages,
      hasMore: page < totalPages,
    );
  }

  static Map<String, dynamic> _transformBooking(Map<String, dynamic> booking) {
    // Extract addresses
    final pickupAddress = booking['pickupAddress'] as Map<String, dynamic>?;
    final dropAddress = booking['dropAddress'] as Map<String, dynamic>?;
    
    // Calculate earnings
    final totalAmount = (booking['totalAmount'] as num?)?.toDouble() ?? 
        (booking['fare'] as num?)?.toDouble() ?? 0;
    final tip = (booking['tip'] as num?)?.toDouble() ?? 0;
    
    // Map status
    String statusStr = 'completed';
    final apiStatus = booking['status']?.toString().toUpperCase();
    if (apiStatus == 'CANCELLED') {
      statusStr = 'cancelled';
    } else if (apiStatus == 'DELIVERED' || apiStatus == 'COMPLETED') {
      statusStr = 'completed';
    }

    // Extract area from full address
    String extractArea(String address) {
      if (address.isEmpty) return '';
      final parts = address.split(',');
      if (parts.length >= 2) {
        return parts[1].trim();
      }
      return parts.first.trim();
    }

    final pickupAddressStr = pickupAddress?['address'] ?? booking['pickupAddressText'] ?? '';
    final dropAddressStr = dropAddress?['address'] ?? booking['dropAddressText'] ?? '';

    return {
      'id': booking['id'] ?? booking['_id'],
      'bookingNumber': booking['bookingNumber'] ?? booking['orderNumber'] ?? 
          'SND-${(booking['id'] ?? '').toString().padLeft(6, '0').substring(0, 6).toUpperCase()}',
      'status': statusStr,
      'pickupAddress': pickupAddressStr,
      'pickupArea': pickupAddress?['area'] ?? pickupAddress?['locality'] ?? 
          extractArea(pickupAddressStr),
      'deliveryAddress': dropAddressStr,
      'deliveryArea': dropAddress?['area'] ?? dropAddress?['locality'] ?? 
          extractArea(dropAddressStr),
      'distance': booking['distance'] ?? 0,
      'duration': booking['duration'] ?? booking['estimatedDuration'] ?? 0,
      'fare': totalAmount,
      'tip': tip,
      'earnings': totalAmount + tip,
      'customerName': booking['user']?['name'] ?? booking['customerName'] ?? 'Customer',
      'packageType': booking['packageType'] ?? 'Parcel',
      'createdAt': booking['createdAt'],
      'completedAt': booking['deliveredAt'] ?? booking['completedAt'],
      'cancelledAt': booking['cancelledAt'],
      'cancellationReason': booking['cancellationReason'],
      'rating': booking['pilotRating'] ?? booking['rating'],
    };
  }
}

/// Job status enum
enum JobStatus {
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case JobStatus.completed:
        return 'Completed';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Job history item model
class JobHistoryItem {
  final String id;
  final String bookingNumber;
  final JobStatus status;
  final String pickupAddress;
  final String pickupArea;
  final String deliveryAddress;
  final String deliveryArea;
  final double distance;
  final int duration; // in minutes
  final double fare;
  final double tip;
  final double earnings;
  final String customerName;
  final String packageType;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final double? rating;

  JobHistoryItem({
    required this.id,
    required this.bookingNumber,
    required this.status,
    required this.pickupAddress,
    required this.pickupArea,
    required this.deliveryAddress,
    required this.deliveryArea,
    required this.distance,
    required this.duration,
    required this.fare,
    required this.tip,
    required this.earnings,
    required this.customerName,
    required this.packageType,
    required this.createdAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.rating,
  });

  factory JobHistoryItem.fromJson(Map<String, dynamic> json) {
    return JobHistoryItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      bookingNumber: json['bookingNumber'] ?? '',
      status: _parseStatus(json['status']),
      pickupAddress: json['pickupAddress'] ?? '',
      pickupArea: json['pickupArea'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      deliveryArea: json['deliveryArea'] ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0,
      duration: json['duration'] as int? ?? 0,
      fare: (json['fare'] as num?)?.toDouble() ?? 0,
      tip: (json['tip'] as num?)?.toDouble() ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0,
      customerName: json['customerName'] ?? '',
      packageType: json['packageType'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'].toString())
          : null,
      cancellationReason: json['cancellationReason'],
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  static JobStatus _parseStatus(dynamic status) {
    if (status == null) return JobStatus.completed;
    final statusStr = status.toString().toLowerCase();
    switch (statusStr) {
      case 'cancelled':
        return JobStatus.cancelled;
      case 'completed':
      case 'delivered':
      default:
        return JobStatus.completed;
    }
  }

  String get durationDisplay {
    if (duration < 60) return '$duration min';
    final hours = duration ~/ 60;
    final mins = duration % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  String get distanceDisplay => '${distance.toStringAsFixed(1)} km';
  String get earningsDisplay => '₹${earnings.toStringAsFixed(0)}';
}
