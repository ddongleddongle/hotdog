import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:software/test.dart';
import 'package:software/User_Provider.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class ReviewInfo {
  late String content;
  late int review;
  late int id;

  ReviewInfo({
    required this.content,
    required this.review,
    required this.id,
  });
}

class MarkerInfo {
  late String title;
  late String description;
  late LatLng position;
  late bool visible;

  MarkerInfo({
    required this.title,
    required this.description,
    required this.position,
    required this.visible,
  });
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  String partyplace = "";  // 파티 참여시 장소
  double visibleditance = 500;
  bool _isLoading = true;
  bool _isParty = false;    //파티 참여를 시작했는가
  bool _isWalking = false;  //산책 시작을 눌렀는가
  bool _canWalking = false;
  Timer? movementTimer;
  Timer? participantTimer;
  LatLng? _currentPosition; // 기본 위치
  Set<Marker> _markers = {};
  Set<Circle> _circles = {}; // 가시 거리 원
  UserProvider? userProvider; // 초기화 이전에는 null 허용
  List<LatLng> userPositions = []; // 사용자 위치 리스트
  List<MarkerInfo> _userMarkers = []; //사용자 마커 리스트
  List<MarkerInfo> _markerInfos = [];
  List<ReviewInfo> _reviewInfos = [];
  List<String> _userParticipant = [];
  List<int> partyRequest = [];

  StreamController<List<String>> _participantStreamController = StreamController<List<String>>.broadcast();
  StreamController<List<int>> _requestStreamController = StreamController<List<int>>.broadcast();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider로부터 userProvider를 가져옴
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future<void> _initialize() async {
    await _getCurrentLocation(); // 현재 위치 가져오기
    await _fetchLocations();
    await _getCurrentLocation(); // 비동기 작업 수행
    setState(() {
      _isLoading = false; // 로딩이 끝났음을 알림
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    super.dispose();
  }
  Future<void> _move() async {
    _getCurrentLocation();
    _fetchUserPositions();
    _addMarkers();
  }

  void _startTime() {
    movementTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      await _move();
      setState(() {
      });
    });
    participantTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if(_isParty) {
        await _updateParticipants();
        _canWalking = await _checkPartyRequest();
      }
      setState(() {
      });
    });
  }

  Future<void> _currentCamera() async {
    await mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 17),
    ));
  }

  Future<void> _addCircle() async {
    // 현재 위치가 설정된 경우 원을 추가
    if (_currentPosition != null) {
      _circles.add(Circle(
        circleId: CircleId('currentRadius'),
        center: _currentPosition!,
        radius: visibleditance / 2,
        fillColor: Colors.blue.withOpacity(0.05), // 투명한 파란색
        strokeColor: Colors.blue, // 외곽선 파란색
        strokeWidth: 1, // 외곽선 두께
      ));
      setState(() {}); // 변경사항 반영
    }
  }

  void _onMarkerTapped(MarkerInfo markerInfo, bool _party) {
    _showMarkerInfo(markerInfo, _party); // 마커 정보를 보여주며 party 상태 전달
  }

  //request를 하나씩 보고 전부 -1 이면 산책 실행
  Future<bool> _checkPartyRequest() async {
    partyRequest = List.from(userProvider?.partyRequest ?? []);

    if (partyRequest != null && partyRequest!.isNotEmpty) {
      for(var request in partyRequest){
        print("-----------------request check : ${request}-----------------");
        if(request != 1)
          return false;
      }
    }

    return true;
  }

  Future<bool> _checkProximityToMarkers(MarkerInfo markerInfo) async {
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      markerInfo.position.latitude,
      markerInfo.position.longitude,
    );

    return distance <= visibleditance
        ? true
        : false; // 파티 범위 이내면 true, 아니면 false
  }

  Future<void> _updateParticipants() async {
    //실시간 파티원 업데이트
    _userParticipant.clear();
    if(partyplace == ""){
      print("파티 장소가 지정되지 않았음");
    }
    await userProvider?.participant(partyplace);
    _userParticipant = List.from(userProvider?.userParticipant ?? []);
    setState(() {
      if (_userParticipant != null && _userParticipant!.isNotEmpty) {
        //_userParticipant = _userParticipant!.map((participant) => participant.trim()).toList();
        _participantStreamController.add(_userParticipant);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 위치 권한 요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return; // 권한이 없으면 종료
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      _circles.clear();
      await userProvider?.updatePosition(
          _currentPosition!.latitude, _currentPosition!.longitude);
      _addCircle();
    } catch (e) {
      print(e); // 오류 처리
    }
  }

  //시설 마커 리스트
  Future<List<MarkerInfo>> fetchLocations() async {
    try {
      final response =
      await http.get(Uri.parse('http://116.124.191.174:15017/locations'));

      // API 응답 상태 코드 확인
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        print('API Response: $jsonResponse'); // API 응답 출력

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

  Future<void> _fetchLocations() async {
    try {
      List<MarkerInfo> locations = await fetchLocations();
      setState(() {
        _markerInfos = locations; // _markerInfos에 저장
      });
      //print('Fetched locations: $_markerInfos');
      await _addMarkers();
    } catch (e) {
      print('Error in _fetchLocations: $e');
    }
  }

  //유저들 위치를 갱신하고 맵에 표시
  void _fetchUserPositions() async {
    await userProvider?.fetchUsersPosition();
    setState(() {
      userPositions = List.from(userProvider?.userPositions ?? []); //혹시 몰라 가져옴
      _userMarkers = List.from(userProvider?.userMarkers ?? []);
    });
  }

  Future<void> _addMarkers() async {
    _markers.clear();

    try {
      // 아이콘 생성
      final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(90, 90)),
        'assets/images/userpet.png',
      );

      // 현재 위치 마커
      _markers.add(Marker(
        markerId: MarkerId('currentLocation'),
        position: _currentPosition!,
        infoWindow: InfoWindow(title: '현재 위치'),
      ));

      // 구조물 마커 (파란색)
      for (var markerInfo in _markerInfos) {
        bool _party = await _checkProximityToMarkers(markerInfo);
        _markers.add(Marker(
          markerId: MarkerId(markerInfo.title),
          position: markerInfo.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            _onMarkerTapped(markerInfo, _party);
          },
        ));
        //print('public marker: ${markerInfo.title} at ${markerInfo.position}'); // 마커 추가 로그
      }

      // 사용자 마커 (visible 동적 설정)
      for (var userMarker in _userMarkers) {
        // db에서 user가 party인지 확인하는 함수를 구현해야할 듯
        _markers.add(Marker(
          markerId: MarkerId(userMarker.title),
          position: userMarker.position,
          visible: true, // 동적 가시성
          icon: customIcon, // 커스텀 아이콘
          onTap: () {
            _onMarkerTapped(userMarker, false);
          },
        ));
        //print('public marker: ${userMarker.title} at ${userMarker.position}'); // 마커 추가 로그
      }

      setState(() {}); // 변경사항 반영
    } catch (e) {
      print('Error loading custom icon: $e'); // 오류 처리
    }
  }

  void _showMarkerInfo(MarkerInfo markerInfo, bool partyStatus) async {
    await userProvider?.getReview(markerInfo.title);
    setState(() {
      _reviewInfos = List.from(userProvider?.userReviews ?? []);
    });

    // 모달 바텀 시트 표시
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 500,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                markerInfo.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
//    ----------------- 구조물 sheet ---------------
              if (!_isParty) ... [
                Text(markerInfo.description),
                if (partyStatus)
                  FloatingActionButton(
                    child: Text('파티하기'),
                    onPressed: () async {
                      await userProvider?.party(userProvider!.email!, markerInfo.title);
                      await userProvider?.participant(markerInfo.title);
                      setState(() {
                        _isParty = true;
                        if(markerInfo.title != null)
                          partyplace = markerInfo.title;
                        _userParticipant = List.from(userProvider?.userParticipant ?? []);
                      });
                      Navigator.of(context).pop();
                      _showMarkerInfo(markerInfo, partyStatus);
                    },
                  ),
//   ------------------ 유저 sheet -------------------
                if (_reviewInfos.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _reviewInfos.length,
                      itemBuilder: (context, index) {
                        var review = _reviewInfos[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(review.content),
                            Row(
                              children: List.generate(review.review ?? 0,
                                      (index) => Icon(Icons.star, color: Colors.yellow)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                if (_reviewInfos.isEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/profile/${markerInfo.title}.jpg',
                          width: 300,
                          height: 300,
                          alignment: Alignment.center,
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            print("error: ${error} , name: ${markerInfo.title}");
                            return Text("사진이 없습니다."); // 이미지가 없을 경우 대체 텍스트
                          },
                        ),
                        Text("${markerInfo.title}의 설명입니다."),
                      ],
                    ),
                  ),
              ],
//  ---------------------- 파티 중 ----------------------
              if (_isParty) ... <Widget>[
                SizedBox(
                    height: 40,
                    child: Center(
                        child: Text(_canWalking == false? "현재 파티원" : "수락한 파티원"),
                    )
                ),
                StreamBuilder<List<String>>(
                  stream: _participantStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // 로딩 중 표시
                    }
                    if (snapshot.hasError) {
                      return Text("오류 발생: ${snapshot.error}");
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("파티원이 없습니다."); // 파티원이 없을 때
                    }
                    // 참가자 목록 표시
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: List.generate(
                            snapshot.data!.length,
                                (index) => Padding(
                              key: ValueKey('participant_${snapshot.data![index]}'),
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                snapshot.data![index],
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    await userProvider?.setparty(userProvider!.email!, -1);
                    setState(() {
                      _isParty = false;
                      _canWalking = false;
                      _userParticipant.clear();
                    });
                    Navigator.of(context).pop();
                    _showMarkerInfo(markerInfo, partyStatus);
                  },
                  child: Text('파티 나가기'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                ),
                if(!_isWalking && !_canWalking)
                  ElevatedButton(
                    onPressed: () async {
                      await userProvider?.request(userProvider!.email!, markerInfo.title);
                      setState(() {
                      });
                      Navigator.of(context).pop();
                      _showMarkerInfo(markerInfo, partyStatus);
                    },
                    child: Text('산책 요청'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                  ),
//     -------------- 산책 시작 ----------------
                if(_canWalking)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _checkPartyRequest();
                        setState(() {
                          _isParty = false;
                          _isWalking = false;
                          _canWalking = false;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => test(
                              petName : userProvider?.petName,
                              coins : userProvider?.coins,
                              totaldistance : userProvider?.totaldistance,
                            )),
                          );
                        });
                      },
                      child: Text('산책 시작'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      ),
                    ),
                  ),
                /*if(_isWalking)
                  Expanded(
                    child: ListView.builder(
                      itemCount: _userParticipant.length,
                      itemBuilder: (context, index) {
                        var participant = _userParticipant[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(participant),
                          ],
                        );
                      },
                    ),
                  ),
                if(_isWalking)
                  StreamBuilder<List<int>>(
                    stream: _requestStreamController.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(); // 로딩 중 표시
                      }
                      if (snapshot.hasError) {
                        return Text("오류 발생: ${snapshot.error}");
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text("파티 요청이 없습니다."); // 파티원이 없을 때
                      }
                      // 참가자 목록 표시
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: List.generate(
                              snapshot.data!.length,
                                  (index) => Padding(
                                key: ValueKey('participant_${snapshot.data![index]}'),
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  snapshot.data![index] == -1 ? "수락" : "대기중",
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ) */
              ],
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('닫기'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 17),
    ));
    _addCircle();
    //유저 정보 업데이트
    userProvider?.updatePosition(
        _currentPosition!.latitude, _currentPosition!.longitude);
    _fetchUserPositions();
    _startTime();
  }

//------------------- 구글 맵 ------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도 화면'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: Stack(
        children: [
          _isLoading
              ? Center(
              child:
              CircularProgressIndicator()) // userProvider 초기화 전 로딩 표시
              : GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition!,
              zoom: 17,
            ),
            markers: _markers,
            circles: _circles,
          ),
          // 현위치 버튼
          Align(
            alignment: Alignment(0.99, 0.73),
            child: ClipOval(
              child: Material(
                color: Colors.orange.shade100,
                child: InkWell(
                  splashColor: Colors.orange,
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(Icons.my_location),
                  ),
                  onTap: () {
                    _currentCamera();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
