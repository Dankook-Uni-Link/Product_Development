import 'dart:convert';

import 'package:app/models/user_model.dart';
import 'package:app/services/token_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "http://10.0.2.2:3000";

  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required DateTime birthDate,
    required String gender,
    required String location,
    required String occupation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'birthDate': birthDate.toIso8601String(),
        'gender': gender,
        'location': location,
        'occupation': occupation,
      }),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to sign up');
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
