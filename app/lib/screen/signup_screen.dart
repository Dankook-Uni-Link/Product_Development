import 'dart:math';

import 'package:flutter/services.dart';
import 'package:app/design/colors.dart';
import 'package:flutter/material.dart';
import 'package:app/screen/home_screen.dart';
import 'package:app/screen/login_screen.dart';
import 'package:app/services/api_service.dart';
import 'package:app/design/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // 숫자만 입력 허용
    final filteredText = text.replaceAll(RegExp(r'[^0-9]'), '');

    // 날짜 형식 자동 완성 (YYYY-MM-DD)
    String formattedText = '';
    if (filteredText.length > 0) {
      formattedText = filteredText.substring(0, min(4, filteredText.length));
    }
    if (filteredText.length > 4) {
      formattedText += '-${filteredText.substring(4, min(6, filteredText.length))}';
    }
    if (filteredText.length > 6) {
      formattedText += '-${filteredText.substring(6, min(8, filteredText.length))}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}


class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _genderController = TextEditingController();
  String? _selectedGender; // 선택한 성별 저장
  final TextEditingController _birthdateController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();  
  final _apiService = ApiService();
  // bool _isUsernameAvailable = true;  // 아이디 중복 검사 결과 저장

  // // 아이디 중복 검사 함수
  // Future<void> _checkUsernameAvailability() async {
  //   String username = _usernameController.text;

  //   if (username.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('아이디를 입력해주세요.')),
  //     );
  //     return;
  //   }

  //   // 아이디 중복을 확인하는 로직 (여기서는 임시로 mock 데이터 사용)
  //   bool isUsernameTaken = await _mockCheckUsernameAvailability(username);

  //   setState(() {
  //     _isUsernameAvailable = !isUsernameTaken;  // 중복 여부 업데이트
  //   });

  //   if (isUsernameTaken) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('이 아이디는 이미 사용 중입니다.')),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('이 아이디는 사용 가능합니다.')),
  //     );
  //   }
  // }

  // 아이디 중복을 확인하는 mock 함수
  // Future<bool> _mockCheckUsernameAvailability(String username) async {
  //   // 예시로 "testuser"라는 아이디는 이미 사용 중이라고 가정
  //   await Future.delayed(const Duration(seconds: 1)); // API 호출 시간 시뮬레이션
  //   return username == 'testuser'; // 'testuser'는 중복된 아이디
  // }

  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return '생년월일을 입력해주세요.';
    }

    final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!datePattern.hasMatch(value)) {
      return '날짜 형식이 올바르지 않습니다. (YYYY-MM-DD)';
    }

    // 날짜 검증
    try {
      final parts = value.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      if (year < 1900 || year > DateTime.now().year) {
        return '유효하지 않은 연도입니다.';
      }
      if (month < 1 || month > 12) {
        return '유효하지 않은 월입니다.';
      }
      if (day < 1 || day > 31) {
        return '유효하지 않은 일입니다.';
      }

      // 유효한 날짜인지 확인
      final parsedDate = DateTime(year, month, day);
      if (parsedDate.month != month || parsedDate.day != day) {
        return '날짜 형식이 올바르지 않습니다.';
      }
    } catch (e) {
      return '날짜 형식이 올바르지 않습니다.';
    }

    return null;
  }
  // void _signup() async {
  //   // 회원가입 로직 구현
  //   if (_formKey.currentState!.validate()) {
  //     String username = _usernameController.text;
  //     String email = _emailController.text;
  //     String password = _passwordController.text;
  //     String gender = _genderController.text;
  //     String birthdate = _birthdateController.text;

  //     // 회원가입 API 호출
  //     try {
  //       final result = await _apiService.signup(username, email, password, gender, birthdate);
  //       if(result['status'] == 'success'){
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('회원가입이 성공적으로 완료되었습니다.')),
  //         );
  //         // 회원가입 후 로그인 페이지로 이동
  //         Navigator.pushReplacement(
  //           context,
  //           MaterialPageRoute(builder: (context) => const LoginScreen()),
  //         );
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('회원가입 실패. 다시 시도해주세요.')),
  //         ); 
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('서버에 연결할 수 없습니다.')),
  //       );
  //     }
  //   }
  // }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) { //&& _isUsernameAvailable // 아이디 중복X
      // 회원가입 로직
      String username = _usernameController.text;
      String password = _passwordController.text;
      String email = _emailController.text;
      String? gender = _selectedGender; // 선택된 성별
      String birthdate = _birthdateController.text;

      final result = await _apiService.signup(username, password, email, gender, birthdate);

      if (result.success) { // 회원가입 성공 여부 확인 (success 필드 예시)
        // final loginData = result.data; // Login 객체 가져오기
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입이 성공적으로 완료되었습니다.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // 실패 시 에러 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: ${result.message}')), // 서버에서 반환된 에러 메시지
        );
      }
    }
    // else {
    //   if (!_isUsernameAvailable) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('아이디 중복 검사를 먼저 해주세요.')),
    //     );
    //   }
    // }
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
                  style: GoogleFonts.blackHanSans(fontSize: 40, shadows: [
                    Shadow(
                      color: const Color.fromARGB(255, 80, 80, 80).withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ])),
                const SizedBox(height: 16),

                // 아이디 입력 필드 // + 중복 검사 버튼
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
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
                      ),
                    ),
                    // IconButton(
                    //   icon: Icon(
                    //     _isUsernameAvailable ? Icons.check : Icons.error,
                    //     color: _isUsernameAvailable ? Colors.green : Colors.red,
                    //   ),
                    //   onPressed: _checkUsernameAvailability,
                    // ),
                  ],
                ),
                const SizedBox(height: 16),

                // 비밀번호 입력 필드
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password을 입력해주세요.';
                          }
                          return null;
                        },
                  ),),],),
                const SizedBox(height: 16),

                // 비밀번호 확인 입력 필드
                Row(children: [
                  Expanded(
                    child: 
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 다시 입력해주세요.';
                        }
                        if (value != _passwordController.text) {
                          return '비밀번호가 일치하지 않습니다.';
                        }
                        return null;
                      },
                    ),)
                ],),
                const SizedBox(height: 16),

                // 이메일 입력 필드
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email을 입력해주세요.';
                          }
                          // 이메일 형식 검증
                          final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return '유효한 이메일 형식이 아닙니다.';
                          }

                          return null;
                        },
                  ),),],),
                const SizedBox(height: 16),

                // 성별 입력 필드
                // Row(
                //   children: [
                //     Expanded(
                //       child: TextFormField(
                //         controller: _genderController,
                //         keyboardType: TextInputType.text,
                //         decoration: const InputDecoration(
                //           labelText: 'Gender',
                //           border: OutlineInputBorder(),
                //         ),
                //         validator: (value) {
                //           if (value == null || value.isEmpty) {
                //             return '성별을 입력해주세요.';
                //           }
                //           return null;
                //         },
                //   ),),],),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
                        ),
                        value: _selectedGender,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('선택하세요')),
                          ...['Male', 'Female', 'Other'].map(
                            (gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          FocusScope.of(context).requestFocus(FocusNode()); // 키보드 숨김
                          setState(() {
                            _selectedGender = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '성별을 선택해주세요.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 생년월일 입력 필드
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _birthdateController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          labelText: 'YYYY-MM-DD',
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')), // 숫자와 '-'만 허용
                          LengthLimitingTextInputFormatter(10), // 최대 10글자
                          DateInputFormatter(), // 날짜 형식 자동 입력
                        ],
                        validator: _validateDate,
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return '생년월일을 입력해주세요.';
                        //   }
                        //   return null;
                        // },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 회원가입 버튼
                SizedBox(
                  width: double.infinity,
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
