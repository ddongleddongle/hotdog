import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String imageUrl;

  const ProductItem({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 109,
      height: 109,
      decoration: BoxDecoration(
        color: Color(0xFF84C1BE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
