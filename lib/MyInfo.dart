import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:software/Walking.dart';
import 'Home.dart';
import 'Login.dart';
import 'QnA.dart';
import 'MyInfoModi.dart';
import 'Shop/Shop.dart';
import 'User_Provider.dart';
import 'Walking.dart';
import 'test.dart';

class MyInfo extends StatefulWidget {
  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  final TextEditingController _passwordController = TextEditingController(); // 비밀번호 입력 컨트롤러
  bool _isPasswordCorrect = true; // 비밀번호 확인 여부

  // 생일 문자열을 DateTime으로 변환하고, 원하는 형식으로 포맷
  String _formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate == '0000') {
      return '잘못된 값 리턴!';
    }
    DateTime date = DateTime.parse(birthDate);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context); // Provider를 사용하여 사용자 정보 가져오기
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image with scaling adjustment
          Positioned.fill(
            child: Image.asset(
              'assets/images/pet.png', // 배경 이미지
              fit: BoxFit.cover, // 이미지가 화면을 채우도록 설정
              alignment: Alignment.center, // 이미지가 화면 중앙에 위치하도록 설정
            ),
          ),
          // Overlay (semi-transparent)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7), // 반투명 오버레이
            ),
          ),
          // White sliding panel at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: screenHeight * 0.65, // 슬라이드 패널 높이를 65%로 설정
              margin: EdgeInsets.only(top: 20), // 상단에 20픽셀 여백
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border.all(
                  color: Color(0xFFAAD5D1), // 경계선 색상
                  width: 4, // 경계선 두께
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile section
                    _buildProfileSection(user),
                    // Additional buttons and info sections
                    _buildQnAButton(context),
                    _buildEditInfoButton(context),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildProfileSection(UserProvider user) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,  // 왼쪽 정렬 설정
        children: [
          // 이름을 크게 하고 bold로 설정
          user.petName != null
              ? _buildProfileText('${user.petName}', isBold: true, fontSize: 30)
              : _buildProfileText('로그인 하세요'),
          user.petBirthDay != null
              ? _buildProfileText('생일: ${_formatBirthDate(user.petBirthDay)}')
              : SizedBox(),
          user.coins != 0
              ? _buildProfileText('보유 포인트: ${user.coins}')
              : SizedBox(),

          // 경계선 추가
          Divider(
            color: Color(0xFFAAD5D1),
            thickness: 2,
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileText(String text, {bool isBold = false, double fontSize = 20}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Color(0xFF62807D),
          fontSize: fontSize,  // 폰트 크기 설정
          fontFamily: 'Inter',
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,  // bold 설정
        ),
      ),
    );
  }

  Widget _buildEditInfoButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: _buildButton('내 정보 수정', () {
          _showPasswordDialog(context); // 비밀번호 확인 다이얼로그 표시
        }),
      ),
    );
  }

  void _navigateToQnA(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QnA()),
    );
  }

  Widget _buildQnAButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: _buildButton('Q&A', () => _navigateToQnA(context)),
      ),
    );
  }

  // 비밀번호 확인 다이얼로그
  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("비밀번호 확인"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(hintText: '비밀번호를 입력하세요'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final enteredPassword = _passwordController.text;
                final correctPassword =
                    Provider.of<UserProvider>(context, listen: false).password;

                if (enteredPassword == correctPassword) {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyInfoModi()),
                  );
                } else {
                  setState(() {
                    _isPasswordCorrect = false;
                  });
                  Navigator.of(context).pop();
                  // 틀렸을 경우 경고 메시지 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('비밀번호가 틀렸습니다.')),
                  );
                }
              },
              child: Text("확인"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: _buildButton('로그아웃', () {
          Provider.of<UserProvider>(context, listen: false).logout();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그아웃 됨')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }),
      ),
    );
  }

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

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: '쇼핑',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: '산책',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '내정보',
        ),
      ],
      backgroundColor: Color(0xFFAAD5D1),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      iconSize: 30,
      selectedFontSize: 16,
      unselectedFontSize: 14,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
            break;
          case 1:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Shop()));
            break;
          case 2:
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Walking(),
                ));
            break;
          case 3:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyInfo()));
            break;
        }
      },
    );
  }
}
