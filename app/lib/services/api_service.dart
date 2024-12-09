import 'package:app/models/gifticon_model.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/models/login_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      "http://localhost:3000"; // 일반적으로 Android 에뮬레이터에서는 10.0.2.2를 로컬 호스트 주소로 사용한다.

  // 로그인
  Future<ApiResponse<Login>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login'); // 설문조사 목록을 가져오는 엔드포인트
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'username': username, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);   //
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // 응답 데이터를 파싱
      final Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body); // Map<String, dynamic>로 파싱됨
        if(data['success'] == true) {
          final login = Login.fromJson(data['user']); // 'user'는 서버 응답에서 유저 데이터가 담긴 키
          return ApiResponse(success: true, message: data['message'], data: login);
        } else {
          return ApiResponse(success: false, message: data['message']);
        }
      } else {
        return ApiResponse(success: false, message: 'HTTP 오류: ${response.statusCode}');
      }
    } catch(e) {
      return ApiResponse(success: false, message: '네트워크 오류: $e');
    }
  }

  // 회원가입
  Future<ApiResponse<Login>> signup(String username, String password, String email, String? gender, String birthdate, String? region, String? job) async {
    final url = Uri.parse('$baseUrl/signup');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'username': username,
      'email': email,
      'password': password,
      'gender': gender,
      'birthdate': birthdate,
      'region': region,
      'job': job,
    });

    final response = await http.post(url, headers: headers, body: body);

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);

        if (data['success']) {
          // 'user'가 존재하는지 확인
          if (data.containsKey('user') && data['user'] != null) {
            final login = Login.fromJson(data['user']);  // 'user' 키가 존재할 경우만 처리
            return ApiResponse(success: true, message: '회원가입 성공', data: login);
          } else {
            return ApiResponse(success: false, message: '사용자 정보가 없습니다.');
          }
        } else {
          return ApiResponse(success: false, message: data['message'] ?? '알 수 없는 오류');
        }
      } catch (e) {
        return ApiResponse(success: false, message: '응답 파싱 오류: $e');
      }
    } else {
      // 실패: 에러 메시지 반환
      try {
        final error = json.decode(response.body);
        return ApiResponse(success: false, message: error['message'] ?? '서버 오류');
      } catch (e) {
        return ApiResponse(success: false, message: '응답 파싱 오류: $e');
      }
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

<<<<<<< HEAD
  // String? _selectRegion;
  // String? _selectJob;

/*
나이대: 10 20 30 40 50 60대 이상
성별: 남성 여성
지역: 서울 경기 인천 강원 충청 전라 경상 제주
직업: 대학생 직장인 자영업자 전문직 주부 무직 기타
*/
=======

>>>>>>> 2db410442a0080b3cb9ba5b2b1c7712c1f61c2eb
  // 설문조사 생성하기
  Future<Result> createSurvey(
    String title,
    String surveyExplain,
    String reward,
    String deadline,
  ) async {
    final response = await http.post(
      Uri.parse('https://your-api-url/create-survey'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'surveyTitle': title,
        'surveyExplain': surveyExplain,
        'reward': reward,
        'deadline': deadline,
      }),
    );

    if (response.statusCode == 200) {
      return Result(success: true, message: 'Survey created successfully');
    } else {
      return Result(success: false, message: 'Failed to create survey');
    }
  }

  Future<Result> newcreateSurvey(
    String surveyTitle,
    List<String> surveyQuestions,
  ) async {
    final response = await http.post(
      Uri.parse('https://your-api-url/create-survey'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'surveyTitle': surveyTitle,
        'questions': surveyQuestions,
      }),
    );

    if (response.statusCode == 200) {
      return Result(success: true, message: 'Survey created successfully');
    } else {
      return Result(success: false, message: 'Failed to create survey');
    }
  }
}


class Result {
  final bool success;
  final String message;

  Result({required this.success, required this.message});
}
