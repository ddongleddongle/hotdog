import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'home.dart'; // Home.dart 파일을 임포트합니다.
import 'register.dart'; // Register.dart 파일을 임포트합니다';
import 'User_Provider.dart';
import 'FindPassword.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    // 이메일과 비밀번호가 입력되지 않았다면 오류 메시지 표시
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('입력 오류', '이메일 또는 비밀번호를 입력해주세요.');
      return; // 입력되지 않으면 로그인 진행하지 않음
    }

    final response = await http.post(
      Uri.parse('http://116.124.191.174:15017/login'), // 실제 로그인 API URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    setState(() {
      isLoading = false;
    });

    // 응답 코드와 응답 본문 로그 출력
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final email = data['email'];
        final password = data['password'];
        final petName = data['pet_name'];
        final petBirthDay = data['pet_birthdate'];
        final coins = data['coins'];

        Provider.of<UserProvider>(context, listen: false)
            .login(email, password, petName, petBirthDay, coins);

        // 로그인 성공 후 사용자 정보를 전달하여 Home 화면으로 이동
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        // 로그인 실패 (이메일 또는 비밀번호 오류)
        _showErrorDialog('로그인 실패', '이메일 또는 비밀번호가 잘못되었습니다.');
      }
    } else if (response.statusCode == 400) {
      // 서버가 400을 반환했을 때 (이메일 또는 비밀번호 잘못됨)
      final data = jsonDecode(response.body);
      _showErrorDialog('로그인 실패', data['message'] ?? '이메일 또는 비밀번호가 잘못되었습니다.');
    } else if (response.statusCode == 500) {
      // 서버 오류
      _showErrorDialog('로그인 실패', '서버 오류가 발생했습니다.');
    } else {
      // 그 외의 오류 코드 처리
      _showErrorDialog('로그인 실패', '알 수 없는 오류가 발생했습니다.');
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 버튼 눌렀을 때 아무 동작도 하지 않음
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF1F1F1),
        body: Center(
          child: Container(
            width: 390,
            decoration: const BoxDecoration(color: Color(0xFFF1F1F1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
              children: [
                const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Color(0xFF314B49),
                    fontSize: 48,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                SizedBox(height: 50), // Sign in과 이메일 입력 필드 사이의 간격
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
                      hintText: 'Your Email',
                      hintStyle: TextStyle(
                        color: Color(0xFF3F2D20),
                        fontSize: 14,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 19),
                    ),
                  ),
                ),
                SizedBox(height: 20), // 이메일 입력 필드와 비밀번호 입력 필드 사이의 간격
                Container(
                  width: 350,
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
                SizedBox(height: 10), // 비밀번호 입력 필드와 비밀번호 찾기 버튼 사이의 간격
                TextButton(
                  onPressed: () {
                    print('비밀번호 찾기 클릭');
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FindPassword()),
                    );
                  },
                  child: Text(
                    '비밀번호를 잊으셨나요?',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                SizedBox(height: 10), // 비밀번호 찾기 버튼과 회원가입 버튼 사이의 간격
                GestureDetector(
                  onTap: () {
                    if (!isLoading) {
                      _login(); // 로그인 버튼 클릭 시 _login 호출
                    }
                  },
                  child: Container(
                    width: 335,
                    height: 65,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFAAD5D1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: const Text(
                        '로그인',
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
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: Text(
                    '회원가입',
                    style: TextStyle(color: Color(0xFF62807D)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
