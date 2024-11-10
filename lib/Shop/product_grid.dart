import 'package:flutter/material.dart';
import 'product_item.dart';
import 'product-detail/ProductDetail.dart'; // ProductDetail 페이지를 import합니다.
import 'ProductClass.dart'; // ProductClass 모델을 import합니다.

class ProductGrid extends StatelessWidget {
  final List<ProductClass> products; // 상품 목록을 받기 위한 매개변수

  const ProductGrid({Key? key, required this.products})
      : super(key: key); // 매개변수 추가

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: products.map((product) {
            return _buildProductColumn(
              context,
              product, // ProductClass 인스턴스를 전달
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductColumn(BuildContext context, ProductClass product) {
    return GestureDetector(
      // 클릭 감지
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetail(product: product), // ProductDetail로 이동
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductItem(imageURL: product.imageURL), // 상품 이미지 URL
          const SizedBox(height: 8),
          ProductRating(
              rating: product.rating, reviews: product.reviews), // 상품 평점
          const SizedBox(height: 4),
          ProductInfo(
              name: product.name, matchScore: product.matchScore), // 상품 정보
        ],
      ),
    );
  }
}
