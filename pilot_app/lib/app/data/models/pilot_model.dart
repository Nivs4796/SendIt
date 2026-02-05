/// Pilot model for the driver/delivery partner
class PilotModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final String? profilePhotoUrl;
  final String? emergencyContact;
  final DateTime? dateOfBirth;
  final int? age;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;
  final PilotStatus status;
  final VerificationStatus verificationStatus;
  final bool isOnline;
  final double? rating;
  final int totalRides;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PilotModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.profilePhotoUrl,
    this.emergencyContact,
    this.dateOfBirth,
    this.age,
    this.address,
    this.city,
    this.state,
    this.pincode,
    this.status = PilotStatus.pending,
    this.verificationStatus = VerificationStatus.pending,
    this.isOnline = false,
    this.rating,
    this.totalRides = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory PilotModel.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase (from API) and snake_case field names
    final createdAtStr = json['createdAt'] ?? json['created_at'];
    final updatedAtStr = json['updatedAt'] ?? json['updated_at'];
    final dateOfBirthStr = json['dateOfBirth'] ?? json['date_of_birth'];
    
    // Determine verification status from multiple possible fields:
    // 1. isVerified boolean (from login response)
    // 2. verificationStatus/verification_status string (from profile response)
    VerificationStatus verificationStatus;
    final isVerifiedBool = json['isVerified'] ?? json['is_verified'];
    final verificationStatusStr = json['verificationStatus'] ?? json['verification_status'];
    
    if (isVerifiedBool == true) {
      // If isVerified is true, pilot is approved
      verificationStatus = VerificationStatus.approved;
    } else if (verificationStatusStr != null) {
      // Use the string value if available
      verificationStatus = VerificationStatus.fromString(verificationStatusStr as String);
    } else if (isVerifiedBool == false) {
      // If explicitly false, pilot is pending
      verificationStatus = VerificationStatus.pending;
    } else {
      // Default to pending
      verificationStatus = VerificationStatus.pending;
    }
    
    return PilotModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      profilePhotoUrl: (json['profilePhotoUrl'] ?? json['profile_photo_url'] ?? json['avatar']) as String?,
      emergencyContact: (json['emergencyContact'] ?? json['emergency_contact']) as String?,
      dateOfBirth: dateOfBirthStr != null
          ? DateTime.parse(dateOfBirthStr as String)
          : null,
      age: json['age'] as int?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      status: PilotStatus.fromString(json['status'] as String? ?? 'active'),
      verificationStatus: verificationStatus,
      isOnline: json['isOnline'] ?? json['is_online'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalRides: json['totalRides'] ?? json['total_rides'] as int? ?? 0,
      createdAt: createdAtStr != null 
          ? DateTime.parse(createdAtStr as String)
          : DateTime.now(),
      updatedAt: updatedAtStr != null
          ? DateTime.parse(updatedAtStr as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'profile_photo_url': profilePhotoUrl,
      'emergency_contact': emergencyContact,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'age': age,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'status': status.value,
      'verification_status': verificationStatus.value,
      'is_online': isOnline,
      'rating': rating,
      'total_rides': totalRides,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Check if pilot is verified
  bool get isVerified => verificationStatus == VerificationStatus.approved;

  PilotModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    String? profilePhotoUrl,
    String? emergencyContact,
    DateTime? dateOfBirth,
    int? age,
    String? address,
    String? city,
    String? state,
    String? pincode,
    PilotStatus? status,
    VerificationStatus? verificationStatus,
    bool? isOnline,
    double? rating,
    int? totalRides,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PilotModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      age: age ?? this.age,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      status: status ?? this.status,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum PilotStatus {
  pending('pending'),
  active('active'),
  approved('approved'),
  suspended('suspended'),
  inactive('inactive');

  final String value;
  const PilotStatus(this.value);

  static PilotStatus fromString(String value) {
    final lowerValue = value.toLowerCase();

    // Handle various formats from backend
    if (lowerValue == 'approved' || lowerValue == 'active') {
      return PilotStatus.active;
    }
    if (lowerValue == 'suspended') {
      return PilotStatus.suspended;
    }
    if (lowerValue == 'inactive') {
      return PilotStatus.inactive;
    }

    return PilotStatus.pending;
  }
}

enum VerificationStatus {
  pending('pending'),
  inReview('in_review'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const VerificationStatus(this.value);

  static VerificationStatus fromString(String value) {
    final lowerValue = value.toLowerCase();
    
    // Handle various formats from backend
    if (lowerValue == 'approved' || lowerValue == 'verified') {
      return VerificationStatus.approved;
    }
    if (lowerValue == 'in_review' || lowerValue == 'inreview' || lowerValue == 'in-review' || lowerValue == 'review') {
      return VerificationStatus.inReview;
    }
    if (lowerValue == 'rejected' || lowerValue == 'declined') {
      return VerificationStatus.rejected;
    }
    
    return VerificationStatus.pending;
  }
}
