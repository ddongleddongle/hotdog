import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String imageURL;

  const ProductItem({Key? key, required this.imageURL}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 200, 230, 230),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Image.asset(
          imageURL,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class ProductRating extends StatelessWidget {
  final double rating;
  final double reviews;

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
                  color: Color(0xFF84C1BE), // 별 색상
                  fontSize: 12, // 별 크기
                ),
              );
            } else if (index < rating.ceil()) {
              return const Text(
                '★', // 반짝이는 별
                style: TextStyle(
                  color: Color(0xFF84C1BE), // 별 색상
                  fontSize: 12,
                ),
              );
            } else {
              return const Text(
                '☆', // 빈 별
                style: TextStyle(
                  color: Color(0xFF84C1BE), // 별 색상
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

class ProductInfo extends StatelessWidget {
  final String name;
  final double matchScore;

  const ProductInfo({Key? key, required this.name, required this.matchScore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(
            color: Color(0xFF1D1D1D),
            fontSize: 10,
            fontWeight: FontWeight.w400,
            fontFamily: 'Monument Extended',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$matchScore% Match',
          style: TextStyle(
            color: Color(0xFF84C1BE),
            fontSize: 8,
            fontWeight: FontWeight.w400,
            fontFamily: 'Monument Extended',
          ),
        ),
      ],
    );
  }
}
