import 'dart:math';

import 'package:app/design/colors.dart';
import 'package:app/screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/home_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();


  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // 로그인 로직 (API 요청 등), 로그인 성공 시 홈 화면으로 이동
      String username = _usernameController.text;
      String password = _passwordController.text;

      final result = await _apiService.login(username, password);

      if(result['succes'] ){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } 
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일 또는 비밀번호가 일치하지 않습니다.')),
      );
    }
  }

  void _signup() async {
    // 회원가입 로직 구현
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String gender = _genderController.text;
      String birthdate = _birthdateController.text;

      // 회원가입 API 호출
      try {
        final result = await _apiService.signup(username, email, password, gender, birthdate);
        if(result['status'] == 'success'){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입이 성공적으로 완료되었습니다.')),
          );
          // 회원가입 후 로그인 페이지로 이동
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('회원가입 실패. 다시 시도해주세요.')),
          ); 
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버에 연결할 수 없습니다.')),
        );
      }
    }
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
                Text("Comeback to sur문",
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
                  controller: _usernameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'username을 입력해주세요.';
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
                  onFieldSubmitted: (value) async {
                    // Enter 키를 누르면 로그인 함수 호출
                    await _login(); // _login(): 비동기 함수
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
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





      // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: Text("회원가입",
    //             style: GoogleFonts.blackHanSans(
    //               fontSize: 20,
    //               fontWeight: FontWeight.normal,
    //               color: Colors.black,
    //               )),
    //     content: const Text('회원가입 기능은 아직 구현되지 않았습니다.'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: const Text('확인'),
    //       ),
    //     ],
    //   ),
    // );

// 영문, 숫자, 특수문자 중 2종류 이상 조합하여 최소 10자리 이상 또는 3종류 이상 조합하여 최소 8자리 이상
                    // final passwordRegExp = RegExp(
                    //   r'^(?=(.*[a-zA-Z]){1,})(?=(.*[0-9]){1,})(?=(.*[\W_]){1,}).{8,}$', // 8자 이상, 영문, 숫자, 특수문자 1개 이상
                    // );
                    // final complexPasswordRegExp = RegExp(
                    //   r'^(?=(.*[a-zA-Z]){1,})(?=(.*[0-9]){1,})(?=(.*[\W_]){1,}).{10,}$', // 10자 이상
                    // );

                    // // 비밀번호 조건 검사
                    // if (!passwordRegExp.hasMatch(value) && !complexPasswordRegExp.hasMatch(value)) {
                    //   return '영문, 숫자, 특수문자 중 2종류 이상을 조합하여 최소 10자리 이상 또는 3종류 이상을 조합하여 최소 8자리 이상의 비밀번호를 입력해주세요.';
                    // }

                    // // 추가적으로 사용자 아이디와 비슷한 비밀번호 방지
                    // if (value.contains(username)) {
                    //   return '아이디와 비슷한 비밀번호는 사용할 수 없습니다.';
                    // }
