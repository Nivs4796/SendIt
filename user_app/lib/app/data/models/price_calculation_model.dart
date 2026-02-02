/// Model representing the price calculation response from the API.
class PriceCalculationModel {
  final double distance;
  final int estimatedDuration;
  final double baseFare;
  final double distanceFare;
  final double taxes;
  final double totalAmount;
  final String? currency;

  PriceCalculationModel({
    required this.distance,
    required this.estimatedDuration,
    required this.baseFare,
    required this.distanceFare,
    this.taxes = 0,
    required this.totalAmount,
    this.currency = 'INR',
  });

  factory PriceCalculationModel.fromJson(Map<String, dynamic> json) {
    return PriceCalculationModel(
      distance: (json['distance'] ?? 0).toDouble(),
      estimatedDuration: (json['estimatedDuration'] ?? 0).toInt(),
      baseFare: (json['baseFare'] ?? 0).toDouble(),
      distanceFare: (json['distanceFare'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'estimatedDuration': estimatedDuration,
      'baseFare': baseFare,
      'distanceFare': distanceFare,
      'taxes': taxes,
      'totalAmount': totalAmount,
      'currency': currency,
    };
  }

  // Display helpers
  String get distanceDisplay => '${distance.toStringAsFixed(1)} km';

  String get durationDisplay {
    if (estimatedDuration < 60) {
      return '$estimatedDuration min';
    }
    final hours = estimatedDuration ~/ 60;
    final minutes = estimatedDuration % 60;
    if (minutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $minutes min';
  }

  String get totalDisplay => '$_currencySymbol${totalAmount.toStringAsFixed(2)}';

  String get baseFareDisplay => '$_currencySymbol${baseFare.toStringAsFixed(2)}';

  String get distanceFareDisplay => '$_currencySymbol${distanceFare.toStringAsFixed(2)}';

  String get taxesDisplay => '$_currencySymbol${taxes.toStringAsFixed(2)}';

  String get _currencySymbol {
    switch (currency) {
      case 'INR':
        return '\u20B9';
      case 'USD':
        return '\$';
      case 'EUR':
        return '\u20AC';
      case 'GBP':
        return '\u00A3';
      default:
        return '\u20B9';
    }
  }
}

/// Request model for creating a new booking.
/// Uses saved address IDs rather than raw coordinates.
class CreateBookingRequest {
  final String vehicleTypeId;
  final String pickupAddressId;
  final String dropAddressId;
  final String packageType;
  final String? packageDescription;
  final double? packageWeight;
  final String paymentMethod;
  final String? couponCode;
  final DateTime? scheduledAt;

  CreateBookingRequest({
    required this.vehicleTypeId,
    required this.pickupAddressId,
    required this.dropAddressId,
    required this.packageType,
    this.packageDescription,
    this.packageWeight,
    required this.paymentMethod,
    this.couponCode,
    this.scheduledAt,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'vehicleTypeId': vehicleTypeId,
      'pickupAddressId': pickupAddressId,
      'dropAddressId': dropAddressId,
      'packageType': packageType.toUpperCase(),
      'paymentMethod': paymentMethod.toUpperCase(),
    };

    if (packageDescription != null && packageDescription!.isNotEmpty) {
      json['packageDescription'] = packageDescription;
    }
    if (packageWeight != null) {
      json['packageWeight'] = packageWeight;
    }
    if (couponCode != null && couponCode!.isNotEmpty) {
      json['couponCode'] = couponCode;
    }
    if (scheduledAt != null) {
      json['scheduledAt'] = scheduledAt!.toIso8601String();
    }

    return json;
  }
}
