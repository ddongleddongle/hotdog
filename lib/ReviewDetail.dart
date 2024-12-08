import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // flutter_rating_bar 패키지 임포트
import 'Home.dart';
import 'MyInfo.dart';
import 'Mapscreen.dart';
import 'Community.dart';
import 'Shop/Shop.dart';

class ReviewDetail extends StatefulWidget {
  final int locationId; // locationId를 받습니다

  ReviewDetail({required this.locationId});

  @override
  _ReviewDetailState createState() => _ReviewDetailState();
}

class _ReviewDetailState extends State<ReviewDetail> {
  List<dynamic> reviews = [];
  bool isLoading = true;

  // 새 리뷰 입력을 위한 텍스트 필드와 별점 변수
  TextEditingController reviewController = TextEditingController();
  double userRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchReviewDetail(widget.locationId); // locationId를 전달하여 리뷰를 가져옵니다.
  }

  // 리뷰 상세 데이터를 서버에서 가져오는 함수
  Future<void> fetchReviewDetail(int locationId) async {
    final url = 'http://116.124.191.174:15017/getReviews?location_id=$locationId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        List<dynamic> data = json.decode(response.body); // 여러 리뷰가 들어있는 리스트
        reviews = data; // 여러 리뷰 리스트 저장
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('상세 정보 가져오기 실패');
    }
  }

  Future<void> submitReview() async {
    if (reviewController.text.isEmpty) {
      // 리뷰 내용이 비어있으면 제출하지 않음
      return;
    }

    final url = 'http://116.124.191.174:15017/submitReview';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json', // JSON 형식으로 보내기 위해 Content-Type을 설정
      },
      body: json.encode({
        'location_id': widget.locationId,
        'text': reviewController.text,
        'review': userRating.toString(),
      }),
    );

    if (response.statusCode == 200) {
      // 리뷰 제출 성공 후 리뷰 목록을 다시 가져옴
      fetchReviewDetail(widget.locationId); // 새로운 리뷰 목록을 가져옵니다.
      reviewController.clear(); // 입력 필드 초기화
      userRating = 0.0; // 별점 초기화

      // 성공적으로 등록되었음을 알리는 다이얼로그 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('성공'),
            content: Text('리뷰가 성공적으로 등록되었습니다.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );

      print('리뷰가 성공적으로 제출되었습니다!');
    } else {
      print('리뷰 제출 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : Column(
        children: [
          // 리뷰 목록
          Expanded(
            child: reviews.isEmpty
                ? Center(child: Text("리뷰가 존재하지 않습니다"))
                : ListView.builder(
              itemCount: reviews.length, // 여러 리뷰 수
              itemBuilder: (context, index) {
                var review = reviews[index]; // 각 리뷰
                double rating = 0.0;

                // review['review']가 문자열일 경우 이를 double로 변환
                if (review['review'] is String) {
                  rating = double.tryParse(review['review']) ?? 0.0;
                } else if (review['review'] is num) {
                  rating = review['review'].toDouble();
                }

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // flutter_rating_bar 위젯을 사용하여 별점 표시
                          RatingBarIndicator(
                            rating: rating,
                            // 정확한 rating 값을 전달
                            itemCount: 5,
                            itemSize: 30,
                            // 아이템 크기 설정
                            direction: Axis.horizontal,
                            itemBuilder: (context, index) =>
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                          ),
                          SizedBox(height: 8),
                          Text('${review['text'] ?? 'No text'}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(), // 리뷰 작성 구분선
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // 별점 입력
                RatingBar.builder(
                  initialRating: userRating,
                  minRating: 0,
                  itemCount: 5,
                  itemSize: 30,
                  itemBuilder: (context, index) =>
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      userRating = rating;
                    });
                  },
                ),
                SizedBox(height: 10),
                // 리뷰 입력 필드
                TextField(
                  controller: reviewController,
                  decoration: InputDecoration(
                    hintText: "리뷰를 작성하세요",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          // 리뷰 작성 버튼을 하단으로 고정
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: submitReview,
                child: Text("리뷰 작성"),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      // 하단 네비게이션 바 추가
      floatingActionButton: _buildWalkingButton(context),
      // 산책 버튼 추가
      floatingActionButtonLocation: FloatingActionButtonLocation
          .centerDocked, // 중앙에 배치
    );
  }
}

  BottomNavigationBar _buildBottomNavigationBar(context) {
  return BottomNavigationBar(
    currentIndex: 3,
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
        icon: Icon(null),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.comment),
        label: '커뮤니티',
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
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Home()));
          break;
        case 1:
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Shop()));
          break;
        case 3:
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Community(),
              ));
          break;
        case 4:
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MyInfo()));
          break;
      }
    },
  );
}

Widget _buildWalkingButton(BuildContext context) {
  return Container(
    width: 90,
    height: 90,
    margin: EdgeInsets.only(top: 30),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      border: Border.all(
        color: Color(0xFFAAD5D1),
        width: 3,
      ),
    ),
    child: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()),
        );
      },
      backgroundColor: Colors.transparent,
      child: Icon(
        Icons.pets,
        size: 65,
        color: Color(0xFFAAD5D1),
      ),
      elevation: 0,
    ),
  );
}

