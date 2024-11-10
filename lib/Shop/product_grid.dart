import 'package:flutter/material.dart';
import 'product_item.dart';
import 'product-detail/product.dart'; // Product.dart를 import합니다.
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
              product.imageURL, // 상품 이미지 URL
              product.rating, // 상품 평점
              product.reviews,
              product.name,
              product.matchScore,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductColumn(BuildContext context, String imageURL,
      double rating, double reviews, String name, double matchScore) {
    return GestureDetector(
      // 클릭 감지
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => product(), // Product.dart의 ProductPage로 이동
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductItem(imageURL: imageURL),
          const SizedBox(height: 8),
          ProductRating(rating: rating, reviews: reviews),
          const SizedBox(height: 4),
          ProductInfo(name: name, matchScore: matchScore),
        ],
      ),
    );
  }
}
