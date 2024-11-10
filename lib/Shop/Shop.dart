import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:software/MyInfo.dart';
import 'dart:convert';
import 'welcome_header.dart';
import 'category_button.dart';
import 'product_grid.dart';
import '../Home.dart';
import '../walking.dart'; // Walking 페이지를 임포트합니다.
import 'ProductClass.dart'; // Product 모델을 임포트합니다.

class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  List<ProductClass> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final response =
          await http.get(Uri.parse('http://116.124.191.174:15017/shop'));

      if (response.statusCode == 200) {
        final List<dynamic> productList =
            json.decode(response.body)['products'];
        setState(() {
          products =
              productList.map((json) => ProductClass.fromJson(json)).toList();
          isLoading = false; // 데이터 로딩 완료
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error fetching products: $error');
      setState(() {
        isLoading = false; // 에러 발생 시 로딩 종료
      });
    }
  }

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
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ProductGrid(products: products), // ProductGrid에 상품 목록 전달
                const SizedBox(height: 57),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: '쇼핑',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: '산책',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '내정보',
        ),
      ],
      backgroundColor: Color(0xFFAAD5D1),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      iconSize: 30,
      selectedFontSize: 16,
      unselectedFontSize: 14,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ),
            );
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Shop(),
              ),
            );
          case 2:
            print('산책 선택됨');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Walking(),
              ),
            );
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyInfo(),
              ),
            );
        }
      },
    );
  }
}
