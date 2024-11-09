import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'User_Provider.dart';

class MyInfoModi extends StatefulWidget {
  @override
  _MyInfoModiState createState() => _MyInfoModiState();
}

class _MyInfoModiState extends State<MyInfoModi> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController petNameController = TextEditingController();
  TextEditingController petBirthDateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // UserProvider에서 데이터 가져오기
    final user = Provider.of<UserProvider>(context, listen: false);

    // 컨트롤러에 값 채우기
    emailController.text = user.email!;
    passwordController.text = user.password!;
    petNameController.text = user.petName!;
    petBirthDateController.text = _formatBirthDate(user.petBirthDay!);
  }

  // 생일 문자열을 DateTime으로 변환하고, 원하는 형식으로 포맷
  String _formatBirthDate(String birthDate) {
    DateTime date = DateTime.parse(birthDate);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // 서버에 사용자 정보를 업데이트하는 함수
  Future<void> _updateUserInfo() async {
    String url = 'http://116.124.191.174:15017/updateUsers';  // 서버 URL을 실제 URL로 수정

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': emailController.text,
          'password': passwordController.text,
          'petName': petNameController.text,
          'petBirthDay': petBirthDateController.text,
          // coins는 수정할 수 없으므로 전송하지 않음
        }),
      );

      if (response.statusCode == 200) {
        // 서버가 정상적으로 응답한 경우
        print('User info updated successfully');

        // UserProvider의 값도 업데이트
        final user = Provider.of<UserProvider>(context, listen: false);
        user.updateUserInfo(
          emailController.text,
          passwordController.text,
          petNameController.text,
          petBirthDateController.text,
        );

        // 성공 메시지 띄우기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('정보가 성공적으로 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // 서버에서 오류 응답을 받은 경우
        print('Failed to update user info');

        // 실패 메시지 띄우기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('정보 수정에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // 요청 도중 에러가 발생한 경우
      print('Error: $e');

      // 에러 메시지 띄우기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버와의 연결에 문제가 발생했습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildEditProfileSection(),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFAAD5D1),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black54),
        onPressed: () {
          Navigator.pop(context); // 뒤로가기 버튼
        },
      ),
      title: Text("내 정보 수정", style: TextStyle(color: Colors.black)),
    );
  }

  // 수정할 프로필 섹션
  Widget _buildEditProfileSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildProfileTextField('이메일', emailController),
          SizedBox(height: 20),
          _buildProfileTextField('비밀번호', passwordController, obscureText: true),
          SizedBox(height: 20),
          _buildProfileTextField('이름', petNameController),
          SizedBox(height: 20),
          _buildProfileTextField('생일', petBirthDateController),
        ],
      ),
    );
  }

  // 프로필 입력 필드
  Widget _buildProfileTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,  // 비밀번호 필드에서는 글자 숨김
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF62807D)),
        border: OutlineInputBorder(),
      ),
    );
  }

  // 저장 버튼
  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: _buildButton('저장', () {
          // 정보 수정 저장 처리
          _updateUserInfo();  // 서버에 정보 업데이트 요청

          // 수정 후 MyInfo 화면으로 돌아가기
          Navigator.pop(context);
        }),
      ),
    );
  }

  // 공통 버튼 스타일
  Widget _buildButton(String label, VoidCallback onPressed) {
    return Container(
      decoration: ShapeDecoration(
        color: Color(0xFFAAD5D1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}