// models/user_activities_model.dart
class UserActivities {
  final List<SurveyActivity> createdSurveys;
  final List<SurveyParticipation> participatedSurveys;

  UserActivities({
    required this.createdSurveys,
    required this.participatedSurveys,
  });

  factory UserActivities.fromJson(Map<String, dynamic> json) {
    return UserActivities(
      createdSurveys: ((json['created_surveys'] as List?) ?? [])
          .map((activity) => SurveyActivity.fromJson(activity))
          .toList(),
      participatedSurveys: ((json['participated_surveys'] as List?) ?? [])
          .map((participation) => SurveyParticipation.fromJson(participation))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'created_surveys':
            createdSurveys.map((activity) => activity.toJson()).toList(),
        'participated_surveys': participatedSurveys
            .map((participation) => participation.toJson())
            .toList(),
      };
}

class SurveyActivity {
  final int surveyId;
  final DateTime createdAt;

  SurveyActivity({
    required this.surveyId,
    required this.createdAt,
  });

  factory SurveyActivity.fromJson(Map<String, dynamic> json) {
    return SurveyActivity(
      surveyId: json['surveyId'] ?? 0, // null일 경우 기본값 제공
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'surveyId': surveyId,
        'createdAt': createdAt.toIso8601String(),
      };
}

class SurveyParticipation {
  final int surveyId;
  final DateTime participatedAt;
  final Map<String, dynamic>? responses;
  final String status;

  SurveyParticipation({
    required this.surveyId,
    required this.participatedAt,
    this.responses,
    required this.status,
  });

  factory SurveyParticipation.fromJson(Map<String, dynamic> json) {
    print('Parsing participation data: $json'); // 데이터 확인용 로그
    return SurveyParticipation(
      surveyId: json['survey_id'] ?? 0, // 'surveyId' -> 'survey_id'로 변경
      participatedAt: json['participated_at'] !=
              null // 'participatedAt' -> 'participated_at'로 변경
          ? DateTime.parse(json['participated_at'])
          : DateTime.now(),
      responses: json['response_data'], // 'responses' -> 'response_data'로 변경
      status: json['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toJson() => {
        'surveyId': surveyId,
        'participatedAt': participatedAt.toIso8601String(),
        if (responses != null) 'responses': responses,
        'status': status,
      };
}
