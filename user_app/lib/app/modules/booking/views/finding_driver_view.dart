import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/widgets.dart';
import '../../../routes/app_routes.dart';
import '../../../services/socket_service.dart';
import '../controllers/booking_controller.dart';

/// FindingDriverView displays the searching animation and status
/// while the app looks for an available driver.
///
/// Features:
/// - Animated pulsing search icon
/// - Timer showing elapsed search time
/// - Booking details card
/// - Cancel booking option
/// - Socket integration for driver assignment
class FindingDriverView extends StatefulWidget {
  const FindingDriverView({super.key});

  @override
  State<FindingDriverView> createState() => _FindingDriverViewState();
}

class _FindingDriverViewState extends State<FindingDriverView>
    with SingleTickerProviderStateMixin {
  // Animation
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // Timer for search duration
  Timer? _searchTimer;
  int _searchDuration = 0; // in seconds

  // Socket service and subscriptions
  late SocketService _socketService;
  StreamSubscription<DriverAssignedData>? _driverAssignedSubscription;
  StreamSubscription<SearchStartedData>? _searchStartedSubscription;
  StreamSubscription<OfferSentData>? _offerSentSubscription;
  StreamSubscription<NoPilotsData>? _noPilotsSubscription;
  StreamSubscription<SearchTimeoutData>? _searchTimeoutSubscription;

  // Assignment progress state
  String _statusMessage = 'Searching for drivers...';
  int _currentPilotNumber = 0;
  bool _showRetryOptions = false;
  bool _canRetry = false;
  bool _canCancel = true;
  String? _failureMessage;

  // Booking controller
  late BookingController _bookingController;

  @override
  void initState() {
    super.initState();

    // Initialize animation
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

    // Get dependencies
    _bookingController = Get.find<BookingController>();
    _socketService = Get.find<SocketService>();

    // Start search timer
    _startSearchTimer();

    // Setup socket listeners for assignment flow
    _setupSocketListeners();

    // Join booking room if we have a booking
    _joinBookingRoom();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchTimer?.cancel();
    _driverAssignedSubscription?.cancel();
    _searchStartedSubscription?.cancel();
    _offerSentSubscription?.cancel();
    _noPilotsSubscription?.cancel();
    _searchTimeoutSubscription?.cancel();
    _leaveBookingRoom();
    super.dispose();
  }

  /// Starts a timer to track how long the search has been active.
  void _startSearchTimer() {
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _searchDuration++;
        });
      }
    });
  }

  /// Sets up all socket listeners for assignment flow events.
  void _setupSocketListeners() {
    final currentBookingId = _bookingController.currentBooking.value?.id;

    // Listen for driver assigned
    _driverAssignedSubscription = _socketService.driverAssignedStream.listen(
      (data) {
        if (currentBookingId != null && data.bookingId == currentBookingId) {
          _navigateToTracking();
        }
      },
      onError: (error) {
        debugPrint('[FindingDriverView] Driver assigned error: $error');
      },
    );

    // Listen for search started
    _searchStartedSubscription = _socketService.searchStartedStream.listen(
      (data) {
        if (currentBookingId != null && data.bookingId == currentBookingId) {
          if (mounted) {
            setState(() {
              _statusMessage = data.message;
              _currentPilotNumber = 0;
              _showRetryOptions = false;
            });
          }
        }
      },
      onError: (error) {
        debugPrint('[FindingDriverView] Search started error: $error');
      },
    );

    // Listen for offer sent to pilot
    _offerSentSubscription = _socketService.offerSentStream.listen(
      (data) {
        if (currentBookingId != null && data.bookingId == currentBookingId) {
          if (mounted) {
            setState(() {
              _statusMessage = data.message;
              _currentPilotNumber = data.pilotNumber;
              _showRetryOptions = false;
            });
          }
        }
      },
      onError: (error) {
        debugPrint('[FindingDriverView] Offer sent error: $error');
      },
    );

    // Listen for no pilots available
    _noPilotsSubscription = _socketService.noPilotsStream.listen(
      (data) {
        if (currentBookingId != null && data.bookingId == currentBookingId) {
          if (mounted) {
            setState(() {
              _showRetryOptions = true;
              _canRetry = data.canRetry;
              _canCancel = data.canCancel;
              _failureMessage = data.message;
              _searchTimer?.cancel();
            });
          }
        }
      },
      onError: (error) {
        debugPrint('[FindingDriverView] No pilots error: $error');
      },
    );

    // Listen for search timeout
    _searchTimeoutSubscription = _socketService.searchTimeoutStream.listen(
      (data) {
        if (currentBookingId != null && data.bookingId == currentBookingId) {
          if (mounted) {
            setState(() {
              _showRetryOptions = true;
              _canRetry = data.canRetry;
              _canCancel = data.canCancel;
              _failureMessage = data.message;
              _searchTimer?.cancel();
            });
          }
        }
      },
      onError: (error) {
        debugPrint('[FindingDriverView] Search timeout error: $error');
      },
    );
  }

  /// Joins the booking room for real-time updates.
  void _joinBookingRoom() {
    final bookingId = _bookingController.currentBooking.value?.id;
    if (bookingId != null && bookingId.isNotEmpty) {
      _socketService.joinBookingRoom(bookingId);
    }
  }

  /// Leaves the booking room on dispose.
  void _leaveBookingRoom() {
    final bookingId = _bookingController.currentBooking.value?.id;
    if (bookingId != null && bookingId.isNotEmpty) {
      _socketService.leaveBookingRoom(bookingId);
    }
  }

  /// Navigates to order tracking screen.
  void _navigateToTracking() {
    final bookingId = _bookingController.currentBooking.value?.id;
    Get.offNamed(
      Routes.orderTracking,
      arguments: {'bookingId': bookingId},
    );
  }

  /// Returns the formatted duration string (MM:SS).
  String get _formattedDuration {
    final minutes = (_searchDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_searchDuration % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Shows a confirmation dialog before cancelling the booking.
  Future<void> _showCancelDialog() async {
    final theme = Theme.of(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Cancel Booking?',
          style: AppTextStyles.h4.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'No, Keep Searching',
              style: AppTextStyles.labelLarge.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Yes, Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFFF87171)
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _cancelBooking();
    }
  }

  /// Cancels the current booking and navigates back.
  Future<void> _cancelBooking() async {
    await _bookingController.cancelBooking(reason: 'User cancelled while finding driver');
    Get.offAllNamed(Routes.main);
  }

  /// Retries the driver search.
  Future<void> _retrySearch() async {
    setState(() {
      _showRetryOptions = false;
      _failureMessage = null;
      _statusMessage = 'Retrying search...';
      _currentPilotNumber = 0;
      _searchDuration = 0;
    });
    _startSearchTimer();

    // Call the retry endpoint
    await _bookingController.retryDriverSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showCancelDialog();
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Main content - centered
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated search icon
                        _buildAnimatedSearchIcon(theme),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          _showRetryOptions ? 'No Drivers Found' : 'Finding a Driver',
                          style: AppTextStyles.h2.copyWith(
                            color: _showRetryOptions
                                ? (theme.brightness == Brightness.dark
                                    ? const Color(0xFFF87171)
                                    : AppColors.error)
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Subtitle / Status message
                        Text(
                          _showRetryOptions
                              ? (_failureMessage ?? 'All drivers are busy at the moment')
                              : _statusMessage,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        // Pilot progress indicator
                        if (_currentPilotNumber > 0 && !_showRetryOptions) ...[
                          const SizedBox(height: 16),
                          _buildPilotProgress(theme),
                        ],

                        const SizedBox(height: 24),

                        // Timer (only when searching)
                        if (!_showRetryOptions) _buildTimer(theme),

                        // Retry options
                        if (_showRetryOptions) _buildRetryOptions(theme),

                        const SizedBox(height: 32),

                        // Booking details card
                        _buildBookingDetailsCard(theme),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom cancel button
              Padding(
                padding: const EdgeInsets.all(24),
                child: Builder(builder: (context) {
                  final theme = Theme.of(context);
                  final errorColor = theme.brightness == Brightness.dark
                      ? const Color(0xFFF87171)
                      : AppColors.error;
                  return AppButton.outline(
                    text: 'Cancel Booking',
                    onPressed: _showCancelDialog,
                    borderColor: errorColor,
                    textColor: errorColor,
                    icon: Icons.close_rounded,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the animated pulsing search icon.
  Widget _buildAnimatedSearchIcon(ThemeData theme) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.search_rounded,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the search timer display.
  Widget _buildTimer(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _formattedDuration,
            style: AppTextStyles.h4.copyWith(
              color: theme.colorScheme.primary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the booking details card.
  Widget _buildBookingDetailsCard(ThemeData theme) {
    return Obx(() {
      final booking = _bookingController.currentBooking.value;
      final pickup = _bookingController.pickupAddress.value;
      final drop = _bookingController.dropAddress.value;
      final vehicle = _bookingController.selectedVehicle.value;
      final price = _bookingController.priceCalculation.value;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.brightness == Brightness.dark
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.2 : 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking ID (if available)
            if (booking?.id != null && booking!.id.isNotEmpty) ...[
              Row(
                children: [
                  Text(
                    'Booking ID: ',
                    style: AppTextStyles.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      booking.id.length > 12
                          ? '${booking.id.substring(0, 12)}...'
                          : booking.id,
                      style: AppTextStyles.caption.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor, height: 1),
              const SizedBox(height: 12),
            ],

            // Pickup location
            Builder(builder: (context) {
              final successColor = theme.brightness == Brightness.dark
                  ? const Color(0xFF34D399)
                  : AppColors.success;
              return _buildLocationRow(
                theme: theme,
                icon: Icons.circle,
                iconColor: successColor,
                label: 'Pickup',
                address: pickup.isNotEmpty ? pickup : 'Loading...',
              );
            }),
            const SizedBox(height: 12),

            // Drop location
            Builder(builder: (context) {
              final errorColor = theme.brightness == Brightness.dark
                  ? const Color(0xFFF87171)
                  : AppColors.error;
              return _buildLocationRow(
                theme: theme,
                icon: Icons.location_on_rounded,
                iconColor: errorColor,
                label: 'Drop',
                address: drop.isNotEmpty ? drop : 'Loading...',
              );
            }),

            const SizedBox(height: 16),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: 16),

            // Vehicle and Price row
            Row(
              children: [
                // Vehicle info
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.local_shipping_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
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
                            Text(
                              vehicle?.name ?? 'Standard',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    price != null
                        ? '\u20B9${price.totalAmount.toStringAsFixed(0)}'
                        : '\u20B9--',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  /// Builds a location row with icon and address.
  Widget _buildLocationRow({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 12,
          color: iconColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the pilot progress indicator showing which driver is being contacted.
  Widget _buildPilotProgress(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Contacting driver #$_currentPilotNumber',
            style: AppTextStyles.labelMedium.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the retry/cancel options when no drivers are found.
  Widget _buildRetryOptions(ThemeData theme) {
    final errorColor = theme.brightness == Brightness.dark
        ? const Color(0xFFF87171)
        : AppColors.error;

    return Column(
      children: [
        // Warning icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: errorColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.warning_amber_rounded,
            size: 32,
            color: errorColor,
          ),
        ),
        const SizedBox(height: 24),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_canRetry)
              Expanded(
                child: AppButton(
                  text: 'Retry Search',
                  onPressed: _retrySearch,
                  icon: Icons.refresh_rounded,
                ),
              ),
            if (_canRetry && _canCancel) const SizedBox(width: 12),
            if (_canCancel)
              Expanded(
                child: AppButton.outline(
                  text: 'Cancel',
                  onPressed: _cancelBooking,
                  borderColor: errorColor,
                  textColor: errorColor,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
