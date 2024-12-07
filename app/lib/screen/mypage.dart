import 'package:app/design/colors.dart';
import 'package:app/screen/login_screen.dart'; 
import 'package:app/screen/gifticon_screen.dart';
import 'package:app/screen/home_screen.dart';
import 'package:app/screen/survey_screen.dart';
import 'package:app/widget/bottomNavbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page',
            style: GoogleFonts.lilitaOne(
              textStyle: const TextStyle(
                color: AppColors.third,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            )),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 로그아웃 버튼 추가
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: AppColors.third),
              onPressed: () {
                // 로그아웃 버튼을 누르면 로그인 페이지로 이동
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false, // 모든 기존 라우트 삭제
                );
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
                // ); // 로그아웃 (뒤로 가기 누르면 로그아웃 전 페이지 나옴)
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // User Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2F2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 70,
                    backgroundImage:
                        AssetImage('assets/thumbnail3.jpg'), // 예시 이미지
                  ),
                  SizedBox(height: 10),
                  Text(
                    '홍길동',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '포인트: 1000p',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.third,
                    ),
                  ),
                  Text(
                    '보유 기프티콘: 5개',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.third,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Menu Options
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.list_alt),
                    title: const Text('당첨 내역'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.third,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('내역보기'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.check_box),
                    title: const Text('설문 참여 내역'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.third,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('내역보기'),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.card_giftcard),
                    title: const Text('보유 기프티콘'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const Gifticon_Screen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.third,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('내역보기'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
