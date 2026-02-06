import 'package:flutter/material.dart';
import '../../data/models/job_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Minimal active job card with emerald left border
/// Shows progress stepper, address, and action buttons
class ActiveJobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onNavigate;
  final VoidCallback onUpdateStatus;
  final VoidCallback? onTap;

  const ActiveJobCard({
    super.key,
    required this.job,
    required this.onNavigate,
    required this.onUpdateStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emerald left border accent
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),

              // Content
              Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'ACTIVE DELIVERY',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Progress stepper
                    _JobProgressStepper(status: job.status, colors: colors),

                    const SizedBox(height: 20),

                    // Drop location
                    Text(
                      _getLocationLabel(),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getCurrentAddress(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Navigate button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onNavigate,
                        icon: const Icon(Icons.navigation, size: 18),
                        label: const Text('NAVIGATE'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Update status button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onUpdateStatus,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primary,
                          side: BorderSide(color: colors.primary, width: 1),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('UPDATE STATUS'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  String _getLocationLabel() {
    switch (job.status) {
      case JobStatus.assigned:
      case JobStatus.navigatingToPickup:
      case JobStatus.arrivedAtPickup:
        return 'Pickup Location';
      case JobStatus.packageCollected:
      case JobStatus.inTransit:
      case JobStatus.arrivedAtDrop:
        return 'Drop Location';
      default:
        return 'Location';
    }
  }

  String _getCurrentAddress() {
    switch (job.status) {
      case JobStatus.assigned:
      case JobStatus.navigatingToPickup:
      case JobStatus.arrivedAtPickup:
        return job.pickupAddress.address;
      case JobStatus.packageCollected:
      case JobStatus.inTransit:
      case JobStatus.arrivedAtDrop:
        return job.dropAddress.address;
      default:
        return job.dropAddress.address;
    }
  }
}

/// Horizontal progress stepper showing delivery status
class _JobProgressStepper extends StatelessWidget {
  final JobStatus status;
  final AppColorScheme colors;

  const _JobProgressStepper({
    required this.status,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final currentStep = _getStepIndex();

    return Row(
      children: [
        // Pickup step
        _StepIndicator(
          isActive: currentStep >= 0,
          isCompleted: currentStep > 0,
          colors: colors,
        ),
        _StepConnector(isActive: currentStep > 0, colors: colors),

        // In Transit step
        _StepIndicator(
          isActive: currentStep >= 1,
          isCompleted: currentStep > 1,
          colors: colors,
        ),
        _StepConnector(isActive: currentStep > 1, colors: colors),

        // Drop step
        _StepIndicator(
          isActive: currentStep >= 2,
          isCompleted: currentStep > 2,
          colors: colors,
        ),
      ],
    );
  }

  int _getStepIndex() {
    switch (status) {
      case JobStatus.assigned:
      case JobStatus.navigatingToPickup:
      case JobStatus.arrivedAtPickup:
        return 0;
      case JobStatus.packageCollected:
      case JobStatus.inTransit:
        return 1;
      case JobStatus.arrivedAtDrop:
      case JobStatus.delivered:
        return 2;
      default:
        return 0;
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;
  final AppColorScheme colors;

  const _StepIndicator({
    required this.isActive,
    required this.isCompleted,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? colors.primary : colors.surfaceVariant,
        border: isActive ? null : Border.all(color: colors.border, width: 1),
      ),
      child: isCompleted
          ? Icon(
              Icons.check,
              size: 8,
              color: colors.textOnPrimary,
            )
          : null,
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isActive;
  final AppColorScheme colors;

  const _StepConnector({
    required this.isActive,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? colors.primary : colors.border,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
