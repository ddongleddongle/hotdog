import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String imageUrl;

  const ProductItem({Key? key, required this.imageUrl}) : super(key: key);

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
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
