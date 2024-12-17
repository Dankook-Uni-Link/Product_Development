import 'package:app/auth/login_screen.dart';
import 'package:app/auth/signup_screen.dart';
import 'package:app/design/colors.dart';
import 'package:app/provider/user_provider.dart';
import 'package:app/screen/home_screen.dart';
import 'package:app/screen/intro_screen.dart';
import 'package:app/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// main.dart 수정
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MainApp(),
    ),
  );
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
        '/': (context) => const IntroScreen(),
        '/splash': (context) => const SplashScreen(),
        '/intro': (context) => const IntroScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
