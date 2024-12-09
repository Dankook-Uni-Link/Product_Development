class Response {
  final int id;
  final int surveyId;
  final int userId;
  final Map<String, dynamic> answers;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'survey_id': surveyId,
        'user_id': userId,
        'answers': answers,
        'created_at': createdAt.toIso8601String()
      };
}
