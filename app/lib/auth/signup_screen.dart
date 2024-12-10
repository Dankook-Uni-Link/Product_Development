// auth/signup_screen.dart
import 'package:app/design/colors.dart';
import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// screens/auth/signup_screen.dart
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회원가입'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: '이메일',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? '이메일을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  filled: true,
                  fillColor: Colors.white,
                ),
                obscureText: true,
                validator: (value) =>
                    value?.isEmpty ?? true ? '비밀번호를 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? '이름을 입력하세요' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(_selectedDate == null
                    ? '생년월일'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                trailing: const Icon(Icons.calendar_today),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: '성별',
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['남성', '여성']
                    .map((label) =>
                        DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) => value == null ? '성별을 선택하세요' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  labelText: '지역',
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['서울', '경기', '인천', '강원', '충청', '전라', '경상', '제주']
                    .map((label) =>
                        DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedLocation = value),
                validator: (value) => value == null ? '지역을 선택하세요' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedOccupation,
                decoration: const InputDecoration(
                  labelText: '직업',
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['학생', '직장인', '자영업자', '전문직', '주부', '무직', '기타']
                    .map((label) =>
                        DropdownMenuItem(value: label, child: Text(label)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedOccupation = value),
                validator: (value) => value == null ? '직업을 선택하세요' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.third,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('가입하기', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('생년월일을 선택하세요')),
        );
        return;
      }

      try {
        final user = await AuthService().signUp(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입 실패: $e')),
        );
      }
    }
  }
}
