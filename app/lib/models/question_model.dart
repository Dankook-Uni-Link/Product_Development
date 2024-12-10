// models/question_model.dart
class Question {
  final int? id;
  final int? surveyId; // 새 질문 생성시에는 null
  final String content;
  final QuestionType type;
  final List<String> options;
  final int order;

  Question({
    this.id,
    this.surveyId,
    required this.content,
    required this.type,
    required this.options,
    required this.order,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      surveyId: json['surveyId'],
      content: json['content'],
      type: QuestionType.values
          .firstWhere((e) => e.toString() == 'QuestionType.${json['type']}'),
      options: List<String>.from(json['options']),
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (surveyId != null) 'surveyId': surveyId,
        'content': content,
        'type': type.toString().split('.').last,
        'options': options,
        'order': order,
      };
}

enum QuestionType { singleChoice, multipleChoice }
