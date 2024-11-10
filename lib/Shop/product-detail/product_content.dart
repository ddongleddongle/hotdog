import 'package:flutter/material.dart';
import '../ProductClass.dart';
import 'nutrition_info.dart';
import 'ingredients_carousel.dart';

class ProductContent extends StatelessWidget {
  final ProductClass product; // 상품 정보를 받을 변수

  const ProductContent({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                product.name, // 상품 이름 표시
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF32324D),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.price.toString(), // 가격 표시
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFF7B2C),
                    ),
                  ),
                  const Text(
                    'won',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB080),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666687),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          const NutritionInfo(),
          const SizedBox(height: 32),
          const IngredientsCarousel(),
        ],
      ),
    );
  }
}
