// import 'package:app/models/question.dart';

// class Survey {
//   final String surveyTitle;
//   final String surveyDescription;
//   final int totalQuestions;
//   final String reward;
//   final int targetNumber;
//   final int winningNumber;
//   final List<Question> questions;

//   Survey({
//     required this.surveyTitle,
//     required this.surveyDescription,
//     required this.totalQuestions,
//     required this.reward,
//     required this.targetNumber,
//     required this.winningNumber,
//     required this.questions,
//   });

//   factory Survey.fromJson(Map<String, dynamic> json) {
//     var questionsFromJson = json['questions'] as List;
//     List<Question> questionList = questionsFromJson
//         .map((question) => Question.fromJson(question))
//         .toList();

//     return Survey(
//       surveyTitle: json['surveyTitle'],
//       surveyDescription: json['surveyDescription'],
//       totalQuestions: json['totalQuestions'],
//       reward: json['reward'],
//       targetNumber: json['Target_number'],
//       winningNumber: json['winning_number'],
//       questions: questionList,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     List<Map<String, dynamic>> questionsToJson =
//         questions.map((question) => question.toJson()).toList();

//     return {
//       'surveyTitle': surveyTitle,
//       'surveyDescription': surveyDescription,
//       'totalQuestions': totalQuestions,
//       'reward': reward,
//       'Target_number': targetNumber,
//       'winning_number': winningNumber,
//       'questions': questionsToJson,
//     };
//   }
// }
class Survey {
  final String surveyTitle;
  final String surveyDescription;
  final int totalQuestions;
  final String reward;
  final int targetNumber;
  final int winningNumber;
  final List<Question> questions;
  final String price;

  Survey({
    required this.surveyTitle,
    required this.surveyDescription,
    required this.totalQuestions,
    required this.reward,
    required this.targetNumber,
    required this.winningNumber,
    required this.questions,
    required this.price,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    var questionsFromJson = json['questions'] as List;
    List<Question> questionList = questionsFromJson
        .map((question) => Question.fromJson(question))
        .toList();

    return Survey(
      surveyTitle: json['surveyTitle'],
      surveyDescription: json['surveyDescription'],
      totalQuestions: json['totalQuestions'],
      reward: json['reward'],
      targetNumber: json['Target_number'],
      winningNumber: json['winning_number'],
      price: json['price'],
      questions: questionList,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> questionsToJson =
        questions.map((question) => question.toJson()).toList();

    return {
      'surveyTitle': surveyTitle,
      'surveyDescription': surveyDescription,
      'totalQuestions': totalQuestions,
      'reward': reward,
      'Target_number': targetNumber,
      'winning_number': winningNumber,
      'price': price,
      'questions': questionsToJson,
    };
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
