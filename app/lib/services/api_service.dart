import 'package:app/models/gifticon_model.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/models/user_model.dart';
import 'package:app/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      "http://10.0.2.2:3000"; // 일반적으로 Android 에뮬레이터에서는 10.0.2.2를 로컬 호스트 주소로 사용한다.

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

  Future<List<Survey>> getSurveyList() async {
    try {
      final url = Uri.parse('$baseUrl/surveys');
      print('Requesting URL: $url'); // URL 확인

      final response = await http.get(url);
      print('Response status: ${response.statusCode}'); // 상태 코드 확인
      print('Response body: ${response.body}'); // 응답 데이터 확인

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        print('Parsed JSON: $jsonList'); // 파싱된 JSON 데이터 확인
        return jsonList.map((json) => Survey.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load survey list');
      }
    } catch (e) {
      print('Error in getSurveyList: $e'); // 에러 메시지 확인
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
  Future<Survey> createSurvey(Survey survey) async {
    final response = await http.post(Uri.parse('$baseUrl/surveys'),
        headers: await _getHeaders(), body: jsonEncode(survey.toJson()));

    if (response.statusCode == 201) {
      return Survey.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create survey');
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
}
