import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/tracking_controller.dart';

/// Real-time delivery tracking view with live map and driver info
class TrackingView extends GetView<TrackingController> {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.booking.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.booking.value == null) {
          return _buildErrorState(context);
        }

        return Stack(
          children: [
            // Full-screen Google Map
            _buildMap(context),

            // Back button (top-left)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: _buildBackButton(context),
            ),

            // Center on driver button (top-right)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: _buildCenterOnDriverButton(context),
            ),

            // Connection status indicator
            if (!controller.isConnected.value)
              Positioned(
                top: MediaQuery.of(context).padding.top + 72,
                left: 16,
                right: 16,
                child: _buildConnectionWarning(context),
              ),

            // Bottom draggable sheet
            _buildBottomSheet(context),
          ],
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load tracking',
              style: AppTextStyles.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(BuildContext context) {
    final booking = controller.booking.value;
    final initialLat =
        booking?.pickupAddress?.lat ?? AppConstants.defaultLat;
    final initialLng =
        booking?.pickupAddress?.lng ?? AppConstants.defaultLng;

    return Obx(() => GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(initialLat, initialLng),
            zoom: AppConstants.defaultZoom,
          ),
          markers: controller.markers.value,
          polylines: controller.routePolyline.isNotEmpty
              ? {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: controller.routePolyline,
                    color: AppColors.primary,
                    width: 4,
                  ),
                }
              : {},
          onMapCreated: controller.onMapCreated,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
        ));
  }

  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.cardColor,
      child: IconButton(
        onPressed: () => Get.back(),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: theme.colorScheme.onSurface,
        ),
        tooltip: 'Back',
      ),
    );
  }

  Widget _buildCenterOnDriverButton(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.cardColor,
      child: IconButton(
        onPressed: controller.centerOnDriver,
        icon: Icon(
          Icons.gps_fixed_rounded,
          color: theme.colorScheme.primary,
        ),
        tooltip: 'Center on Driver',
      ),
    );
  }

  Widget _buildConnectionWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            color: AppColors.warningDark,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Reconnecting to live tracking...',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warningDark,
              ),
            ),
          ),
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.warningDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ETA Card
              _buildEtaCard(context),
              const SizedBox(height: 16),

              // Status Card
              _buildStatusCard(context),
              const SizedBox(height: 16),

              // Driver Card
              _buildDriverCard(context),

              // OTP Card (conditional)
              Obx(() {
                final booking = controller.booking.value;
                if (booking == null) return const SizedBox.shrink();

                final showOtp = booking.status == BookingStatus.arrivedDrop ||
                    booking.status == BookingStatus.inTransit;

                if (!showOtp || booking.deliveryOtp == null) {
                  return const SizedBox.shrink();
                }

                return Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildOtpCard(context, booking.deliveryOtp!),
                  ],
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEtaCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() => Row(
            children: [
              // ETA Column
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.timer_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ETA',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.etaDisplay,
                            style: AppTextStyles.h4.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                width: 1,
                height: 48,
                color: theme.dividerColor,
              ),

              // Distance Column
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Builder(builder: (context) {
                      final theme = Theme.of(context);
                      final infoColor = theme.brightness == Brightness.dark
                          ? const Color(0xFF60A5FA)
                          : AppColors.info;
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: infoColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.route_rounded,
                          color: infoColor,
                          size: 24,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.distanceDisplay,
                            style: AppTextStyles.h4.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final booking = controller.booking.value;
        if (booking == null) {
          return const SizedBox(height: 60);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status header
            Row(
              children: [
                Builder(builder: (context) {
                  final theme = Theme.of(context);
                  final successColor = theme.brightness == Brightness.dark
                      ? const Color(0xFF34D399)
                      : AppColors.success;
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: successColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: successColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(width: 10),
                Text(
                  booking.statusDisplay,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status timeline
            _buildStatusTimeline(context, booking.status),
          ],
        );
      }),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, BookingStatus status) {
    final theme = Theme.of(context);

    // Define the status stages
    final stages = [
      BookingStatus.accepted,
      BookingStatus.arrivedPickup,
      BookingStatus.pickedUp,
      BookingStatus.inTransit,
      BookingStatus.delivered,
    ];

    final currentIndex = stages.indexOf(status);
    final isCompleted = status == BookingStatus.delivered;

    return Row(
      children: List.generate(stages.length * 2 - 1, (index) {
        // Even indices are circles, odd indices are lines
        if (index.isEven) {
          final stageIndex = index ~/ 2;
          final isActive = stageIndex <= currentIndex || isCompleted;
          final isCurrent = stageIndex == currentIndex && !isCompleted;

          return Container(
            width: isCurrent ? 20 : 16,
            height: isCurrent ? 20 : 16,
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(
                      color: theme.colorScheme.primary,
                      width: 3,
                    )
                  : null,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isActive && !isCurrent
                ? Icon(
                    Icons.check_rounded,
                    size: 10,
                    color: theme.colorScheme.onPrimary,
                  )
                : null,
          );
        } else {
          // Line between circles
          final stageIndex = index ~/ 2;
          final isActive = stageIndex < currentIndex || isCompleted;

          return Expanded(
            child: Container(
              height: 3,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
            ),
          );
        }
      }),
    );
  }

  Widget _buildDriverCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final booking = controller.booking.value;
      final pilot = booking?.pilot;

      if (pilot == null) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: isDark
              ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Driver avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage:
                  pilot.avatar != null ? NetworkImage(pilot.avatar!) : null,
              child: pilot.avatar == null
                  ? Text(
                      pilot.name.isNotEmpty ? pilot.name[0].toUpperCase() : 'D',
                      style: AppTextStyles.h3.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Driver info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pilot.name,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pilot.rating.toStringAsFixed(1),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (pilot.vehicleNumber != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pilot.vehicleNumber!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Call button
            Builder(builder: (context) {
              final theme = Theme.of(context);
              final successColor = theme.brightness == Brightness.dark
                  ? const Color(0xFF34D399)
                  : AppColors.success;
              return Container(
                decoration: BoxDecoration(
                  color: successColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: controller.callDriver,
                  icon: Icon(
                    Icons.call_rounded,
                    color: successColor,
                  ),
                  tooltip: 'Call Driver',
                ),
              );
            }),
            const SizedBox(width: 8),

            // Chat button
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: controller.openChat,
                icon: Icon(
                  Icons.chat_rounded,
                  color: theme.colorScheme.primary,
                ),
                tooltip: 'Chat',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOtpCard(BuildContext context, String otp) {
    final theme = Theme.of(context);

    // Ensure OTP is 4 digits
    final otpDigits = otp.padLeft(4, '0').substring(0, 4);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Label
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Delivery OTP',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // OTP digits
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              return Container(
                margin: EdgeInsets.only(
                  left: index == 0 ? 0 : 8,
                ),
                width: 52,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    otpDigits[index],
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),

          // Helper text
          Text(
            'Share this OTP with the driver for delivery verification',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
