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
import 'Community.dart';
import 'MyInfo.dart';
import 'Mapscreen.dart';
import 'Walking.dart';
import 'test.dart';

class Community extends StatefulWidget {
  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(
        context); // Provider를 사용하여 사용자 정보 가져오기
    return Scaffold(
        body: GestureDetector(
        onHorizontalDragEnd: (details) {
      // 좌우 스와이프 시 화면 전환
      if (details.primaryVelocity! < 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyInfo()),
        );
      }
      else if (details.primaryVelocity! > 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      }
    },
      child: Stack(
        children: [
          // 다른 UI 요소들...
        ],
      ),
        ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildWalkingButton(context), // 산책 버튼 추가
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // 중앙에 배치
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(context) {
    final user = Provider.of<UserProvider>(context);
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
          icon: Icon(null),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.comment),
          label: '커뮤니티',
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
            break;
          case 1:
            print('쇼핑 선택됨');
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Shop()));
            break;
          case 2:
            break;
          case 3:
            print('커뮤니티 선택됨');
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Community(),
                ));
            break;
          case 4:
            print('내정보 선택됨');
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyInfo()));
            break;
        }
      },
    );
  }

  Widget _buildWalkingButton(BuildContext context) {
    return Container(
      width: 90,
      // 버튼의 너비
      height: 90,
      // 버튼의 높이
      margin: EdgeInsets.only(top: 30),
      // 아래쪽 여백 추가
      decoration: BoxDecoration(
        shape: BoxShape.circle, // 동그란 모양
        color: Colors.white, // 버튼 색상
        border: Border.all(
          color: Color(0xFFAAD5D1), // 테두리 색상
          width: 3, // 테두리 두께
        ),
      ),
      child: FloatingActionButton(
        onPressed: () {
          // 산책 버튼 클릭 시 처리
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          );
        },
        backgroundColor: Colors.transparent, // 투명하게 설정
        child: Icon(
          Icons.pets,
          size: 65, // 아이콘 크기
          color: Color(0xFFAAD5D1), // 아이콘 색상
        ),
        elevation: 0, // 그림자 제거
      ),
    );
  }
}
