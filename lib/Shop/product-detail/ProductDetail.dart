import 'package:flutter/material.dart';
import 'product_header.dart';
import 'product_presentation.dart';
import 'product_content.dart';
import 'order_section.dart';
import 'product_review.dart'; // ReviewSection 추가
import '../ProductClass.dart'; // Product 모델 import

class ProductDetail extends StatelessWidget {
  final ProductClass product; // 상품 정보를 받을 변수

  const ProductDetail({Key? key, required this.product}) : super(key: key);

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
                  children: [
                    ProductHeader(),
                    const SizedBox(height: 16),
                    ProductPresentation(product: product), // 상품 정보를 전달
                    ProductContent(product: product),
                    ReviewSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: OrderSection(product: product), // const 제거
    );
  }
}
