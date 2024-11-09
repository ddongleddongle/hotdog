import 'package:flutter/material.dart';
import 'product_header.dart';
import 'product_presentation.dart';
import 'product_content.dart';
import 'order_section.dart';
import 'product_review.dart'; // ReviewSection 추가
import 'ingredients_carousel.dart'; // IngredientsCarousel 추가

class product extends StatelessWidget {
  const product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(0, 56, 0, 6),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: const [
                    ProductHeader(),
                    SizedBox(height: 16),
                    ProductPresentation(),
                    ProductContent(),
                    ReviewSection(), // 리뷰 섹션 추가
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const OrderSection(), // OrderSection을 하단바로 설정
    );
  }
}
