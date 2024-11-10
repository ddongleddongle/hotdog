import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Login.dart'; // 로그인 화면을 임포트해야 합니다.

class ResetPassword extends StatefulWidget {
  final String email;

  ResetPassword({required this.email});

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPassword> {
  TextEditingController newPasswordController = TextEditingController();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    setState(() {
      isLoading = true;
    });

    if (newPasswordController.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('입력 오류', '새 비밀번호를 입력해주세요.');
      return;
    }

    final response = await http.post(
      Uri.parse('http://116.124.191.174:15017/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': widget.email,
        'newPassword': newPasswordController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        _showSuccessDialog('성공', data['message']);
      } else {
        _showErrorDialog('실패', data['message']);
      }
    } else {
      _showErrorDialog('서버 오류', '서버와 연결할 수 없습니다.');
    }
  }

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
                Navigator.of(context).pop(); // 다이얼로그 닫기
                // 로그인 화면으로 이동
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()), // 로그인 화면으로 이동
                );
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
      appBar: AppBar(title: Text('비밀번호 재설정')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 350,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFB3E0DB), width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '새 비밀번호',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                ),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : GestureDetector(
              onTap: _resetPassword,
              child: Container(
                width: 335,
                height: 65,
                decoration: ShapeDecoration(
                  color: Color(0xFFAAD5D1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Center(
                  child: Text(
                    '비밀번호 재설정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}