import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:software/Mapscreen.dart';

class UserProvider with ChangeNotifier {
  String? _email;
  String? _password;
  String? _petName;
  String? _petBirthDay;
  int? _coins;
  double? _totaldistance;
  double? _lat;
  double? _lng;
  int? _partyid;
  bool? _partyRequest;
  String? _imagePath;

  // Getters
  String? get email => _email;
  String? get password => _password;
  String? get petName => _petName;
  String? get petBirthDay => _petBirthDay;
  int? get coins => _coins;
  double? get totaldistance => _totaldistance;
  double? get lat => _lat;
  double? get lng => _lng;
  int? get partyid => _partyid;
  bool? get party_request => _partyRequest;
  String? get imagePath => _imagePath;

  //late MarkerInfo markerInfo;
  late List<LatLng> userPositions = []; // LatLng 객체를 저장할 리스트
  late List<MarkerInfo> userMarkers = [];
  late List<ReviewInfo> userReviews = [];
  late List<String> userParticipant = [];
  late List<int> partyRequest = [];

  set coins(int? value) {
    _coins = value;
    notifyListeners(); // 상태 변경 통지
  }

  set totaldistance(double? value) {
    _totaldistance = value;
    notifyListeners(); // 상태 변경 통지
  }

  bool get isLoggedIn => _email != null;

  // 로그인 처리
  Future<void> login(
      String email,
      String password,
      String petName,
      String petBirthDay,
      int coins,
      double totaldistance,
      double? lat,
      double? lng,
      int? partyid,
      bool? paty_request)
  async {
    _email = email;
    _password = password;
    _petName = petName;
    _petBirthDay = petBirthDay;
    _coins = coins;
    _totaldistance = totaldistance;
    _lat = lat;
    _lng = lng;
    _partyid = partyid;
    _partyRequest = paty_request;
    notifyListeners(); // 로그인 상태 변경
  }

  // 로그아웃 처리
  Future<void> logout() async {
    final url = 'http://116.124.191.174:15017/resetposition'; // 여기에 API 엔드포인트를 입력하세요

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': _email,
          'lat': null, // 사용자의 이메일 또는 ID로 식별
          'lng': null,
        }),
      );
      if (response.statusCode == 200) {
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to update user data');
      }
    } catch (error) {
      throw error; // 에러 처리
    }

    _email = null;
    _password = null;
    _petName = null;
    _petBirthDay = null;
    _coins = null;
    _totaldistance = null;
    _lat = null;
    _lng = null;

    notifyListeners(); // 로그아웃 상태 변경
  }

  // 사용자 정보 업데이트
  void updateUserInfo(
      String email, String password, String petName, String petBirthDay) {
    _email = email;
    _password = password;
    _petName = petName;
    _petBirthDay = petBirthDay;
    notifyListeners(); // 상태 변경을 UI에 반영
  }

  Future<void> updateUserCoinsAndDistance(
      int coins, double totaldistance) async {
    final url = 'http://116.124.191.174:15017/update'; // 여기에 API 엔드포인트를 입력하세요

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': _email, // 사용자의 이메일 또는 ID로 식별
          'coins': coins,
          'totaldistance': totaldistance,
        }),
      );

      if (response.statusCode == 200) {
        _coins = coins; // 업데이트된 코인 저장
        _totaldistance = totaldistance; // 업데이트된 총 거리 저장
        // 서버 응답 처리
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to update user data');
      }
    } catch (error) {
      throw error; // 에러 처리
    }
  }
  
  //리뷰 가져오기
  Future<void> getReview(String title) async {
    userReviews.clear();
    final url = 'http://116.124.191.174:15017/review'; // API 엔드포인트
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': title}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['results']; // 'results' 키에서 데이터 추출
        //print("review : ${data}");
        print("리뷰 가져옴");


        for (var Review in data) {
          String content = Review['text'] ?? "Unknown Location";
          int? review = Review['review'];
          int? id = Review['id'];

          // null 체크를 통해 안전하게 추가
          if (review != null && id != null) {
            userReviews.add(
              ReviewInfo(
                content: content,
                review: review,
                id: id,
              ),
            );
          } else {
            print('Review or ID is null for this review: $Review'); // null인 경우 로그 출력
          }
        }
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to load review');
      }
    } catch (error) {
      print('Error loading review: $error');
    }
  }

  Future<void> getPosition(double? lat, double? lng) async {
    _lat = lat;
    _lng = lng;
    notifyListeners(); // 상태 변경 통지
  }

  // 리뷰 조회수 증가
  Future<void> incrementlocation(String name) async {
    final url = 'http://116.124.191.174:15017/incrementlocation'; // API 엔드포인트

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        // 서버 응답 처리
        notifyListeners(); // 상태 변경 통지
        print('${name} 조회수 증가');
      } else {
        // 상태 코드에 따라 에러 메시지 다르게 처리
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to update position data: ${response.body}');
      }
    } catch (error) {
      print('Increment location error: $error'); // 구체적인 에러 메시지 출력
      throw error; // 에러 처리
    }
  }

// 리뷰 색 가져오기
  Future<int> locationColor(String name) async {
    final url = 'http://116.124.191.174:15017/locationcolor'; // API 엔드포인트
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['results']; // 'results' 키에서 데이터 추출
        //print("리뷰 color 가져옴");

        if (data.isNotEmpty) {
          int? view = data[0]['view'];

          if (view != null) {
            return view;
          } else {
            print('view is null for this review: $view'); // null인 경우 로그 출력
          }
        } else {
          print('No results found for the given name: $name');
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load location color: ${response.body}');
      }
    } catch (error) {
      print('Error loading location color: $error');
    }

    print('아무 색도 받아오지 못함');
    return -1; // 오류 발생 시 기본값
  }

  //시설 마커 리스트
  Future<List<MarkerInfo>> fetchLocations() async {
    try {
      final response =
      await http.get(Uri.parse('http://116.124.191.174:15017/locations'));

      // API 응답 상태 코드 확인
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);

        //print('API Response: $jsonResponse'); // API 응답 출력
        print("구조물 가져옴");

        // JSON 데이터를 MarkerInfo로 변환
        return jsonResponse
            .map((location) => MarkerInfo(
          title: location['name'],
          description: location['description'],
          position: LatLng(location['lat'], location['lng']),
          visible: true,
        ))
            .toList();
      } else {
        print(
            'Failed to load locations: ${response.statusCode}');
        throw Exception('Failed to load locations');
      }
    } catch (e) {
      print('Error fetching locations: $e');
      throw Exception('Error fetching locations');
    }
  }

  //위치 정보 획득
  Future<void> fetchUsersPosition() async {
    final url = 'http://116.124.191.174:15017/usersposition'; // API 엔드포인트

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': _email}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        print("유저 가져옴");
        // 응답에서 lat, lng 값을 가져와서 LatLng 리스트에 추가
        userPositions.clear(); // 기존 리스트 초기화
        userMarkers.clear();
        for (var item in data) {
          double? lat = item['lat'];
          double? lng = item['lng'];
          String pet_name = item['pet_name'] ?? 'Unknown Pet';

          // null 체크 후 LatLng 객체 생성
          if (lat != null && lng != null) {
            LatLng position = LatLng(lat, lng);

            // LatLng 객체를 리스트에 추가
            userPositions.add(position);

            // pet_name이 null이 아닐 경우에만 MarkerInfo 추가
            if (pet_name != null) {
              userMarkers.add(
                MarkerInfo(
                  title: pet_name,
                  description: 'User의 관한 내용입니다',
                  position: position,
                  visible: false,
                ),
              );
            }
          }
        }
      } else {
        throw Exception('Failed to fetch users position');
      }
    } catch (error) {
      print('Error fetching users position: $error');
    }
  }

  //위치 정보 처리
  Future<void> updatePosition(double? lat, double? lng) async {
    final url = 'http://116.124.191.174:15017/position'; // 여기에 API 엔드포인트를 입력하세요

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': _email,
          'lat': lat,
          'lng': lng,
        }),
      );

      if (response.statusCode == 200) {
        _lat = lat;
        _lng = lng; // 업데이트된 좌표 저장
        // 서버 응답 처리
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to update position data');
      }
    } catch (error) {
      throw error; // 에러 처리
    }
  }

  Future<void> participant(String title, int party_request) async {
    final url = 'http://116.124.191.174:15017/participant'; // 여기에 API 엔드포인트를 입력하세요

    print("파티 참가자 파라미터 : ${title} ${party_request}");
    userParticipant.clear();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name' : title,
          'party_request' : party_request,
        }),
      );

      //print("--------------참가자 함수 작동");

      final Map<String, dynamic> data = jsonDecode(response.body); // JSON 객체로 파싱
      final List<dynamic> participants = data['results']; // 'results' 키로 접근

      for(var participant in participants){
        String pet_name = participant['pet_name'] ?? 'Unknown Participant';
        int? party_id = participant['party_id'];

        userParticipant.add(pet_name);
        if (party_id != null) {
          partyRequest.add(party_id);
        }
      }

      print("파티 참가자 가져옴 : ${participants}");

      if (response.statusCode == 200) {
        // 서버 응답 처리
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to get participant');
      }
    } catch (error) {
      throw error; // 에러 처리
    }
  }

  Future<void> party(String email, String title) async {
    final url = 'http://116.124.191.174:15017/party'; // 여기에 API 엔드포인트를 입력하세요

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'name' : title,
        }),
      );
      if (response.statusCode == 200) {
        // 서버 응답 처리
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to party');
      }
    } catch (error) {
      throw error; // 에러 처리
    }
  }

  Future<void> setparty(String email, int partyid) async {
    final url = 'http://116.124.191.174:15017/partyset'; // 여기에 API 엔드포인트를 입력하세요

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'party_id' : partyid != 0 ? partyid : null,
        }),
      );

      if (response.statusCode == 200) {
        // 서버 응답 처리
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to reset party');
      }
    } catch (error) {
      throw error; // 에러 처리
    }
  }

  Future<void> request(String email, String name) async {
    final url = 'http://116.124.191.174:15017/request'; // 여기에 API 엔드포인트를 입력하세요

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'name' : name,
        }),
      );

      //final Map<String, dynamic> data = jsonDecode(response.body); // JSON 객체로 파싱
      //final List<dynamic> requests = data['results']; // 'results' 키로 접근

      partyRequest.clear();

      final List<dynamic> data = jsonDecode(response.body);

      print("request : ${data}");

      for(var request in data){
        int? party_request = request['party_request'];

        if (party_request != null) {
          partyRequest.add(party_request);
        }
      }

      if (response.statusCode == 200) {
        // 서버 응답 처리
        notifyListeners(); // 상태 변경 통지
      } else {
        throw Exception('Failed to request');
      }
    } catch (error) {
      throw error; // 에러 처리
    }
  }
}
