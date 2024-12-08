class Survey {
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
  final String status; // "진행중" | "마감됨"

  Survey({
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
      surveyTitle: json['surveyTitle'] ?? '',
      surveyDescription: json['surveyDescription'] ?? '',
      totalQuestions: json['totalQuestions'] ?? 0,
      reward: json['reward']?.toString() ?? '0',
      targetNumber: json['Target_number'] is String
          ? int.parse(json['Target_number'])
          : (json['Target_number'] ?? 0),
      winningNumber: json['winning_number'] is String
          ? int.parse(json['winning_number'])
          : (json['winning_number'] ?? 0),
      price: json['price']?.toString() ?? '0',
      questions: questionList,
      targetConditions:
          SurveyTargetConditions.fromJson(json['targetConditions'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isEnded: json['isEnded'] ?? false,
      currentResponses: json['currentResponses'] ?? 0,
      status: json['status'] ?? '진행중',
    );
  }

  Map<String, dynamic> toJson() => {
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

  // 설문이 마감되었는지 확인하는 getter
  bool get isExpired {
    final deadline = createdAt.add(const Duration(days: 30));
    return DateTime.now().isAfter(deadline);
  }

  // 목표 인원이 달성되었는지 확인하는 getter
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
