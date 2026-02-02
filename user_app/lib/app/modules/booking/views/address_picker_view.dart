import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../routes/app_routes.dart';
import '../controllers/booking_controller.dart';

/// View for selecting a saved address for pickup or drop location.
/// Shows all saved addresses and allows user to select one.
class AddressPickerView extends GetView<BookingController> {
  const AddressPickerView({super.key});

  /// Returns true if this is pickup selection, false for drop
  bool get isPickup => Get.arguments?['isPickup'] == true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isPickup ? 'Select Pickup Address' : 'Select Drop Address'),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: _AddressListBody(
        isPickup: isPickup,
        onAddressSelected: (address) {
          controller.setFromSavedAddress(
            address: address,
            isPickup: isPickup,
          );
          Get.back();
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppButton.outline(
        text: 'Add New Address',
        onPressed: () {
          // Navigate to add address page
          Get.toNamed(Routes.savedAddresses);
        },
      ),
    );
  }
}

/// Body widget that loads and displays addresses
class _AddressListBody extends StatefulWidget {
  final bool isPickup;
  final Function(AddressModel) onAddressSelected;

  const _AddressListBody({
    required this.isPickup,
    required this.onAddressSelected,
  });

  @override
  State<_AddressListBody> createState() => _AddressListBodyState();
}

class _AddressListBodyState extends State<_AddressListBody> {
  final AddressRepository _addressRepository = AddressRepository();
  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await _addressRepository.getAddresses();

      if (response.success && response.data != null) {
        addresses.value = response.data!;
      } else {
        errorMessage.value = response.message ?? 'Failed to load addresses';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      // Loading state
      if (isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        );
      }

      // Error state
      if (errorMessage.value.isNotEmpty) {
        return _buildErrorState(context);
      }

      // Empty state
      if (addresses.isEmpty) {
        return _buildEmptyState(context);
      }

      // Address list
      return RefreshIndicator(
        onRefresh: _loadAddresses,
        color: theme.colorScheme.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: addresses.length,
          itemBuilder: (context, index) {
            final address = addresses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SelectableAddressCard(
                address: address,
                onTap: () => widget.onAddressSelected(address),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 64,
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No saved addresses',
              style: AppTextStyles.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add addresses to quickly select pickup and drop locations',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage.value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton.primary(
              text: 'Retry',
              onPressed: _loadAddresses,
            ),
          ],
        ),
      ),
    );
  }
}

/// Selectable address card for the picker
class _SelectableAddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onTap;

  const _SelectableAddressCard({
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: address.isDefault
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : isDark
                    ? Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      )
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                blurRadius: isDark ? 8 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: address.isDefault
                        ? theme.colorScheme.primaryContainer
                        : isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForLabel(address.label),
                    color: address.isDefault
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Address details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.label,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Default',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('home')) {
      return Icons.home_outlined;
    } else if (lowerLabel.contains('office') || lowerLabel.contains('work')) {
      return Icons.business_outlined;
    }
    return Icons.location_on_outlined;
  }
}
