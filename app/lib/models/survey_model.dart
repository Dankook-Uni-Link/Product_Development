class Survey {
  final int? id; // nullable로 변경
  final String surveyTitle;
  final String surveyDescription;
  final int totalQuestions;
  final String reward;
  final int targetNumber;
  final int winningNumber;
  final List<Question> questions;
  final String price;
  final SurveyTargetConditions targetConditions;
  final DateTime createdAt;
  final bool isEnded;
  final int currentResponses;
  final String status;

  Survey({
    this.id, // required 제거
    required this.surveyTitle,
    required this.surveyDescription,
    required this.totalQuestions,
    required this.reward,
    required this.targetNumber,
    required this.winningNumber,
    required this.questions,
    required this.price,
    required this.targetConditions,
    required this.createdAt,
    required this.isEnded,
    required this.currentResponses,
    required this.status,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    var questionsFromJson = json['questions'] as List;
    List<Question> questionList = questionsFromJson
        .map((question) => Question.fromJson(question))
        .toList();

    return Survey(
      id: json['id'],
      surveyTitle: json['surveyTitle'],
      surveyDescription: json['surveyDescription'],
      totalQuestions: json['totalQuestions'],
      reward: json['reward'],
      targetNumber: json['Target_number'],
      winningNumber: json['winning_number'],
      price: json['price'],
      questions: questionList,
      targetConditions:
          SurveyTargetConditions.fromJson(json['targetConditions']),
      createdAt: DateTime.parse(json['createdAt']),
      isEnded: json['isEnded'],
      currentResponses: json['currentResponses'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'surveyTitle': surveyTitle,
        'surveyDescription': surveyDescription,
        'totalQuestions': totalQuestions,
        'reward': reward,
        'Target_number': targetNumber,
        'winning_number': winningNumber,
        'price': price,
        'questions': questions.map((q) => q.toJson()).toList(),
        'targetConditions': targetConditions.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'isEnded': isEnded,
        'currentResponses': currentResponses,
        'status': status,
      };

  // getter 추가
  bool get isExpired {
    final deadline = createdAt.add(const Duration(days: 30));
    return DateTime.now().isAfter(deadline);
  }

  // 목표 인원이 달성되었는지 확인하는 getter도 함께 추가
  bool get isTargetReached {
    return currentResponses >= targetNumber;
  }
}

class Question {
  final String question;
  final String type;
  final List<String> options;

  Question({
    required this.question,
    required this.type,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    var optionsFromJson = json['options'] as List;
    List<String> optionsList =
        optionsFromJson.map((option) => option.toString()).toList();

    return Question(
      question: json['question'],
      type: json['type'],
      options: optionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'type': type,
      'options': options,
    };
  }
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

class SurveyStats {
  final int surveyId;
  final int currentResponses;
  final int targetNumber;
  final double responseRate;
  final int expectedPoints;
  final Map<String, int> responsesByAge;
  final Map<String, int> responsesByGender;
  final Map<String, int> responsesByLocation;
  final List<QuestionStats> questionStats;

  SurveyStats({
    required this.surveyId,
    required this.currentResponses,
    required this.targetNumber,
    required this.responseRate,
    required this.expectedPoints,
    required this.responsesByAge,
    required this.responsesByGender,
    required this.responsesByLocation,
    required this.questionStats,
  });

  factory SurveyStats.fromJson(Map<String, dynamic> json) {
    return SurveyStats(
      surveyId: json['surveyId'],
      currentResponses: json['currentResponses'],
      targetNumber: json['targetNumber'],
      responseRate: json['responseRate'].toDouble(),
      expectedPoints: json['expectedPoints'],
      responsesByAge: Map<String, int>.from(json['responsesByAge']),
      responsesByGender: Map<String, int>.from(json['responsesByGender']),
      responsesByLocation: Map<String, int>.from(json['responsesByLocation']),
      questionStats: (json['questionStats'] as List)
          .map((q) => QuestionStats.fromJson(q))
          .toList(),
    );
  }
}

class QuestionStats {
  final int questionId;
  final String question;
  final String type;
  final Map<String, int> options;

  QuestionStats({
    required this.questionId,
    required this.question,
    required this.type,
    required this.options,
  });

  factory QuestionStats.fromJson(Map<String, dynamic> json) {
    return QuestionStats(
      questionId: json['questionId'],
      question: json['question'],
      type: json['type'],
      options: Map<String, int>.from(json['options']),
    );
  }
}
