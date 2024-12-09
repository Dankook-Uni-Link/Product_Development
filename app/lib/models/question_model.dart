class Question {
  final int id;
  final int surveyId;
  final String content;
  final QuestionType type;
  final List<String> options;
  final int order;

  Map<String, dynamic> toJson() => {
        'id': id,
        'survey_id': surveyId,
        'content': content,
        'type': type.toString(),
        'options': options,
        'order': order
      };
}

enum QuestionType { singleChoice, multipleChoice }
