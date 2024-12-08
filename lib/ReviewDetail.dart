import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReviewDetail extends StatefulWidget {
  final int locationId;

  // 생성자에서 locationId를 받아옴
  ReviewDetail({required this.locationId});

  @override
  _ReviewDetailState createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {
  Map<String, dynamic> reviewDetail = {}; // 리뷰 상세 정보 저장
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchReviewDetail(widget.locationId); // locationId에 해당하는 리뷰 상세 정보 가져오기
  }

  // 서버에서 리뷰 상세 정보 가져오기
  Future<void> fetchReviewDetail(int locationId) async {
    final url = 'http://116.124.191.174:15017/getReviewDetail?location_id=$locationId'; // 서버에서 상세 정보 요청
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        reviewDetail = json.decode(response.body); // 응답 데이터를 리뷰 상세 정보로 저장
        isLoading = false; // 로딩 완료
      });
    } else {
      setState(() {
        isLoading = false; // 로딩 실패
      });
      print('상세 정보 가져오기 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('리뷰 상세'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중에는 로딩 인디케이터 표시
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '리뷰: ${reviewDetail['review'] ?? 'No review'}', // 리뷰 필드 표시
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 10),
            Text(
              '상세 내용: ${reviewDetail['text'] ?? 'No text available'}', // text 필드 표시
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
