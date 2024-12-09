class PointTransaction {
  final int id;
  final int userId;
  final int amount;
  final TransactionType type;
  final TransactionStatus status;
  final int? surveyId;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'amount': amount,
        'type': type.toString(),
        'status': status.toString(),
        'survey_id': surveyId,
        'created_at': createdAt.toIso8601String()
      };
}

enum TransactionType {
  surveyCreation,
  surveyParticipation,
  pointPurchase,
  pointRefund
}

enum TransactionStatus { pending, completed, failed, refunded }
