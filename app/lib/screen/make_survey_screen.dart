// import 'package:app/screen/home_screen.dart';
// import 'package:app/screen/mypage.dart';
// import 'package:app/widget/bottomNavbar.dart';
// import 'package:flutter/material.dart';

// class MakeSurveyScreen extends StatelessWidget {
//   const MakeSurveyScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Survey Screen'),
//       ),
//       body: const Center(
//         child: Text('This is the survey screen'),
//       ),
//       bottomNavigationBar: const BottomNavBar(currentIndex: 4),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/design/colors.dart';
import 'package:app/services/api_service.dart';

class MakeSurveyScreen extends StatefulWidget {
  const MakeSurveyScreen({super.key});

  @override
  _SurveyCreateScreenState createState() => _SurveyCreateScreenState();
}

class _SurveyCreateScreenState extends State<MakeSurveyScreen> {
  ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  String surveyTitle = '';
  int totalQuestions = 1;
  String reward = '';
  String deadline = '';
  
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
                      return '제목을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 총 문항 수 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '총 문항 수',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.secondary,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      totalQuestions = int.tryParse(value) ?? 1;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '문항 수를 입력해주세요.';
                    }
                    if (int.tryParse(value) == null) {
                      return '올바른 문항 수를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 리워드 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '리워드',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.secondary,
                  ),
                  onChanged: (value) {
                    setState(() {
                      reward = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '리워드를 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 마감일 입력 필드
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '마감일 (예: 2024-12-31)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: AppColors.secondary,
                  ),
                  onChanged: (value) {
                    setState(() {
                      deadline = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '마감일을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // 서베이 생성 버튼
                ElevatedButton(
                  onPressed: _createSurvey,
                  style: ElevatedButton.styleFrom(
                    // primary: AppColors.secondary,
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
        final result = await apiService.createSurvey(
          surveyTitle,
          totalQuestions,
          reward,
          deadline,
        );

        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('서베이가 성공적으로 생성되었습니다.')),
          );
          Navigator.pop(context);  // 뒤로 가기
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
}


