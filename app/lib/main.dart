import 'package:app/design/colors.dart';
import 'package:app/screen/home_screen.dart';
import 'package:app/screen/intro.dart';
// import 'package:app/screen/login_signup_screen.dart'; // 로그인 화면 추가
import 'package:app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  ApiService().getSurvey(1);
  print("Hello World");
  runApp(const MyApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'sur문',
//       theme: ThemeData(
//         primarySwatch: Colors.brown,
//       ),
//       home: const WelcomeScreen(),
//     );
//   }
// }

// class WelcomeScreen extends StatefulWidget {
//   const WelcomeScreen({super.key});

//   @override
//   State<WelcomeScreen> createState() => _WelcomeScreenState();
// }

// class _WelcomeScreenState extends State<WelcomeScreen>
//     with SingleTickerProviderStateMixin {
//   AnimationController? _controller;
//   Animation<double>? _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 3), //애니메이션 지속 시간
//       vsync: this,
//     );
//     _animation =
//         CurvedAnimation(parent: _controller!, curve: Curves.easeInSine);

//     _controller!.forward();
//     _navigateToHome();
//   }

//   _navigateToHome() async {
//     await Future.delayed(const Duration(seconds: 5)); // 3초 딜레이
//     Navigator.of(context).pushReplacement(
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) =>
//             const HomeScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _controller!.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             // Image.asset(
//             //   'assets/logo.png', // 로고 이미지 파일 경로
//             //   width: 280,
//             //   height: 280,
//             // ),
//             Text('sur문',
//                 style: GoogleFonts.blackHanSans(fontSize: 60, shadows: [
//                   Shadow(
//                     color:
//                         const Color.fromARGB(255, 80, 80, 80).withOpacity(0.5),
//                     offset: const Offset(2, 2),
//                     blurRadius: 4,
//                   ),
//                 ])),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }