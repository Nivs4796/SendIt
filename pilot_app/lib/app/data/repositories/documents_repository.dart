import 'dart:io';
import 'package:dio/dio.dart' hide Response;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import '../models/document_model.dart';
import '../providers/api_client.dart';
import '../providers/api_exceptions.dart';
import '../../core/constants/api_constants.dart';

class DocumentsRepository {
  final ApiClient _api = Get.find<ApiClient>();

  /// Get all pilot documents
  /// GET /pilots/documents
  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await _api.get(ApiConstants.pilotDocuments);
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => DocumentModel.fromJson(_transformDocument(e))).toList();
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to load documents',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on NetworkException {
      // Return mock data for development when network fails
      return _getMockDocuments();
    } on TimeoutException {
      return _getMockDocuments();
    } catch (e) {
      // Fallback to mock data for development
      return _getMockDocuments();
    }
  }

  /// Upload a new document
  /// POST /pilots/documents (multipart)
  Future<DocumentModel> uploadDocument({
    required DocumentType type,
    required File file,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': _documentTypeToApiValue(type),
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        if (documentNumber != null) 'documentNumber': documentNumber,
        if (expiryDate != null) 'expiryDate': expiryDate.toIso8601String(),
      });

      final response = await _api.uploadFile(
        ApiConstants.pilotDocuments,
        formData: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          return DocumentModel.fromJson(_transformDocument(response.data['data']));
        }
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to upload document',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Upload failed: $e');
    }
  }

  /// Re-upload a document (update existing)
  /// PUT /pilots/documents/:id
  Future<DocumentModel> reuploadDocument({
    required String documentId,
    required File file,
    String? documentNumber,
    DateTime? expiryDate,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        if (documentNumber != null) 'documentNumber': documentNumber,
        if (expiryDate != null) 'expiryDate': expiryDate.toIso8601String(),
      });

      final response = await _api.put(
        ApiConstants.pilotDocument(documentId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return DocumentModel.fromJson(_transformDocument(response.data['data']));
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to update document',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Re-upload failed: $e');
    }
  }

  /// Delete a document
  /// DELETE /pilots/documents/:id
  Future<bool> deleteDocument(String documentId) async {
    try {
      final response = await _api.delete(ApiConstants.pilotDocument(documentId));
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      
      throw ApiException(
        message: response.data['message'] ?? 'Failed to delete document',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'Delete failed: $e');
    }
  }

  /// Get document verification status summary
  Future<DocumentsSummary> getDocumentsSummary() async {
    final documents = await getDocuments();
    
    int verified = 0;
    int pending = 0;
    int rejected = 0;
    int expired = 0;
    int notUploaded = 0;

    for (final doc in documents) {
      switch (doc.status) {
        case DocumentStatus.verified:
          verified++;
          break;
        case DocumentStatus.pending:
          pending++;
          break;
        case DocumentStatus.rejected:
          rejected++;
          break;
        case DocumentStatus.expired:
          expired++;
          break;
        case DocumentStatus.notUploaded:
          notUploaded++;
          break;
      }
    }

    return DocumentsSummary(
      total: documents.length,
      verified: verified,
      pending: pending,
      rejected: rejected,
      expired: expired,
      notUploaded: notUploaded,
    );
  }

  /// Transform API document format to app format
  Map<String, dynamic> _transformDocument(Map<String, dynamic> doc) {
    return {
      'id': doc['id'] ?? doc['_id'],
      'type': _apiValueToDocumentType(doc['type']),
      'documentNumber': doc['documentNumber'] ?? doc['number'],
      'fileUrl': doc['fileUrl'] ?? doc['url'] ?? doc['file'],
      'status': _apiStatusToDocumentStatus(doc['status']),
      'expiryDate': doc['expiryDate'] ?? doc['expiry'],
      'uploadedAt': doc['uploadedAt'] ?? doc['createdAt'],
      'verifiedAt': doc['verifiedAt'],
      'rejectionReason': doc['rejectionReason'] ?? doc['reason'],
    };
  }

  /// Convert document type to API value
  String _documentTypeToApiValue(DocumentType type) {
    switch (type) {
      case DocumentType.drivingLicense:
        return 'DRIVING_LICENSE';
      case DocumentType.vehicleRC:
        return 'VEHICLE_RC';
      case DocumentType.insurance:
        return 'INSURANCE';
      case DocumentType.aadhaarCard:
        return 'AADHAAR';
      case DocumentType.panCard:
        return 'PAN';
      case DocumentType.profilePhoto:
        return 'PROFILE_PHOTO';
      case DocumentType.vehiclePhoto:
        return 'VEHICLE_PHOTO';
      case DocumentType.other:
        return 'OTHER';
    }
  }

  /// Convert API type value to document type name
  String _apiValueToDocumentType(String? apiType) {
    switch (apiType?.toUpperCase()) {
      case 'DRIVING_LICENSE':
      case 'DL':
        return 'drivingLicense';
      case 'VEHICLE_RC':
      case 'RC':
        return 'vehicleRC';
      case 'INSURANCE':
        return 'insurance';
      case 'AADHAAR':
      case 'AADHAAR_CARD':
        return 'aadhaarCard';
      case 'PAN':
      case 'PAN_CARD':
        return 'panCard';
      case 'PROFILE_PHOTO':
      case 'PHOTO':
        return 'profilePhoto';
      case 'VEHICLE_PHOTO':
        return 'vehiclePhoto';
      case 'OTHER':
        return 'other';
      default:
        return apiType?.toLowerCase() ?? 'other';
    }
  }

  /// Convert API status to document status name
  String _apiStatusToDocumentStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'VERIFIED':
      case 'APPROVED':
        return 'verified';
      case 'PENDING':
      case 'UNDER_REVIEW':
        return 'pending';
      case 'REJECTED':
        return 'rejected';
      case 'EXPIRED':
        return 'expired';
      case 'NOT_UPLOADED':
      case 'MISSING':
        return 'notUploaded';
      default:
        return status?.toLowerCase() ?? 'pending';
    }
  }

  List<DocumentModel> _getMockDocuments() {
    final now = DateTime.now();
    return [
      DocumentModel(
        id: '1',
        type: DocumentType.drivingLicense,
        documentNumber: 'DL-1234567890',
        fileUrl: 'https://example.com/dl.jpg',
        status: DocumentStatus.verified,
        expiryDate: now.add(const Duration(days: 365)),
        uploadedAt: now.subtract(const Duration(days: 30)),
        verifiedAt: now.subtract(const Duration(days: 28)),
      ),
      DocumentModel(
        id: '2',
        type: DocumentType.vehicleRC,
        documentNumber: 'KA-01-AB-1234',
        fileUrl: 'https://example.com/rc.jpg',
        status: DocumentStatus.verified,
        expiryDate: now.add(const Duration(days: 730)),
        uploadedAt: now.subtract(const Duration(days: 30)),
        verifiedAt: now.subtract(const Duration(days: 28)),
      ),
      DocumentModel(
        id: '3',
        type: DocumentType.insurance,
        documentNumber: 'INS-123456',
        fileUrl: 'https://example.com/insurance.jpg',
        status: DocumentStatus.expired,
        expiryDate: now.subtract(const Duration(days: 10)),
        uploadedAt: now.subtract(const Duration(days: 400)),
        verifiedAt: now.subtract(const Duration(days: 398)),
      ),
      DocumentModel(
        id: '4',
        type: DocumentType.aadhaarCard,
        documentNumber: '1234 5678 9012',
        fileUrl: 'https://example.com/aadhaar.jpg',
        status: DocumentStatus.verified,
        uploadedAt: now.subtract(const Duration(days: 30)),
        verifiedAt: now.subtract(const Duration(days: 28)),
      ),
      DocumentModel(
        id: '5',
        type: DocumentType.panCard,
        documentNumber: 'ABCDE1234F',
        status: DocumentStatus.pending,
        fileUrl: 'https://example.com/pan.jpg',
        uploadedAt: now.subtract(const Duration(days: 2)),
      ),
      DocumentModel(
        id: '6',
        type: DocumentType.profilePhoto,
        status: DocumentStatus.rejected,
        fileUrl: 'https://example.com/photo.jpg',
        rejectionReason: 'Photo is blurry. Please upload a clear photo.',
        uploadedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}

/// Documents summary model
class DocumentsSummary {
  final int total;
  final int verified;
  final int pending;
  final int rejected;
  final int expired;
  final int notUploaded;

  DocumentsSummary({
    required this.total,
    required this.verified,
    required this.pending,
    required this.rejected,
    required this.expired,
    required this.notUploaded,
  });

  int get actionRequired => rejected + expired + notUploaded;
  bool get allVerified => verified == total && total > 0;
  double get verificationProgress => total > 0 ? verified / total : 0;
}
