import 'package:app/models/question_model.dart';
import 'package:app/services/api_service.dart';

class Survey {
  final int? id;
  final int creatorId;
  final String title;
  final String description;
  final List<Question> questions;
  final int rewardAmount;
  final int targetResponses;
  final SurveyTargetConditions targetConditions; // 추가
  final int currentResponses;
  final DateTime createdAt;
  final DateTime expiresAt;
  final SurveyStatus status;
  final String creatorName; // creatorName 필드 추가

  Survey({
    this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.questions,
    required this.rewardAmount,
    this.targetResponses = 100,
    SurveyTargetConditions? targetConditions, // 선택적 매개변수
    this.currentResponses = 0,
    DateTime? createdAt,
    DateTime? expiresAt,
    this.status = SurveyStatus.active,
    this.creatorName = '', // 기본값 설정
  })  : targetConditions = targetConditions ?? SurveyTargetConditions(// 기본값 설정
            ageRanges: [], genders: [], locations: [], occupations: []),
        createdAt = createdAt ?? DateTime.now(),
        expiresAt = expiresAt ??
            DateTime.now()
                .add(const Duration(days: 30)); // 기본값 설정 (예: 30일 후 만료)

  // 기존 코드와의 호환성을 위한 getter들
  String get surveyTitle => title;
  String get surveyDescription => description;
  String get reward => rewardAmount.toString();
  int get targetNumber => targetResponses;
  bool get isEnded => status != SurveyStatus.active;
  String get statusText => status == SurveyStatus.active ? "진행중" : "종료됨";
  int get totalQuestions => questions.length;

  // 유틸리티 메서드들
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isTargetReached => currentResponses >= targetResponses;

  double getProgress() {
    if (targetResponses <= 0) return 0.0;
    return (currentResponses / targetResponses).clamp(0.0, 1.0);
  }

  factory Survey.fromJson(Map<String, dynamic> json) {
    // 각 필드 데이터 로깅
    print('Parsing survey data:');
    print('id: ${json['id']}');
    print('creator_id: ${json['creator_id']}');
    print('title: ${json['title']}');
    print('description: ${json['description']}');
    print('questions: ${json['questions']}');
    print('reward_amount: ${json['reward_amount']}');
    print('current_responses: ${json['current_responses']}');
    print('created_at: ${json['created_at']}');
    print('creator_name: ${json['creator_name']}'); // null이 오는 부분 확인
    print('target_responses: ${json['target_responses']}');
    print('target_conditions: ${json['target_conditions']}');
    print('expires_at: ${json['expires_at']}');
    print('status: ${json['status']}');

    try {
      return Survey(
          id: json['id'],
          creatorId: json['creator_id'] ?? 0,
          title: json['title'] ?? '',
          description: json['description'] ?? '',
          questions: (json['questions'] as List?)
                  ?.map((q) => Question.fromJson(q))
                  .toList() ??
              [],
          rewardAmount: json['reward_amount'] ?? 0,
          currentResponses: json['current_responses'] ?? 0,
          createdAt: json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
          targetResponses: json['target_responses'] ?? 100,
          targetConditions: json['target_conditions'] != null
              ? SurveyTargetConditions.fromJson(json['target_conditions'])
              : SurveyTargetConditions(
                  ageRanges: [], genders: [], locations: [], occupations: []),
          expiresAt: json['expires_at'] != null
              ? DateTime.parse(json['expires_at'])
              : DateTime.now().add(const Duration(days: 30)),
          status: SurveyStatus.values.firstWhere(
              (e) =>
                  e.toString() == 'SurveyStatus.${json['status'] ?? 'active'}',
              orElse: () => SurveyStatus.active),
          creatorName: json['creator_name']?.toString() ?? '' // toString() 추가
          );
    } catch (e, stack) {
      print('Error parsing survey: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'creatorId': creatorId,
        'title': title,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'rewardAmount': rewardAmount,
        'targetResponses': targetResponses,
        'targetConditions': targetConditions.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'status': status.toString().split('.').last,
        'currentResponses': currentResponses,
      };

  Future<bool> canUserParticipate(int userId) async {
    if (isExpired || isTargetReached || status != SurveyStatus.active) {
      return false;
    }

    try {
      final activities = await ApiService().getUserActivities(userId);
      final hasParticipated = activities.participatedSurveys
          .any((participation) => participation.surveyId == id);

      return !hasParticipated;
    } catch (e) {
      print('Error checking participation eligibility: $e');
      return false;
    }
  }

  Future<bool> hasUserParticipated(int userId) async {
    try {
      final activities = await ApiService().getUserActivities(userId);
      print('Checking participation for survey $id, user $userId');
      print('Survey ID to check: $id');
      for (var participation in activities.participatedSurveys) {
        print('Participation survey ID: ${participation.surveyId}');
      }

      final hasParticipated =
          activities.participatedSurveys.any((p) => p.surveyId == id);
      print('Has participated: $hasParticipated');
      return hasParticipated;
    } catch (e) {
      print('Error checking participation: $e');
      return false;
    }
  }
}

enum SurveyStatus {
  active, // 진행중
  completed, // 완료됨
  cancelled // 취소됨
}

class SurveyTargetConditions {
  final List<String> ageRanges;
  final List<String> genders;
  final List<String> locations;
  final List<String> occupations;

  SurveyTargetConditions({
    required this.ageRanges,
    required this.genders,
    required this.locations,
    required this.occupations,
  });

  factory SurveyTargetConditions.fromJson(Map<String, dynamic> json) {
    return SurveyTargetConditions(
      ageRanges: List<String>.from(json['ageRanges'] ?? []),
      genders: List<String>.from(json['genders'] ?? []),
      locations: List<String>.from(json['locations'] ?? []),
      occupations: List<String>.from(json['occupations'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'ageRanges': ageRanges,
        'genders': genders,
        'locations': locations,
        'occupations': occupations,
      };
}

class PointHistory {
  final int id;
  final int points;
  final String title;
  final String type;
  final DateTime createdAt;

  PointHistory({
    required this.id,
    required this.points,
    required this.title,
    required this.type,
    required this.createdAt,
  });

  factory PointHistory.fromJson(Map<String, dynamic> json) {
    return PointHistory(
      id: json['id'] ?? 0,
      points: json['points'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class SurveyStats {
  final Summary summary;
  final Map<String, QuestionStats> questions;

  SurveyStats({
    required this.summary,
    required this.questions,
  });

  factory SurveyStats.fromJson(Map<String, dynamic> json) {
    return SurveyStats(
      summary: Summary.fromJson(json['summary']),
      questions: Map.fromEntries(
        (json['questions'] as Map<String, dynamic>)
            .entries
            .map((e) => MapEntry(e.key, QuestionStats.fromJson(e.value))),
      ),
    );
  }
}

class QuestionStats {
  final Map<String, int> responses;

  QuestionStats({
    required this.responses,
  });

  factory QuestionStats.fromJson(Map<String, dynamic> json) {
    return QuestionStats(
      responses: Map<String, int>.from(json['responses'] as Map),
    );
  }
}

class Summary {
  final int totalResponses;
  final DateTime lastUpdated;

  Summary({
    required this.totalResponses,
    required this.lastUpdated,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalResponses: json['totalResponses'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

class QuestionStat {
  final Map<String, int> responses;

  QuestionStat({
    required this.responses,
  });

  factory QuestionStat.fromJson(Map<String, dynamic> json) {
    return QuestionStat(
      responses: Map<String, int>.from(json['responses'] as Map),
    );
  }
}
