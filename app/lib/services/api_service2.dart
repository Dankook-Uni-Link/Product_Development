import 'dart:convert';
import 'package:app/models/point_transaction_model.dart';
import 'package:app/models/response_model.dart';
import 'package:app/models/survey_model2.dart';
import 'package:app/services/token_service.dart';

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000";

  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Survey APIs
  Future<List<Survey>> getSurveyList() async {
    final response = await http.get(Uri.parse('$baseUrl/surveys'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((json) => Survey.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load surveys');
  }

  Future<Survey> getSurvey(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/surveys/$id'));
    if (response.statusCode == 200) {
      return Survey.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load survey');
  }

  Future<void> createSurvey(Survey survey) async {
    final response = await http.post(Uri.parse('$baseUrl/surveys'),
        headers: await _getHeaders(), body: jsonEncode(survey.toJson()));
  }

  // Response APIs
  Future<void> submitResponse(Response response) async {
    final response = await http.post(Uri.parse('$baseUrl/responses'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(response.toJson()));
    if (response.statusCode != 201) {
      throw Exception('Failed to submit response');
    }
  }

  // Point Transaction APIs
  Future<List<PointTransaction>> getPointHistory(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/points'));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List)
          .map((json) => PointTransaction.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load point history');
  }
}
