import 'package:flutter/material.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data; // 제네릭을 사용해 데이터 타입 유연화

  ApiResponse({required this.success, required this.message, this.data});
}

class Login {
  final int id;
  final String username;
  final String password;
  final String email;
  final String gender;
  final String birthdate;
  final String region;
  final String job;
  // final String token; // 로그인 성공 시 받은 JWT 토큰

  // Login({required this.token});
  Login({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.gender,
    required this.birthdate,
    required this.region,
    required this.job,
  });

  // JSON 데이터를 객체로 변환
  factory Login.fromJson(Map<String, dynamic> json) {
    return Login(
      // token: json['token'], // API 응답에서 token을 반환받는다고 가정
      id: json['id'],
      username: json['username'],
      password: json['password'],
      email: json['email'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      region: json['region'],
      job: json['job'],
    );
  }
}