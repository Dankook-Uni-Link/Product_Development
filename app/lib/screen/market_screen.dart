import 'dart:math';
import 'package:app/design/colors.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/models/gifticon_model.dart'; // 기프티콘 모델 임포트
import 'package:app/screen/survey_detail.dart';
import 'package:app/screen/survey_sell_description.dart';
import 'package:app/services/api_service.dart';
import 'package:app/widget/bottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  ApiService apiService = ApiService();
  bool isEnded = false;
  String searchQuery = "";
  bool showSurveys = true; // 리스트 전환을 위한 변수 추가

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: false,
            floating: false,
            expandedHeight: 135.0,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("설문 결과 판매",
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
                                  color: Color.fromARGB(70, 0, 0, 0),
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
                                fillColor: Colors.grey[200],
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
                                color: Color.fromARGB(70, 0, 0, 0),
                                blurRadius: 4,
                                offset: Offset(0, 0),
                              ),
                            ],
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                showSurveys = !showSurveys; // 버튼 클릭 시 리스트 전환
                              });
                            },
                            child: Icon(
                                showSurveys
                                    ? Icons.create_new_folder_outlined
                                    : Icons.wallet_giftcard,
                                color: Colors.black),
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
                return FutureBuilder<List<dynamic>>(
                  future: showSurveys
                      ? apiService.getSurveyList()
                      : apiService.getGifticonList(), // 상태에 따라 다른 데이터를 가져옴
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No data found.'));
                    } else {
                      List<dynamic> items = snapshot.data!;
                      items = items.where((item) {
                        return showSurveys
                            ? (item as Survey).surveyTitle.contains(searchQuery)
                            : (item as Gifticon)
                                .productName
                                .contains(searchQuery);
                      }).toList();
                      if (showSurveys) {
                        return Column(
                          children: items.map((item) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: SurveyCard(
                                title: (item as Survey).surveyTitle,
                                total_questions: item.totalQuestions,
                                reward: item.reward,
                                deadline: 'D-7',
                                imageUrl: 'assets/sell2.jpg',
                                price: item.price,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                              Survey_sell_DetailScreen(
                                                  title: item.surveyTitle),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                              ),
                            );
                          }).toList(),
                        );
                      } else {
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 2열로 표시
                            childAspectRatio: 0.7,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index] as Gifticon;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GifticonCard(
                                storeName: item.storeName,
                                productName: item.productName,
                                imageUrl: item.imageUrl,
                                price: item.price,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (context, animation1, animation2) =>
                                              Survey_sell_DetailScreen(
                                                  title: item.productName),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }
                    }
                  },
                );
              },
              childCount: 1,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
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
  final String price;

  const SurveyCard({
    super.key,
    required this.title,
    required this.total_questions,
    required this.reward,
    required this.deadline,
    required this.onTap,
    required this.imageUrl,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 358,
        height: 134,
        decoration: BoxDecoration(
          color: Colors.grey[200],
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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('가격: $price',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
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

class GifticonCard extends StatelessWidget {
  final String storeName;
  final String productName;
  final String imageUrl;
  final String price;
  final VoidCallback onTap;

  const GifticonCard({
    super.key,
    required this.storeName,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              storeName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(productName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '가격: $price',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
