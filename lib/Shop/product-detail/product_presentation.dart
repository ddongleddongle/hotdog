import 'package:flutter/material.dart';

class ProductPresentation extends StatelessWidget {
  const ProductPresentation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFCFCFC),
            Color(0xFFF7F7F7),
            Color(0xFFF7F7F7),
            Color(0xFFF7F7F7),
            Color(0xFFFCFCFC)
          ],
          stops: [0, 0.1004, 0.5156, 0.8958, 1],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(80, 10, 32, 56),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/8b5c3cbf447a60efa20bd527f6e07ee9ba60eeead2bd34939ad08101c24468c2?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                  width: 156,
                  fit: BoxFit.contain,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                    children: [
                      Text(
                        '★', // 채워진 별
                        style: TextStyle(
                          color: Colors.amber, // 별 색상
                          fontSize: 12, // 별 크기
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.0',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8E8EA9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
