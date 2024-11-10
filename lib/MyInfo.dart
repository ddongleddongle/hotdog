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

class MyInfo extends StatefulWidget {
  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  final TextEditingController _passwordController =
  TextEditingController(); // 비밀번호 입력 컨트롤러
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
    final user =
    Provider.of<UserProvider>(context); // Provider를 사용하여 사용자 정보 가져오기
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildProfileSection(user), // user를 전달하여 프로필 섹션에 데이터 사용
            _buildQnAButton(context),
            _buildEditInfoButton(context),
            _buildLogoutButton(context), // 로그아웃 버튼
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
      title: Text("내 정보", style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildProfileSection(UserProvider user) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: Image.asset('assets/images/pet.png', fit: BoxFit.contain),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                user.petName != null
                    ? _buildProfileText('이름: ${user.petName}')
                    : _buildProfileText('로그인 하세요'),
                user.petBirthDay != null
                    ? _buildProfileText(
                    '생일: ${_formatBirthDate(user.petBirthDay)}')
                    : SizedBox(),
                user.coins != 0
                    ? _buildProfileText('보유 포인트: ${user.coins}')
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Color(0xFF62807D),
          fontSize: 20,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
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

  // 비밀번호 확인 다이얼로그
  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("비밀번호 확인"),
          content: SingleChildScrollView(
            // 키보드가 올라왔을 때 스크롤이 가능하도록 함
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
                // 비밀번호 확인
                final enteredPassword = _passwordController.text;
                final correctPassword =
                    Provider
                        .of<UserProvider>(context, listen: false)
                        .password;

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
          // 로그아웃 처리
          Provider.of<UserProvider>(context, listen: false).logout();

          // 로그아웃 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('로그아웃 됨')),
          );

          // 로그인 화면으로 돌아가기
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

  int _currentIndex = 3;

  BottomNavigationBar _buildBottomNavigationBar(context) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      // 현재 선택된 인덱스
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
        setState(() {
          _currentIndex = index; // 인덱스 업데이트
        });
        switch (index) {
          case 0:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Shop(),
              ),
            );
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Walking(),
              ),
            );
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Shop()));
            break;
          case 2:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Walking()));
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