import 'address_model.dart';
import 'vehicle_type_model.dart';
import '../../core/constants/app_constants.dart';

class BookingModel {
  final String id;
  final String bookingNumber;
  final String userId;
  final String? pilotId;
  final String? vehicleId;
  final String vehicleTypeId;
  final String pickupAddressId;
  final String dropAddressId;
  final PackageType packageType;
  final double? packageWeight;
  final String? packageDescription;
  final double distance;
  final double baseFare;
  final double distanceFare;
  final double taxes;
  final double discount;
  final double totalAmount;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final BookingStatus status;
  final DateTime? scheduledAt;
  final DateTime? acceptedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final String? pickupOtp;
  final String? deliveryOtp;
  final double? currentLat;
  final double? currentLng;
  final String? deliveryPhoto;
  final DateTime createdAt;
  final DateTime updatedAt;

  final AddressModel? pickupAddress;
  final AddressModel? dropAddress;
  final VehicleTypeModel? vehicleType;
  final PilotInfo? pilot;

  BookingModel({
    required this.id,
    required this.bookingNumber,
    required this.userId,
    this.pilotId,
    this.vehicleId,
    required this.vehicleTypeId,
    required this.pickupAddressId,
    required this.dropAddressId,
    this.packageType = PackageType.parcel,
    this.packageWeight,
    this.packageDescription,
    required this.distance,
    required this.baseFare,
    required this.distanceFare,
    this.taxes = 0,
    this.discount = 0,
    required this.totalAmount,
    this.paymentMethod = PaymentMethod.cash,
    this.paymentStatus = PaymentStatus.pending,
    this.status = BookingStatus.pending,
    this.scheduledAt,
    this.acceptedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelReason,
    this.pickupOtp,
    this.deliveryOtp,
    this.currentLat,
    this.currentLng,
    this.deliveryPhoto,
    required this.createdAt,
    required this.updatedAt,
    this.pickupAddress,
    this.dropAddress,
    this.vehicleType,
    this.pilot,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      bookingNumber: json['bookingNumber'],
      userId: json['userId'],
      pilotId: json['pilotId'],
      vehicleId: json['vehicleId'],
      vehicleTypeId: json['vehicleTypeId'],
      pickupAddressId: json['pickupAddressId'],
      dropAddressId: json['dropAddressId'],
      packageType: _parsePackageType(json['packageType']),
      packageWeight: json['packageWeight']?.toDouble(),
      packageDescription: json['packageDescription'],
      distance: (json['distance'] ?? 0).toDouble(),
      baseFare: (json['baseFare'] ?? 0).toDouble(),
      distanceFare: (json['distanceFare'] ?? 0).toDouble(),
      taxes: (json['taxes'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      paymentStatus: _parsePaymentStatus(json['paymentStatus']),
      status: _parseBookingStatus(json['status']),
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt']) : null,
      pickedUpAt: json['pickedUpAt'] != null ? DateTime.parse(json['pickedUpAt']) : null,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt']) : null,
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      cancelReason: json['cancelReason'],
      pickupOtp: json['pickupOtp'],
      deliveryOtp: json['deliveryOtp'],
      currentLat: json['currentLat']?.toDouble(),
      currentLng: json['currentLng']?.toDouble(),
      deliveryPhoto: json['deliveryPhoto'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      pickupAddress: json['pickupAddress'] != null
          ? AddressModel.fromJson(json['pickupAddress'])
          : null,
      dropAddress: json['dropAddress'] != null
          ? AddressModel.fromJson(json['dropAddress'])
          : null,
      vehicleType: json['vehicleType'] != null
          ? VehicleTypeModel.fromJson(json['vehicleType'])
          : null,
      pilot: json['pilot'] != null
          ? PilotInfo.fromJson(json['pilot'])
          : null,
    );
  }

  static PackageType _parsePackageType(String? value) {
    switch (value?.toUpperCase()) {
      case 'DOCUMENT': return PackageType.document;
      case 'FOOD': return PackageType.food;
      case 'GROCERY': return PackageType.grocery;
      case 'MEDICINE': return PackageType.medicine;
      case 'FRAGILE': return PackageType.fragile;
      case 'OTHER': return PackageType.other;
      default: return PackageType.parcel;
    }
  }

  static PaymentMethod _parsePaymentMethod(String? value) {
    switch (value?.toUpperCase()) {
      case 'UPI': return PaymentMethod.upi;
      case 'CARD': return PaymentMethod.card;
      case 'WALLET': return PaymentMethod.wallet;
      case 'NETBANKING': return PaymentMethod.netbanking;
      default: return PaymentMethod.cash;
    }
  }

  static PaymentStatus _parsePaymentStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'COMPLETED': return PaymentStatus.completed;
      case 'FAILED': return PaymentStatus.failed;
      case 'REFUNDED': return PaymentStatus.refunded;
      default: return PaymentStatus.pending;
    }
  }

  static BookingStatus _parseBookingStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACCEPTED': return BookingStatus.accepted;
      case 'ARRIVED_PICKUP': return BookingStatus.arrivedPickup;
      case 'PICKED_UP': return BookingStatus.pickedUp;
      case 'IN_TRANSIT': return BookingStatus.inTransit;
      case 'ARRIVED_DROP': return BookingStatus.arrivedDrop;
      case 'DELIVERED': return BookingStatus.delivered;
      case 'CANCELLED': return BookingStatus.cancelled;
      default: return BookingStatus.pending;
    }
  }

  bool get isActive => status != BookingStatus.delivered && status != BookingStatus.cancelled;
  bool get isCompleted => status == BookingStatus.delivered;
  bool get isCancelled => status == BookingStatus.cancelled;

  String get statusDisplay {
    switch (status) {
      case BookingStatus.pending: return 'Pending';
      case BookingStatus.accepted: return 'Accepted';
      case BookingStatus.arrivedPickup: return 'Driver Arrived';
      case BookingStatus.pickedUp: return 'Picked Up';
      case BookingStatus.inTransit: return 'In Transit';
      case BookingStatus.arrivedDrop: return 'Near Destination';
      case BookingStatus.delivered: return 'Delivered';
      case BookingStatus.cancelled: return 'Cancelled';
    }
  }

  String get amountDisplay => '₹${totalAmount.toStringAsFixed(2)}';
}

class PilotInfo {
  final String id;
  final String name;
  final String phone;
  final String? avatar;
  final double rating;
  final String? vehicleNumber;
  final String? vehicleModel;

  PilotInfo({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    this.rating = 0,
    this.vehicleNumber,
    this.vehicleModel,
  });

  factory PilotInfo.fromJson(Map<String, dynamic> json) {
    return PilotInfo(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      avatar: json['avatar'],
      rating: (json['rating'] ?? 0).toDouble(),
      vehicleNumber: json['vehicle']?['registrationNo'],
      vehicleModel: json['vehicle']?['model'],
    );
  }
}
