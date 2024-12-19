import 'dart:convert';

import 'package:app/models/user_model.dart';
import 'package:app/services/token_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl =
      "http://10.0.2.2:3000"; //"http://localhost:3000"; //"http://10.0.2.2:3000";//

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
    required String gender,
    required String location,
    required String occupation,
  }) async {
    try {
      print('Attempting to sign up with data:'); // 추가
      print('Email: $email'); // 추가
      print('Name: $name'); // 추가
      print('Birth Date: $birthDate'); // 추가
      print('Gender: $gender'); // 추가
      print('Location: $location'); // 추가
      print('Occupation: $occupation'); // 추가

      final requestBody = jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'birthDate': birthDate.toLocal().toString().split(' ')[0],
        'gender': gender,
        'location': location,
        'occupation': occupation,
      });

      print('Request body: $requestBody'); // 추가
      print('Request URL: $baseUrl/auth/signup'); // 추가

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      print('Response status: ${response.statusCode}'); // 추가
      print('Response body: ${response.body}'); // 추가

      if (response.statusCode == 201) {
        return User.fromJson(jsonDecode(response.body));
      }

      // 에러 응답 처리 개선
      final error = jsonDecode(response.body);
      throw Exception(
          error['message'] ?? 'Failed to sign up: ${response.statusCode}');
    } catch (e, stackTrace) {
      // stackTrace 추가
      print('Sign up error: $e'); // 추가
      print('Stack trace: $stackTrace'); // 추가
      rethrow;
    }
  }

  // auth_service.dart
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(
          response.body); // {'token': String, 'user': Map<String, dynamic>}
    }
    throw Exception('Failed to login');
  }

  Future<void> logout() async {
    await TokenService.deleteToken();
  }
}
