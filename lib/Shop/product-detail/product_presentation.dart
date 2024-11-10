import 'package:flutter/material.dart';
import '../ProductClass.dart'; // Product 모델 import

class ProductPresentation extends StatelessWidget {
  final ProductClass product; // 상품 정보를 받을 변수

  const ProductPresentation({Key? key, required this.product})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFCFCFC),
            Color(0xFFF7F7F7),
            Color(0xFFF7F7F7),
            Color(0xFFF7F7F7),
            Color(0xFFFCFCFC)
          ],
          stops: [0, 0.1004, 0.5156, 0.8958, 1],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 10, 32, 56),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  product.imageURL, // 로컬 이미지 경로 사용
                  width: 156,
                  fit: BoxFit.contain,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        '★',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(), // 상품의 평점 표시
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8EA9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
