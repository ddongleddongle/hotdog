import 'package:flutter/material.dart';

class IngredientsCarousel extends StatelessWidget {
  const IngredientsCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ingredients',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666687),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              IngredientItem(
                  image:
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/936af5314973c20e8b38cf811679834c16eddfb9ae050c5d8dedcff06443afd9?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                  name: 'Egg'),
              SizedBox(width: 16),
              IngredientItem(
                  image:
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/adf427c1a72b1d9b58ad07d9bf33edb0dad221fef3e49aa04b074a50d47370b6?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                  name: 'Avocado'),
              SizedBox(width: 16),
              IngredientItem(
                  image:
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/a3333b91f53ec7ef8160d22195247df6ee9c351a6d0f65c2a25a11efcf0783c1?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                  name: 'Spinach'),
              SizedBox(width: 16),
              IngredientItem(
                  image:
                      'https://cdn.builder.io/api/v1/image/assets/TEMP/e388f992cbbbb7311c94c536768c7a7e7248b2b4f2ee1afbc41aad64bea1ab0e?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                  name: 'Bread'),
            ],
          ),
        ),
      ],
    );
  }
}

class IngredientItem extends StatelessWidget {
  final String image;
  final String name;

  const IngredientItem({Key? key, required this.image, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            image,
            width: 20,
            height: 20,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E8EA9),
            ),
          ),
        ],
      ),
    );
  }
}
