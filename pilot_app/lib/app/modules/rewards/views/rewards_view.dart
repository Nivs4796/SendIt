import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/rewards_controller.dart';

class RewardsView extends GetView<RewardsController> {
  const RewardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Rewards'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Points Card
                _buildPointsCard(colors),
                const SizedBox(height: 20),

                // Referral Card
                _buildReferralCard(colors),
                const SizedBox(height: 24),

                // Rewards Section
                _buildRewardsSection(colors),
                const SizedBox(height: 24),

                // Achievements Section
                _buildAchievementsSection(colors),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPointsCard(AppColorScheme colors) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.accent, colors.warning],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reward Points',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  '${controller.rewardPoints.value}',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )),
                const SizedBox(height: 4),
                Text(
                  'points available',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.stars_rounded,
            color: Colors.white.withValues(alpha: 0.3),
            size: 80,
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Refer & Earn',
                style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Invite other pilots and earn ₹200 for each successful referral!',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Referral Code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                    controller.referralCode.value,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  )),
                ),
                IconButton(
                  onPressed: controller.copyReferralCode,
                  icon: const Icon(Icons.copy),
                  color: colors.primary,
                ),
                IconButton(
                  onPressed: controller.shareReferralCode,
                  icon: const Icon(Icons.share),
                  color: colors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Referral Stats
          Row(
            children: [
              Expanded(
                child: _buildReferralStat(
                  colors,
                  'Total Referrals',
                  controller.totalReferrals.value.toString(),
                ),
              ),
              Expanded(
                child: _buildReferralStat(
                  colors,
                  'Pending',
                  controller.pendingReferrals.value.toString(),
                ),
              ),
              Expanded(
                child: _buildReferralStat(
                  colors,
                  'Earned',
                  '₹${controller.earnedFromReferrals.value.toInt()}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReferralStat(AppColorScheme colors, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: colors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardsSection(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem Rewards',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.rewards.length,
          itemBuilder: (context, index) {
            return _buildRewardItem(colors, controller.rewards[index]);
          },
        )),
      ],
    );
  }

  Widget _buildRewardItem(AppColorScheme colors, RewardItem reward) {
    final canClaim = !reward.isClaimed && controller.rewardPoints.value >= reward.pointsRequired;

    IconData icon;
    Color iconColor;
    switch (reward.iconType) {
      case RewardIconType.wallet:
        icon = Icons.account_balance_wallet;
        iconColor = colors.success;
        break;
      case RewardIconType.priority:
        icon = Icons.star;
        iconColor = colors.accent;
        break;
      case RewardIconType.fuel:
        icon = Icons.local_gas_station;
        iconColor = colors.info;
        break;
      case RewardIconType.voucher:
        icon = Icons.card_giftcard;
        iconColor = colors.primaryDark;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: reward.isClaimed
            ? colors.surfaceVariant.withValues(alpha: 0.5)
            : colors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: reward.isClaimed ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  reward.description,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          reward.isClaimed
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Claimed',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: canClaim ? () => controller.claimReward(reward.id) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('${reward.pointsRequired} pts'),
                ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(AppColorScheme colors) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: controller.achievements.length,
          itemBuilder: (context, index) {
            final achievement = controller.achievements[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: achievement.isUnlocked
                    ? Border.all(color: colors.primary.withValues(alpha: 0.3))
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    achievement.iconEmoji,
                    style: TextStyle(
                      fontSize: 32,
                      color: achievement.isUnlocked ? null : colors.textHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.title,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: achievement.isUnlocked
                          ? colors.textPrimary
                          : colors.textHint,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (achievement.isUnlocked)
                    Text(
                      dateFormat.format(achievement.unlockedAt!),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colors.primary,
                      ),
                    )
                  else if (achievement.progress != null)
                    Column(
                      children: [
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: achievement.progress!,
                          backgroundColor: colors.border.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation(colors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(achievement.progress! * 100).toInt()}%',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colors.textHint,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        )),
      ],
    );
  }
}
