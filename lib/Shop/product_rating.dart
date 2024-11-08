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
              return Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/bfac95006ec7b6979ba7073999a3b86634dd7013faa6548be872dd9aa26aa46a?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                  width: 13,
                  height: 12);
            } else if (index < rating.ceil()) {
              return Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/c05c1dad1522258d11c19174b49dfd67fe67a9caa8d43e39174387424cf92791?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                  width: 13,
                  height: 12);
            } else {
              return Image.network(
                  'https://cdn.builder.io/api/v1/image/assets/TEMP/48ff786201979fae2ec9ce8a99ac1fb4d173a190a792f21ab36af943e9ed8de5?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                  width: 13,
                  height: 12);
            }
          }),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviews)',
          style: TextStyle(
            color: Color(0x801D1D1D),
            fontSize: 6,
            fontWeight: FontWeight.w400,
            fontFamily: 'Monument Extended',
          ),
        ),
      ],
    );
  }
}
