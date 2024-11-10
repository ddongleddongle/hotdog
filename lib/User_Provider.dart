import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserProvider with ChangeNotifier {
  String? _email;
  String? _password;
  String? _petName;
  String? _petBirthDay;
  int? _coins;
  double? _totaldistance;

  // Getters
  String? get email => _email;
  String? get password => _password;
  String? get petName => _petName;
  String? get petBirthDay => _petBirthDay;
  int? get coins => _coins;
  double? get totaldistance => _totaldistance;

  set coins(int? value) {
    _coins = value;
    notifyListeners(); // 상태 변경 통지
  }

  set totaldistance(double? value) {
    _totaldistance = value;
    notifyListeners(); // 상태 변경 통지
  }

  bool get isLoggedIn => _email != null;

  // 로그인 처리
  Future<void> login(String email, String password, String petName,
      String petBirthDay, int coins, double totaldistance) async {
    _email = email;
    _password = password;
    _petName = petName;
    _petBirthDay = petBirthDay;
    _coins = coins;
    _totaldistance = totaldistance;
    notifyListeners(); // 로그인 상태 변경
  }

  // 로그아웃 처리
  Future<void> logout() async {
    _email = null;
    _password = null;
    _petName = null;
    _petBirthDay = null;
    _coins = null;
    _totaldistance = null;
    notifyListeners(); // 로그아웃 상태 변경
  }

  // 사용자 정보 업데이트
  void updateUserInfo(
      String email, String password, String petName, String petBirthDay) {
    _email = email;
    _password = password;
    _petName = petName;
    _petBirthDay = petBirthDay;
    notifyListeners(); // 상태 변경을 UI에 반영
  }

  Future<void> updateUserCoinsAndDistance(
      int coins, double totaldistance) async {
    final url = 'http://116.124.191.174:15017/update'; // 여기에 API 엔드포인트를 입력하세요

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': _email, // 사용자의 이메일 또는 ID로 식별
          'coins': coins,
          'totaldistance': totaldistance,
        }),
      );

      if (response.statusCode == 200) {
        _coins = coins; // 업데이트된 코인 저장
        _totaldistance = totaldistance; // 업데이트된 총 거리 저장
        // 서버 응답 처리
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to update user data');
      }
    } catch (error) {
      throw error; // 에러 처리
    }
  }
}
