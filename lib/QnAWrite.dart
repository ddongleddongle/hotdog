import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'User_Provider.dart'; // UserProvider import

class QnAWrite extends StatefulWidget {
  @override
  _QnAWriteState createState() => _QnAWriteState();
}

class _QnAWriteState extends State<QnAWrite> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _status = 'public'; // 글 상태 (default: public)

  // 글 등록 함수
  Future<void> _submitPost() async {
    final String title = _titleController.text;
    final String content = _contentController.text;

    // UserProvider에서 로그인된 사용자 정보를 가져옵니다.
    final user = Provider.of<UserProvider>(context, listen: false);
    final String email = user.email ?? ''; // 로그인된 사용자 EMAIL 사용

    if (title.isEmpty || content.isEmpty) {
      // 제목과 내용이 비어있으면 경고
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('제목과 내용을 입력해주세요.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // REST API로 POST 요청 보내기
    final response = await http.post(
      Uri.parse('http://116.124.191.174:15017/posts'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'title': title,
        'content': content,
        'status': _status, // 글 상태 (public, private)
      }),
    );

    if (response.statusCode == 200) {
      // 글이 성공적으로 등록되었을 경우
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success'),
          content: Text('글이 성공적으로 등록되었습니다!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // 글 작성 화면 종료 후 뒤로가기
              },
              child: Text('확인'),
            ),
          ],
        ),
      );
    } else {
      // 글 등록 실패 시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('글 등록에 실패했습니다. 다시 시도해주세요.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QnA 글쓰기'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목',
                labelStyle: TextStyle(
                  color: Color(0xFF62807D),
                  fontSize: 18,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF62807D)),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                labelStyle: TextStyle(
                  color: Color(0xFF62807D),
                  fontSize: 18,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF62807D)),
                ),
              ),
              maxLines: 6,
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _status,
              onChanged: (String? newValue) {
                setState(() {
                  _status = newValue!;
                });
              },
              items: <String>['public', 'private']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'public' ? '공개' : '비공개'),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitPost,
              child: Text('등록'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFAAD5D1),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}