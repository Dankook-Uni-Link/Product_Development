import 'package:app/design/colors.dart';
import 'package:app/models/survey_model.dart';
import 'package:flutter/material.dart';
import 'survey_screen.dart';

// survey_detail.dart
class SurveyDetailScreen extends StatelessWidget {
  final Survey survey;

  const SurveyDetailScreen({super.key, required this.survey});

  Widget _buildInfoCard(String title, Widget content) {
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
              fontSize: 16,
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

  Widget _buildTargetChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.third.withOpacity(0.8),
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          survey.title,
          style: const TextStyle(
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
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              "설문 정보",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(survey.description),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('총 문항: ${survey.totalQuestions}개'),
                      Text(
                        '리워드: ${survey.reward}P',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.third,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildInfoCard(
              "진행 상황",
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: survey.getProgress(),
                    backgroundColor: Colors.grey[200],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.third),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${survey.currentResponses}/${survey.targetResponses}명 참여',
                        style: const TextStyle(color: AppColors.third),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: survey.isEnded ? Colors.grey : AppColors.third,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          survey.isExpired
                              ? 'D-0'
                              : 'D-${survey.expiresAt.difference(DateTime.now()).inDays}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildInfoCard(
              "대상자 조건",
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...survey.targetConditions.ageRanges
                      .map((age) => _buildTargetChip(age)),
                  ...survey.targetConditions.genders
                      .map((gender) => _buildTargetChip(gender)),
                  ...survey.targetConditions.locations
                      .map((loc) => _buildTargetChip(loc)),
                  ...survey.targetConditions.occupations
                      .map((occ) => _buildTargetChip(occ)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: survey.isEnded
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SurveyScreen(survey: survey),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.third,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  '참여하기',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
