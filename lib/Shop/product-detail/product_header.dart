import 'package:flutter/material.dart';

class ProductHeader extends StatelessWidget {
  const ProductHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.menu, // 메뉴 아이콘 사용
            size: 36, // 아이콘 크기
            color: Color(0xFF62807D), // 아이콘 색상
          ),
          Image.network(
            'https://cdn.builder.io/api/v1/image/assets/TEMP/6c43bc2c65757942b4c22d11f34094922ae8db10babb7d328beb2581cf78a412?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
