import 'package:app/design/colors.dart';
import 'package:app/models/question_model.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SurveyStatsScreen extends StatelessWidget {
  final Survey survey;

  const SurveyStatsScreen({
    super.key,
    required this.survey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '설문 통계',
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
      ),
      body: FutureBuilder<SurveyStats>(
        future: ApiService().getSurveyStats(survey.id), // API 추가 필요
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 응답 현황 요약 카드
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey.surveyTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: survey.currentResponses / survey.targetNumber,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.third),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${survey.currentResponses}/${survey.targetNumber}명 참여',
                              style: const TextStyle(color: AppColors.third),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'D-${survey.isExpired ? "0" : survey.createdAt.difference(DateTime.now()).inDays.abs()}',
                                style: const TextStyle(
                                  color: AppColors.third,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 응답 현황 상세 정보
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: '목표 달성률',
                        value:
                            '${((survey.currentResponses / survey.targetNumber) * 100).toStringAsFixed(1)}%',
                        icon: Icons.flag,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: '예상 포인트',
                        value:
                            '${int.parse(survey.reward) * survey.currentResponses}P',
                        icon: Icons.attach_money,
                      ),
                    ),
                  ],
                ),
                _buildQuestionStats(snapshot.data!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.third),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionStats(SurveyStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            '질문별 통계',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...stats.questions.entries
            .map((entry) => _buildQuestionCard(
                  questionId: entry.key,
                  stats: entry.value,
                  survey: survey, // survey 전달
                ))
            .toList(),
      ],
    );
  }

  Widget _buildQuestionCard(
      {required String questionId,
      required QuestionStats stats,
      required Survey survey}) {
    // questionId가 "0"부터 시작하는지 "1"부터 시작하는지 확인
    print('QuestionId (raw): $questionId');
    print('All questions:');
    for (var q in survey.questions) {
      print('Order: ${q.order}, Type: ${q.type}, Content: ${q.content}');
    }

    // questionId를 인덱스로 사용하여 질문 찾기 (0-based)
    final questionIndex = int.parse(questionId);
    final question = questionIndex < survey.questions.length
        ? survey.questions[questionIndex]
        : Question(
            content: 'Unknown Question',
            type: QuestionType.singleChoice,
            options: [],
            order: questionIndex,
          );

    print(
        'Selected question - Index: $questionIndex, Type: ${question.type}, Content: ${question.content}');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250, // 차트 높이 조정
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildChart(question.type, stats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(QuestionType type, QuestionStats stats) {
    if (type == QuestionType.singleChoice) {
      return PieChart(
        PieChartData(
          sectionsSpace: 3,
          centerSpaceRadius: 30,
          sections: _createPieChartSections(stats),
          pieTouchData: PieTouchData(enabled: true),
        ),
      );
    } else {
      return BarChart(
        BarChartData(
          maxY: stats.responses.values
                  .reduce((max, value) => max > value ? max : value)
                  .toDouble() *
              1.2,
          barGroups: _createBarGroups(stats.responses),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: const [5, 5],
              );
            },
          ),
          // 바 터치 효과 제거
          barTouchData: BarTouchData(
            enabled: true,
          ),
          // 세로축 숫자 간격 조정
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      stats.responses.keys.elementAt(value.toInt()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1.0, // 간격을 1로 설정
                getTitlesWidget: (value, meta) {
                  // 정수값만 표시
                  if (value == value.roundToDouble()) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );
    }
  }

  List<BarChartGroupData> _createBarGroups(Map<String, int> responses) {
    return responses.entries.map((entry) {
      final index = responses.keys.toList().indexOf(entry.key);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value.toDouble(),
            width: 30,
            color: const Color(0xFF5C6BC0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: responses.values
                  .reduce((max, value) => max > value ? max : value)
                  .toDouble(),
              color: Colors.grey[200],
            ),
          ),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  List<PieChartSectionData> _createPieChartSections(QuestionStats qStats) {
    final colors = [
      const Color(0xFF5C6BC0),
      const Color(0xFF66BB6A),
      const Color(0xFFFFB74D),
      const Color(0xFF9575CD),
      const Color(0xFF4DB6AC),
      const Color(0xFFF06292),
    ];

    final totalResponses =
        qStats.responses.values.fold<int>(0, (prev, value) => prev + value);

    return qStats.responses.entries.map((entry) {
      final index = qStats.responses.keys.toList().indexOf(entry.key);
      final value = entry.value;
      final percentage = (value / totalResponses) * 100;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80, // 크기 조정
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            entry.key,
            style: TextStyle(
              color: colors[index % colors.length],
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        badgePositionPercentageOffset: 1.2,
      );
    }).toList();
  }
}
