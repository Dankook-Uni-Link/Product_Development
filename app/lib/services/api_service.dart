import 'package:app/models/gifticon_model.dart';
import 'package:app/models/survey_model.dart';
import 'package:app/screen/make_survey_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      "http://10.0.2.2:3000"; // 일반적으로 Android 에뮬레이터에서는 10.0.2.2를 로컬 호스트 주소로 사용한다.

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

  Future<bool> createSurvey({
    required String title,
    required String description,
    required int targetNumber,
    required int rewardPerPerson,
    required SurveyTargetConditions targetConditions,
    required List<QuestionData> questions,
  }) async {
    final url = Uri.parse('$baseUrl/surveys');

    final surveyData = {
      'surveyTitle': title,
      'surveyDescription': description,
      'totalQuestions': questions.length,
      'reward': rewardPerPerson.toString(),
      'Target_number': targetNumber,
      'targetConditions': targetConditions.toJson(),
      'questions': questions
          .map((q) => {
                'question': q.question,
                'type': q.type,
                'options': q.options,
              })
          .toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(surveyData),
      );

      if (response.statusCode == 201) {
        // 생성 성공
        return true;
      } else {
        throw Exception('Failed to create survey');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
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
