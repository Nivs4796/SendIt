/// Vehicle model for pilot's registered vehicles
class VehicleModel {
  final String id;
  final String pilotId;
  final VehicleType type;
  final VehicleCategory category;
  final String vehicleNumber;
  final String? model;
  final String? make;
  final bool isActive;
  final bool isVerified;
  final VehicleDocuments? documents;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VehicleModel({
    required this.id,
    required this.pilotId,
    required this.type,
    required this.category,
    required this.vehicleNumber,
    this.model,
    this.make,
    this.isActive = false,
    this.isVerified = false,
    this.documents,
    required this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      pilotId: json['pilot_id'] as String,
      type: VehicleType.fromString(json['type'] as String),
      category: VehicleCategory.fromString(json['category'] as String),
      vehicleNumber: json['vehicle_number'] as String,
      model: json['model'] as String?,
      make: json['make'] as String?,
      isActive: json['is_active'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      documents: json['documents'] != null
          ? VehicleDocuments.fromJson(json['documents'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pilot_id': pilotId,
      'type': type.value,
      'category': category.value,
      'vehicle_number': vehicleNumber,
      'model': model,
      'make': make,
      'is_active': isActive,
      'is_verified': isVerified,
      'documents': documents?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get display name for vehicle type
  String get displayName {
    final typeStr = type.displayText;
    if (category == VehicleCategory.ev) {
      return '$typeStr (EV)';
    }
    return typeStr;
  }

  /// Check if vehicle is EV
  bool get isEv => category == VehicleCategory.ev;

  VehicleModel copyWith({
    String? id,
    String? pilotId,
    VehicleType? type,
    VehicleCategory? category,
    String? vehicleNumber,
    String? model,
    String? make,
    bool? isActive,
    bool? isVerified,
    VehicleDocuments? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      pilotId: pilotId ?? this.pilotId,
      type: type ?? this.type,
      category: category ?? this.category,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      model: model ?? this.model,
      make: make ?? this.make,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Vehicle documents
class VehicleDocuments {
  final String? rcUrl;
  final String? insuranceUrl;
  final String? pollutionUrl;
  final DateTime? rcExpiry;
  final DateTime? insuranceExpiry;
  final DateTime? pollutionExpiry;

  VehicleDocuments({
    this.rcUrl,
    this.insuranceUrl,
    this.pollutionUrl,
    this.rcExpiry,
    this.insuranceExpiry,
    this.pollutionExpiry,
  });

  factory VehicleDocuments.fromJson(Map<String, dynamic> json) {
    return VehicleDocuments(
      rcUrl: json['rc_url'] as String?,
      insuranceUrl: json['insurance_url'] as String?,
      pollutionUrl: json['pollution_url'] as String?,
      rcExpiry: json['rc_expiry'] != null
          ? DateTime.parse(json['rc_expiry'] as String)
          : null,
      insuranceExpiry: json['insurance_expiry'] != null
          ? DateTime.parse(json['insurance_expiry'] as String)
          : null,
      pollutionExpiry: json['pollution_expiry'] != null
          ? DateTime.parse(json['pollution_expiry'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rc_url': rcUrl,
      'insurance_url': insuranceUrl,
      'pollution_url': pollutionUrl,
      'rc_expiry': rcExpiry?.toIso8601String(),
      'insurance_expiry': insuranceExpiry?.toIso8601String(),
      'pollution_expiry': pollutionExpiry?.toIso8601String(),
    };
  }
}

/// Vehicle type enum
enum VehicleType {
  cycle('cycle'),
  evCycle('ev_cycle'),
  twoWheeler('2_wheeler'),
  threeWheeler('3_wheeler'),
  truck('truck');

  final String value;
  const VehicleType(this.value);

  static VehicleType fromString(String value) {
    return VehicleType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VehicleType.twoWheeler,
    );
  }

  String get displayText {
    switch (this) {
      case VehicleType.cycle:
        return 'Cycle';
      case VehicleType.evCycle:
        return 'EV Cycle';
      case VehicleType.twoWheeler:
        return '2 Wheeler';
      case VehicleType.threeWheeler:
        return '3 Wheeler';
      case VehicleType.truck:
        return 'Truck';
    }
  }
}

/// Vehicle category (fuel type)
enum VehicleCategory {
  manual('manual'), // For cycle
  ev('ev'),
  petrol('petrol'),
  diesel('diesel'),
  cng('cng');

  final String value;
  const VehicleCategory(this.value);

  static VehicleCategory fromString(String value) {
    return VehicleCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VehicleCategory.petrol,
    );
  }

  String get displayText {
    switch (this) {
      case VehicleCategory.manual:
        return 'Manual';
      case VehicleCategory.ev:
        return 'Electric';
      case VehicleCategory.petrol:
        return 'Petrol';
      case VehicleCategory.diesel:
        return 'Diesel';
      case VehicleCategory.cng:
        return 'CNG';
    }
  }
}
