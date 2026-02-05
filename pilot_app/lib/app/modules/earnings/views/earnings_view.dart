import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/earnings_repository.dart';
import '../controllers/earnings_controller.dart';

class EarningsView extends GetView<EarningsController> {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Earnings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.earnings.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                _buildPeriodSelector(theme),
                const SizedBox(height: 20),

                // Total Earnings Card
                _buildTotalEarningsCard(theme),
                const SizedBox(height: 20),

                // Earnings Breakdown
                _buildEarningsBreakdown(theme),
                const SizedBox(height: 20),

                // Performance Stats
                _buildPerformanceStats(theme),
                const SizedBox(height: 20),

                // Daily Chart
                _buildDailyChart(theme),
                const SizedBox(height: 20),

                // Transactions
                _buildTransactionsList(theme),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPeriodSelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodTab(theme, 'Today', 'today'),
          _buildPeriodTab(theme, 'Week', 'week'),
          _buildPeriodTab(theme, 'Month', 'month'),
        ],
      ),
    );
  }

  Widget _buildPeriodTab(ThemeData theme, String label, String value) {
    final isSelected = controller.selectedPeriod.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changePeriod(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTotalEarningsCard(ThemeData theme) {
    final earnings = controller.earnings.value;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Text(
            'Total Earnings',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${earnings?.totalEarnings.toStringAsFixed(0) ?? '0'}',
            style: AppTextStyles.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickStat('Rides', '${earnings?.totalRides ?? 0}', Colors.white),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildQuickStat('Hours', earnings?.hoursDisplay ?? '0h', Colors.white),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildQuickStat('Rating', '${earnings?.rating ?? 0}', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: color.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsBreakdown(ThemeData theme) {
    final earnings = controller.earnings.value;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Breakdown',
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildBreakdownRow('Trip Earnings', earnings?.tripEarnings ?? 0, theme),
          _buildBreakdownRow('Bonuses', earnings?.bonusEarnings ?? 0, theme, isBonus: true),
          _buildBreakdownRow('Incentives', earnings?.incentiveEarnings ?? 0, theme, isBonus: true),
          _buildBreakdownRow('Tips', earnings?.tipEarnings ?? 0, theme, isBonus: true),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, ThemeData theme, {bool isBonus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isBonus ? Icons.star : Icons.local_shipping_outlined,
                size: 16,
                color: isBonus ? Colors.amber : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.bodyMedium),
            ],
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isBonus ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStats(ThemeData theme) {
    final earnings = controller.earnings.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPerformanceCard(
                theme,
                'Acceptance',
                '${earnings?.acceptanceRate.toStringAsFixed(0) ?? 0}%',
                Icons.check_circle_outline,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPerformanceCard(
                theme,
                'Completion',
                '${earnings?.completionRate.toStringAsFixed(0) ?? 0}%',
                Icons.verified_outlined,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChart(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 Days',
            style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Obx(() {
              final data = controller.dailyBreakdown;
              if (data.isEmpty) {
                return const Center(child: Text('No data available'));
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.map((d) => _buildChartBar(theme, d)).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(ThemeData theme, DailyEarnings data) {
    final maxHeight = 80.0;
    final barHeight = controller.maxDailyEarning > 0
        ? (data.earnings / controller.maxDailyEarning) * maxHeight
        : 0.0;
    final dayFormat = DateFormat('E');

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '₹${data.earnings.toInt()}',
          style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: barHeight.clamp(8, maxHeight),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          dayFormat.format(data.date),
          style: AppTextStyles.labelSmall.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final transactions = controller.transactions;
          if (transactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Text(
                  'No transactions yet',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            );
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildTransactionItem(theme, transactions[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildTransactionItem(ThemeData theme, EarningTransaction transaction) {
    final timeFormat = DateFormat('h:mm a');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: transaction.isPositive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction.isPositive ? Icons.arrow_downward : Icons.arrow_upward,
              color: transaction.isPositive ? Colors.green : Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${transaction.typeLabel} • ${timeFormat.format(transaction.timestamp)}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${transaction.isPositive ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: transaction.isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
