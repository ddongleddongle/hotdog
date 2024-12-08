import 'dart:convert';
import 'dart:math'; // 거리 계산을 위한 수학 함수
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // 위치 정보를 가져오기 위한 패키지
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'Home.dart';
import 'MyInfo.dart';
import 'Mapscreen.dart';
import 'Shop/Shop.dart';
import 'User_Provider.dart';
import 'ReviewDetail.dart';

class Community extends StatefulWidget {
  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  List<dynamic> reviews = [];
  Position? userPosition; // 사용자 위치 저장
  String selectedFilter = 'review'; // 기본적으로 'review' 필터를 선택

  @override
  void initState() {
    super.initState();
    fetchAndShowLocations(selectedFilter); // 기본적으로 리뷰 평균으로 정렬
  }

  // 사용자 위치 가져오고 데이터 요청
  Future<void> fetchAndShowLocations(String filter) async {
    try {
      userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high); // 현재 위치 가져오기
      double lat = userPosition!.latitude;
      double lng = userPosition!.longitude;

      // 위치 기반 데이터 가져오기
      await showLocations(lat, lng, filter);
    } catch (e) {
      print("위치 정보를 가져오는 중 오류 발생: $e");
    }
  }

  // 서버에서 데이터 가져오기
  Future<void> showLocations(double lat, double lng, String filter) async {
    final url =
        'http://116.124.191.174:15017/showLocations?lat=$lat&lng=$lng&filter=$filter';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        reviews = json.decode(response.body); // 응답 데이터를 리스트로 저장
      });
    } else {
      print('데이터 가져오기 실패');
    }
  }

  // 거리 계산 함수
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const earthRadius = 6371; // 지구 반지름(km)
    double dLat = _degToRad(lat2 - lat1);
    double dLng = _degToRad(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c; // 거리(km)
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("커뮤니티"),
        actions: [
          DropdownButton<String>(
            value: selectedFilter,
            icon: Icon(Icons.filter_list),
            onChanged: (String? newValue) {
              setState(() {
                selectedFilter = newValue!;
              });
              fetchAndShowLocations(selectedFilter);
            },
            items: <String>['review', 'distance']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value == 'review' ? '리뷰 기준' : '거리 기준'),
              );
            }).toList(),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // 좌우 스와이프 시 화면 전환
          if (details.primaryVelocity! < 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyInfo()),
            );
          } else if (details.primaryVelocity! > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MapScreen()),
            );
          }
        },
        child: Stack(
          children: [
            ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                // avg_review 값을 double로 변환하여 처리
                double avgReview = double.tryParse(reviews[index]['avg_review'].toString()) ?? 0.0;

                // 위치 정보가 null일 경우 처리
                double distance = 0.0;
                if (userPosition != null) {
                  distance = calculateDistance(
                    userPosition!.latitude,
                    userPosition!.longitude,
                    reviews[index]['lat'],
                    reviews[index]['lng'],
                  );
                }

                // 구별을 위한 배경색 변경 (리뷰 기준으로 정렬시 다르게)
                Color backgroundColor = (index % 2 == 0) ? Colors.grey[100]! : Colors.white;

                return Container(
                  color: backgroundColor, // 배경색 설정
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(reviews[index]['name'] ?? 'No name'),
                        subtitle: Text(
                          '${reviews[index]['description'] ?? 'No Description'}\n현재 위치에서 거리: ${distance.toStringAsFixed(2)} km\n리뷰 평균: ${avgReview.toStringAsFixed(1)}',
                        ),
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ReviewDetail(locationId: reviews[index]['id']),
                            ),
                          );
                        }
                      ),
                      Divider(thickness: 1), // 구분선 추가
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildWalkingButton(context), // 산책 버튼 추가
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // 중앙에 배치
    );
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
}
