import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/job_model.dart';

/// Visual stepper showing job status progression
class JobStatusStepper extends StatelessWidget {
  final JobStatus status;

  const JobStatusStepper({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Progress',
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStepper(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    final steps = _getSteps();
    final currentIndex = _getCurrentStepIndex();

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentIndex;
          
          return Expanded(
            child: Container(
              height: 3,
              color: isCompleted 
                  ? AppColors.primary 
                  : Colors.grey.shade300,
            ),
          );
        }
        
        // Step circle
        final stepIndex = index ~/ 2;
        final step = steps[stepIndex];
        final isCompleted = stepIndex < currentIndex;
        final isCurrent = stepIndex == currentIndex;
        
        return _buildStep(
          icon: step.icon,
          label: step.label,
          isCompleted: isCompleted,
          isCurrent: isCurrent,
        );
      }),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color backgroundColor;
    Color iconColor;
    
    if (isCompleted) {
      backgroundColor = AppColors.primary;
      iconColor = Colors.white;
    } else if (isCurrent) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.2);
      iconColor = AppColors.primary;
    } else {
      backgroundColor = Colors.grey.shade200;
      iconColor = Colors.grey.shade400;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isCurrent ? 44 : 36,
          height: isCurrent ? 44 : 36,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: isCurrent 
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
            boxShadow: isCurrent ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: iconColor,
            size: isCurrent ? 22 : 18,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isCurrent 
                  ? AppColors.primary 
                  : (isCompleted ? Colors.grey.shade700 : Colors.grey.shade500),
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  int _getCurrentStepIndex() {
    switch (status) {
      case JobStatus.pending:
      case JobStatus.assigned:
      case JobStatus.navigatingToPickup:
        return 0;
      case JobStatus.arrivedAtPickup:
        return 1;
      case JobStatus.packageCollected:
      case JobStatus.inTransit:
        return 2;
      case JobStatus.arrivedAtDrop:
        return 3;
      case JobStatus.delivered:
        return 4;
      case JobStatus.cancelled:
        return -1;
    }
  }

  List<_StepData> _getSteps() {
    return const [
      _StepData(Icons.directions_car, 'Going to\nPickup'),
      _StepData(Icons.location_on, 'At\nPickup'),
      _StepData(Icons.inventory_2, 'Package\nCollected'),
      _StepData(Icons.local_shipping, 'At\nDrop'),
      _StepData(Icons.check_circle, 'Delivered'),
    ];
  }
}

class _StepData {
  final IconData icon;
  final String label;

  const _StepData(this.icon, this.label);
}
