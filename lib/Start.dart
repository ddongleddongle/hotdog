import 'package:flutter/material.dart';
import 'Home.dart';
import 'Login.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    // 1초 후에 Login 화면으로 이동
    Future.delayed(Duration(milliseconds: 1000), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity, // 화면 너비에 맞추기
        height: double.infinity, // 화면 높이에 맞추기
        color: Color(0xFFB3E0DB),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Image.asset('assets/images/logo.png', width: 200, height: 200, fit: BoxFit.cover, ),
                
                const SizedBox(height: 20),
                const Text(
                  "동반자와 함께 떠나는 모험",
                  style: TextStyle(fontSize: 25, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20), // 아래쪽 여백 추가
                const Text(
                  "핫도그",
                  style: TextStyle(fontSize: 50, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60), // 아래쪽 여백 추가
              ],
            ),
          ),
        ),
      ),
    );
  }
}