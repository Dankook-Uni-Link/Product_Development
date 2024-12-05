import 'dart:math';

import 'package:app/design/colors.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/home_screen.dart';
import 'package:app/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({Key? key}) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  void _login() {
    if (_formKey.currentState!.validate()) {
      // 로그인 로직 (API 요청 등), 로그인 성공 시 홈 화면으로 이동
      String username = _userController.text;
      String password = _passwordController.text;

      if(username == 'user' && password == '1234'){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // 로그인 실패 시 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('아이디 또는 비밀번호가 일치하지 않습니다.')),
        );
      }
      
    }
  }

  void _signup() {
    // 회원가입 로직 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("회원가입",
                style: GoogleFonts.blackHanSans(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  )),
        content: const Text('회원가입 기능은 아직 구현되지 않았습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Welcome to sur문",
                  // style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  style: GoogleFonts.blackHanSans(fontSize: 40, shadows: [
                    Shadow(
                      color:
                          const Color.fromARGB(255, 80, 80, 80).withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ])),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _userController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username을 입력해주세요.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    // Enter 키를 누르면 로그인 함수 호출
                    _login();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password를 입력해주세요.';
                    }
                    return null;
                  },
                  onFieldSubmitted: (value) {
                    // Enter 키를 누르면 로그인 함수 호출
                    _login();
                  },
                ),
                // const SizedBox(height: 16),
                // ElevatedButton(
                //   onPressed: _login,
                //   child: Text("로그인",
                //   style: GoogleFonts.blackHanSans(
                //     fontSize: 20,
                //     fontWeight: FontWeight.normal,
                //     color: Colors.black,
                //     )),
                // ),
                // const SizedBox(height: 16), // 버튼 사이에 여백 추가
                // ElevatedButton(
                //   onPressed: _signup,
                //   child: Text("회원가입",
                //     style: GoogleFonts.blackHanSans(
                //       fontSize: 20,
                //       fontWeight: FontWeight.normal,
                //       color: Colors.black,
                //     )),
                // ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity, // 너비를 화면에 맞게 확장
                  child: ElevatedButton(
                    onPressed: _login,
                    child: Text(
                      "로그인",
                      style: GoogleFonts.blackHanSans(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // 버튼 사이에 여백 추가
                SizedBox(
                  width: double.infinity, // 너비를 화면에 맞게 확장
                  child: ElevatedButton(
                    onPressed: _signup,
                    child: Text(
                      "회원가입",
                      style: GoogleFonts.blackHanSans(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
