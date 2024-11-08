import 'package:flutter/material.dart';
import 'welcome_header.dart';
import 'category_button.dart';
import 'product_grid.dart';

class Shop extends StatelessWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 59, 18, 163),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WelcomeHeader(),
                const SizedBox(height: 27),
                const CategoryButton(),
                const SizedBox(height: 29),
                ProductGrid(),
                const SizedBox(height: 57),
                ProductGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
