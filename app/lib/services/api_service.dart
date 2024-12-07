import 'package:app/models/gifticon_model.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/models/login_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      "http://127.0.0.1:3000"; // 일반적으로 Android 에뮬레이터에서는 10.0.2.2를 로컬 호스트 주소로 사용한다.

  // 로그인 
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login'); // 설문조사 목록을 가져오는 엔드포인트
    final response = await http.post(url, body: {
      'username': username, 'password': password,});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> signup(String username, String email, String password, String gender, String birthdate) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(url, body: {
      'username': username,
      'email': email,
      'password': password,
      'gender': gender,
      'birthdate': birthdate,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  // 서버 응답을 JSON 형태로 반환
    } else {
      throw Exception('회원가입 실패');
    }

  }

  // 설문조사 목록 가져오기
  Future<List<Survey>> getSurveyList() async {
    final url = Uri.parse('$baseUrl/surveys'); // 설문조사 목록을 가져오는 엔드포인트
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Survey.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load survey list');
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
}
