import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // UserProvider 사용을 위한 import
import 'QnAWrite.dart';
import 'QnADetail.dart';
import 'User_Provider.dart';

// QnA 화면
class QnA extends StatefulWidget {
  @override
  _QnAState createState() => _QnAState();
}

class _QnAState extends State<QnA> {
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts(); // 페이지가 로드될 때 게시글 가져오기
  }

  // 서버에서 게시글 목록 가져오기
  Future<void> fetchPosts() async {
    final response = await http.get(Uri.parse('http://116.124.191.174:15017/posts'));

    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body); // 응답 데이터를 리스트로 저장
      });
    } else {
      print('데이터 가져오기 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    // UserProvider에서 데이터 가져오기
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QnA'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: posts.isEmpty
          ? Center(child: Text('게시글이 없습니다.'))
          : ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          bool isPrivate = post['status'] == 'private' && post['email'] != user.email;

          return ListTile(
            title: Text(post['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isPrivate
                    ? Text('비밀글입니다.', style: TextStyle(color: Colors.grey[700]))
                    : Text(post['content'], maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('작성자: ${post['email']}', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            trailing: isPrivate
                ? Icon(Icons.lock, color: Colors.grey)
                : Icon(Icons.arrow_forward_ios),
            onTap: () {
              if (isPrivate) {
                if (post['email'] == user.email) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QnADetail(
                        title: post['title'],
                        content: post['content'],
                      ),
                    ),
                  );
                } else {
                  // 비공개 글에 접근할 수 없는 경우 알림 표시
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('비공개 글입니다. 본인만 접근할 수 있습니다.')),
                  );
                }
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QnADetail(
                      title: post['title'],
                      content: post['content'],
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QnAWrite(),
            ),
          );
        },
        backgroundColor: Color(0xFFAAD5D1),
        child: const Icon(Icons.edit),
        tooltip: '글쓰기',
      ),
    );
  }
}