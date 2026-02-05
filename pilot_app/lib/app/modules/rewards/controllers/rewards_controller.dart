import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/repositories/rewards_repository.dart';

class RewardsController extends GetxController {
  final RewardsRepository _repository = RewardsRepository();

  // State
  final isLoading = true.obs;
  final isClaimingReward = false.obs;
  final rewardPoints = 0.obs;
  final referralCode = ''.obs;
  final totalReferrals = 0.obs;
  final pendingReferrals = 0.obs;
  final earnedFromReferrals = 0.0.obs;
  final rewardPerReferral = 200.0.obs;
  final rewards = <RewardItem>[].obs;
  final achievements = <Achievement>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRewardsData();
  }

  /// Load all rewards data
  Future<void> loadRewardsData() async {
    try {
      isLoading.value = true;
      
      // Load data from repository
      final results = await Future.wait([
        _repository.getReferralInfo(),
        _repository.getRewards(),
        _repository.getAchievements(),
      ]);
      
      final referralInfo = results[0] as ReferralInfo;
      final rewardsData = results[1] as List<RewardItemModel>;
      final achievementsData = results[2] as List<AchievementModel>;
      
      // Update referral info
      referralCode.value = referralInfo.referralCode;
      totalReferrals.value = referralInfo.totalReferrals;
      pendingReferrals.value = referralInfo.pendingReferrals;
      earnedFromReferrals.value = referralInfo.earnedFromReferrals;
      rewardPerReferral.value = referralInfo.rewardPerReferral;
      rewardPoints.value = referralInfo.rewardPoints;
      
      // Convert and update rewards
      rewards.value = rewardsData.map((r) => RewardItem(
        id: r.id,
        title: r.title,
        description: r.description,
        pointsRequired: r.pointsRequired,
        iconType: RewardIconType.values.firstWhere(
          (t) => t.name == r.iconType.name,
          orElse: () => RewardIconType.wallet,
        ),
        isClaimed: r.isClaimed,
      )).toList();
      
      // Convert and update achievements
      achievements.value = achievementsData.map((a) => Achievement(
        id: a.id,
        title: a.title,
        description: a.description,
        iconEmoji: a.iconEmoji,
        isUnlocked: a.isUnlocked,
        unlockedAt: a.unlockedAt,
        progress: a.progress,
      )).toList();
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to load rewards',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Copy referral code to clipboard
  void copyReferralCode() {
    Clipboard.setData(ClipboardData(text: referralCode.value));
    Get.snackbar(
      'Copied!',
      'Referral code copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
    );
  }

  /// Share referral code
  void shareReferralCode() {
    final message = '''
🚀 Join SendIt as a Pilot!

Use my referral code: ${referralCode.value}

Earn ₹${rewardPerReferral.value.toStringAsFixed(0)} bonus on your first delivery!

Download now: https://sendit.app/pilot
''';
    Share.share(message, subject: 'Join SendIt as a Pilot');
  }

  /// Claim reward
  Future<bool> claimReward(String rewardId) async {
    final index = rewards.indexWhere((r) => r.id == rewardId);
    if (index == -1) return false;
    
    final reward = rewards[index];
    if (reward.isClaimed) {
      Get.snackbar(
        'Already Claimed',
        'You have already claimed this reward',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }
    
    if (rewardPoints.value < reward.pointsRequired) {
      Get.snackbar(
        'Insufficient Points',
        'You need ${reward.pointsRequired - rewardPoints.value} more points',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return false;
    }

    try {
      isClaimingReward.value = true;
      
      final result = await _repository.claimReward(rewardId);
      
      // Update local state
      rewards[index] = reward.copyWith(isClaimed: true);
      rewardPoints.value = result.newPointsBalance;
      
      Get.snackbar(
        'Reward Claimed! 🎉',
        'You claimed: ${reward.title}',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Claim Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    } finally {
      isClaimingReward.value = false;
    }
  }

  /// Refresh data
  Future<void> refresh() => loadRewardsData();
}

/// Reward icon types
enum RewardIconType { wallet, priority, fuel, voucher }

/// Reward item model
class RewardItem {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final RewardIconType iconType;
  final bool isClaimed;

  RewardItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.iconType,
    this.isClaimed = false,
  });

  RewardItem copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsRequired,
    RewardIconType? iconType,
    bool? isClaimed,
  }) {
    return RewardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      iconType: iconType ?? this.iconType,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double? progress;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress,
  });
}
