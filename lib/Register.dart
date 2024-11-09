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
      appBar: AppBar(
        title: Text('회원가입'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '비밀번호 확인',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: petNameController,
              decoration: InputDecoration(
                labelText: '펫 이름',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: petBirthdateController,
              decoration: InputDecoration(
                labelText: '펫 생일 (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFAAD5D1),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                '회원가입',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}