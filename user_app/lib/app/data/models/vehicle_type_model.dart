class VehicleTypeModel {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final double maxWeight;
  final double basePrice;
  final double pricePerKm;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.maxWeight,
    required this.basePrice,
    required this.pricePerKm,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      maxWeight: (json['maxWeight'] ?? 0).toDouble(),
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      pricePerKm: (json['pricePerKm'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'maxWeight': maxWeight,
      'basePrice': basePrice,
      'pricePerKm': pricePerKm,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get weightDisplay => '${maxWeight.toStringAsFixed(0)} kg';
  String get basePriceDisplay => '₹${basePrice.toStringAsFixed(0)}';
}
