import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              'https://cdn.builder.io/api/v1/image/assets/TEMP/55d0a08f7c6fb87e79bfa7f421251de2401b0da47c0ca8d600aa8ca25d504308?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 29),
            Text(
              'Welcome shop',
              style: TextStyle(
                color: Color(0xFF324B49),
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontFamily: 'Mulish',
              ),
            ),
          ],
        ),
        const SizedBox(width: 78),
        Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: Image.network(
                'https://cdn.builder.io/api/v1/image/assets/TEMP/6c43bc2c65757942b4c22d11f34094922ae8db10babb7d328beb2581cf78a412?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 26),
            Image.network(
              'https://cdn.builder.io/api/v1/image/assets/TEMP/c10999444e8bd7a04cec62accf3de8898274388d4d89ea50ca9fc62bd40995af?placeholderIfAbsent=true&apiKey=5a2bd66ac2224367918a8ced0d986eb2',
              width: 37,
              height: 58,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ],
    );
  }
}
