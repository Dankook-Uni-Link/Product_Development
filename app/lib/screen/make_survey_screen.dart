import 'package:app/design/colors.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/services/api_service.dart';
import 'package:app/widget/bottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MakeSurveyScreen extends StatefulWidget {
  const MakeSurveyScreen({super.key});

  @override
  State<MakeSurveyScreen> createState() => _MakeSurveyScreenState();
}

// 설문 문항 데이터 클래스
class QuestionData {
  String question;
  String type;
  List<String> options;

  QuestionData({
    required this.question,
    required this.type,
    required this.options,
  });
}

class _MakeSurveyScreenState extends State<MakeSurveyScreen> {
  int currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  int userPoints = 1000; // 초기 포인트 1000

  // Step 1 controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetNumberController = TextEditingController();
  final _rewardController = TextEditingController();

  // Step 2 controllers
  final List<String> _selectedAgeRanges = [];
  final List<String> _selectedGenders = [];
  final List<String> _selectedLocations = [];
  final List<String> _selectedOccupations = [];

  // Step 3 controllers
  final List<QuestionData> _questions = [];
  final _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  String _selectedQuestionType = 'single_choice';

  // Available options
  final List<String> ageRanges = ['10대', '20대', '30대', '40대', '50대', '60대 이상'];
  final List<String> genders = ['남성', '여성'];
  final List<String> locations = [
    '서울',
    '경기',
    '인천',
    '강원',
    '충청',
    '전라',
    '경상',
    '제주'
  ];
  final List<String> occupations = [
    '대학생',
    '직장인',
    '자영업자',
    '전문직',
    '주부',
    '무직',
    '기타'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetNumberController.dispose();
    _rewardController.dispose();
    super.dispose();
  }

  Widget buildTargetConditionSection({
    required String title,
    required List<String> options,
    required List<String> selectedOptions,
    required Function(String) onToggle,
    bool isSingleChoice = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.third,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            bool isSelected = selectedOptions.contains(option);
            if (isSingleChoice) {
              isSelected =
                  selectedOptions.isNotEmpty && selectedOptions.first == option;
            }
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (bool selected) {
                if (isSingleChoice) {
                  if (selected) {
                    onToggle(option);
                  }
                } else {
                  onToggle(option);
                }
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.option_fill,
              checkmarkColor: AppColors.third,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.third : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget buildStep1() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '기본 정보 입력',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.third,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '설문 제목',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.third),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.third, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '설문 제목을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '설문 설명',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.third),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.third, width: 2),
                ),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '설문 설명을 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetNumberController,
                    decoration: InputDecoration(
                      labelText: '목표 인원',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.third),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.third, width: 2),
                      ),
                      suffixText: '명',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '목표 인원을 입력해주세요';
                      }
                      if (int.parse(value) < 1) {
                        return '1명 이상 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _rewardController,
                    decoration: InputDecoration(
                      labelText: '1인당 보상',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.third),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.third, width: 2),
                      ),
                      suffixText: 'P',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '보상 포인트를 입력해주세요';
                      }
                      if (int.parse(value) < 100) {
                        return '최소 100P 이상';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      currentStep = 1; // Move to next step
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.third,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('다음 단계', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 새로운 문항 추가를 위한 다이얼로그
  Future<void> _showAddQuestionDialog() async {
    _questionController.clear();
    _optionControllers.clear();
    _optionControllers.add(TextEditingController());
    _optionControllers.add(TextEditingController());
    _selectedQuestionType = 'single_choice';

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('새 문항 추가'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(
                        labelText: '질문',
                        hintText: '질문을 입력하세요',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      value: _selectedQuestionType,
                      items: const [
                        DropdownMenuItem(
                          value: 'single_choice',
                          child: Text('단일 선택'),
                        ),
                        DropdownMenuItem(
                          value: 'multiple_choice',
                          child: Text('복수 선택'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedQuestionType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('선택지:'),
                    ...List.generate(
                      _optionControllers.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _optionControllers[index],
                                decoration: InputDecoration(
                                  labelText: '선택지 ${index + 1}',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: _optionControllers.length <= 2
                                  ? null
                                  : () {
                                      setState(() {
                                        _optionControllers.removeAt(index);
                                      });
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _optionControllers.add(TextEditingController());
                        });
                      },
                      child: const Text('선택지 추가'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('추가'),
                  onPressed: () {
                    if (_questionController.text.isNotEmpty &&
                        _optionControllers.every(
                            (controller) => controller.text.isNotEmpty)) {
                      this.setState(() {
                        _questions.add(QuestionData(
                          question: _questionController.text,
                          type: _selectedQuestionType,
                          options: _optionControllers
                              .map((controller) => controller.text)
                              .toList(),
                        ));
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildStep4() {
    // 총 필요 포인트 계산
    int totalPoints = int.parse(_rewardController.text) *
        int.parse(_targetNumberController.text);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '설문 미리보기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.third,
            ),
          ),
          const SizedBox(height: 24),

          // 기본 정보 섹션
          _buildPreviewSection(
            title: '기본 정보',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제목: ${_titleController.text}'),
                const SizedBox(height: 8),
                Text('설명: ${_descriptionController.text}'),
                const SizedBox(height: 8),
                Text('목표 인원: ${_targetNumberController.text}명'),
                Text('1인당 보상: ${_rewardController.text}P'),
                Text('총 필요 포인트: ${totalPoints}P',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: AppColors.third)),
              ],
            ),
          ),

          // 대상자 조건 섹션
          _buildPreviewSection(
            title: '대상자 조건',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('나이대: ${_selectedAgeRanges.join(", ")}'),
                Text(
                    '성별: ${_selectedGenders.isEmpty ? "제한 없음" : _selectedGenders.join(", ")}'),
                Text('지역: ${_selectedLocations.join(", ")}'),
                Text('직업: ${_selectedOccupations.join(", ")}'),
              ],
            ),
          ),

          // 설문 문항 미리보기
          _buildPreviewSection(
            title: '설문 문항',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_questions.length, (index) {
                final question = _questions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${index + 1}. ${question.question}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...question.options.map((option) => Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, bottom: 4.0),
                            child: Row(
                              children: [
                                question.type == 'single_choice'
                                    ? const Icon(Icons.radio_button_unchecked,
                                        size: 20)
                                    : const Icon(Icons.check_box_outline_blank,
                                        size: 20),
                                const SizedBox(width: 8),
                                Text(option),
                              ],
                            ),
                          )),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 2;
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.third,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: AppColors.third),
                  ),
                ),
                child: const Text('이전', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      int totalPoints = int.parse(_rewardController.text) *
                          int.parse(_targetNumberController.text);

                      return StatefulBuilder(
                          // StatefulBuilder 추가하여 다이얼로그 내 상태 관리
                          builder: (context, setDialogState) {
                        return AlertDialog(
                          title: const Text('포인트 결제'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '총 필요 포인트: ${totalPoints}P',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.third),
                              ),
                              const SizedBox(height: 16),
                              Text('현재 보유 포인트: ${userPoints}P',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      userPoints += 10000;
                                    });
                                    setState(() {
                                      userPoints += 10000;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('10000P가 충전되었습니다.'),
                                        backgroundColor: AppColors.third,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('포인트 구매 (+10000P)'),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('취소',
                                  style: TextStyle(color: Colors.grey)),
                            ),
                            ElevatedButton(
                              onPressed: userPoints >= totalPoints
                                  ? () async {
                                      final currentContext =
                                          context; // context를 지역 변수로 저장
                                      try {
                                        final apiService = ApiService();
                                        final survey = Survey(
                                          id: null, // 새로 만드는 설문이므로 null
                                          surveyTitle: _titleController.text,
                                          surveyDescription:
                                              _descriptionController.text,
                                          totalQuestions: _questions.length,
                                          reward: _rewardController.text,
                                          targetNumber: int.parse(
                                              _targetNumberController.text),
                                          winningNumber: int.parse(
                                              _targetNumberController.text),
                                          questions: _questions
                                              .map((questionData) => Question(
                                                    question:
                                                        questionData.question,
                                                    type: questionData.type,
                                                    options:
                                                        questionData.options,
                                                  ))
                                              .toList(),
                                          price: totalPoints.toString(),
                                          targetConditions:
                                              SurveyTargetConditions(
                                            ageRanges: _selectedAgeRanges,
                                            genders: _selectedGenders,
                                            locations: _selectedLocations,
                                            occupations: _selectedOccupations,
                                          ),
                                          createdAt: DateTime.now(), // 현재 시간
                                          isEnded: false, // 새로 만드는 설문은 진행중
                                          currentResponses: 0, // 응답자 0명으로 시작
                                          status: "진행중", // 상태는 진행중으로 시작
                                        );

                                        await apiService.createSurvey(
                                          title: _titleController.text,
                                          description:
                                              _descriptionController.text,
                                          targetNumber: int.parse(
                                              _targetNumberController.text),
                                          rewardPerPerson:
                                              int.parse(_rewardController.text),
                                          targetConditions:
                                              SurveyTargetConditions(
                                            ageRanges: _selectedAgeRanges,
                                            genders: _selectedGenders,
                                            locations: _selectedLocations,
                                            occupations: _selectedOccupations,
                                          ),
                                          questions: _questions,
                                        );

                                        setState(() {
                                          userPoints -= totalPoints;
                                        });

                                        if (!mounted) {
                                          return; // 위젯이 여전히 존재하는지 확인
                                        }
                                        Navigator.pop(currentContext);
                                        ScaffoldMessenger.of(currentContext)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('설문이 성공적으로 등록되었습니다.'),
                                            backgroundColor: AppColors.third,
                                          ),
                                        );
                                        Navigator.pop(currentContext);
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(currentContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('설문 등록에 실패했습니다: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.third,
                              ),
                              child: Text(userPoints >= totalPoints
                                  ? '결제하기'
                                  : '포인트 부족'),
                            ),
                          ],
                        );
                      });
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.third,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('설문 게시하기', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewSection({
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.third,
            ),
          ),
          const Divider(height: 24),
          content,
        ],
      ),
    );
  }

  Widget buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '설문 문항 작성',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.third,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showAddQuestionDialog,
                icon: const Icon(Icons.add),
                label: const Text('문항 추가'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.third,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_questions.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  '문항을 추가해주세요',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final question = _questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Q${index + 1}.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  _questions.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: question.options.map((option) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(option),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.type == 'single_choice' ? '단일 선택' : '복수 선택',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.third,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: AppColors.third),
                  ),
                ),
                child: const Text('이전', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: _questions.isNotEmpty
                    ? () {
                        setState(() {
                          currentStep = 3;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.third,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('다음 단계', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대상자 조건 설정',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.third,
            ),
          ),
          const SizedBox(height: 24),
          buildTargetConditionSection(
            title: '나이대 (복수 선택 가능)',
            options: ageRanges,
            selectedOptions: _selectedAgeRanges,
            onToggle: (option) {
              setState(() {
                if (_selectedAgeRanges.contains(option)) {
                  _selectedAgeRanges.remove(option);
                } else {
                  _selectedAgeRanges.add(option);
                }
              });
            },
          ),
          buildTargetConditionSection(
            title: '성별 (복수 선택 가능)', // 제목 수정
            options: genders,
            selectedOptions: _selectedGenders, // List로 변경
            onToggle: (option) {
              setState(() {
                if (_selectedGenders.contains(option)) {
                  _selectedGenders.remove(option);
                } else {
                  _selectedGenders.add(option);
                }
              });
            },
            // isSingleChoice 파라미터 제거
          ),
          buildTargetConditionSection(
            title: '지역 (복수 선택 가능)',
            options: locations,
            selectedOptions: _selectedLocations,
            onToggle: (option) {
              setState(() {
                if (_selectedLocations.contains(option)) {
                  _selectedLocations.remove(option);
                } else {
                  _selectedLocations.add(option);
                }
              });
            },
          ),
          buildTargetConditionSection(
            title: '직업 (복수 선택 가능)',
            options: occupations,
            selectedOptions: _selectedOccupations,
            onToggle: (option) {
              setState(() {
                if (_selectedOccupations.contains(option)) {
                  _selectedOccupations.remove(option);
                } else {
                  _selectedOccupations.add(option);
                }
              });
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 0;
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.third,
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: const BorderSide(color: AppColors.third),
                  ),
                ),
                child: const Text('이전', style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: _selectedAgeRanges.isNotEmpty &&
                        _selectedLocations.isNotEmpty &&
                        _selectedOccupations.isNotEmpty // 성별 조건 제거
                    ? () {
                        setState(() {
                          currentStep = 2;
                        });
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.third,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('다음 단계', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설문 만들기',
            style:
                TextStyle(color: AppColors.third, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.third),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 4,
                        decoration: BoxDecoration(
                          color: i == currentStep
                              ? AppColors.third
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (currentStep == 0) buildStep1(),
            if (currentStep == 1) buildStep2(),
            if (currentStep == 2) buildStep3(),
            if (currentStep == 3) buildStep4(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}
