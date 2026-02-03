import 'address_model.dart';

/// Job model representing a delivery job for pilots
class JobModel {
  final String id;
  final String bookingId;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final AddressModel pickupAddress;
  final AddressModel dropAddress;
  final double fare;
  final double distance;
  final int estimatedDuration; // in minutes
  final JobStatus status;
  final PackageDetails? packageDetails;
  final bool loadAssistNeeded;
  final PaymentMethod paymentMethod;
  final double? codAmount;
  final String? pickupPhotoUrl;
  final String? deliveryPhotoUrl;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  JobModel({
    required this.id,
    required this.bookingId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fare,
    required this.distance,
    required this.estimatedDuration,
    this.status = JobStatus.pending,
    this.packageDetails,
    this.loadAssistNeeded = false,
    this.paymentMethod = PaymentMethod.online,
    this.codAmount,
    this.pickupPhotoUrl,
    this.deliveryPhotoUrl,
    required this.createdAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      pickupAddress: AddressModel.fromJson(
          json['pickup_address'] as Map<String, dynamic>),
      dropAddress:
          AddressModel.fromJson(json['drop_address'] as Map<String, dynamic>),
      fare: (json['fare'] as num).toDouble(),
      distance: (json['distance'] as num).toDouble(),
      estimatedDuration: json['estimated_duration'] as int,
      status: JobStatus.fromString(json['status'] as String? ?? 'pending'),
      packageDetails: json['package_details'] != null
          ? PackageDetails.fromJson(
              json['package_details'] as Map<String, dynamic>)
          : null,
      loadAssistNeeded: json['load_assist_needed'] as bool? ?? false,
      paymentMethod: PaymentMethod.fromString(
          json['payment_method'] as String? ?? 'online'),
      codAmount: (json['cod_amount'] as num?)?.toDouble(),
      pickupPhotoUrl: json['pickup_photo_url'] as String?,
      deliveryPhotoUrl: json['delivery_photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'pickup_address': pickupAddress.toJson(),
      'drop_address': dropAddress.toJson(),
      'fare': fare,
      'distance': distance,
      'estimated_duration': estimatedDuration,
      'status': status.value,
      'package_details': packageDetails?.toJson(),
      'load_assist_needed': loadAssistNeeded,
      'payment_method': paymentMethod.value,
      'cod_amount': codAmount,
      'pickup_photo_url': pickupPhotoUrl,
      'delivery_photo_url': deliveryPhotoUrl,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancellation_reason': cancellationReason,
    };
  }

  /// Get formatted fare display
  String get fareDisplay => '₹${fare.toStringAsFixed(2)}';

  /// Get formatted distance display
  String get distanceDisplay => '${distance.toStringAsFixed(1)} km';

  /// Get formatted ETA display
  String get etaDisplay {
    if (estimatedDuration < 60) {
      return '$estimatedDuration min';
    }
    final hours = estimatedDuration ~/ 60;
    final mins = estimatedDuration % 60;
    return mins > 0 ? '$hours h $mins min' : '$hours h';
  }

  /// Check if job is active
  bool get isActive =>
      status == JobStatus.assigned ||
      status == JobStatus.navigatingToPickup ||
      status == JobStatus.arrivedAtPickup ||
      status == JobStatus.packageCollected ||
      status == JobStatus.inTransit ||
      status == JobStatus.arrivedAtDrop;

  /// Check if job is completed
  bool get isCompleted => status == JobStatus.delivered;

  /// Check if job is cancelled
  bool get isCancelled => status == JobStatus.cancelled;
}

/// Package details for a job
class PackageDetails {
  final String? type;
  final String? description;
  final double? weight;
  final String? dimensions;

  PackageDetails({
    this.type,
    this.description,
    this.weight,
    this.dimensions,
  });

  factory PackageDetails.fromJson(Map<String, dynamic> json) {
    return PackageDetails(
      type: json['type'] as String?,
      description: json['description'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      dimensions: json['dimensions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'weight': weight,
      'dimensions': dimensions,
    };
  }
}

/// Job status enum matching backend
enum JobStatus {
  pending('pending'),
  assigned('assigned'),
  navigatingToPickup('navigating_to_pickup'),
  arrivedAtPickup('arrived_at_pickup'),
  packageCollected('package_collected'),
  inTransit('in_transit'),
  arrivedAtDrop('arrived_at_drop'),
  delivered('delivered'),
  cancelled('cancelled');

  final String value;
  const JobStatus(this.value);

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => JobStatus.pending,
    );
  }

  /// Get display text for status
  String get displayText {
    switch (this) {
      case JobStatus.pending:
        return 'Pending';
      case JobStatus.assigned:
        return 'Assigned';
      case JobStatus.navigatingToPickup:
        return 'Navigating to Pickup';
      case JobStatus.arrivedAtPickup:
        return 'Arrived at Pickup';
      case JobStatus.packageCollected:
        return 'Package Collected';
      case JobStatus.inTransit:
        return 'In Transit';
      case JobStatus.arrivedAtDrop:
        return 'Arrived at Drop';
      case JobStatus.delivered:
        return 'Delivered';
      case JobStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Payment method enum
enum PaymentMethod {
  online('online'),
  cod('cod'),
  wallet('wallet');

  final String value;
  const PaymentMethod(this.value);

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PaymentMethod.online,
    );
  }
}
