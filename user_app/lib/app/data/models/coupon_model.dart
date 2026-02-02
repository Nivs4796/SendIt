import 'package:flutter/material.dart';

class CouponModel {
  final String id;
  final String code;
  final String? description;
  final DiscountType discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscount;
  final DateTime? expiresAt;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscount,
    this.expiresAt,
    this.isActive = true,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'],
      code: json['code'],
      description: json['description'],
      discountType: json['discountType'] == 'FIXED'
          ? DiscountType.fixed
          : DiscountType.percentage,
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      maxDiscount: json['maxDiscount']?.toDouble(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  /// Auto-generated banner title based on discount type
  String get bannerTitle {
    if (discountType == DiscountType.percentage) {
      return '${discountValue.toInt()}% OFF';
    } else {
      return '₹${discountValue.toInt()} OFF';
    }
  }

  /// Auto-generated banner subtitle
  String get bannerSubtitle {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    if (minOrderAmount != null && minOrderAmount! > 0) {
      return 'Min order ₹${minOrderAmount!.toInt()}';
    }
    return 'Limited time offer';
  }

  /// Get banner icon based on discount type
  IconData get bannerIcon {
    if (discountType == DiscountType.percentage) {
      return Icons.percent;
    }
    return Icons.local_offer;
  }

  /// Check if coupon is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return expiresAt!.isBefore(DateTime.now());
  }

  /// Format expiry date for display
  String? get expiryDisplay {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inDays > 30) {
      return 'Valid till ${expiresAt!.day}/${expiresAt!.month}/${expiresAt!.year}';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays} days left';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} hours left';
    }
    return 'Expires soon';
  }

  /// Gradient colors palette for banners
  static const List<List<Color>> gradientPalette = [
    [Color(0xFF667eea), Color(0xFF764ba2)], // Purple
    [Color(0xFFf093fb), Color(0xFFf5576c)], // Pink
    [Color(0xFF4facfe), Color(0xFF00f2fe)], // Blue
    [Color(0xFF43e97b), Color(0xFF38f9d7)], // Green
    [Color(0xFFfa709a), Color(0xFFfee140)], // Orange
  ];

  /// Get gradient colors for banner based on index
  List<Color> getBannerGradient(int index) {
    return gradientPalette[index % gradientPalette.length];
  }
}

enum DiscountType { percentage, fixed }
