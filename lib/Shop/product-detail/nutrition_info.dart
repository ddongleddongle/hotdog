import 'package:flutter/material.dart';

class NutritionInfo extends StatelessWidget {
  const NutritionInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          NutritionItem(value: '400', unit: 'kcal'),
          NutritionItem(value: '510', unit: 'grams'),
          NutritionItem(value: '30', unit: 'proteins'),
          NutritionItem(value: '56', unit: 'carbs'),
          NutritionItem(value: '24', unit: 'fats'),
        ],
      ),
    );
  }
}

class NutritionItem extends StatelessWidget {
  final String value;
  final String unit;

  const NutritionItem({Key? key, required this.value, required this.unit})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A2D78),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666687),
          ),
        ),
      ],
    );
  }
}
