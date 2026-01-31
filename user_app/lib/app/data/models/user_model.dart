class UserModel {
  final String id;
  final String phone;
  final String? email;
  final String? name;
  final String? avatar;
  final double walletBalance;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.phone,
    this.email,
    this.name,
    this.avatar,
    this.walletBalance = 0,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      name: json['name'],
      avatar: json['avatar'],
      walletBalance: (json['walletBalance'] ?? 0).toDouble(),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'avatar': avatar,
      'walletBalance': walletBalance,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? email,
    String? name,
    String? avatar,
    double? walletBalance,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      walletBalance: walletBalance ?? this.walletBalance,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
