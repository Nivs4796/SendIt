import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/delivery_map.dart';
import '../../../data/models/job_model.dart';
import '../../../services/location_service.dart';
import '../controllers/jobs_controller.dart';
import '../widgets/job_status_stepper.dart';

/// Main screen for managing an active delivery job
class ActiveJobView extends GetView<JobsController> {
  const ActiveJobView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: Obx(() {
        final job = controller.activeJob.value;

        if (job == null) {
          return const Center(
            child: Text('No active job'),
          );
        }

        return Stack(
          children: [
            // Main Content
            CustomScrollView(
              slivers: [
                // App Bar
                _buildAppBar(context, colors, job),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Status Stepper
                      JobStatusStepper(status: job.status),

                      const SizedBox(height: 16),

                      // Live Map
                      _buildLiveMap(colors, job),

                      const SizedBox(height: 16),

                      // Job Info Card
                      _buildJobInfoCard(colors, job),

                      const SizedBox(height: 16),

                      // Customer Card
                      _buildCustomerCard(colors, job),

                      const SizedBox(height: 16),

                      // Addresses Card
                      _buildAddressesCard(colors, job),

                      const SizedBox(height: 16),

                      // Payment Info
                      if (job.paymentMethod == PaymentMethod.cod)
                        _buildCodCard(colors, job),

                      // Space for bottom buttons
                      const SizedBox(height: 120),
                    ]),
                  ),
                ),
              ],
            ),

            // Bottom Action Buttons
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomActions(colors, job),
            ),
          ],
        );
      }),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, AppColorScheme colors, JobModel job) {
    return SliverAppBar(
      floating: true,
      backgroundColor: colors.primary,
      foregroundColor: colors.textOnPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job #${job.bookingId.substring(0, 8).toUpperCase()}',
            style: AppTextStyles.h4.copyWith(
              color: colors.textOnPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            job.status.displayText,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textOnPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      actions: [
        // Navigate Button
        IconButton(
          icon: const Icon(Icons.navigation),
          tooltip: 'Navigate',
          onPressed: () => _openNavigation(job),
        ),
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value, job),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Need Help'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel_outlined, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Cancel Job', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveMap(AppColorScheme colors, JobModel job) {
    final locationService = Get.find<LocationService>();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Obx(() {
            final currentLocation = locationService.currentLocation.value;
            LatLng? pilotLatLng;
            if (currentLocation != null) {
              pilotLatLng = LatLng(currentLocation.lat, currentLocation.lng);
            }

            return DeliveryMap(
              height: 200,
              pickupLocation: LatLng(job.pickupAddress.lat, job.pickupAddress.lng),
              dropLocation: LatLng(job.dropAddress.lat, job.dropAddress.lng),
              pilotLocation: pilotLatLng,
              showRoute: true,
              trackPilot: true,
            );
          }),
          // Quick navigation buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _buildMapQuickAction(
                    icon: Icons.navigation,
                    label: 'Navigate',
                    color: colors.primary,
                    onTap: () => _openNavigation(job),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMapQuickAction(
                    icon: Icons.fullscreen,
                    label: 'Full Map',
                    color: colors.info,
                    onTap: () => _openFullScreenMap(job),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenMap(JobModel job) {
    final locationService = Get.find<LocationService>();

    Get.to(() => Builder(builder: (context) {
      final colors = AppColorScheme.of(context);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Live Tracking'),
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: () => _openNavigation(job),
          ),
        ],
      ),
      body: Obx(() {
        final currentLocation = locationService.currentLocation.value;
        LatLng? pilotLatLng;
        if (currentLocation != null) {
          pilotLatLng = LatLng(currentLocation.lat, currentLocation.lng);
        }

        return DeliveryMap(
          height: double.infinity,
          pickupLocation: LatLng(job.pickupAddress.lat, job.pickupAddress.lng),
          dropLocation: LatLng(job.dropAddress.lat, job.dropAddress.lng),
          pilotLocation: pilotLatLng,
          showRoute: true,
          trackPilot: true,
        );
      }),
    );
    }));
  }

  Widget _buildJobInfoCard(AppColorScheme colors, JobModel job) {
    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildInfoItem(
              colors,
              icon: Icons.currency_rupee,
              label: 'Fare',
              value: job.fareDisplay,
              color: colors.primary,
            ),
            _buildDivider(colors),
            _buildInfoItem(
              colors,
              icon: Icons.route,
              label: 'Distance',
              value: job.distanceDisplay,
              color: colors.info,
            ),
            _buildDivider(colors),
            _buildInfoItem(
              colors,
              icon: Icons.schedule,
              label: 'ETA',
              value: job.etaDisplay,
              color: colors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    AppColorScheme colors, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(AppColorScheme colors) {
    return Container(
      height: 40,
      width: 1,
      color: colors.border,
    );
  }

  Widget _buildCustomerCard(AppColorScheme colors, JobModel job) {
    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.primary.withValues(alpha: 0.1),
              child: Text(
                (job.customerName ?? 'C')[0].toUpperCase(),
                style: AppTextStyles.h4.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Name & Phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.customerName ?? 'Customer',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (job.customerPhone != null)
                    Text(
                      job.customerPhone!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // Call Button
            if (job.customerPhone != null) ...[
              IconButton(
                onPressed: () => _callCustomer(job.customerPhone!),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.call,
                    color: colors.success,
                    size: 20,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _messageCustomer(job.customerPhone!),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.info.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.message,
                    color: colors.info,
                    size: 20,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressesCard(AppColorScheme colors, JobModel job) {
    final isPickupPhase = job.status.index <= JobStatus.packageCollected.index;

    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pickup
            _buildAddressRow(
              colors,
              icon: Icons.radio_button_checked,
              color: colors.success,
              label: 'Pickup',
              address: job.pickupAddress.address,
              isActive: isPickupPhase,
            ),

            // Connector line
            Container(
              margin: const EdgeInsets.only(left: 10),
              height: 32,
              child: Row(
                children: [
                  Container(
                    width: 2,
                    color: colors.border,
                  ),
                ],
              ),
            ),

            // Drop
            _buildAddressRow(
              colors,
              icon: Icons.location_on,
              color: colors.error,
              label: 'Drop',
              address: job.dropAddress.address,
              isActive: !isPickupPhase,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(
    AppColorScheme colors, {
    required IconData icon,
    required Color color,
    required String label,
    required String address,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.05) : null,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: color.withValues(alpha: 0.2))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CURRENT',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: colors.textOnPrimary,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodCard(AppColorScheme colors, JobModel job) {
    final warningBg = colors.warning.withValues(alpha: 0.1);

    return Card(
      color: warningBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payments,
                color: colors.warning,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash on Delivery',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.warning,
                    ),
                  ),
                  Text(
                    '\u20B9${(job.codAmount ?? job.fare).toStringAsFixed(0)}',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.warning,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'COLLECT',
              style: AppTextStyles.labelMedium.copyWith(
                color: colors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(AppColorScheme colors, JobModel job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Navigate Button (always shown)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openNavigation(job),
                icon: const Icon(Icons.navigation),
                label: Text(_getNavigateButtonText(job)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: colors.primary),
                  foregroundColor: colors.primary,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Primary Action Button
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: controller.getNextActionText(),
                    onPressed: controller.isUpdatingStatus.value
                        ? null
                        : () => _handlePrimaryAction(job),
                    isLoading: controller.isUpdatingStatus.value,
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.large,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _getNavigateButtonText(JobModel job) {
    // Pickup phase: before package is collected
    // Drop phase: after package is collected
    final isPickupPhase = job.status.index < JobStatus.packageCollected.index;
    return isPickupPhase ? 'Navigate to Pickup' : 'Navigate to Drop';
  }

  // ============================================
  // ACTIONS
  // ============================================

  void _handlePrimaryAction(JobModel job) async {
    final nextStatus = controller.getNextStatus();
    if (nextStatus == null) return;

    // Check if photo is required
    if (controller.isPhotoRequired()) {
      await _captureAndUploadPhoto();
    }

    // Update status
    await controller.updateStatus(nextStatus);
  }

  Future<void> _captureAndUploadPhoto() async {
    final ImagePicker picker = ImagePicker();

    // Show options
    final source = await Get.bottomSheet<ImageSource>(
      Builder(builder: (context) {
        final colors = AppColorScheme.of(context);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delivery Photo Required',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a photo as proof of delivery',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: colors.primary),
                ),
                title: Text('Take Photo', style: TextStyle(color: colors.textPrimary)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.info.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: colors.info),
                ),
                title: Text('Choose from Gallery', style: TextStyle(color: colors.textPrimary)),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        );
      }),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (image != null) {
      // Show loading
      Get.dialog(
        const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Uploading photo...'),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Upload
      final url = await controller.uploadPhoto(image.path);

      // Close loading
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (url == null) {
        Get.snackbar(
          'Upload Failed',
          'Please try again',
          backgroundColor: colors.error.withValues(alpha: 0.2),
        );
      }
    }
  }

  // Late-bound colors reference for snackbar — grab from the controller's context
  AppColorScheme get colors => AppColorScheme.of(Get.context!);

  void _openNavigation(JobModel job) async {
    final isPickupPhase = job.status.index <= JobStatus.packageCollected.index;
    final destination = isPickupPhase
        ? job.pickupAddress
        : job.dropAddress;

    final lat = destination.lat;
    final lng = destination.lng;

    // Try Google Maps first
    final googleMapsUrl = Uri.parse(
      'google.navigation:q=$lat,$lng&mode=d',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
      return;
    }

    // Fallback to web
    final webUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );
    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  }

  void _callCustomer(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _messageCustomer(String phone) async {
    final url = Uri.parse('sms:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _handleMenuAction(String action, JobModel job) {
    switch (action) {
      case 'help':
        Get.snackbar('Help', 'Contact support: 1800-XXX-XXXX');
        break;
      case 'cancel':
        _showCancelDialog(job);
        break;
    }
  }

  void _showCancelDialog(JobModel job) {
    final TextEditingController reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Job?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this job? This may affect your rating.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (required)',
                hintText: 'Why are you cancelling?',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep Job'),
          ),
          TextButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please provide a reason');
                return;
              }
              Get.back();
              controller.cancelJob(reasonController.text.trim());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Job'),
          ),
        ],
      ),
    );
  }
}
