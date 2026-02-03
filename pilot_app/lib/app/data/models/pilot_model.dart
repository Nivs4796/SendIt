/// Pilot model for the driver/delivery partner
class PilotModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
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
    return PilotModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      age: json['age'] as int?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      status: PilotStatus.fromString(json['status'] as String? ?? 'pending'),
      verificationStatus: VerificationStatus.fromString(
          json['verification_status'] as String? ?? 'pending'),
      isOnline: json['is_online'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble(),
      totalRides: json['total_rides'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
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

  PilotModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
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
  suspended('suspended'),
  inactive('inactive');

  final String value;
  const PilotStatus(this.value);

  static PilotStatus fromString(String value) {
    return PilotStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PilotStatus.pending,
    );
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
    return VerificationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => VerificationStatus.pending,
    );
  }
}
