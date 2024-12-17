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
  final SurveyTargetConditions targetConditions;
  final DateTime createdAt;
  final DateTime expiresAt;
  final SurveyStatus status;
  final int currentResponses; // 필드 추가

  Survey({
    this.id,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.questions,
    required this.rewardAmount,
    required this.targetResponses,
    required this.targetConditions,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.currentResponses = 0,
  });

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
    return Survey(
      id: json['id'],
      creatorId: json['creatorId'],
      title: json['title'],
      description: json['description'],
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
      rewardAmount: json['rewardAmount'],
      targetResponses: json['targetResponses'],
      targetConditions:
          SurveyTargetConditions.fromJson(json['targetConditions']),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      status: SurveyStatus.values
          .firstWhere((e) => e.toString() == 'SurveyStatus.${json['status']}'),
      currentResponses: json['currentResponses'] ?? 0,
    );
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

// survey_model.dart
  Future<bool> hasUserParticipated(int userId) async {
    try {
      final activities = await ApiService().getUserActivities(userId);
      print('Checking participation for survey $id, user $userId');
      print('User activities: ${activities.participatedSurveys}');
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

// 포인트 내역을 위한 모델
class PointHistory {
  final String title;
  final DateTime date;
  final int points;
  final String type; // 'earn' or 'use'

  PointHistory({
    required this.title,
    required this.date,
    required this.points,
    required this.type,
  });

  factory PointHistory.fromJson(Map<String, dynamic> json) {
    return PointHistory(
      title: json['title'],
      date: DateTime.parse(json['date']),
      points: json['points'],
      type: json['type'],
    );
  }
}

// class SurveyStats {
//   final int surveyId;
//   final int currentResponses;
//   final int targetNumber;
//   final double responseRate;
//   final int expectedPoints;
//   final Map<String, int> responsesByAge;
//   final Map<String, int> responsesByGender;
//   final Map<String, int> responsesByLocation;
//   final List<QuestionStats> questionStats;

//   SurveyStats({
//     required this.surveyId,
//     required this.currentResponses,
//     required this.targetNumber,
//     required this.responseRate,
//     required this.expectedPoints,
//     required this.responsesByAge,
//     required this.responsesByGender,
//     required this.responsesByLocation,
//     required this.questionStats,
//   });

//   factory SurveyStats.fromJson(Map<String, dynamic> json) {
//     return SurveyStats(
//       surveyId: json['surveyId'],
//       currentResponses: json['currentResponses'],
//       targetNumber: json['targetNumber'],
//       responseRate: json['responseRate'].toDouble(),
//       expectedPoints: json['expectedPoints'],
//       responsesByAge: Map<String, int>.from(json['responsesByAge']),
//       responsesByGender: Map<String, int>.from(json['responsesByGender']),
//       responsesByLocation: Map<String, int>.from(json['responsesByLocation']),
//       questionStats: (json['questionStats'] as List)
//           .map((q) => QuestionStats.fromJson(q))
//           .toList(),
//     );
//   }
// }

// class QuestionStats {
//   final int questionId;
//   final String question;
//   final String type;
//   final Map<String, int> options;

//   QuestionStats({
//     required this.questionId,
//     required this.question,
//     required this.type,
//     required this.options,
//   });

//   factory QuestionStats.fromJson(Map<String, dynamic> json) {
//     return QuestionStats(
//       questionId: json['questionId'],
//       question: json['question'],
//       type: json['type'],
//       options: Map<String, int>.from(json['options']),
//     );
//   }
// }
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
