import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/history_repository.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Job History'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => controller.selectDateRange(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.jobs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Stats Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildStatsCard(colors),
                ),
              ),

              // Date Filter Indicator
              Obx(() {
                if (controller.startDate.value != null) {
                  return SliverToBoxAdapter(
                    child: _buildDateFilterChip(colors),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }),

              // Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildFilterChips(colors),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Jobs List
              _buildJobsList(colors),

              // Loading More Indicator
              Obx(() => controller.isLoadingMore.value
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox(height: 80))),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatsCard(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primary,
            colors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Summary',
                style: AppTextStyles.titleMedium.copyWith(
                  color: colors.textOnPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Text(
                      '${controller.totalJobs.value} jobs',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colors.textOnPrimary,
                      ),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Earnings',
                  '₹${controller.totalEarnings.value.toStringAsFixed(0)}',
                  Icons.account_balance_wallet,
                  Colors.white,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                child: _buildStatItem(
                  'Completed',
                  controller.completedJobs.value.toString(),
                  Icons.check_circle,
                  colors.success,
                ),
              ),
              Container(width: 1, height: 50, color: Colors.white.withValues(alpha: 0.3)),
              Expanded(
                child: _buildStatItem(
                  'Cancelled',
                  controller.cancelledJobs.value.toString(),
                  Icons.cancel,
                  colors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color iconColor) {
    // No Obx needed - values are pre-computed and parent widget rebuilds on observable changes
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDateFilterChip(AppColorScheme colors) {
    final dateFormat = DateFormat('dd MMM');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.date_range, size: 16, color: colors.primary),
            const SizedBox(width: 8),
            Obx(() => Text(
                  '${dateFormat.format(controller.startDate.value!)} - ${dateFormat.format(controller.endDate.value!)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors.primary,
                  ),
                )),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.clearDateFilter,
              child: Icon(Icons.close, size: 16, color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(AppColorScheme colors) {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Icons.list},
      {'key': 'completed', 'label': 'Completed', 'icon': Icons.check_circle_outline},
      {'key': 'cancelled', 'label': 'Cancelled', 'icon': Icons.cancel_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                showCheckmark: false,
                avatar: Icon(
                  filter['icon'] as IconData,
                  size: 16,
                  color: isSelected ? colors.primary : colors.textPrimary,
                ),
                label: Text(filter['label'] as String),
                onSelected: (_) => controller.applyFilter(filter['key'] as String),
                selectedColor: colors.primary.withValues(alpha: 0.2),
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? colors.primary : colors.textPrimary,
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildJobsList(AppColorScheme colors) {
    return Obx(() {
      final jobs = controller.jobs;
      if (jobs.isEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 64,
                  color: colors.textDisabled,
                ),
                const SizedBox(height: 16),
                Text(
                  'No jobs found',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your completed deliveries will appear here',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textHint,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == jobs.length - 1) {
              // Trigger load more
              controller.loadMore();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _buildJobCard(colors, jobs[index]),
            );
          },
          childCount: jobs.length,
        ),
      );
    });
  }

  Widget _buildJobCard(AppColorScheme colors, JobHistoryItem job) {
    final dateFormat = DateFormat('dd MMM, hh:mm a');
    final statusColor = controller.getStatusColor(job.status);

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showJobDetails(colors, job),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '#${job.bookingNumber}',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                controller.getStatusIcon(job.status),
                                size: 10,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                job.status.displayName,
                                style: AppTextStyles.caption.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      job.earningsDisplay,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: job.status == JobStatus.completed
                            ? colors.success
                            : colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Route
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 24,
                          color: colors.border,
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.pickupArea,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            job.deliveryArea,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date
                    Text(
                      dateFormat.format(job.createdAt),
                      style: AppTextStyles.caption.copyWith(
                        color: colors.textHint,
                      ),
                    ),

                    // Stats
                    Row(
                      children: [
                        _buildMiniStat(
                          colors,
                          Icons.straighten,
                          job.distanceDisplay,
                        ),
                        const SizedBox(width: 12),
                        if (job.duration > 0)
                          _buildMiniStat(
                            colors,
                            Icons.access_time,
                            job.durationDisplay,
                          ),
                        if (job.rating != null) ...[
                          const SizedBox(width: 12),
                          _buildMiniStat(
                            colors,
                            Icons.star,
                            job.rating!.toStringAsFixed(1),
                            iconColor: colors.accent,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(AppColorScheme colors, IconData icon, String value,
      {Color? iconColor}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: iconColor ?? colors.textHint,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.caption.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showJobDetails(AppColorScheme colors, JobHistoryItem job) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${job.bookingNumber}',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat.format(job.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: controller.getStatusColor(job.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.getStatusIcon(job.status),
                          size: 14,
                          color: controller.getStatusColor(job.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          job.status.displayName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: controller.getStatusColor(job.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Route Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 40,
                              color: colors.border,
                            ),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: colors.success,
                                ),
                              ),
                              Text(
                                job.pickupAddress,
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Delivery',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: colors.error,
                                ),
                              ),
                              Text(
                                job.deliveryAddress,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Trip Stats
              Row(
                children: [
                  Expanded(
                    child: _buildDetailCard(
                      colors,
                      'Distance',
                      job.distanceDisplay,
                      Icons.straighten,
                      colors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      colors,
                      'Duration',
                      job.durationDisplay,
                      Icons.access_time,
                      colors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDetailCard(
                      colors,
                      'Package',
                      job.packageType,
                      Icons.inventory_2,
                      colors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Earnings Breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earnings Breakdown',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.success,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildEarningsRow(colors, 'Base Fare', '₹${job.fare.toStringAsFixed(0)}'),
                    if (job.tip > 0)
                      _buildEarningsRow(colors, 'Tip', '₹${job.tip.toStringAsFixed(0)}'),
                    const Divider(),
                    _buildEarningsRow(
                      colors,
                      'Total Earnings',
                      '₹${job.earnings.toStringAsFixed(0)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              if (job.rating != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.star, color: colors.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Customer Rating: ${job.rating!.toStringAsFixed(1)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              if (job.cancellationReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cancellation: ${job.cancellationReason}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailCard(
    AppColorScheme colors,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsRow(AppColorScheme colors, String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)
                : AppTextStyles.bodySmall,
          ),
          Text(
            value,
            style: isBold
                ? AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.success,
                  )
                : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
