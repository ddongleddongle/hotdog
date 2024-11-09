import 'package:flutter/material.dart';
import 'product_item.dart';
import 'product-detail/product.dart'; // Product.dart를 import합니다.

class ProductGrid extends StatelessWidget {
  const ProductGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProductColumn(
              context, // context를 전달합니다.
              'https://cdn.builder.io/api/v1/image/assets/TEMP/1ba66cc355262a017d88c5371f40ee7acf8ae46f0ce5db0b119cde413c1af288?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
              4.5,
              120,
              'Purina Pro Plan',
              95,
            ),
            _buildProductColumn(
              context, // context를 전달합니다.
              'https://cdn.builder.io/api/v1/image/assets/TEMP/37db8fa1b70611557081f7dfabed8131f3d056086298edac4702e8b5919e80b1?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
              4.5,
              74,
              'Advance',
              86,
            ),
            _buildProductColumn(
              context, // context를 전달합니다.
              'https://cdn.builder.io/api/v1/image/assets/TEMP/fcb287690240b12f9aa9269b30f40f90ed50ed9b6106ee87087380f27cc2c3c6?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
              4.0,
              0,
              'Schesir Sterilized',
              80,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductColumn(BuildContext context, String imageUrl,
      double rating, int reviews, String name, int match) {
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
          ProductItem(imageUrl: imageUrl),
          const SizedBox(height: 8),
          ProductRating(rating: rating, reviews: reviews),
          const SizedBox(height: 4),
          ProductInfo(name: name, match: match),
        ],
      ),
    );
  }
}
