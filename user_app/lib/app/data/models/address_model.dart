class AddressModel {
  final String id;
  final String userId;
  final String label;
  final String address;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final double lat;
  final double lng;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.lat,
    required this.lng,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      userId: json['userId'],
      label: json['label'],
      address: json['address'],
      landmark: json['landmark'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
