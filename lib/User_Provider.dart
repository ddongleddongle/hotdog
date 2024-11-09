import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _email;
  String? _password;
  String? _petName;
  String? _petBirthDay;
  int? _coins;

  // Getters
  String? get email => _email;
  String? get password => _password;
  String? get petName => _petName;
  String? get petBirthDay => _petBirthDay;
  int? get coins => _coins;

  bool get isLoggedIn => _email != null;

  // 로그인 처리
  Future<void> login(String email, String password, String petName, String petBirthDay, int coins) async {
    _email = email;
    _password = password;
    _petName = petName;
    _petBirthDay = petBirthDay;
    _coins = coins;
    notifyListeners();  // 로그인 상태 변경
  }

  // 로그아웃 처리
  Future<void> logout() async {
    _email = null;
    _password = null;
    _petName = null;
    _petBirthDay = null;
    _coins = null;
    notifyListeners();  // 로그아웃 상태 변경
  }

  // 사용자 정보 업데이트
  void updateUserInfo(String email, String password, String petName, String petBirthDay) {
    _email = email;
    _password = password;
    _petName = petName;
    _petBirthDay = petBirthDay;
    notifyListeners();  // 상태 변경을 UI에 반영
  }
}