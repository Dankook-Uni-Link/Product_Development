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
                    child: Text("딩굴",
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
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No survey data found.'));
                    } else {
                      List<Survey> surveys = snapshot.data!;
                      surveys = surveys
                          .where((survey) =>
                              survey.surveyTitle.contains(searchQuery))
                          .toList();
                      return Column(
                        children: surveys.map((survey) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SurveyCard(
                              title: survey.surveyTitle,
                              total_questions: survey.totalQuestions,
                              reward: survey.reward,
                              deadline: 'D-7',
                              imageUrl:
                                  'assets/thumbnail${surveys.indexOf(survey)}.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (context, animation1, animation2) =>
                                            SurveyDetailScreen(survey: survey),
                                    transitionDuration: Duration.zero,
                                    reverseTransitionDuration: Duration.zero,
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }
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
  final String title;
  final int total_questions;
  final String reward;
  final String deadline;
  final VoidCallback onTap;
  final String imageUrl;

  const SurveyCard({
    super.key,
    required this.title,
    required this.total_questions,
    required this.reward,
    required this.deadline,
    required this.onTap,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 358,
        height: 134,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(50, 0, 0, 0),
              blurRadius: 4,
              offset: Offset(0, 0),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('총 문항 수: $total_questions',
                      style: const TextStyle(color: AppColors.third)),
                  const SizedBox(
                    height: 4,
                  ),
                  Text('리워드: $reward',
                      style: const TextStyle(color: AppColors.third)),
                  const SizedBox(height: 4),
                  Text('마감: $deadline',
                      style: const TextStyle(color: AppColors.third)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey,
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
