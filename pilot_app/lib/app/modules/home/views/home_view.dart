import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/active_job_card.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/earnings_bar.dart';
import '../../../core/widgets/online_toggle_button.dart';
import '../../../core/widgets/profile_tab.dart';
import '../../../routes/app_routes.dart';
import '../../jobs/controllers/jobs_controller.dart';
import '../controllers/home_controller.dart';

/// Minimal Dark Dashboard - Professional Pilot App Home Screen
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    // Cache the JobsController reference to avoid Get.find inside Obx
    final jobsController = Get.find<JobsController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // If on Profile tab, switch to Home tab instead of popping
        if (controller.selectedNavIndex.value != 0) {
          controller.selectedNavIndex.value = 0;
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Content area with IndexedStack
              Expanded(
                child: Obx(() => IndexedStack(
                      index: controller.selectedNavIndex.value,
                      children: [
                        _buildHomeContent(colors, jobsController),
                        const ProfileTab(),
                      ],
                    )),
              ),

              // Bottom Navigation
              Obx(() => BottomNavBar(
                    currentIndex: controller.selectedNavIndex.value,
                    onTap: controller.onNavTap,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  /// Home tab content — header + scrollable body
  Widget _buildHomeContent(
      AppColorScheme colors, JobsController jobsController) {
    return Column(
      children: [
        // Minimal Header
        _buildMinimalHeader(colors),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Active Job Card or Online Toggle - only this part is reactive
                Obx(() {
                  final hasActiveJob =
                      jobsController.activeJob.value != null;

                  if (hasActiveJob) {
                    return _buildActiveJobSection(jobsController, colors);
                  } else {
                    return _buildOnlineToggleSection(colors);
                  }
                }),

                const SizedBox(height: 24),

                // Earnings Bar
                _buildEarningsSection(colors),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Minimal header with logo
  Widget _buildMinimalHeader(AppColorScheme colors) {
    return Obx(() {
      final isOnline = controller.isOnline.value;

      return Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            // Logo or Online Status
            if (isOnline)
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ONLINE',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              )
            else
              Text(
                'SendIt',
                style: AppTextStyles.h2.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Online toggle section - hero element
  Widget _buildOnlineToggleSection(AppColorScheme colors) {
    return Obx(() => OnlineToggleButton(
          isOnline: controller.isOnline.value,
          isLoading: controller.isLoading.value,
          onToggle: controller.toggleOnlineStatus,
        ));
  }

  /// Active job section with small online indicator
  Widget _buildActiveJobSection(
      JobsController jobsController, AppColorScheme colors) {
    return Column(
      children: [
        // Small online status indicator
        Obx(() {
          if (controller.isOnline.value) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Online - Accepting deliveries',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: controller.toggleOnlineStatus,
                    child: Text(
                      'Go Offline',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Active Job Card
        Obx(() {
          final job = jobsController.activeJob.value;
          if (job == null) return const SizedBox.shrink();

          return ActiveJobCard(
            job: job,
            onNavigate: () => Get.toNamed(Routes.activeJob),
            onUpdateStatus: () => Get.toNamed(Routes.activeJob),
            onTap: () => Get.toNamed(Routes.activeJob),
          );
        }),
      ],
    );
  }

  /// Earnings bar section
  Widget _buildEarningsSection(AppColorScheme colors) {
    return Obx(() {
      final earnings = controller.currentEarnings;
      return EarningsBar(
        earnings: earnings?.totalEarnings ?? 0,
        tripCount: earnings?.totalRides ?? 0,
        onTap: () => Get.toNamed(Routes.earnings),
      );
    });
  }
}
