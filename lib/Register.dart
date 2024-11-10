import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController petNameController = TextEditingController();
  TextEditingController petBirthdateController = TextEditingController();

  // 회원가입 버튼 클릭 시 서버로 데이터 전송
  Future<void> _register() async {
    // 비밀번호와 비밀번호 확인이 일치하는지 검사
    if (passwordController.text != confirmPasswordController.text) {
      _showErrorDialog('회원가입 실패', '비밀번호가 일치하지 않습니다.');
      return;
    }

    // 서버로 회원가입 요청 전송
    final response = await http.post(
      Uri.parse('http://116.124.191.174:15017/register'), // 실제 회원가입 API URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
        'pet_name': petNameController.text,
        'pet_birthdate': petBirthdateController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        // 회원가입 성공 후, 다이얼로그로 성공 메시지 표시 후 로그인 화면으로 돌아감
        _showSuccessDialog('회원가입 성공', '회원가입이 완료되었습니다!');
      } else {
        _showErrorDialog('회원가입 실패', data['message']);
      }
    } else {
      _showErrorDialog('회원가입 실패', '서버와의 연결이 실패했습니다.');
    }
  }

  // 성공 메시지 다이얼로그
  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pop(context); // 로그인 화면으로 돌아가기
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 에러 메시지 다이얼로그
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        // Center 위젯으로 전체를 중앙 정렬
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
            crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
            children: [
              const Text(
                'Register',
                style: TextStyle(
                  color: Color(0xFF314B49),
                  fontSize: 48,
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              SizedBox(height: 50),
              // 이메일 입력 필드
              Container(
                width: 335,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFB3E0DB), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '이메일',
                    hintStyle: TextStyle(
                      color: Color(0xFF3F2D20),
                      fontSize: 14,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                  ),
                ),
              ),
              SizedBox(height: 20), // 간격
              // 비밀번호 입력 필드
              Container(
                width: 335,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFB3E0DB), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '비밀번호',
                    hintStyle: TextStyle(
                      color: Color(0xFF3F2D20),
                      fontSize: 14,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                  ),
                ),
              ),
              SizedBox(height: 20), // 간격
              // 비밀번호 확인 입력 필드
              Container(
                width: 335,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFB3E0DB), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '비밀번호 확인',
                    hintStyle: TextStyle(
                      color: Color(0xFF3F2D20),
                      fontSize: 14,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                  ),
                ),
              ),
              SizedBox(height: 20), // 간격
              // 펫 이름 입력 필드
              Container(
                width: 335,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFB3E0DB), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: petNameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '펫 이름',
                    hintStyle: TextStyle(
                      color: Color(0xFF3F2D20),
                      fontSize: 14,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                  ),
                ),
              ),
              SizedBox(height: 20), // 간격
              // 펫 생일 입력 필드
              Container(
                width: 335,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFB3E0DB), width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: petBirthdateController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '펫 생일 (YYYY-MM-DD)',
                    hintStyle: TextStyle(
                      color: Color(0xFF3F2D20),
                      fontSize: 14,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                  ),
                ),
              ),
              SizedBox(height: 20), // 간격
              Container(
                width: 335, // 버튼 너비 설정
                height: 65, // 버튼 높이 설정
                decoration: BoxDecoration(
                  color: Color(0xFFAAD5D1),
                  borderRadius: BorderRadius.circular(20), // 버튼 테두리 라운드 설정
                ),
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFAAD5D1),
                    padding: EdgeInsets.zero, // 패딩을 0으로 설정하여 크기 유지
                  ),
                  child: Text(
                    '회원가입',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Mulish',
                      fontWeight: FontWeight.w700,
                      height: 1.06,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
