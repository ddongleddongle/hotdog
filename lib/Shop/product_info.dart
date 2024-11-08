import 'package:flutter/material.dart';

class ProductInfo extends StatelessWidget {
  final String name;
  final int match;

  const ProductInfo({Key? key, required this.name, required this.match})
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
            fontSize: 8,
            fontWeight: FontWeight.w400,
            fontFamily: 'Monument Extended',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$match% Match',
          style: TextStyle(
            color: Color(0xFF84C1BE),
            fontSize: 6,
            fontWeight: FontWeight.w400,
            fontFamily: 'Monument Extended',
          ),
        ),
      ],
    );
  }
}
