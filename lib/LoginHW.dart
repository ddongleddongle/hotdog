import 'package:flutter/material.dart';
import 'home.dart'; // Home.dart 파일을 임포트합니다.

class LoginHW extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F1F1),
      body: Center(
        child: Container(
          width: 390,
          height: 844,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Color(0xFFF1F1F1)),
          child: Stack(
            children: [
              Positioned(
                left: 28,
                top: 678,
                child: GestureDetector(
                  onTap: () {
                    // Get Started 버튼 클릭 시 Home.dart로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
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
                              color:
                                  const Color(0xFFAAD5D1), // Get Started 버튼 색상
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(98),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 101,
                          top: 18,
                          child: const Text(
                            'Get Started',
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
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 115,
                top: 122,
                child: const Text(
                  'Sign in',
                  style: TextStyle(
                    color: Color(0xFF314B49),
                    fontSize: 48,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
              Positioned(
                left: 38,
                top: 230,
                child: Container(
                  width: 310,
                  height: 50,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 176,
                          height: 50,
                          decoration: ShapeDecoration(
                            color: const Color(0xFFAAD5D1), // With Google 버튼 색상
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(98),
                            ),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google.png', // Google 아이콘 이미지 경로
                                  width: 16,
                                  height: 16,
                                ),
                                const SizedBox(width: 8), // 아이콘과 텍스트 사이 간격
                                const Text(
                                  'With Google',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: 'Mulish',
                                    fontWeight: FontWeight.w500,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 193,
                        top: 0,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFB3E0DB),
                                width: 1), // 테두리 색상 및 두께
                            borderRadius: BorderRadius.circular(20), // 동그란 모서리
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/facebook.png', // Facebook 아이콘 이미지 경로
                              width: 16,
                              height: 16,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 260,
                        top: 0,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Color(0xFFB3E0DB),
                                width: 1), // 테두리 색상 및 두께
                            borderRadius: BorderRadius.circular(20), // 동그란 모서리
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/twitter.png', // Twitter 아이콘 이미지 경로
                              width: 16,
                              height: 16,
                            ),
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
                child: const Text(
                  'Or with Email',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 20,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w400,
                    height: 1,
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
                        color: Color(0xFFB3E0DB), width: 1), // 테두리 색상 및 두께
                    borderRadius: BorderRadius.circular(20), // 동그란 모서리
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 19,
                        child: const Text(
                          'Your Email',
                          style: TextStyle(
                            color: Color(0xFF3F2D20),
                            fontSize: 14,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w400,
                            height: 1,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 322,
                        top: 23,
                        child: Image.asset(
                          'assets/images/check.png', // 체크 아이콘 이미지 경로
                          width: 12,
                          height: 12,
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
                        color: Color(0xFFB3E0DB), width: 1), // 테두리 색상 및 두께
                    borderRadius: BorderRadius.circular(20), // 동그란 모서리
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 285,
                        top: 19,
                        child: const Text(
                          'Forgot?',
                          style: TextStyle(
                            color: Color(0xFFB3E0DB),
                            fontSize: 14,
                            fontFamily: 'Mulish',
                            fontWeight: FontWeight.w400,
                            height: 1,
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
                          height: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF0C0C0C),
                          fontSize: 16,
                          fontFamily: 'Mulish',
                          fontWeight: FontWeight.w700,
                          height: 1,
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
    );
  }
}
