// models/response_model.dart
class Response {
  final int? id;
  final int surveyId;
  final int userId;
  final Map<String, dynamic> answers; // {"questionId": selected_answer}
  final DateTime createdAt;
  final ResponseStatus status;

  Response({
    this.id,
    required this.surveyId,
    required this.userId,
    required this.answers,
    required this.createdAt,
    this.status = ResponseStatus.submitted,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      id: json['id'],
      surveyId: json['surveyId'],
      userId: json['userId'],
      answers: Map<String, dynamic>.from(json['answers']),
      createdAt: DateTime.parse(json['createdAt']),
      status: ResponseStatus.values.firstWhere(
          (e) => e.toString() == 'ResponseStatus.${json['status']}'),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'surveyId': surveyId,
        'userId': userId,
        'answers': answers,
        'createdAt': createdAt.toIso8601String(),
        'status': status.toString().split('.').last,
      };
}

enum ResponseStatus {
  submitted, // 제출됨
  verified, // 확인됨
  rejected // 거절됨
}
