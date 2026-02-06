import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
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
    final colors = AppColorScheme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colors.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: colors.textPrimary,
            ),
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
                          // Title
                          const AppText.h2('Verification Code'),
                          const SizedBox(height: 8),
                          Obx(() => AppText.secondary(
                            'We have sent the code to ${controller.countryCode.value} ${controller.phone.value}',
                          )),

                          const SizedBox(height: 40),

                          // OTP Input
                          Center(
                            child: Obx(() => AppOtpField(
                              length: 6,
                              controller: _pinController,
                              focusNode: _pinFocusNode,
                              errorText: controller.errorMessage.value.isNotEmpty
                                  ? controller.errorMessage.value
                                  : null,
                              onCompleted: (pin) {
                                controller.otp.value = pin;
                                controller.verifyOtp();
                              },
                              onChanged: (value) {
                                controller.otp.value = value;
                                if (controller.errorMessage.isNotEmpty) {
                                  controller.clearError();
                                }
                              },
                            )),
                          ),

                          const SizedBox(height: 24),

                          // Resend OTP
                          Center(
                            child: Obx(() => AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: controller.canResendOtp.value
                                  ? AppButton.text(
                                      key: const ValueKey('resend'),
                                      text: 'Resend OTP',
                                      icon: Icons.refresh_rounded,
                                      onPressed: controller.resendOtp,
                                    )
                                  : Row(
                                      key: const ValueKey('timer'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 18,
                                          color: colors.textSecondary,
                                        ),
                                        const SizedBox(width: 8),
                                        AppText.secondary(
                                          'Resend OTP in ${controller.resendSeconds.value}s',
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
                          Obx(() => AppButton.primary(
                            text: 'Verify',
                            isLoading: controller.isLoading.value,
                            onPressed: controller.verifyOtp,
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
