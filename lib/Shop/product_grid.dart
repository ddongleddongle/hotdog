import 'package:flutter/material.dart';
import 'product_item.dart';
import 'product_rating.dart';
import 'product_info.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProductItem(
                imageUrl:
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/1ba66cc355262a017d88c5371f40ee7acf8ae46f0ce5db0b119cde413c1af288?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2'),
            ProductItem(
                imageUrl:
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/37db8fa1b70611557081f7dfabed8131f3d056086298edac4702e8b5919e80b1?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2'),
            ProductItem(
                imageUrl:
                    'https://cdn.builder.io/api/v1/image/assets/TEMP/fcb287690240b12f9aa9269b30f40f90ed50ed9b6106ee87087380f27cc2c3c6?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProductRating(rating: 4.5, reviews: 120),
            ProductRating(rating: 4.5, reviews: 74),
            ProductRating(rating: 4.0, reviews: 0),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProductInfo(name: 'Purina Pro Plan', match: 95),
            ProductInfo(name: 'Advance', match: 86),
            ProductInfo(name: 'Schesir Sterilized', match: 80),
          ],
        ),
      ],
    );
  }
}
