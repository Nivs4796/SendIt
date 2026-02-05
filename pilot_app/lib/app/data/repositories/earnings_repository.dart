import 'package:get/get.dart' hide Response;
import '../models/earnings_model.dart';
import '../providers/api_client.dart';
import '../../core/config/app_config.dart';

class EarningsRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get earnings summary for a period
  Future<EarningsModel> getEarnings({
    required String period, // 'today', 'week', 'month', 'custom'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{'period': period};
      if (startDate != null) params['startDate'] = startDate.toIso8601String();
      if (endDate != null) params['endDate'] = endDate.toIso8601String();

      final response = await _api.get('/pilots/earnings', queryParameters: params);
      
      if (response.data['success'] == true) {
        return EarningsModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to load earnings');
    } catch (e) {
      // Return mock data for development only
      if (AppConfig.enableMockData) return _getMockEarnings(period);
      rethrow;
    }
  }

  /// Get daily breakdown for a date range
  Future<List<DailyEarnings>> getDailyBreakdown({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _api.get('/pilots/earnings/daily', queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => DailyEarnings.fromJson(e))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load daily breakdown');
    } catch (e) {
      if (AppConfig.enableMockData) return _getMockDailyBreakdown();
      rethrow;
    }
  }

  /// Get transaction history
  Future<List<EarningTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type, // 'trip', 'bonus', 'incentive', 'tip', 'penalty'
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (type != null) params['type'] = type;

      final response = await _api.get('/pilots/earnings/transactions', queryParameters: params);

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((e) => EarningTransaction.fromJson(e))
            .toList();
      }
      throw Exception(response.data['message'] ?? 'Failed to load transactions');
    } catch (e) {
      if (AppConfig.enableMockData) return _getMockTransactions();
      rethrow;
    }
  }

  // Mock data for development
  EarningsModel _getMockEarnings(String period) {
    switch (period) {
      case 'today':
        return EarningsModel(
          totalEarnings: 1250.0,
          tripEarnings: 980.0,
          bonusEarnings: 150.0,
          incentiveEarnings: 100.0,
          tipEarnings: 20.0,
          totalHours: 6.5,
          totalRides: 12,
          acceptanceRate: 85.0,
          completionRate: 95.0,
          rating: 4.8,
          period: period,
        );
      case 'week':
        return EarningsModel(
          totalEarnings: 8500.0,
          tripEarnings: 6800.0,
          bonusEarnings: 1000.0,
          incentiveEarnings: 500.0,
          tipEarnings: 200.0,
          totalHours: 42.0,
          totalRides: 78,
          acceptanceRate: 82.0,
          completionRate: 94.0,
          rating: 4.7,
          period: period,
        );
      case 'month':
        return EarningsModel(
          totalEarnings: 32000.0,
          tripEarnings: 25000.0,
          bonusEarnings: 4000.0,
          incentiveEarnings: 2500.0,
          tipEarnings: 500.0,
          totalHours: 168.0,
          totalRides: 320,
          acceptanceRate: 80.0,
          completionRate: 93.0,
          rating: 4.7,
          period: period,
        );
      default:
        return EarningsModel(totalEarnings: 0, period: period);
    }
  }

  List<DailyEarnings> _getMockDailyBreakdown() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return DailyEarnings(
        date: date,
        earnings: 1000.0 + (i * 150),
        rides: 10 + i,
        hours: 5.0 + (i * 0.5),
      );
    });
  }

  List<EarningTransaction> _getMockTransactions() {
    final now = DateTime.now();
    return [
      EarningTransaction(
        id: '1',
        type: TransactionType.trip,
        amount: 149.0,
        description: 'Delivery #SND-001',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      EarningTransaction(
        id: '2',
        type: TransactionType.tip,
        amount: 20.0,
        description: 'Tip from customer',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      EarningTransaction(
        id: '3',
        type: TransactionType.trip,
        amount: 89.0,
        description: 'Delivery #SND-002',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      EarningTransaction(
        id: '4',
        type: TransactionType.bonus,
        amount: 100.0,
        description: 'Peak hour bonus',
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      EarningTransaction(
        id: '5',
        type: TransactionType.incentive,
        amount: 50.0,
        description: '5 deliveries streak',
        timestamp: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }
}

/// Daily earnings summary
class DailyEarnings {
  final DateTime date;
  final double earnings;
  final int rides;
  final double hours;

  DailyEarnings({
    required this.date,
    required this.earnings,
    required this.rides,
    required this.hours,
  });

  factory DailyEarnings.fromJson(Map<String, dynamic> json) {
    return DailyEarnings(
      date: DateTime.parse(json['date']),
      earnings: (json['earnings'] as num).toDouble(),
      rides: json['rides'] as int,
      hours: (json['hours'] as num).toDouble(),
    );
  }
}

/// Individual earning transaction
enum TransactionType { trip, bonus, incentive, tip, penalty }

class EarningTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime timestamp;

  EarningTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  factory EarningTransaction.fromJson(Map<String, dynamic> json) {
    return EarningTransaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.trip,
      ),
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String get typeLabel {
    switch (type) {
      case TransactionType.trip:
        return 'Trip';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.incentive:
        return 'Incentive';
      case TransactionType.tip:
        return 'Tip';
      case TransactionType.penalty:
        return 'Penalty';
    }
  }

  bool get isPositive => type != TransactionType.penalty;
}
