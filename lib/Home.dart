import 'package:flutter/material.dart';
import 'Login.dart';
import 'Shop.dart';
import 'Start.dart';
import 'Walking.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildProfileSection(),
            Expanded(child: _buildGridButtons(context)),
            _buildWalkingButton(context),
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
        icon: Icon(Icons.settings, color: Colors.black54),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Start()));
        },
      ),
      title: Text("Hot Dog", style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 30, 0, 30),
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: Image.asset('assets/pet.png', fit: BoxFit.contain),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProfileText('이름: DB처리'),
                _buildProfileText('생일: DB처리'),
                _buildProfileText('보유 포인트: DB처리'),
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

  Widget _buildGridButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 35, 0, 0),
      margin: const EdgeInsets.symmetric(horizontal: 32.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 32,
        mainAxisSpacing: 30,
        childAspectRatio: 1.6,
        children: [
          _buildButton('산책 매칭', () => print('산책 매칭 버튼 클릭')),
          _buildButton('임시 Login 페이지 망작', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
          }),
          _buildButton('Shop', () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Shop()));
          }),
          _buildButton('네 번째 매칭', () => print('네 번째 매칭 버튼 클릭')),
        ],
      ),
    );
  }

  Widget _buildWalkingButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      margin: EdgeInsets.only(bottom: 60),
      child: SizedBox(
        height: 100,
        width: double.infinity,
        child: _buildButton('산책하러가기', () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => Walking()));
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
              fontSize: 25,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // 아래로 쭉 하단바
  BottomNavigationBar _buildBottomNavigationBar(context) {
    return BottomNavigationBar(
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
            print('홈 선택됨');
            break;
          case 1:
            print('쇼핑 선택됨');
            Navigator.push(context, MaterialPageRoute(builder: (context) => Shop()));
            break;
          case 2:
            print('산책 선택됨');
            Navigator.push(context, MaterialPageRoute(builder: (context) => Walking()));
            break;
          case 3:
            print('내정보 선택됨');
            // 로직 아직 추가 안함
            break;
        }
      },
    );
  }
}
// 여기 껄쥐