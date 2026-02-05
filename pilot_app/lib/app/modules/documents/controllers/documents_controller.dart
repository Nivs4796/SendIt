import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/document_model.dart';
import '../../../data/repositories/documents_repository.dart';

class DocumentsController extends GetxController {
  final DocumentsRepository _repository = DocumentsRepository();
  final ImagePicker _picker = ImagePicker();

  // State
  final isLoading = true.obs;
  final isUploading = false.obs;
  final documents = <DocumentModel>[].obs;
  final summary = Rxn<DocumentsSummary>();
  
  // Filter
  final selectedFilter = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  /// Load all documents
  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;
      documents.value = await _repository.getDocuments();
      summary.value = await _repository.getDocumentsSummary();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load documents',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered documents
  List<DocumentModel> get filteredDocuments {
    switch (selectedFilter.value) {
      case 'verified':
        return documents.where((d) => d.status == DocumentStatus.verified).toList();
      case 'pending':
        return documents.where((d) => d.status == DocumentStatus.pending).toList();
      case 'action':
        return documents.where((d) => d.status.isActionRequired).toList();
      default:
        return documents;
    }
  }

  /// Upload new document
  Future<void> uploadDocument({
    required DocumentType type,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      isUploading.value = true;

      final newDoc = await _repository.uploadDocument(
        type: type,
        file: File(image.path),
        documentNumber: documentNumber,
        expiryDate: expiryDate,
      );

      // Update local list
      final index = documents.indexWhere((d) => d.type == type);
      if (index != -1) {
        documents[index] = newDoc;
      } else {
        documents.add(newDoc);
      }

      // Refresh summary
      summary.value = await _repository.getDocumentsSummary();

      Get.snackbar(
        'Success',
        'Document uploaded successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isUploading.value = false;
    }
  }

  /// Re-upload document (for rejected/expired)
  Future<void> reuploadDocument({
    required DocumentModel document,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      isUploading.value = true;

      final updatedDoc = await _repository.reuploadDocument(
        documentId: document.id,
        file: File(image.path),
        documentNumber: documentNumber ?? document.documentNumber,
        expiryDate: expiryDate ?? document.expiryDate,
      );

      // Update local list
      final index = documents.indexWhere((d) => d.id == document.id);
      if (index != -1) {
        documents[index] = updatedDoc;
      }

      // Refresh summary
      summary.value = await _repository.getDocumentsSummary();

      Get.snackbar(
        'Success',
        'Document re-uploaded successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Re-upload Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isUploading.value = false;
    }
  }

  /// Take photo with camera
  Future<void> takePhoto({
    required DocumentType type,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return;

      isUploading.value = true;

      final newDoc = await _repository.uploadDocument(
        type: type,
        file: File(image.path),
        documentNumber: documentNumber,
        expiryDate: expiryDate,
      );

      // Update local list
      final index = documents.indexWhere((d) => d.type == type);
      if (index != -1) {
        documents[index] = newDoc;
      } else {
        documents.add(newDoc);
      }

      // Refresh summary
      summary.value = await _repository.getDocumentsSummary();

      Get.snackbar(
        'Success',
        'Document uploaded successfully',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isUploading.value = false;
    }
  }

  /// Delete document
  Future<void> deleteDocument(DocumentModel document) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Document'),
          content: Text('Are you sure you want to delete ${document.type.displayName}?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await _repository.deleteDocument(document.id);
      documents.removeWhere((d) => d.id == document.id);
      summary.value = await _repository.getDocumentsSummary();

      Get.snackbar(
        'Deleted',
        'Document deleted successfully',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Delete Failed',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  /// Refresh documents
  Future<void> refresh() => loadDocuments();

  /// Get status color
  Color getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return Colors.green;
      case DocumentStatus.pending:
        return Colors.orange;
      case DocumentStatus.rejected:
        return Colors.red;
      case DocumentStatus.expired:
        return Colors.red;
      case DocumentStatus.notUploaded:
        return Colors.grey;
    }
  }

  /// Get status icon
  IconData getStatusIcon(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.verified:
        return Icons.check_circle;
      case DocumentStatus.pending:
        return Icons.access_time;
      case DocumentStatus.rejected:
        return Icons.cancel;
      case DocumentStatus.expired:
        return Icons.warning;
      case DocumentStatus.notUploaded:
        return Icons.upload_file;
    }
  }
}
