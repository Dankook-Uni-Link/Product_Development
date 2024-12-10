import 'dart:math';

import 'package:app/design/colors.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/screen/survey_detail.dart';
import 'package:app/services/api_service.dart';
import 'package:app/widget/bottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiService apiService = ApiService();
  bool isEnded = false;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            expandedHeight: 135.0,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Sur문",
                        style: GoogleFonts.blackHanSans(
                            fontSize: 40,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            shadows: [
                              Shadow(
                                color: const Color.fromARGB(255, 80, 80, 80)
                                    .withOpacity(0.5),
                                offset: const Offset(2, 2),
                                blurRadius: 4,
                              ),
                            ])),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 45,
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Color.fromARGB(50, 0, 0, 0),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                ),
                              ],
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppColors.secondary,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 0.0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 48,
                          height: 60,
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(50, 0, 0, 0),
                                blurRadius: 4,
                                offset: Offset(0, 0),
                              ),
                            ],
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              // 전환 버튼 클릭 시의 동작을 정의합니다.
                            },
                            child: const Icon(Icons.tune, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return FutureBuilder<List<Survey>>(
                  future: apiService.getSurveyList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 60, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              '데이터를 불러올 수 없습니다.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('등록된 설문이 없습니다.'),
                      );
                    }

                    List<Survey> surveys = snapshot.data!;
                    surveys = surveys
                        .where((survey) =>
                            survey.surveyTitle.contains(searchQuery))
                        .toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: surveys.length,
                      itemBuilder: (context, index) {
                        final survey = surveys[index];
                        return SurveyCard(
                          survey: survey,
                          imageUrl: 'assets/thumbnail${index + 1}.jpg',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SurveyDetailScreen(survey: survey),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class SurveyCard extends StatelessWidget {
  final Survey survey;
  final VoidCallback onTap;
  final String imageUrl;

  const SurveyCard({
    super.key,
    required this.survey,
    required this.onTap,
    required this.imageUrl,
  });

  String _getRemainingDays() {
    final remaining = survey.expiresAt.difference(DateTime.now()).inDays;
    return 'D-$remaining';
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.third.withOpacity(0.8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            survey.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: survey.isEnded
                                  ? Colors.grey
                                  : AppColors.third,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              survey.statusText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: survey.getProgress(),
                  backgroundColor: Colors.grey[300],
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.third),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${survey.currentResponses}/${survey.targetResponses}명 참여',
                      style: const TextStyle(color: AppColors.third),
                    ),
                    Text(
                      _getRemainingDays(),
                      style: const TextStyle(color: AppColors.third),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...survey.targetConditions.ageRanges
                        .map((age) => _buildChip(age)),
                    ...survey.targetConditions.genders
                        .map((gender) => _buildChip(gender)),
                    ...survey.targetConditions.locations
                        .map((loc) => _buildChip(loc)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '총 문항: ${survey.totalQuestions}개',
                      style: const TextStyle(color: AppColors.third),
                    ),
                    Text(
                      '리워드: ${survey.reward}P',
                      style: const TextStyle(
                        color: AppColors.third,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
