import 'package:app/auth/login_screen.dart';
import 'package:app/auth/signup_screen.dart';
import 'package:app/design/colors.dart';
import 'package:app/screen/home_screen.dart';
import 'package:app/screen/make_survey_screen.dart';
import 'package:app/screen/my_page.dart';
import 'package:app/screen/splash_screen.dart';
import 'package:flutter/material.dart';

// main.dart 수정
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sur문',
      theme: ThemeData(
        primaryColor: AppColors.third,
        scaffoldBackgroundColor: AppColors.primary,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
        '/mypage': (context) => const MyPageScreen(),
        '/makesurvey': (context) => const MakeSurveyScreen(),
      },
    );
  }
}
