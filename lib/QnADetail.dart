import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'User_Provider.dart';

class QnADetail extends StatelessWidget {
  final String title;
  final String content;

  QnADetail({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    // UserProvider에서 email 가져오기
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('글 상세보기'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            // UserProvider에서 이메일 가져오기
            Text(
              '작성자: ${user.email ?? '알 수 없음'}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}