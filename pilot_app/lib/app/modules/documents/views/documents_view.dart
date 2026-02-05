import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/document_model.dart';
import '../controllers/documents_controller.dart';

class DocumentsView extends GetView<DocumentsController> {
  const DocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Documents'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.documents.isEmpty) {
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
                // Summary Card
                _buildSummaryCard(theme),
                const SizedBox(height: 20),

                // Filter Chips
                _buildFilterChips(theme),
                const SizedBox(height: 16),

                // Documents List
                _buildDocumentsList(theme),
              ],
            ),
          ),
        );
      }),
      // Upload FAB
      floatingActionButton: Obx(() => controller.isUploading.value
          ? const FloatingActionButton(
              onPressed: null,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: () => _showUploadOptions(context, theme),
              icon: const Icon(Icons.add),
              label: const Text('Upload'),
            )),
    );
  }

  Widget _buildSummaryCard(ThemeData theme) {
    final summary = controller.summary.value;
    if (summary == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Document Status',
                style: AppTextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${summary.verified}/${summary.total} Verified',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.verificationProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: [
              _buildStatItem('Verified', summary.verified, Colors.white),
              _buildStatItem('Pending', summary.pending, Colors.amber),
              _buildStatItem('Action', summary.actionRequired, Colors.red.shade200),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: AppTextStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'verified', 'label': 'Verified'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'action', 'label': 'Action Required'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == filter['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                label: Text(filter['label']!),
                onSelected: (_) => controller.selectedFilter.value = filter['key']!,
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? AppColors.primary : theme.colorScheme.onSurface,
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildDocumentsList(ThemeData theme) {
    return Obx(() {
      final docs = controller.filteredDocuments;

      if (docs.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No documents found',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildDocumentCard(theme, docs[index]);
        },
      );
    });
  }

  Widget _buildDocumentCard(ThemeData theme, DocumentModel document) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final statusColor = controller.getStatusColor(document.status);
    final statusIcon = controller.getStatusIcon(document.status);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: document.status.isActionRequired
            ? Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDocumentDetails(theme, document),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Document Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          document.type.iconEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Document Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            document.type.displayName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (document.documentNumber.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              document.documentNumber,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            document.status.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Rejection Reason
                if (document.status == DocumentStatus.rejected &&
                    document.rejectionReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            document.rejectionReason!,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Expiry Warning
                if (document.isExpiringSoon && !document.isExpired) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expires in ${document.daysUntilExpiry} days',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Footer with dates and actions
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dates
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (document.uploadedAt != null)
                          Text(
                            'Uploaded: ${dateFormat.format(document.uploadedAt!)}',
                            style: AppTextStyles.caption.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        if (document.expiryDate != null)
                          Text(
                            'Expires: ${dateFormat.format(document.expiryDate!)}',
                            style: AppTextStyles.caption.copyWith(
                              color: document.isExpired
                                  ? Colors.red
                                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                      ],
                    ),

                    // Action Button
                    if (document.status.isActionRequired)
                      TextButton.icon(
                        onPressed: () => controller.reuploadDocument(document: document),
                        icon: const Icon(Icons.upload, size: 16),
                        label: const Text('Re-upload'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDocumentDetails(ThemeData theme, DocumentModel document) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Document Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      document.type.iconEmoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.type.displayName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: controller.getStatusColor(document.status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          document.status.displayName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: controller.getStatusColor(document.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Document Details
            if (document.documentNumber.isNotEmpty)
              _buildDetailRow('Document Number', document.documentNumber),
            if (document.expiryDate != null)
              _buildDetailRow(
                'Expiry Date',
                DateFormat('dd MMM yyyy').format(document.expiryDate!),
              ),
            if (document.uploadedAt != null)
              _buildDetailRow(
                'Uploaded On',
                DateFormat('dd MMM yyyy').format(document.uploadedAt!),
              ),
            if (document.verifiedAt != null)
              _buildDetailRow(
                'Verified On',
                DateFormat('dd MMM yyyy').format(document.verifiedAt!),
              ),

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                if (document.status.isActionRequired) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.reuploadDocument(document: document);
                      },
                      icon: const Icon(Icons.upload),
                      label: const Text('Re-upload'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.reuploadDocument(document: document);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Update'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadOptions(BuildContext context, ThemeData theme) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Upload Document',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the type of document to upload',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),

            // Document Types Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: DocumentType.values
                  .where((t) => t != DocumentType.other)
                  .map((type) => _buildDocTypeButton(theme, type))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDocTypeButton(ThemeData theme, DocumentType type) {
    // Check if already uploaded
    final existingDoc = controller.documents.firstWhereOrNull((d) => d.type == type);
    final isUploaded = existingDoc != null &&
        existingDoc.status != DocumentStatus.notUploaded;

    return GestureDetector(
      onTap: () {
        Get.back();
        _showUploadForm(theme, type, existingDoc);
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isUploaded
              ? Border.all(color: Colors.green.withValues(alpha: 0.5))
              : null,
        ),
        child: Column(
          children: [
            Text(type.iconEmoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              type.displayName,
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (isUploaded) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle, size: 14, color: Colors.green),
            ],
          ],
        ),
      ),
    );
  }

  void _showUploadForm(ThemeData theme, DocumentType type, DocumentModel? existingDoc) {
    final docNumberController = TextEditingController(
      text: existingDoc?.documentNumber ?? '',
    );
    final expiryDate = Rxn<DateTime>(existingDoc?.expiryDate);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Text(type.iconEmoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Text(
                  'Upload ${type.displayName}',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Document Number
            TextField(
              controller: docNumberController,
              decoration: InputDecoration(
                labelText: 'Document Number',
                hintText: 'Enter document number',
                prefixIcon: const Icon(Icons.numbers),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Expiry Date (for applicable documents)
            if (type == DocumentType.drivingLicense ||
                type == DocumentType.insurance ||
                type == DocumentType.vehicleRC) ...[
              Obx(() => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Expiry Date'),
                    subtitle: Text(
                      expiryDate.value != null
                          ? DateFormat('dd MMM yyyy').format(expiryDate.value!)
                          : 'Select expiry date',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: Get.context!,
                        initialDate: expiryDate.value ?? DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 3650)),
                      );
                      if (date != null) {
                        expiryDate.value = date;
                      }
                    },
                  )),
              const SizedBox(height: 16),
            ],

            // Upload Options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.takePhoto(
                        type: type,
                        documentNumber: docNumberController.text.isNotEmpty
                            ? docNumberController.text
                            : null,
                        expiryDate: expiryDate.value,
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      controller.uploadDocument(
                        type: type,
                        documentNumber: docNumberController.text.isNotEmpty
                            ? docNumberController.text
                            : null,
                        expiryDate: expiryDate.value,
                      );
                    },
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
