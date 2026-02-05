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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                _buildAppBar(context, job),
                
                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Status Stepper
                      JobStatusStepper(status: job.status),
                      
                      const SizedBox(height: 16),
                      
                      // Live Map
                      _buildLiveMap(job),
                      
                      const SizedBox(height: 16),
                      
                      // Job Info Card
                      _buildJobInfoCard(context, job),

                      const SizedBox(height: 16),

                      // Customer Card
                      _buildCustomerCard(context, job),

                      const SizedBox(height: 16),

                      // Addresses Card
                      _buildAddressesCard(context, job),

                      const SizedBox(height: 16),

                      // Payment Info
                      if (job.paymentMethod == PaymentMethod.cod)
                        _buildCodCard(context, job),
                      
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
              child: _buildBottomActions(context, job),
            ),
          ],
        );
      }),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, JobModel job) {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: true,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Job #${job.bookingId.substring(0, 8).toUpperCase()}',
            style: AppTextStyles.h4.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            job.status.displayText,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
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

  Widget _buildLiveMap(JobModel job) {
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
                    color: AppColors.primary,
                    onTap: () => _openNavigation(job),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMapQuickAction(
                    icon: Icons.fullscreen,
                    label: 'Full Map',
                    color: Colors.blue,
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
      final theme = Theme.of(context);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Live Tracking'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
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

  Widget _buildJobInfoCard(BuildContext context, JobModel job) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final infoColor = theme.brightness == Brightness.dark
        ? const Color(0xFF60A5FA)
        : Colors.blue;
    final warningColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFBBF24)
        : Colors.orange;

    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildInfoItem(
              context,
              icon: Icons.currency_rupee,
              label: 'Fare',
              value: job.fareDisplay,
              color: primaryColor,
            ),
            _buildDivider(context),
            _buildInfoItem(
              context,
              icon: Icons.route,
              label: 'Distance',
              value: job.distanceDisplay,
              color: infoColor,
            ),
            _buildDivider(context),
            _buildInfoItem(
              context,
              icon: Icons.schedule,
              label: 'ETA',
              value: job.etaDisplay,
              color: warningColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      width: 1,
      color: theme.dividerColor,
    );
  }

  Widget _buildCustomerCard(BuildContext context, JobModel job) {
    final theme = Theme.of(context);
    final successColor = theme.brightness == Brightness.dark
        ? const Color(0xFF34D399)
        : Colors.green.shade700;
    final infoColor = theme.brightness == Brightness.dark
        ? const Color(0xFF60A5FA)
        : Colors.blue.shade700;

    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                (job.customerName ?? 'C')[0].toUpperCase(),
                style: AppTextStyles.h4.copyWith(
                  color: theme.colorScheme.primary,
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
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (job.customerPhone != null)
                    Text(
                      job.customerPhone!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                    color: successColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.call,
                    color: successColor,
                    size: 20,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _messageCustomer(job.customerPhone!),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: infoColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.message,
                    color: infoColor,
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

  Widget _buildAddressesCard(BuildContext context, JobModel job) {
    final theme = Theme.of(context);
    final isPickupPhase = job.status.index <= JobStatus.packageCollected.index;
    final successColor = theme.brightness == Brightness.dark
        ? const Color(0xFF34D399)
        : Colors.green;
    final errorColor = theme.brightness == Brightness.dark
        ? const Color(0xFFF87171)
        : Colors.red;

    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pickup
            _buildAddressRow(
              context,
              icon: Icons.radio_button_checked,
              color: successColor,
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
                    color: theme.dividerColor,
                  ),
                ],
              ),
            ),

            // Drop
            _buildAddressRow(
              context,
              icon: Icons.location_on,
              color: errorColor,
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
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required String address,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
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
                            color: theme.brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodCard(BuildContext context, JobModel job) {
    final theme = Theme.of(context);
    final warningColor = theme.brightness == Brightness.dark
        ? const Color(0xFFFBBF24)
        : Colors.orange.shade700;
    final warningBg = warningColor.withValues(alpha: 0.1);

    return Card(
      color: warningBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: warningColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: warningColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payments,
                color: warningColor,
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
                      color: warningColor,
                    ),
                  ),
                  Text(
                    '₹${(job.codAmount ?? job.fare).toStringAsFixed(0)}',
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: warningColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'COLLECT',
              style: AppTextStyles.labelMedium.copyWith(
                color: warningColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, JobModel job) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.3 : 0.1),
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
                  side: BorderSide(color: theme.colorScheme.primary),
                  foregroundColor: theme.colorScheme.primary,
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
        final theme = Theme.of(context);
        final infoColor = theme.brightness == Brightness.dark
            ? const Color(0xFF60A5FA)
            : Colors.blue;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardColor,
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
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a photo as proof of delivery',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
                ),
                title: Text('Take Photo', style: TextStyle(color: theme.colorScheme.onSurface)),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: infoColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library, color: infoColor),
                ),
                title: Text('Choose from Gallery', style: TextStyle(color: theme.colorScheme.onSurface)),
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
          backgroundColor: Colors.red.shade100,
        );
      }
    }
  }

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
