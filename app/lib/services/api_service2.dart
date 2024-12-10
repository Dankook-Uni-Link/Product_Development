// // services/api_service.dart
// import 'dart:convert';

// import 'package:app/models/point_transaction_model.dart';
// import 'package:app/models/response_model.dart';
// import 'package:app/models/survey_model.dart';
// import 'package:app/services/token_service.dart';
// import 'package:http/http.dart' as http;

// class ApiService {
//   final String baseUrl = "http://10.0.2.2:3000";

//   // Headers 설정
//   Future<Map<String, String>> _getHeaders() async {
//     final token = await TokenService.getToken();
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // Survey 관련 API
//   Future<List<Survey>> getSurveyList() async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/surveys'),
//       headers: await _getHeaders(),
//     );
//     if (response.statusCode == 200) {
//       return (jsonDecode(response.body) as List)
//           .map((json) => Survey.fromJson(json))
//           .toList();
//     }
//     throw Exception('Failed to load surveys');
//   }

//   Future<Survey> getSurvey(int id) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/surveys/$id'),
//       headers: await _getHeaders(),
//     );
//     if (response.statusCode == 200) {
//       return Survey.fromJson(jsonDecode(response.body));
//     }
//     throw Exception('Failed to load survey');
//   }

//   Future<Survey> createSurvey(Survey survey) async {
//     final response = await http.post(Uri.parse('$baseUrl/surveys'),
//         headers: await _getHeaders(), body: jsonEncode(survey.toJson()));
//     if (response.statusCode == 201) {
//       return Survey.fromJson(jsonDecode(response.body));
//     }
//     throw Exception('Failed to create survey');
//   }

//   // Response 관련 API
//   Future<Response> submitResponse(Response response) async {
//     final apiResponse = await http.post(Uri.parse('$baseUrl/responses'),
//         headers: await _getHeaders(), body: jsonEncode(response.toJson()));
//     if (apiResponse.statusCode == 201) {
//       return Response.fromJson(jsonDecode(apiResponse.body));
//     }
//     throw Exception('Failed to submit response');
//   }

//   Future<List<Response>> getUserResponses(int userId) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/users/$userId/responses'),
//       headers: await _getHeaders(),
//     );
//     if (response.statusCode == 200) {
//       return (jsonDecode(response.body) as List)
//           .map((json) => Response.fromJson(json))
//           .toList();
//     }
//     throw Exception('Failed to load user responses');
//   }

//   // Point Transaction 관련 API
//   Future<List<PointTransaction>> getPointHistory(int userId) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/users/$userId/points'),
//       headers: await _getHeaders(),
//     );
//     if (response.statusCode == 200) {
//       return (jsonDecode(response.body) as List)
//           .map((json) => PointTransaction.fromJson(json))
//           .toList();
//     }
//     throw Exception('Failed to load point history');
//   }

//   Future<int> getCurrentPoints(int userId) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/users/$userId/points/current'),
//       headers: await _getHeaders(),
//     );
//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       return json['points'];
//     }
//     throw Exception('Failed to load current points');
//   }
// }
