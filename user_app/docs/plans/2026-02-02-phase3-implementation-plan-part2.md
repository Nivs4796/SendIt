# Phase 3 Implementation Plan - Part 2

> **Continuation of:** `2026-02-02-phase3-implementation-plan.md`

---

## Track C: Booking Module (Continued)

### Task 9: Create CreateBookingView

**Files:**
- Create: `lib/app/modules/booking/views/create_booking_view.dart`

**Step 1: Create the view file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../routes/app_routes.dart';
import '../controllers/booking_controller.dart';

class CreateBookingView extends GetView<BookingController> {
  const CreateBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Booking'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup Location
                    _buildLocationCard(
                      context: context,
                      title: 'Pickup Location',
                      icon: Icons.trip_origin,
                      iconColor: Colors.green,
                      controller: controller.pickupController,
                      hint: 'Enter pickup address',
                      onTap: () => _showLocationPicker(context, isPickup: true),
                      onCurrentLocation: controller.useCurrentLocationAsPickup,
                    ),

                    const SizedBox(height: 16),

                    // Drop Location
                    _buildLocationCard(
                      context: context,
                      title: 'Drop Location',
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      controller: controller.dropController,
                      hint: 'Enter drop address',
                      onTap: () => _showLocationPicker(context, isPickup: false),
                    ),

                    const SizedBox(height: 24),

                    // Package Type
                    Text(
                      'Package Type',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPackageTypeSelector(context),

                    const SizedBox(height: 24),

                    // Package Description (Optional)
                    Text(
                      'Package Description (Optional)',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller.packageDescriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any special instructions...',
                        filled: true,
                        fillColor: theme.cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Obx(() => AppButton(
                text: 'Continue',
                onPressed: controller.canProceedToVehicle
                    ? () => Get.toNamed(Routes.vehicleSelection)
                    : null,
                isLoading: controller.isLoading,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color iconColor,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onTap,
    VoidCallback? onCurrentLocation,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (onCurrentLocation != null)
                TextButton.icon(
                  onPressed: onCurrentLocation,
                  icon: const Icon(Icons.my_location, size: 16),
                  label: const Text('Current'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTypeSelector(BuildContext context) {
    final theme = Theme.of(context);

    final packageTypes = [
      (PackageType.parcel, 'Parcel', Icons.inventory_2),
      (PackageType.document, 'Document', Icons.description),
      (PackageType.food, 'Food', Icons.restaurant),
      (PackageType.grocery, 'Grocery', Icons.shopping_basket),
      (PackageType.medicine, 'Medicine', Icons.medical_services),
      (PackageType.fragile, 'Fragile', Icons.warning_amber),
    ];

    return Obx(() => Wrap(
      spacing: 10,
      runSpacing: 10,
      children: packageTypes.map((item) {
        final isSelected = controller.selectedPackageType.value == item.$1;
        return GestureDetector(
          onTap: () => controller.selectPackageType(item.$1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withOpacity(0.1)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.$3,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  item.$2,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ));
  }

  void _showLocationPicker(BuildContext context, {required bool isPickup}) {
    // TODO: Implement full location picker with map
    // For now, show a simple dialog with saved addresses
    Get.toNamed(
      isPickup ? Routes.pickupLocation : Routes.dropLocation,
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/booking/views/create_booking_view.dart
git commit -m "feat(booking): add CreateBookingView with location and package selection"
```

---

### Task 10: Create VehicleSelectionView

**Files:**
- Create: `lib/app/modules/booking/views/vehicle_selection_view.dart`

**Step 1: Create the view file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../data/models/vehicle_type_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/booking_controller.dart';

class VehicleSelectionView extends GetView<BookingController> {
  const VehicleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Vehicle'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Route Summary
                    _buildRouteSummary(context),

                    const SizedBox(height: 24),

                    // Vehicle Types
                    Text(
                      'Choose Vehicle Type',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(() {
                      if (controller.bookingState.value == BookingState.loadingVehicles) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (controller.vehicleTypes.isEmpty) {
                        return Center(
                          child: Text(
                            'No vehicles available',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: controller.vehicleTypes.map((vehicle) {
                          return _buildVehicleCard(context, vehicle);
                        }).toList(),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Price Breakdown
                    Obx(() {
                      if (controller.priceCalculation.value == null) {
                        return const SizedBox.shrink();
                      }
                      return _buildPriceBreakdown(context);
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Obx(() => AppButton(
                text: controller.priceCalculation.value != null
                    ? 'Continue • ${controller.priceCalculation.value!.totalDisplay}'
                    : 'Select Vehicle',
                onPressed: controller.canProceedToPayment
                    ? () => Get.toNamed(Routes.reviewBooking)
                    : null,
                isLoading: controller.bookingState.value == BookingState.calculatingPrice,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.trip_origin, color: Colors.green, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Text(
                  controller.pickupAddress.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Container(
              width: 2,
              height: 20,
              color: theme.dividerColor,
            ),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => Text(
                  controller.dropAddress.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, VehicleTypeModel vehicle) {
    final theme = Theme.of(context);

    return Obx(() {
      final isSelected = controller.selectedVehicle.value?.id == vehicle.id;

      return GestureDetector(
        onTap: () => controller.selectVehicle(vehicle),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Vehicle Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getVehicleIcon(vehicle.name),
                  size: 32,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),

              // Vehicle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Up to ${vehicle.weightDisplay}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (vehicle.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        vehicle.description!,
                        style: AppTextStyles.caption.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    vehicle.basePriceDisplay,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'base fare',
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              // Selection Indicator
              if (isSelected) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPriceBreakdown(BuildContext context) {
    final theme = Theme.of(context);
    final price = controller.priceCalculation.value!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: AppTextStyles.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow(context, 'Distance', price.distanceDisplay),
          _buildPriceRow(context, 'Est. Time', price.durationDisplay),
          const Divider(height: 24),
          _buildPriceRow(context, 'Base Fare', price.baseFareDisplay),
          _buildPriceRow(context, 'Distance Fare', price.distanceFareDisplay),
          if (price.taxes > 0)
            _buildPriceRow(context, 'Taxes', price.taxesDisplay),
          const Divider(height: 24),
          _buildPriceRow(
            context,
            'Total',
            price.totalDisplay,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context, String label, String value,
      {bool isTotal = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: (isTotal ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium).copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: (isTotal ? AppTextStyles.titleSmall : AppTextStyles.bodyMedium).copyWith(
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVehicleIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('bike') || lowerName.contains('two')) {
      return Icons.two_wheeler;
    } else if (lowerName.contains('car') || lowerName.contains('sedan')) {
      return Icons.directions_car;
    } else if (lowerName.contains('van') || lowerName.contains('mini')) {
      return Icons.airport_shuttle;
    } else if (lowerName.contains('truck')) {
      return Icons.local_shipping;
    }
    return Icons.local_shipping;
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/booking/views/vehicle_selection_view.dart
git commit -m "feat(booking): add VehicleSelectionView with price calculation"
```

---

### Task 11: Create PaymentView (Review & Pay)

**Files:**
- Create: `lib/app/modules/booking/views/payment_view.dart`

**Step 1: Create the view file**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../controllers/booking_controller.dart';

class PaymentView extends GetView<BookingController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Pay'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Summary
                    _buildBookingSummary(context),

                    const SizedBox(height: 24),

                    // Payment Methods
                    Text(
                      'Payment Method',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentMethods(context),

                    const SizedBox(height: 24),

                    // Coupon Code
                    _buildCouponSection(context),

                    const SizedBox(height: 24),

                    // Final Price
                    _buildFinalPrice(context),
                  ],
                ),
              ),
            ),

            // Confirm Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Obx(() => AppButton(
                text: 'Confirm Booking • ${controller.finalAmountDisplay}',
                onPressed: controller.bookingState.value == BookingState.creatingBooking
                    ? null
                    : () => controller.createBooking(),
                isLoading: controller.bookingState.value == BookingState.creatingBooking,
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: AppTextStyles.titleSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Locations
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Icon(Icons.trip_origin, color: Colors.green, size: 16),
                  Container(
                    width: 2,
                    height: 30,
                    color: theme.dividerColor,
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 16),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      controller.pickupAddress.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                    const SizedBox(height: 20),
                    Obx(() => Text(
                      controller.dropAddress.value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          // Package & Vehicle
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Package',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controller.selectedPackageType.value.name.capitalize!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle',
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      controller.selectedVehicle.value?.name ?? '-',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() => Column(
      children: [
        // Wallet
        _buildPaymentOption(
          context: context,
          method: PaymentMethod.wallet,
          title: 'Wallet',
          subtitle: 'Balance: ₹${controller.walletBalance.value.toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet,
          isSelected: controller.selectedPaymentMethod.value == PaymentMethod.wallet,
          isEnabled: controller.hasSufficientBalance.value,
          warning: !controller.hasSufficientBalance.value
              ? 'Insufficient balance'
              : null,
        ),

        const SizedBox(height: 12),

        // Cash
        _buildPaymentOption(
          context: context,
          method: PaymentMethod.cash,
          title: 'Cash on Delivery',
          subtitle: 'Pay when delivered',
          icon: Icons.money,
          isSelected: controller.selectedPaymentMethod.value == PaymentMethod.cash,
        ),

        const SizedBox(height: 12),

        // UPI (Razorpay placeholder)
        _buildPaymentOption(
          context: context,
          method: PaymentMethod.upi,
          title: 'UPI',
          subtitle: 'Coming soon',
          icon: Icons.qr_code,
          isSelected: controller.selectedPaymentMethod.value == PaymentMethod.upi,
          isEnabled: false,
        ),
      ],
    ));
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required PaymentMethod method,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    bool isEnabled = true,
    String? warning,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: isEnabled ? () => controller.selectPaymentMethod(method) : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (warning != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        warning,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCouponSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_offer,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Apply Coupon',
              style: AppTextStyles.bodyMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showCouponDialog(context),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPrice(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final price = controller.priceCalculation.value;
      if (price == null) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  price.totalDisplay,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (controller.couponDiscount.value > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discount',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '-₹${controller.couponDiscount.value.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  controller.finalAmountDisplay,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _showCouponDialog(BuildContext context) {
    final theme = Theme.of(context);
    final couponController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Apply Coupon'),
        content: TextField(
          controller: couponController,
          decoration: const InputDecoration(
            hintText: 'Enter coupon code',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.applyCoupon(couponController.text);
              Get.back();
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/booking/views/payment_view.dart
git commit -m "feat(booking): add PaymentView with payment method selection"
```

---

### Task 12: Create FindingDriverView

**Files:**
- Create: `lib/app/modules/booking/views/finding_driver_view.dart`

**Step 1: Create the view file**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons/app_button.dart';
import '../../../routes/app_routes.dart';
import '../../../services/socket_service.dart';
import '../controllers/booking_controller.dart';

class FindingDriverView extends GetView<BookingController> {
  const FindingDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    return _FindingDriverContent(controller: controller);
  }
}

class _FindingDriverContent extends StatefulWidget {
  final BookingController controller;

  const _FindingDriverContent({required this.controller});

  @override
  State<_FindingDriverContent> createState() => _FindingDriverContentState();
}

class _FindingDriverContentState extends State<_FindingDriverContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  StreamSubscription? _driverAssignedSubscription;
  int _searchDuration = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _startSearchTimer();
    _listenForDriverAssigned();
  }

  void _startSearchTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _searchDuration++;
      });
    });
  }

  void _listenForDriverAssigned() {
    final socketService = Get.find<SocketService>();

    // Join booking room for updates
    if (widget.controller.currentBooking.value != null) {
      socketService.joinBookingRoom(widget.controller.currentBooking.value!.id);
    }

    _driverAssignedSubscription = socketService.onDriverAssigned.listen((data) {
      // Driver found - navigate to tracking
      Get.offNamed(
        Routes.orderTracking,
        arguments: {'bookingId': widget.controller.currentBooking.value?.id},
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _driverAssignedSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedDuration {
    final minutes = _searchDuration ~/ 60;
    final seconds = _searchDuration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        _showCancelDialog(context);
        return false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),

                // Animated Search Icon
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.search,
                          size: 60,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  'Finding a Driver',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Please wait while we connect you\nwith a nearby driver',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                // Timer
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formattedDuration,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Booking Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.trip_origin, color: Colors.green, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.controller.pickupAddress.value,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.controller.dropAddress.value,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.controller.selectedVehicle.value?.name ?? '',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.controller.finalAmountDisplay,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Cancel Button
                AppButton(
                  text: 'Cancel Booking',
                  onPressed: () => _showCancelDialog(context),
                  type: AppButtonType.outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text(
          'Are you sure you want to cancel this booking? You may be charged a cancellation fee.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No, Wait'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              widget.controller.cancelBooking(reason: 'User cancelled while finding driver');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/app/modules/booking/views/finding_driver_view.dart
git commit -m "feat(booking): add FindingDriverView with animation and socket listener"
```

---

*Plan continues in Part 3 with Orders Module (Tasks 13-17), Tracking Module (Tasks 18-22), and Integration (Tasks 23-25)...*
