// auth/signup_screen.dart
import 'package:app/design/colors.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedLocation;
  String? _selectedOccupation;

  // 드롭다운 초기화가 제대로 되었는지 확인
  @override
  void initState() {
    super.initState();
    print('Initial values:');
    print('Gender: $_selectedGender');
    print('Location: $_selectedLocation');
    print('Occupation: $_selectedOccupation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: Text(
          '회원가입',
          style: GoogleFonts.blackHanSans(
            fontSize: 24,
            color: AppColors.third,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.third),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(
                controller: _emailController,
                label: '이메일',
                validator: (value) =>
                    value?.isEmpty ?? true ? '이메일을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _passwordController,
                label: '비밀번호',
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? '비밀번호를 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                controller: _nameController,
                label: '이름',
                validator: (value) =>
                    value?.isEmpty ?? true ? '이름을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              // 생년월일 선택
              Container(
                decoration: _buildBoxDecoration(),
                child: ListTile(
                  title: Text(
                    _selectedDate == null
                        ? '생년월일'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    style: TextStyle(
                      color: _selectedDate == null
                          ? Colors.grey[600]
                          : Colors.black,
                    ),
                  ),
                  trailing:
                      const Icon(Icons.calendar_today, color: AppColors.third),
                  onTap: _selectDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 성별 선택
              _buildDropdownField(
                value: _selectedGender,
                label: '성별',
                items: ['남성', '여성'],
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 16),
              // 지역 선택
              _buildDropdownField(
                value: _selectedLocation,
                label: '지역',
                items: ['서울', '경기', '인천', '강원', '충청', '전라', '경상', '제주'],
                onChanged: (value) => setState(() => _selectedLocation = value),
              ),
              const SizedBox(height: 16),
              // 직업 선택
              _buildDropdownField(
                value: _selectedOccupation,
                label: '직업',
                items: ['학생', '직장인', '자영업자', '전문직', '주부', '무직', '기타'],
                onChanged: (value) =>
                    setState(() => _selectedOccupation = value),
              ),
              const SizedBox(height: 32),
              // 가입하기 버튼
              ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.third,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  '가입하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 입력 필드 위젯
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: _buildBoxDecoration(),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  // 드롭다운 필드 위젯
  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required void Function(String?)? onChanged,
  }) {
    return Container(
      decoration: _buildBoxDecoration(),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? '$label을(를) 선택하세요' : null,
      ),
    );
  }

  // 박스 데코레이션
  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // 날짜 선택
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.third,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // 회원가입 처리
  void _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('생년월일을 선택하세요')),
        );
        return;
      }
// 값 확인 로그 추가
      print('Sending signup data:');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
      print('Name: ${_nameController.text}');
      print('Birth Date: $_selectedDate');
      print('Gender: $_selectedGender');
      print('Location: $_selectedLocation');
      print('Occupation: $_selectedOccupation');
      try {
        await AuthService().signUp(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          birthDate: _selectedDate!,
          gender: _selectedGender!,
          location: _selectedLocation!,
          occupation: _selectedOccupation!,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공!')),
        );

        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        if (!mounted) return;
        // 에러 메시지에서 'Exception: ' 부분을 제거하고 표시
        final errorMessage = e.toString().replaceAll('Exception: ', '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 100,
              right: 20,
              left: 20,
            ),
          ),
        );
      }
    }
  }
}
