import 'package:app/design/colors.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/screen/my_surveyState_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';

class MySurveysScreen extends StatefulWidget {
  const MySurveysScreen({super.key});

  @override
  State<MySurveysScreen> createState() => _MySurveysScreenState();
}

class _MySurveysScreenState extends State<MySurveysScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내가 작성한 설문',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.third,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.third,
          tabs: const [
            Tab(text: '진행중'),
            Tab(text: '종료됨'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSurveyList(isActive: true),
          _buildSurveyList(isActive: false),
        ],
      ),
    );
  }

  Widget _buildSurveyList({required bool isActive}) {
    return FutureBuilder<List<Survey>>(
      future: apiService.getSurveyList(), // TODO: getMySurveys API 만들기
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('작성한 설문이 없습니다.'),
          );
        }

        // 진행중/종료된 설문 필터링
        final surveys = snapshot.data!
            .where((survey) => isActive ? !survey.isEnded : survey.isEnded)
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surveys.length,
          itemBuilder: (context, index) {
            final survey = surveys[index];
            return _buildSurveyCard(survey);
          },
        );
      },
    );
  }

  Widget _buildSurveyCard(Survey survey) {
    // 진행률 계산 함수
    double getProgress() {
      if (survey.targetNumber <= 0) return 0.0;
      return (survey.currentResponses / survey.targetNumber).clamp(0.0, 1.0);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    survey.surveyTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'D-${survey.isExpired ? '0' : survey.createdAt.difference(DateTime.now()).inDays.abs()}',
                    style: const TextStyle(
                      color: AppColors.third,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: getProgress(),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.third),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${survey.currentResponses}/${survey.targetNumber}명 참여',
                  style: const TextStyle(color: Colors.grey),
                ),
                TextButton.icon(
                  onPressed: () {
                    // TODO: 통계 화면으로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurveyStatsScreen(
                          survey: survey,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('통계 보기'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.third,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
