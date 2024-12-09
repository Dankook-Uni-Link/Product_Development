class Survey {
  final int id;
  final int creatorId;
  final String title;
  final String description;
  final Map<String, dynamic> targetConditions;
  final int rewardAmount;
  final int targetResponses;
  final SurveyStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
}

enum SurveyStatus { active, completed, cancelled }
