import 'package:flutter/material.dart';

class ProductRating extends StatelessWidget {
  final double rating;
  final int reviews;

  const ProductRating({Key? key, required this.rating, required this.reviews})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: List.generate(5, (index) {
            if (index < rating.floor()) {
              return const Text(
                '★', // 채워진 별
                style: TextStyle(
                  color: Color(0xFFAAD5D1), // 별 색상
                  fontSize: 12, // 별 크기
                ),
              );
            } else if (index < rating.ceil()) {
              return const Text(
                '★', // 반짝이는 별
                style: TextStyle(
                  color: Color(0xFFAAD5D1), // 별 색상
                  fontSize: 12,
                ),
              );
            } else {
              return const Text(
                '☆', // 빈 별
                style: TextStyle(
                  color: Color(0xFFAAD5D1), // 별 색상
                  fontSize: 12,
                ),
              );
            }
          }),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviews)',
          style: TextStyle(
            color: const Color(0x801D1D1D),
            fontSize: 6,
            fontWeight: FontWeight.w400,
            fontFamily: 'Monument Extended',
          ),
        ),
      ],
    );
  }
}
