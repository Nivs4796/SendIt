import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/support_repository.dart';
import '../controllers/support_controller.dart';

class HelpView extends GetView<SupportController> {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.faqCategories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                _buildSearchBar(colors),
                const SizedBox(height: 20),

                // Search Results or Main Content
                Obx(() => controller.searchQuery.isNotEmpty
                    ? _buildSearchResults(colors)
                    : _buildMainContent(colors)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar(AppColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: TextField(
        onChanged: controller.searchFaqs,
        decoration: InputDecoration(
          hintText: 'Search for help...',
          prefixIcon: Icon(
            Icons.search,
            color: colors.textHint,
          ),
          suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.searchFaqs('');
                  },
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              '${controller.searchResults.length} results found',
              style: AppTextStyles.labelSmall.copyWith(
                color: colors.textHint,
              ),
            )),
        const SizedBox(height: 12),
        Obx(() => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final faq = controller.searchResults[index];
                return _buildFaqCard(colors, faq);
              },
            )),
      ],
    );
  }

  Widget _buildMainContent(AppColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Contact Card
        _buildContactCard(colors),
        const SizedBox(height: 24),

        // FAQs Section
        Text(
          'Frequently Asked Questions',
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildFaqCategories(colors),
        const SizedBox(height: 24),

        // Create Ticket Button
        _buildCreateTicketButton(colors),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildContactCard(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.cyan.shade600,
            Colors.cyan.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.headset_mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Help?',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() => Text(
                          controller.contact.value?.workingHours ?? '24/7 Support',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Contact Options
          Row(
            children: [
              Expanded(
                child: _buildContactOption(
                  colors,
                  icon: Icons.phone,
                  label: 'Call',
                  onTap: controller.callSupport,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactOption(
                  colors,
                  icon: Icons.email,
                  label: 'Email',
                  onTap: controller.emailSupport,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactOption(
                  colors,
                  icon: Icons.chat,
                  label: 'WhatsApp',
                  color: colors.success,
                  onTap: controller.whatsappSupport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(
    AppColorScheme colors, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: (color ?? Colors.white).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqCategories(AppColorScheme colors) {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.faqCategories.length,
          itemBuilder: (context, index) {
            final category = controller.faqCategories[index];
            return _buildFaqCategoryCard(colors, category);
          },
        ));
  }

  Widget _buildFaqCategoryCard(AppColorScheme colors, FaqCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              category.icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${category.faqs.length} questions',
          style: AppTextStyles.labelSmall.copyWith(
            color: colors.textHint,
          ),
        ),
        childrenPadding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        children: category.faqs.map((faq) => _buildFaqItem(colors, faq)).toList(),
      ),
    );
  }

  Widget _buildFaqItem(AppColorScheme colors, FaqItem faq) {
    return Obx(() {
      final isExpanded = controller.expandedFaqId.value == faq.id;
      return Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.toggleFaq(faq.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: colors.textHint,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Text(
                  faq.answer,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildFaqCard(AppColorScheme colors, FaqItem faq) {
    return Obx(() {
      final isExpanded = controller.expandedFaqId.value == faq.id;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.toggleFaq(faq.id),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faq.question,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: colors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isExpanded)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  faq.answer,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildCreateTicketButton(AppColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.support_agent,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Still need help?',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Create a support ticket and we\'ll get back to you',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: colors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateTicketSheet(colors),
              icon: const Icon(Icons.add),
              label: const Text('Create Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateTicketSheet(AppColorScheme colors) {
    // Reset form
    controller.subjectController.clear();
    controller.descriptionController.clear();
    controller.selectedCategory.value = 'general';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxHeight: Get.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: controller.ticketFormKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Create Support Ticket',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Describe your issue and we\'ll help you resolve it',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 24),

                // Category Dropdown
                Text('Category', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                Obx(() => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedCategory.value,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(12),
                          items: controller.ticketCategories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['key'],
                              child: Text(cat['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedCategory.value = value;
                            }
                          },
                        ),
                      ),
                    )),
                const SizedBox(height: 16),

                // Subject
                TextFormField(
                  controller: controller.subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    hintText: 'Brief description of your issue',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter subject' : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: controller.descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide details about your issue...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter description';
                    if (v.length < 20) return 'Please provide more details';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Submit Button
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.submitTicket,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Submit Ticket'),
                      ),
                    )),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
