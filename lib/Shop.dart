import 'package:flutter/material.dart';
import 'Start.dart';

class Shop  extends StatelessWidget {
  const Shop ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.settings, color: Colors.black54), // 설정 아이콘
            onPressed: () {
              // 설정 화면으로 이동하는 로직 추가
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Start()), // Start 페이지로 이동
              );
            },
          ),
          title: Text(
            "SHOP",
          ),
        ),
      ),
    );
  }
}

