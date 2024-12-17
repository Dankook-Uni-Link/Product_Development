import 'package:app/models/gifticon_model.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/models/user_activities_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      "http://localhost:3000"; // 10.0.2.2 대신 localhost 사용 // 애뮬레이터는 10.0.2.2

  // api_service.dart에 추가
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

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    }
    throw Exception('Failed to login');
  }

// api_service.dart
  Future<List<Survey>> getSurveyList() async {
    try {
      final url = Uri.parse('$baseUrl/surveys');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print('API Response: $jsonList'); // 응답 데이터 확인
        return jsonList.map((json) => Survey.fromJson(json)).toList();
      }
      throw Exception('Failed to load survey list');
    } catch (e) {
      print('Error in getSurveyList: $e');
      rethrow;
    }
  }

  Future<Survey> getSurvey(int surveyId) async {
    final url = Uri.parse('$baseUrl/survey/$surveyId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      return Survey.fromJson(jsonData);
    } else {
      throw Exception('Failed to load survey');
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

// 기프티콘 데이터를 가져오는 메서드 추가
  Future<List<Gifticon>> getGifticonList() async {
    final url = Uri.parse('$baseUrl/gifticons'); // 기프티콘 목록을 가져오는 엔드포인트
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Gifticon.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load gifticon list');
    }
  }

// services/api_service.dart
  Future<bool> createSurvey(Survey survey) async {
    final response = await http.post(Uri.parse('$baseUrl/surveys'),
        headers: await _getHeaders(), body: jsonEncode(survey.toJson()));

    return response.statusCode == 201;
  }

  Future<List<PointHistory>> getPointHistory() async {
    final url = Uri.parse('$baseUrl/points/history');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => PointHistory.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load point history');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<int> getCurrentPoints() async {
    final url = Uri.parse('$baseUrl/points/current');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return json['points'] as int;
      } else {
        throw Exception('Failed to load current points');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<SurveyStats> getSurveyStats(int? surveyId) async {
    if (surveyId == null) {
      throw Exception('Survey ID cannot be null');
    }

    final url = Uri.parse('$baseUrl/survey/$surveyId/stats');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return SurveyStats.fromJson(json);
      } else {
        throw Exception('Failed to load survey statistics');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // api_service.dart
  Future<User> getUserProfile(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/users/$userId/profile'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load user profile');
  }

  // Future<List<Survey>> getUserSurveys(int userId) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/users/$userId/surveys'),
  //     headers: await _getHeaders(),
  //   );

  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     return data.map((json) => Survey.fromJson(json)).toList();
  //   }
  //   throw Exception('Failed to load user surveys');
  // }

  // api_service.dart
  Future<List<Survey>> getUserSurveys(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/users/$userId/surveys');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Survey.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user surveys');
      }
    } catch (e) {
      print('Error in getUserSurveys: $e');
      rethrow;
    }
  }

  Future<UserActivities> getUserActivities(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/activities'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return UserActivities.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to load user activities');
    } catch (e) {
      print('Error getting user activities: $e');
      rethrow;
    }
  }

  Future<Survey> participateInSurvey(
      int surveyId, int userId, Map<String, List<String>> responses) async {
    try {
      final requestBody = {
        'userId': userId,
        'responses': responses,
      };

      print('Request body: ${jsonEncode(requestBody)}'); // 디버깅용

      final response = await http.post(
        Uri.parse('$baseUrl/surveys/$surveyId/participate'),
        headers: await _getHeaders(),
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}'); // 디버깅용
      print('Response body: ${response.body}'); // 디버깅용

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Survey.fromJson(data['updatedSurvey']);
      }

      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to participate in survey');
    } catch (e) {
      print('Error in participateInSurvey: $e');
      rethrow;
    }
  }

  // api_service.dart
  Future<List<Survey>> getParticipatedSurveys(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/users/$userId/participations');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Survey.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load participated surveys');
      }
    } catch (e) {
      print('Error in getParticipatedSurveys: $e');
      rethrow;
    }
  }
}
