/// Earnings summary model
class EarningsSummary {
  final double totalEarnings;
  final int totalRides;
  final double totalHours;
  final double averagePerRide;
  final double incentives;
  final String period;
  final List<DailyEarning> dailyBreakdown;

  EarningsSummary({
    required this.totalEarnings,
    required this.totalRides,
    required this.totalHours,
    required this.averagePerRide,
    required this.incentives,
    required this.period,
    this.dailyBreakdown = const [],
  });

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: (json['total_earnings'] as num).toDouble(),
      totalRides: json['total_rides'] as int,
      totalHours: (json['total_hours'] as num).toDouble(),
      averagePerRide: (json['average_per_ride'] as num).toDouble(),
      incentives: (json['incentives'] as num?)?.toDouble() ?? 0,
      period: json['period'] as String,
      dailyBreakdown: (json['daily_breakdown'] as List<dynamic>?)
              ?.map((e) => DailyEarning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get totalEarningsDisplay => '₹${totalEarnings.toStringAsFixed(2)}';
  String get averagePerRideDisplay => '₹${averagePerRide.toStringAsFixed(2)}';
  String get incentivesDisplay => '₹${incentives.toStringAsFixed(2)}';

  String get totalHoursDisplay {
    final hours = totalHours.floor();
    final mins = ((totalHours - hours) * 60).round();
    if (mins > 0) {
      return '$hours h $mins min';
    }
    return '$hours h';
  }
}

/// Daily earning breakdown
class DailyEarning {
  final DateTime date;
  final double earnings;
  final int rides;
  final double hours;

  DailyEarning({
    required this.date,
    required this.earnings,
    required this.rides,
    required this.hours,
  });

  factory DailyEarning.fromJson(Map<String, dynamic> json) {
    return DailyEarning(
      date: DateTime.parse(json['date'] as String),
      earnings: (json['earnings'] as num).toDouble(),
      rides: json['rides'] as int,
      hours: (json['hours'] as num).toDouble(),
    );
  }
}

/// Wallet model
class WalletModel {
  final String id;
  final String pilotId;
  final double balance;
  final double holdAmount;
  final DateTime updatedAt;

  WalletModel({
    required this.id,
    required this.pilotId,
    required this.balance,
    this.holdAmount = 0,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      pilotId: json['pilot_id'] as String,
      balance: (json['balance'] as num).toDouble(),
      holdAmount: (json['hold_amount'] as num?)?.toDouble() ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  double get availableBalance => balance - holdAmount;
  String get balanceDisplay => '₹${balance.toStringAsFixed(2)}';
  String get availableBalanceDisplay =>
      '₹${availableBalance.toStringAsFixed(2)}';
}

/// Transaction model
class TransactionModel {
  final String id;
  final String walletId;
  final TransactionType type;
  final double amount;
  final String? description;
  final String? referenceId;
  final TransactionStatus status;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    this.status = TransactionStatus.completed,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      type: TransactionType.fromString(json['type'] as String),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      referenceId: json['reference_id'] as String?,
      status:
          TransactionStatus.fromString(json['status'] as String? ?? 'completed'),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isCredit =>
      type == TransactionType.orderEarning ||
      type == TransactionType.bonus ||
      type == TransactionType.referral ||
      type == TransactionType.adminCredit ||
      type == TransactionType.addMoney;

  String get amountDisplay {
    final prefix = isCredit ? '+' : '-';
    return '$prefix₹${amount.abs().toStringAsFixed(2)}';
  }
}

/// Transaction type enum
enum TransactionType {
  orderEarning('order_earning'),
  withdrawal('withdrawal'),
  bonus('bonus'),
  referral('referral'),
  adminCredit('admin_credit'),
  adminDebit('admin_debit'),
  addMoney('add_money');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.orderEarning,
    );
  }

  String get displayText {
    switch (this) {
      case TransactionType.orderEarning:
        return 'Order Earning';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.referral:
        return 'Referral Bonus';
      case TransactionType.adminCredit:
        return 'Admin Credit';
      case TransactionType.adminDebit:
        return 'Admin Debit';
      case TransactionType.addMoney:
        return 'Added Money';
    }
  }
}

/// Transaction status enum
enum TransactionStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  failed('failed');

  final String value;
  const TransactionStatus(this.value);

  static TransactionStatus fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionStatus.completed,
    );
  }
}
