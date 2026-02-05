/// Document status enum
enum DocumentStatus {
  pending,
  verified,
  rejected,
  expired,
  notUploaded;

  String get displayName {
    switch (this) {
      case DocumentStatus.pending:
        return 'Pending';
      case DocumentStatus.verified:
        return 'Verified';
      case DocumentStatus.rejected:
        return 'Rejected';
      case DocumentStatus.expired:
        return 'Expired';
      case DocumentStatus.notUploaded:
        return 'Not Uploaded';
    }
  }

  bool get isActionRequired =>
      this == DocumentStatus.rejected ||
      this == DocumentStatus.expired ||
      this == DocumentStatus.notUploaded;
}

/// Document type enum
enum DocumentType {
  drivingLicense,
  vehicleRC,
  insurance,
  aadhaarCard,
  panCard,
  profilePhoto,
  vehiclePhoto,
  other;

  String get displayName {
    switch (this) {
      case DocumentType.drivingLicense:
        return 'Driving License';
      case DocumentType.vehicleRC:
        return 'Vehicle RC';
      case DocumentType.insurance:
        return 'Insurance';
      case DocumentType.aadhaarCard:
        return 'Aadhaar Card';
      case DocumentType.panCard:
        return 'PAN Card';
      case DocumentType.profilePhoto:
        return 'Profile Photo';
      case DocumentType.vehiclePhoto:
        return 'Vehicle Photo';
      case DocumentType.other:
        return 'Other Document';
    }
  }

  String get iconEmoji {
    switch (this) {
      case DocumentType.drivingLicense:
        return '🪪';
      case DocumentType.vehicleRC:
        return '🚗';
      case DocumentType.insurance:
        return '📋';
      case DocumentType.aadhaarCard:
        return '🆔';
      case DocumentType.panCard:
        return '💳';
      case DocumentType.profilePhoto:
        return '📸';
      case DocumentType.vehiclePhoto:
        return '🏍️';
      case DocumentType.other:
        return '📄';
    }
  }

  bool get isRequired {
    return this != DocumentType.other && this != DocumentType.vehiclePhoto;
  }
}

/// Document model
class DocumentModel {
  final String id;
  final DocumentType type;
  final String documentNumber;
  final String? fileUrl;
  final String? thumbnailUrl;
  final DocumentStatus status;
  final String? rejectionReason;
  final DateTime? expiryDate;
  final DateTime? uploadedAt;
  final DateTime? verifiedAt;

  DocumentModel({
    required this.id,
    required this.type,
    this.documentNumber = '',
    this.fileUrl,
    this.thumbnailUrl,
    this.status = DocumentStatus.notUploaded,
    this.rejectionReason,
    this.expiryDate,
    this.uploadedAt,
    this.verifiedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String? ?? '',
      type: DocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => DocumentType.other,
      ),
      documentNumber: json['documentNumber'] as String? ?? '',
      fileUrl: json['fileUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DocumentStatus.notUploaded,
      ),
      rejectionReason: json['rejectionReason'] as String?,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'])
          : null,
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'])
          : null,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.tryParse(json['verifiedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'documentNumber': documentNumber,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'expiryDate': expiryDate?.toIso8601String(),
      'uploadedAt': uploadedAt?.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
    };
  }

  DocumentModel copyWith({
    String? id,
    DocumentType? type,
    String? documentNumber,
    String? fileUrl,
    String? thumbnailUrl,
    DocumentStatus? status,
    String? rejectionReason,
    DateTime? expiryDate,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      type: type ?? this.type,
      documentNumber: documentNumber ?? this.documentNumber,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      expiryDate: expiryDate ?? this.expiryDate,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry > 0 && daysUntilExpiry <= 30;
  }

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }
}
