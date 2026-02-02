import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../controllers/auth_controller.dart';

class OtpView extends GetView<AuthController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OtpContent();
  }
}

class _OtpContent extends StatefulWidget {
  const _OtpContent();

  @override
  State<_OtpContent> createState() => _OtpContentState();
}

class _OtpContentState extends State<_OtpContent>
    with SingleTickerProviderStateMixin {
  late TextEditingController _pinController;
  late FocusNode _pinFocusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pinController = TextEditingController();
    _pinFocusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    // Auto-focus the OTP input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    // Glassmorphism-themed pin theme
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: AppTextStyles.h3.copyWith(
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.glassInputBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.glassInputBorder),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.glassInputBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.primary),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppColors.error),
      ),
    );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Get.back(),
          ),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 48,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verification Code',
                            style: AppTextStyles.h2,
                          ),
                          const SizedBox(height: 8),
                          Obx(() => Text(
                            'We have sent the code to +91 ${controller.phone.value}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                          const SizedBox(height: 40),
                          // OTP Input with themed styling
                          Center(
                            child: Obx(() => Pinput(
                              controller: _pinController,
                              focusNode: _pinFocusNode,
                              length: AppConstants.otpLength,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              errorPinTheme: errorPinTheme,
                              forceErrorState: controller.errorMessage.isNotEmpty,
                              hapticFeedbackType: HapticFeedbackType.lightImpact,
                              closeKeyboardWhenCompleted: true,
                              animationCurve: Curves.easeInOut,
                              animationDuration: const Duration(milliseconds: 200),
                              onCompleted: (pin) {
                                controller.otp.value = pin;
                                controller.verifyOtp();
                              },
                              onChanged: (value) {
                                controller.otp.value = value;
                                // Clear error when user starts typing
                                if (controller.errorMessage.isNotEmpty) {
                                  controller.clearError();
                                }
                              },
                            )),
                          ),
                          const SizedBox(height: 24),
                          // Error Message with animation
                          Obx(() => AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            child: controller.errorMessage.isNotEmpty
                                ? Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        controller.errorMessage.value,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          )),
                          const SizedBox(height: 24),
                          // Resend OTP with better styling
                          Center(
                            child: Obx(() => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: controller.canResendOtp.value
                                  ? TextButton.icon(
                                      key: const ValueKey('resend'),
                                      onPressed: controller.resendOtp,
                                      icon: const Icon(Icons.refresh_rounded, size: 18),
                                      label: Text(
                                        'Resend OTP',
                                        style: AppTextStyles.labelLarge.copyWith(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      key: const ValueKey('timer'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 18,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Resend OTP in ${controller.resendSeconds.value}s',
                                          style: AppTextStyles.bodyMedium.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                            )),
                          ),
                          // Spacer
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15,
                          ),
                          // Verify Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.verifyOtp,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        key: ValueKey('loading'),
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Verify',
                                        key: ValueKey('text'),
                                      ),
                              ),
                            ),
                          )),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
