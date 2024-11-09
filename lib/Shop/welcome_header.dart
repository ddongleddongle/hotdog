import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.menu, // 메뉴 아이콘 사용
              size: 36, // 아이콘 크기
              color: Color(0xFF62807D), // 아이콘 색상
            ),
            const SizedBox(height: 29),
            Text(
              'Welcome shop',
              style: TextStyle(
                color: Color(0xFF324B49),
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontFamily: 'Mulish',
              ),
            ),
          ],
        ),
        const Spacer(), // 남은 공간을 차지하여 오른쪽으로 이동
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: Image.asset(
                'assets/images/pet.png', // 프로필 이미지 경로
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 26),
            Icon(
              Icons.search, // 검색 아이콘 사용
              size: 37, // 아이콘 크기
              color: const Color.fromARGB(255, 163, 163, 163), // 아이콘 색상
            ),
          ],
        ),
      ],
    );
  }
}
