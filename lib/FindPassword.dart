import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ResetPassword.dart';

class FindPassword extends StatefulWidget {
  @override
  _FindPasswordState createState() => _FindPasswordState();
}

class _FindPasswordState extends State<FindPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController petNameController = TextEditingController();
  TextEditingController petBirthDateController = TextEditingController();
  bool isLoading = false;

  Future<void> _verifyUser() async {
    setState(() {
      isLoading = true;
    });

    if (emailController.text.isEmpty ||
        petNameController.text.isEmpty ||
        petBirthDateController.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('입력 오류', '모든 필드를 입력해주세요.');
      return;
    }

    final response = await http.post(
      Uri.parse('http://116.124.191.174:15017/verify-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'petName': petNameController.text,
        'petBirthDate': petBirthDateController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['success']) {
        // 사용자 확인 후 비밀번호 재설정 페이지로 이동
        _showSuccessDialog();
      } else {
        _showErrorDialog('실패', data['message']);
      }
    }
    else if(response.statusCode == 400){
      _showErrorDialog('잘못된 입력', data['message']);
    }
    else if(response.statusCode == 500){
      _showErrorDialog('서버 오류', data['message']);
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('확인되었습니다'),
          content: Text('사용자 정보가 확인되었습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // 비밀번호 재설정 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResetPassword(email: emailController.text),
                  ),
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
      appBar: AppBar(title: Text('비밀번호 찾기')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 350,
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
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 350,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFB3E0DB), width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: petNameController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '반려동물 이름',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: 350,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFB3E0DB), width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: petBirthDateController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '반려동물 생일',
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                ),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : GestureDetector(
              onTap: _verifyUser,
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
                    '사용자 확인',
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