// models/question_model.dart
class Question {
  final int? id;
  final String question;
  final QuestionType type; // 다시 QuestionType으로 변경
  final List<String> options;
  final int order;

  Question({
    this.id,
    required this.question,
    required this.type,
    required this.options,
    this.order = 0,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      question: json['question'] ?? '',
      type: _parseQuestionType(json['type']), // 문자열을 QuestionType으로 변환
      options: List<String>.from(json['options'] ?? []),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'question': question,
        'type': type
            .toString()
            .split('.')
            .last
            .toLowerCase(), // QuestionType을 문자열로 변환
        'options': options,
        'order': order,
      };

  // 문자열을 QuestionType으로 변환하는 헬퍼 메서드
  static QuestionType _parseQuestionType(String? type) {
    switch (type?.toLowerCase()) {
      case 'multiple':
        return QuestionType.multipleChoice;
      case 'single':
      default:
        return QuestionType.singleChoice;
    }
  }

  // Question 객체를 복제하는 메서드 추가
  Question toQuestion() {
    return Question(
      id: id,
      question: question,
      type: type,
      options: options,
      order: order,
    );
  }
}

enum QuestionType { singleChoice, multipleChoice }
