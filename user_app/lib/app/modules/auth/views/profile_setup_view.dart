import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/auth_controller.dart';

class ProfileSetupView extends GetView<AuthController> {
  const ProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileSetupContent();
  }
}

class _ProfileSetupContent extends StatefulWidget {
  const _ProfileSetupContent();

  @override
  State<_ProfileSetupContent> createState() => _ProfileSetupContentState();
}

class _ProfileSetupContentState extends State<_ProfileSetupContent>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late FocusNode _nameFocusNode;
  late FocusNode _emailFocusNode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
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

    // Auto-focus name input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: const Text('Complete Profile'),
          automaticallyImplyLeading: false,
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
                          // Title - Using AppText
                          const AppText.h3('Tell us about yourself'),
                          const SizedBox(height: 8),
                          const AppText.secondary(
                            'This helps us personalize your experience',
                          ),

                          const SizedBox(height: 32),

                          // Name Input - Using AppTextField.name
                          Obx(() => AppTextField.name(
                            controller: _nameController,
                            focusNode: _nameFocusNode,
                            label: 'Full Name',
                            hint: 'Enter your name',
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.textSecondary,
                            ),
                            errorText: controller.errorMessage.value.isNotEmpty &&
                                    controller.errorMessage.value.contains('Name')
                                ? controller.errorMessage.value
                                : null,
                            onChanged: (value) => controller.name.value = value,
                            onSubmitted: (_) => _emailFocusNode.requestFocus(),
                          )),

                          const SizedBox(height: 16),

                          // Email Input - Using AppTextField.email
                          AppTextField.email(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            label: 'Email (Optional)',
                            hint: 'Enter your email',
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onChanged: (value) => controller.email.value = value,
                          ),

                          // Spacer
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15,
                          ),

                          // Submit Button - Using AppButton
                          Obx(() => AppButton.primary(
                            text: 'Continue',
                            isLoading: controller.isLoading.value,
                            onPressed: controller.updateProfile,
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
