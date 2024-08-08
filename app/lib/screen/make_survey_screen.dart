import 'package:app/screen/home_screen.dart';
import 'package:app/screen/mypage.dart';
import 'package:app/widget/bottomNavbar.dart';
import 'package:flutter/material.dart';

class MakeSurveyScreen extends StatelessWidget {
  const MakeSurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Screen'),
      ),
      body: const Center(
        child: Text('This is the survey screen'),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }
}
