/// Vehicle model for pilot's registered vehicles
class VehicleModel {
  final String id;
  final String pilotId;
  final VehicleType vehicleType;
  final VehicleCategory? category;
  final String registrationNumber;
  final String? model;
  final String? make;
  final int? year;
  final String? color;
  final bool isActive;
  final bool isVerified;
  final bool isElectric;
  final String? insuranceNumber;
  final DateTime? insuranceExpiry;
  final VehicleDocuments? documents;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VehicleModel({
    required this.id,
    required this.pilotId,
    required this.vehicleType,
    this.category,
    required this.registrationNumber,
    this.model,
    this.make,
    this.year,
    this.color,
    this.isActive = false,
    this.isVerified = false,
    this.isElectric = false,
    this.insuranceNumber,
    this.insuranceExpiry,
    this.documents,
    required this.createdAt,
    this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    // Support both snake_case and camelCase
    final typeStr = (json['vehicle_type'] ?? json['vehicleType'] ?? json['type'] ?? 'twoWheeler') as String;
    final categoryStr = json['category'] as String?;
    
    return VehicleModel(
      id: json['id'] as String,
      pilotId: (json['pilot_id'] ?? json['pilotId'] ?? '') as String,
      vehicleType: VehicleType.fromString(typeStr),
      category: categoryStr != null ? VehicleCategory.fromString(categoryStr) : null,
      registrationNumber: (json['registration_number'] ?? json['registrationNumber'] ?? json['vehicle_number'] ?? '') as String,
      model: json['model'] as String?,
      make: json['make'] as String?,
      year: json['year'] as int?,
      color: json['color'] as String?,
      isActive: (json['is_active'] ?? json['isActive'] ?? false) as bool,
      isVerified: (json['is_verified'] ?? json['isVerified'] ?? false) as bool,
      isElectric: (json['is_electric'] ?? json['isElectric'] ?? json['category'] == 'ev') as bool,
      insuranceNumber: (json['insurance_number'] ?? json['insuranceNumber']) as String?,
      insuranceExpiry: json['insurance_expiry'] != null 
          ? DateTime.parse(json['insurance_expiry'] as String)
          : json['insuranceExpiry'] != null
              ? DateTime.parse(json['insuranceExpiry'] as String)
              : null,
      documents: json['documents'] != null
          ? VehicleDocuments.fromJson(json['documents'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pilot_id': pilotId,
      'vehicle_type': vehicleType.value,
      'category': category?.value,
      'registration_number': registrationNumber,
      'model': model,
      'make': make,
      'year': year,
      'color': color,
      'is_active': isActive,
      'is_verified': isVerified,
      'is_electric': isElectric,
      'insurance_number': insuranceNumber,
      'insurance_expiry': insuranceExpiry?.toIso8601String(),
      'documents': documents?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get display name for vehicle type
  String get displayName {
    final typeStr = vehicleType.displayText;
    if (isElectric || category == VehicleCategory.ev) {
      return '$typeStr (EV)';
    }
    return typeStr;
  }

  VehicleModel copyWith({
    String? id,
    String? pilotId,
    VehicleType? vehicleType,
    VehicleCategory? category,
    String? registrationNumber,
    String? model,
    String? make,
    int? year,
    String? color,
    bool? isActive,
    bool? isVerified,
    bool? isElectric,
    String? insuranceNumber,
    DateTime? insuranceExpiry,
    VehicleDocuments? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      pilotId: pilotId ?? this.pilotId,
      vehicleType: vehicleType ?? this.vehicleType,
      category: category ?? this.category,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      model: model ?? this.model,
      make: make ?? this.make,
      year: year ?? this.year,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      isElectric: isElectric ?? this.isElectric,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
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
  fourWheeler('4_wheeler'),
  truck('truck');

  final String value;
  const VehicleType(this.value);

  static VehicleType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cycle':
        return VehicleType.cycle;
      case 'ev_cycle':
      case 'evcycle':
        return VehicleType.evCycle;
      case 'twowheeler':
      case 'two_wheeler':
      case '2_wheeler':
      case '2wheeler':
        return VehicleType.twoWheeler;
      case 'threewheeler':
      case 'three_wheeler':
      case '3_wheeler':
      case '3wheeler':
        return VehicleType.threeWheeler;
      case 'fourwheeler':
      case 'four_wheeler':
      case '4_wheeler':
      case '4wheeler':
        return VehicleType.fourWheeler;
      case 'truck':
        return VehicleType.truck;
      default:
        return VehicleType.twoWheeler;
    }
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
      case VehicleType.fourWheeler:
        return '4 Wheeler';
      case VehicleType.truck:
        return 'Truck';
    }
  }

  /// For vehicles view compatibility
  String get displayName => displayText;
}

/// Vehicle category (fuel type)
enum VehicleCategory {
  manual('manual'),
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
