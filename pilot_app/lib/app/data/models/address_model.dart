class AddressModel {
  final String id;
  final String? userId;
  final String label;
  final String address;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pincode;
  final double lat;
  final double lng;
  final bool isDefault;
  final String? contactName;
  final String? contactPhone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    this.userId,
    required this.label,
    required this.address,
    this.landmark,
    this.city,
    this.state,
    this.pincode,
    required this.lat,
    required this.lng,
    this.isDefault = false,
    this.contactName,
    this.contactPhone,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // Handle createdAt/updatedAt parsing safely
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return AddressModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] ?? json['user_id'] as String?,
      label: json['label'] as String? ?? 'Address',
      address: json['address'] as String? ?? '',
      landmark: json['landmark'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      isDefault: json['isDefault'] ?? json['is_default'] as bool? ?? false,
      contactName: json['contactName'] ?? json['contact_name'] as String?,
      contactPhone: json['contactPhone'] ?? json['contact_phone'] as String?,
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      updatedAt: parseDate(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'label': label,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'label': label,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'lat': lat,
      'lng': lng,
      'isDefault': isDefault,
    };
  }

  String get shortAddress {
    if (address.length > 40) {
      return '${address.substring(0, 40)}...';
    }
    return address;
  }

  String get fullAddress {
    final parts = [address, landmark, city, state, pincode]
        .where((p) => p != null && p.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}
