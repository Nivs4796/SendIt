class WalletTransactionModel {
  final String id;
  final String userId;
  final WalletTxnType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? description;
  final String? referenceId;
  final String? referenceType;
  final WalletTxnStatus status;
  final DateTime createdAt;

  WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    this.referenceId,
    this.referenceType,
    this.status = WalletTxnStatus.completed,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'] == 'CREDIT' ? WalletTxnType.credit : WalletTxnType.debit,
      amount: (json['amount'] ?? 0).toDouble(),
      balanceBefore: (json['balanceBefore'] ?? 0).toDouble(),
      balanceAfter: (json['balanceAfter'] ?? 0).toDouble(),
      description: json['description'],
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static WalletTxnStatus _parseStatus(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING': return WalletTxnStatus.pending;
      case 'FAILED': return WalletTxnStatus.failed;
      case 'REVERSED': return WalletTxnStatus.reversed;
      default: return WalletTxnStatus.completed;
    }
  }

  bool get isCredit => type == WalletTxnType.credit;
  String get amountDisplay => '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}';
}

enum WalletTxnType { credit, debit }
enum WalletTxnStatus { pending, completed, failed, reversed }
