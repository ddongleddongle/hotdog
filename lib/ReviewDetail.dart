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
  Map<String, dynamic> location = {}; // location 정보를 저장할 변수

  // 새 리뷰 입력을 위한 텍스트 필드와 별점 변수
  TextEditingController reviewController = TextEditingController();
  double userRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchReviewDetail(widget.locationId); // locationId를 전달하여 리뷰를 가져옵니다.
  }

  Future<void> fetchReviewDetail(int locationId) async {
    final url = 'http://116.124.191.174:15017/getReviews?location_id=$locationId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> data = json.decode(response.body); // 서버 응답은 Map 형태
        print(data); // 응답 데이터를 출력하여 확인합니다

        // 서버 응답에서 'reviews'와 'location' 데이터를 올바르게 추출합니다
        if (data.containsKey('reviews') && data['reviews'] is List) {
          reviews = List<dynamic>.from(data['reviews']); // reviews 배열만 추출
        } else {
          print('reviews 데이터를 찾을 수 없습니다');
        }

        if (data.containsKey('location') && data['location'] is List) {
          location = data['location'].first; // location은 배열 형태이므로 첫 번째 항목을 가져옵니다
        } else {
          print('location 데이터를 찾을 수 없습니다');
        }

        setState(() {
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('서버 데이터 처리 중 오류 발생: $e');
      }
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
        backgroundColor: Color(0xFFAAD5D1),
        title: Text(
          "Reviews",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : Column(
        children: [
          // 상단 이미지 (화면 가득 채우기)
          Container(
            padding: EdgeInsets.zero,  // 여백을 없애줍니다
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Image.asset(
              'assets/location/${location['name'] ?? 'default_image'}.jpg',
              fit: BoxFit.cover, // 이미지 크기에 맞게 잘림
            ),
          ),

          // 장소 정보 표시
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 기본값이므로 이미 왼쪽 정렬입니다
              children: [
                Align(
                  alignment: Alignment.centerLeft, // 왼쪽 정렬을 강제합니다
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0), // 왼쪽으로 8픽셀 만큼 여백을 추가
                    child: Text(
                      '${location['name'] ?? '없음'}',
                      style: TextStyle(
                        fontSize: 20, // 폰트 크기 키우기
                        fontWeight: FontWeight.bold, // 볼드체
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8), // 장소 이름과 설명 사이에 간격 추가
                Align(
                  alignment: Alignment.centerLeft, // 왼쪽 정렬을 강제합니다
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0), // 왼쪽으로 8픽셀 만큼 여백을 추가
                    child: Text(
                      '${location['description'] ?? '없음'}',
                      style: TextStyle(
                        fontSize: 16, // 설명은 기본 크기
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Color(0xFFAAD5D1), // 경계선 색상
            thickness: 2, // 경계선 두께
          ),

          // 리뷰 목록
          Expanded(
            child: reviews.isEmpty
                ? Center(child: Text("리뷰가 존재하지 않습니다"))
                : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                var review = reviews[index];
                double rating = 0.0;
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
                          RatingBarIndicator(
                            rating: rating,
                            itemCount: 5,
                            itemSize: 30,
                            direction: Axis.horizontal,
                            itemBuilder: (context, index) =>
                                Icon(
                                  Icons.star,
                                  color: Color(0xFFAAD5D1),
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
          Divider(
            color: Color(0xFFAAD5D1), // 경계선 색상
            thickness: 2, // 경계선 두께
          ),// 리뷰 작성 구분선
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
                        color: Color(0xFFAAD5D1),
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
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFFAAD5D1),     // 텍스트 색상 (글씨 색)
                ),
              ),
            ),
          )
        ],
      ),
    );
  }


}
