import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/design/colors.dart';
import 'package:app/services/api_service.dart';

class CreateSurveyScreen extends StatefulWidget {
  const CreateSurveyScreen({super.key});

  @override
  _SurveyCreateScreenState createState() => _SurveyCreateScreenState();
}

class _SurveyCreateScreenState extends State<CreateSurveyScreen> {
  ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String surveyTitle = '';

  // 질문 필드 관리
  final List<TextEditingController> _questionControllers = [];
  final List<GlobalKey<FormState>> _questionFormKeys = [];

  @override
  void initState() {
    super.initState();
    _addSurveyField(); // 기본 하나의 질문 필드 추가
  }

  // 새로운 질문 필드 추가
  void _addSurveyField() {
    setState(() {
      _questionControllers.add(TextEditingController());
      _questionFormKeys.add(GlobalKey<FormState>());
    });
  }

  // 질문 필드 삭제
  void _removeSurveyField(int index) {
    setState(() {
      _questionControllers[index].dispose();
      _questionControllers.removeAt(index);
      _questionFormKeys.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          '서베이 생성',
          style: GoogleFonts.blackHanSans(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 서베이 제목 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '서베이 제목',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.secondary,
                  ),
                  onChanged: (value) {
                    setState(() {
                      surveyTitle = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '서베이 제목을 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // 동적 질문 입력 필드
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _questionControllers.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              controller: _questionControllers[index],
                              decoration: InputDecoration(
                                labelText: '질문 ${index + 1}',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: AppColors.secondary,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '질문을 입력하세요.';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeSurveyField(index),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 질문 추가 버튼
                ElevatedButton(
                  onPressed: _addSurveyField,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    '+ 질문 추가',
                    style: GoogleFonts.blackHanSans(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 32),

                // 서베이 생성 버튼
                ElevatedButton(
                  onPressed: _createSurvey,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    '서베이 생성',
                    style: GoogleFonts.blackHanSans(fontSize: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 서베이 생성 로직
  Future<void> _createSurvey() async {
    if (_formKey.currentState!.validate()) {
      try {
        final surveyQuestions = _questionControllers.map((c) => c.text).toList();
        final result = await apiService.newcreateSurvey(
          surveyTitle,
          surveyQuestions, // 각 질문 전달
        );

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('서베이가 성공적으로 생성되었습니다.')),
          );
          Navigator.pop(context); // 뒤로 가기
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('서베이 생성 실패: ${result.message}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류 발생: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _questionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
