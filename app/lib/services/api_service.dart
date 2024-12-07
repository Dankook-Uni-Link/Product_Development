import 'package:app/models/gifticon_model.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/models/login_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      "http://127.0.0.1:3000"; // 일반적으로 Android 에뮬레이터에서는 10.0.2.2를 로컬 호스트 주소로 사용한다.

  // 로그인
  Future<ApiResponse<Login>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login'); // 설문조사 목록을 가져오는 엔드포인트
    final headers = {'Content-Type': 'application/json'};
    // final body = jsonEncode({'username': username, 'password': password});

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final login = Login.fromJson(data['user']); // 'user'는 서버 응답에서 유저 데이터가 담긴 키
      return ApiResponse(success: true, message: '유저 정보 가져오기 성공', data: login);
    } else {
      throw Exception('Failed to fetch user info: ${response.body}');
    }
  }

  // 회원가입
  Future<ApiResponse> signup(String username, String password, String email, String? gender, String birthdate) async {
    final url = Uri.parse('$baseUrl/signup');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      'gender': gender,
      'birthdate': birthdate,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // 성공: 응답 데이터에서 Login 객체 생성
      final data = json.decode(response.body);
      final login = Login.fromJson(data['user']); // 'user'는 서버 응답에서 유저 데이터가 담긴 키
      return ApiResponse(success: true, message: '회원가입 성공', data: login);
    } else {
      // 실패: 에러 메시지 반환
      final error = json.decode(response.body);
      return ApiResponse(success: false, message: error['message']);
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
