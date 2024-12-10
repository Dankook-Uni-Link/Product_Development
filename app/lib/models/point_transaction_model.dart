// models/point_transaction_model.dart
class PointTransaction {
  final int? id;
  final int userId;
  final int amount;
  final TransactionType type;
  final TransactionStatus status;
  final int? surveyId; // 설문 관련 거래인 경우에만 존재
  final DateTime createdAt;

  PointTransaction({
    this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.surveyId,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'],
      userId: json['userId'],
      amount: json['amount'],
      type: TransactionType.values
          .firstWhere((e) => e.toString() == 'TransactionType.${json['type']}'),
      status: TransactionStatus.values.firstWhere(
          (e) => e.toString() == 'TransactionStatus.${json['status']}'),
      surveyId: json['surveyId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'userId': userId,
        'amount': amount,
        'type': type.toString().split('.').last,
        'status': status.toString().split('.').last,
        if (surveyId != null) 'surveyId': surveyId,
        'createdAt': createdAt.toIso8601String(),
      };
}

enum TransactionType {
  surveyCreation, // 설문 생성시 차감
  surveyParticipation, // 설문 참여시 지급
  pointPurchase, // 포인트 구매
  pointRefund // 환불
}

enum TransactionStatus {
  pending, // 대기중
  completed, // 완료
  failed, // 실패
  refunded // 환불됨
}
