import 'package:flutter/material.dart';
import 'package:software/Start.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [Column(
          children: [
            Container(
              width: 390,
              height: 844,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Color(0xFFF1F1F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -503,
                    top: 362,
                    child: Container(
                      width: 241.07,
                      height: 262.74,
                      child: Stack(
                        children: [
                          Positioned(
                            left: -8.93,
                            top: -5.54,
                            child: Container(
                              width: 249.85,
                              height: 268.13,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: 249.85,
                                      height: 268.13,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('google.png'), // AssetImage를 사용하여 이미지 경로를 설정합니다.
                                          fit: BoxFit.cover, // 원하는 fit 옵션을 설정합니다.
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 479.66,
                            top: 211.84,
                            child: Transform(
                              transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-3.14),
                              child: Container(
                                width: 129.52,
                                height: 179.46,
                                decoration: ShapeDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(0.00, -1.00),
                                    end: Alignment(0, 1),
                                    colors: [Color(0xFFEF7E06), Color(0x00C4C4C4)],
                                  ),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(width: 3, color: Colors.white),
                                    borderRadius: BorderRadius.circular(27),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: -913,
                    top: 129,
                    child: Container(
                      width: 501,
                      height: 544,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('google.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -455,
                    top: 140,
                    child: Container(
                      width: 431,
                      height: 419,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('google.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 986,
                    child: Container(
                      width: 390,
                      height: 437,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(120),
                            topRight: Radius.circular(120),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 128,
                    top: 827,
                    child: Container(
                      width: 134,
                      height: 7,
                      decoration: ShapeDecoration(
                        color: Color(0xFFF3EFE8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 28,
                    top: 1309,
                    child: Container(
                      width: 335,
                      height: 65,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 335,
                              height: 65,
                              decoration: ShapeDecoration(
                                color: Color(0xFFB3E0DB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(98),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 8,
                            top: 4,
                            child: Container(
                              width: 57,
                              height: 57,
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: 57,
                                      height: 57,
                                      decoration: ShapeDecoration(
                                        color: Color(0xFF0C0C0C),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 5,
                                    top: 15,
                                    child: Transform(
                                      transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(-0.27),
                                      child: Container(
                                        width: 38,
                                        height: 37.99,
                                        child: Stack(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 28,
                    top: 678,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => Start(),
                      )),
                      child: Container(
                        width: 335,
                        height: 65,
                        decoration: ShapeDecoration(
                          color: Color(0xFFAAD5D1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(98),
                          ),
                        ),
                        child: Center( // Center 위젯을 사용하여 중앙 정렬
                          child: Text(
                            'Get Started',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w700,
                              height: 0.06,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 115,
                    top: 122,
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color(0xFF314B49),
                        fontSize: 48,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w800,
                        height: 0,
                      ),
                    ),
                  ),
                Positioned(
                  left: 38,
                  top: 230,
                  child: Container(
                    width: 310,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.transparent, // 배경색을 투명으로 설정
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 176,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFFAAD5D1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row( // Row를 사용하여 아이템을 가로로 배치
                            mainAxisAlignment: MainAxisAlignment.center, // 가로 중앙 정렬
                            crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
                            children: [
                              Image.asset(
                                'google.png',
                                height: 20,
                                width: 20,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'With Google',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Mulish',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10), // 아이콘과의 간격
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFAAD5D1)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center( // Center로 아이콘 중앙 정렬
                            child: Image.asset(
                              'facebook.png',
                              height: 20, // 아이콘 크기 조정
                              width: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 10), // 아이콘과의 간격
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFAAD5D1)),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center( // Center로 아이콘 중앙 정렬
                            child: Image.asset(
                              'twitter.png',
                              height: 20, // 아이콘 크기 조정
                              width: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                  Positioned(
                    left: 133,
                    top: 328,
                    child: Text(
                      'Or with Email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF444444),
                        fontSize: 20,
                        fontFamily: 'Mulish',
                        fontWeight: FontWeight.w400,
                        height: 0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 409,
                    child: Container(
                      width: 350,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFB3E0DB), // 테두리 색상
                          width: 1.0, // 테두리 두께
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                        ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 20,
                            top: 19,
                            child: Text(
                              'Your Email',
                              style: TextStyle(
                                color: Color(0xFF3F2D20),
                                fontSize: 14,
                                fontFamily: 'Mulish',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 322,
                            top: 23,
                            child: Image.asset(
                                'check.png'
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    top: 493,
                    child: Container(
                      width: 350,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xFFB3E0DB), // 테두리 색상
                          width: 1.0, // 테두리 두께
                        ),
                        borderRadius: BorderRadius.circular(8.0), // 테두리 모서리 둥글기 (선택 사항)
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 285,
                            top: 19,
                            child: Text(
                              'Forgot?',
                              style: TextStyle(
                                color: Color(0xFFB3E0DB),
                                fontSize: 14,
                                fontFamily: 'Mulish',
                                fontWeight: FontWeight.w400,
                                height: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
        
                  ),
                  Positioned(
                    left: 127,
                    top: 783,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'New User? ',
                            style: TextStyle(
                              color: Color(0xFF73665C),
                              fontSize: 14,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF0C0C0C),
                              fontSize: 16,
                              fontFamily: 'Mulish',
                              fontWeight: FontWeight.w700,
                              height: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]
      ),
    );
  }
}