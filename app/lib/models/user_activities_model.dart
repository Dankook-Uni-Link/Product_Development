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
      createdSurveys: (json['created_surveys'] as List)
          .map((activity) => SurveyActivity.fromJson(activity))
          .toList(),
      participatedSurveys: (json['participated_surveys'] as List)
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
      surveyId: json['surveyId'],
      createdAt: DateTime.parse(json['createdAt']),
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
    return SurveyParticipation(
      surveyId: json['surveyId'],
      participatedAt: DateTime.parse(json['participatedAt']),
      responses: json['responses'],
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
