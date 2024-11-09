import 'package:flutter/material.dart';

class ReviewSection extends StatelessWidget {
  const ReviewSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666687),
            ),
          ),
          const SizedBox(height: 10),
          // 예시 리뷰
          _buildReview('Great product!', 5),
          _buildReview('I really liked it.', 4),
          _buildReview('Could be better.', 3),
        ],
      ),
    );
  }

  Widget _buildReview(String text, int rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // 별점 표시
          Row(
            children: List.generate(rating,
                (index) => const Icon(Icons.star, color: Color(0xFFAAD5D1))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
