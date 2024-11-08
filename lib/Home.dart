import 'package:flutter/material.dart';
import 'Login.dart';
import '/Shop/Shop.dart';
import 'Start.dart';
import 'Walking.dart';
import 'LoginHW.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.settings, color: Colors.black54), // 설정 아이콘
          onPressed: () {
            // 설정 화면으로 이동하는 로직 추가
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Start()), // Start 페이지로 이동
            );
          },
        ),
        title: Text("Home Page",
            style: TextStyle(color: Colors.black)), // 제목을 더 명확하게 설정
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 60),
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1, // 이미지가 차지할 비율
                    child: Image.asset('assets/images/pet.png',
                        fit: BoxFit.contain), // 이미지 비율 유지
                  ),
                  Expanded(
                    flex: 2, // 텍스트가 차지할 비율
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // 텍스트 중앙 정렬
                      children: [
                        SizedBox(
                          width: 225,
                          height: 59,
                          child: Text(
                            '보리\n10살(2015.xx.xx생)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF62807D),
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '보유 포인트 : 1,000p',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF63817E),
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 50),
                margin: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GridView(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 32,
                    mainAxisSpacing: 30,
                    childAspectRatio: 1.6,
                  ),
                  children: [
                    buildContainer(
                      '산책 매칭',
                      () {
                        // 첫 번째 버튼 클릭 시 실행할 코드
                        print('산책 매칭 버튼 클릭');
                      },
                    ),
                    buildContainer(
                      '임시 Login 페이지 망작',
                      () {
                        // 두 번째 버튼 클릭 시 실행할 코드
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginHW()), // Start 페이지로 이동
                        );
                      },
                    ),
                    buildContainer(
                      'Shop',
                      () {
                        // 세 번째 버튼 클릭 시 실행할 코드
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Shop()), // Start 페이지로 이동
                        );
                      },
                    ),
                    buildContainer(
                      '네 번째 매칭',
                      () {
                        // 네 번째 버튼 클릭 시 실행할 코드
                        print('네 번째 매칭 버튼 클릭');
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(30),
                margin: EdgeInsets.only(bottom: 100),
                child: buildContainer("산책하러가기", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Walking()), // Start 페이지로 이동
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buildContainer(String message, VoidCallback onPressed) {
    return Container(
      decoration: ShapeDecoration(
        color: Color(0xFFAAD5D1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // 배경색 투명
          shadowColor: Colors.transparent, // 그림자 없애기
          padding: EdgeInsets.all(0), // 패딩 제거
        ),
        onPressed: onPressed,
        child: Center(
          child: Text(
            message, // 전달된 message를 사용
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
}
