import 'package:app/design/colors.dart';
import 'package:app/models/question_model.dart';
import 'package:app/models/survey_model.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

// survey_screen.dart
class SurveyScreen extends StatefulWidget {
  final Survey survey;

  const SurveyScreen({super.key, required this.survey});

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  Map<int, List<String>> selectedOptions = {};
  int currentQuestionIndex = 0;
  bool showRatingPage = false;
  String? selectedEmoji;

  void nextQuestion() {
    setState(() {
      if (currentQuestionIndex < widget.survey.questions.length - 1) {
        currentQuestionIndex++;
      } else {
        showRatingPage = true;
      }
    });
  }

  void selectEmoji(String emoji) {
    setState(() {
      selectedEmoji = emoji;
      Future.delayed(const Duration(seconds: 2), () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('감사합니다!'),
              content: const Text('설문에 응해주셔서 감사합니다!\n마이페이지에서 리워드를 확인해 보세요!!'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
            );
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showRatingPage) {
      return _buildRatingPage();
    }

    Question currentQuestion = widget.survey.questions[currentQuestionIndex];
    bool isSingleChoice = currentQuestion.type == QuestionType.singleChoice;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(widget.survey.title,
            style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 16.0, right: 16.0, top: 5, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Question ${currentQuestionIndex + 1}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              currentQuestion.content,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ...currentQuestion.options
                      .map((option) => _buildOptionItem(
                            option: option,
                            isSingleChoice: isSingleChoice,
                          ))
                      .toList(),
                ],
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed:
                    (selectedOptions[currentQuestionIndex]?.isNotEmpty ?? false)
                        ? nextQuestion
                        : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.third,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                    currentQuestionIndex == widget.survey.questions.length - 1
                        ? '완료'
                        : '다음'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(
      {required String option, required bool isSingleChoice}) {
    bool isSelected =
        selectedOptions[currentQuestionIndex]?.contains(option) ?? false;

    return GestureDetector(
      onTap: () => _handleOptionSelection(option, isSingleChoice),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.option_fill : Colors.white,
          border: Border.all(color: AppColors.option_border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (isSingleChoice)
              Radio<String>(
                value: option,
                groupValue: selectedOptions[currentQuestionIndex]?.firstOrNull,
                onChanged: (value) => _handleOptionSelection(value!, true),
              )
            else
              Checkbox(
                value: isSelected,
                onChanged: (value) => _handleOptionSelection(option, false),
              ),
            Expanded(
              child: Text(
                option,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOptionSelection(String option, bool isSingleChoice) {
    setState(() {
      if (isSingleChoice) {
        selectedOptions[currentQuestionIndex] = [option];
      } else {
        selectedOptions[currentQuestionIndex] =
            (selectedOptions[currentQuestionIndex] ?? [])..add(option);
      }
    });
  }

  Widget _buildRatingPage() {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (selectedEmoji != null)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                top: selectedEmoji != null
                    ? MediaQuery.of(context).size.height / 2 - 50
                    : MediaQuery.of(context).size.height / 2 - 150,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 500),
                  scale: selectedEmoji != null ? 3.0 : 1.0,
                  child: Opacity(
                    opacity: selectedEmoji != null ? 0.5 : 1.0,
                    child: Image.asset(
                      'assets/$selectedEmoji.gif',
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '마지막 질문이에요!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  '설문은 맘에 드셨나요?',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEmojiOption('upset', '별로예요'),
                    _buildEmojiOption('hmm', '보통이에요'),
                    _buildEmojiOption('happy', '좋아요'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiOption(String emoji, String label) {
    return GestureDetector(
      onTap: () => selectEmoji(emoji),
      child: Column(
        children: [
          Image.asset(
            'assets/$emoji.gif',
            width: 60,
            height: 60,
          ),
          Text(label),
        ],
      ),
    );
  }
}
