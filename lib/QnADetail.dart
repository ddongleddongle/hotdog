import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'User_Provider.dart';

class QnADetail extends StatefulWidget {
  final String title;
  final String content;
  final String authorEmail;

  QnADetail({
    super.key,
    required this.title,
    required this.content,
    required this.authorEmail,
  });

  @override
  _QnADetailState createState() => _QnADetailState();
}

class _QnADetailState extends State<QnADetail> {
  final TextEditingController _commentController = TextEditingController();
  List<String> comments = []; // 예시용 댓글 목록

  // 댓글 추가 함수
  void _addComment(String comment) {
    setState(() {
      comments.add(comment);
    });
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
              widget.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '작성자: ${widget.authorEmail}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Text(
              widget.content,
              style: TextStyle(fontSize: 18),
            ),
            Divider(height: 32, thickness: 1),
            Text(
              '댓글',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(comments[index]),
                  );
                },
              ),
            ),
            if (user.email == 'admin') // email이 admin일 때만 댓글 입력란 보이기
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: '댓글을 입력하세요',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        _addComment(_commentController.text);
                      }
                    },
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  '댓글 작성은 관리자만 가능합니다.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}