import 'package:get/get.dart' hide Response;
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';

class RewardsRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get referral info
  /// GET /pilots/referral
  Future<ReferralInfo> getReferralInfo() async {
    try {
      final response = await _api.get(ApiConstants.referral);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return ReferralInfo.fromJson(response.data['data']);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load referral info',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      return _getMockReferralInfo();
    } on TimeoutException {
      return _getMockReferralInfo();
    } catch (e) {
      return _getMockReferralInfo();
    }
  }

  /// Get available rewards
  /// GET /pilots/rewards
  Future<List<RewardItemModel>> getRewards() async {
    try {
      final response = await _api.get(ApiConstants.rewards);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> rewardsList = data is List 
            ? data 
            : (data['rewards'] ?? []);
        return rewardsList.map((e) => RewardItemModel.fromJson(e)).toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load rewards',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      return _getMockRewards();
    } on TimeoutException {
      return _getMockRewards();
    } catch (e) {
      return _getMockRewards();
    }
  }

  /// Claim a reward
  /// POST /pilots/rewards/:id/claim
  Future<ClaimResult> claimReward(String rewardId) async {
    try {
      final response = await _api.post(ApiConstants.claimReward(rewardId));
      
      if ((response.statusCode == 200 || response.statusCode == 201) && 
          response.data['success'] == true) {
        return ClaimResult.fromJson(response.data['data'] ?? response.data);
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to claim reward',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Claim failed: $e');
    }
  }

  /// Get achievements
  /// GET /pilots/achievements
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final response = await _api.get(ApiConstants.achievements);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final List<dynamic> achievementsList = data is List 
            ? data 
            : (data['achievements'] ?? []);
        return achievementsList.map((e) => AchievementModel.fromJson(e)).toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load achievements',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      return _getMockAchievements();
    } on TimeoutException {
      return _getMockAchievements();
    } catch (e) {
      return _getMockAchievements();
    }
  }

  ReferralInfo _getMockReferralInfo() {
    return ReferralInfo(
      referralCode: 'PILOT2024XYZ',
      totalReferrals: 12,
      pendingReferrals: 3,
      earnedFromReferrals: 2400.0,
      rewardPerReferral: 200.0,
      rewardPoints: 850,
    );
  }

  List<RewardItemModel> _getMockRewards() {
    return [
      RewardItemModel(
        id: '1',
        title: '₹50 Wallet Credit',
        description: 'Get ₹50 added to your wallet',
        pointsRequired: 500,
        iconType: RewardIconTypeModel.wallet,
        isClaimed: false,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      RewardItemModel(
        id: '2',
        title: '₹100 Wallet Credit',
        description: 'Get ₹100 added to your wallet',
        pointsRequired: 900,
        iconType: RewardIconTypeModel.wallet,
        isClaimed: false,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
      RewardItemModel(
        id: '3',
        title: 'Priority Job Access',
        description: 'Get priority access to high-value jobs for 24 hours',
        pointsRequired: 300,
        iconType: RewardIconTypeModel.priority,
        isClaimed: true,
        claimedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      RewardItemModel(
        id: '4',
        title: 'Free Fuel Voucher',
        description: '₹200 fuel voucher at partner stations',
        pointsRequired: 1500,
        iconType: RewardIconTypeModel.fuel,
        isClaimed: false,
        expiresAt: DateTime.now().add(const Duration(days: 60)),
      ),
      RewardItemModel(
        id: '5',
        title: 'Insurance Discount',
        description: '10% off on vehicle insurance renewal',
        pointsRequired: 2000,
        iconType: RewardIconTypeModel.voucher,
        isClaimed: false,
        expiresAt: DateTime.now().add(const Duration(days: 90)),
      ),
    ];
  }

  List<AchievementModel> _getMockAchievements() {
    return [
      AchievementModel(
        id: '1',
        title: 'First Delivery',
        description: 'Complete your first delivery',
        iconEmoji: '🚀',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
        pointsAwarded: 50,
      ),
      AchievementModel(
        id: '2',
        title: 'Speed Demon',
        description: 'Complete 10 deliveries in one day',
        iconEmoji: '⚡',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
        pointsAwarded: 100,
      ),
      AchievementModel(
        id: '3',
        title: 'Century Club',
        description: 'Complete 100 deliveries',
        iconEmoji: '💯',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 5)),
        pointsAwarded: 200,
      ),
      AchievementModel(
        id: '4',
        title: 'Star Performer',
        description: 'Maintain 4.8+ rating for 30 days',
        iconEmoji: '⭐',
        isUnlocked: false,
        progress: 0.7,
        pointsAwarded: 150,
      ),
      AchievementModel(
        id: '5',
        title: 'Top Earner',
        description: 'Earn ₹50,000 in a month',
        iconEmoji: '💰',
        isUnlocked: false,
        progress: 0.4,
        pointsAwarded: 300,
      ),
      AchievementModel(
        id: '6',
        title: 'Referral King',
        description: 'Refer 25 new pilots',
        iconEmoji: '👑',
        isUnlocked: false,
        progress: 0.48,
        pointsAwarded: 500,
      ),
      AchievementModel(
        id: '7',
        title: 'Night Owl',
        description: 'Complete 50 deliveries between 10 PM - 6 AM',
        iconEmoji: '🦉',
        isUnlocked: false,
        progress: 0.2,
        pointsAwarded: 150,
      ),
      AchievementModel(
        id: '8',
        title: 'Weekend Warrior',
        description: 'Complete 100 weekend deliveries',
        iconEmoji: '🏆',
        isUnlocked: false,
        progress: 0.35,
        pointsAwarded: 200,
      ),
    ];
  }
}

/// Referral info model
class ReferralInfo {
  final String referralCode;
  final int totalReferrals;
  final int pendingReferrals;
  final double earnedFromReferrals;
  final double rewardPerReferral;
  final int rewardPoints;

  ReferralInfo({
    required this.referralCode,
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.earnedFromReferrals,
    required this.rewardPerReferral,
    required this.rewardPoints,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralCode: json['referralCode'] ?? json['code'] ?? '',
      totalReferrals: json['totalReferrals'] as int? ?? json['total'] as int? ?? 0,
      pendingReferrals: json['pendingReferrals'] as int? ?? json['pending'] as int? ?? 0,
      earnedFromReferrals: (json['earnedFromReferrals'] as num?)?.toDouble() ?? 
          (json['earnings'] as num?)?.toDouble() ?? 0,
      rewardPerReferral: (json['rewardPerReferral'] as num?)?.toDouble() ?? 
          (json['rewardAmount'] as num?)?.toDouble() ?? 200,
      rewardPoints: json['rewardPoints'] as int? ?? json['points'] as int? ?? 0,
    );
  }
}

/// Reward icon types
enum RewardIconTypeModel { wallet, priority, fuel, voucher }

/// Reward item model
class RewardItemModel {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final RewardIconTypeModel iconType;
  final bool isClaimed;
  final DateTime? expiresAt;
  final DateTime? claimedAt;

  RewardItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.iconType,
    this.isClaimed = false,
    this.expiresAt,
    this.claimedAt,
  });

  factory RewardItemModel.fromJson(Map<String, dynamic> json) {
    return RewardItemModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      pointsRequired: json['pointsRequired'] as int? ?? json['points'] as int? ?? 0,
      iconType: _parseIconType(json['iconType'] ?? json['type']),
      isClaimed: json['isClaimed'] as bool? ?? json['claimed'] as bool? ?? false,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      claimedAt: json['claimedAt'] != null
          ? DateTime.tryParse(json['claimedAt'].toString())
          : null,
    );
  }

  static RewardIconTypeModel _parseIconType(dynamic type) {
    if (type == null) return RewardIconTypeModel.wallet;
    final typeStr = type.toString().toLowerCase();
    switch (typeStr) {
      case 'wallet':
      case 'cash':
      case 'credit':
        return RewardIconTypeModel.wallet;
      case 'priority':
      case 'access':
        return RewardIconTypeModel.priority;
      case 'fuel':
      case 'petrol':
        return RewardIconTypeModel.fuel;
      case 'voucher':
      case 'discount':
      case 'coupon':
        return RewardIconTypeModel.voucher;
      default:
        return RewardIconTypeModel.wallet;
    }
  }

  RewardItemModel copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsRequired,
    RewardIconTypeModel? iconType,
    bool? isClaimed,
    DateTime? expiresAt,
    DateTime? claimedAt,
  }) {
    return RewardItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      iconType: iconType ?? this.iconType,
      isClaimed: isClaimed ?? this.isClaimed,
      expiresAt: expiresAt ?? this.expiresAt,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }
}

/// Achievement model
class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double? progress;
  final int pointsAwarded;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress,
    this.pointsAwarded = 0,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      iconEmoji: json['iconEmoji'] ?? json['icon'] ?? json['emoji'] ?? '🏆',
      isUnlocked: json['isUnlocked'] as bool? ?? json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'].toString())
          : null,
      progress: (json['progress'] as num?)?.toDouble(),
      pointsAwarded: json['pointsAwarded'] as int? ?? json['points'] as int? ?? 0,
    );
  }
}

/// Claim result
class ClaimResult {
  final bool success;
  final String message;
  final int newPointsBalance;

  ClaimResult({
    required this.success,
    required this.message,
    required this.newPointsBalance,
  });

  factory ClaimResult.fromJson(Map<String, dynamic> json) {
    return ClaimResult(
      success: json['success'] as bool? ?? true,
      message: json['message'] ?? 'Reward claimed successfully',
      newPointsBalance: json['newPointsBalance'] as int? ?? 
          json['pointsBalance'] as int? ?? 
          json['balance'] as int? ?? 0,
    );
  }
}
