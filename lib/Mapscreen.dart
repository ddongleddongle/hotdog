import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:software/test.dart';
import 'package:software/User_Provider.dart';
import 'package:http/http.dart' as http;

import 'Home.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class ReviewInfo {
  late String content;
  late int review;
  late int id;          //DB에서 reviews 의 id

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
  String _partyplace = "";  // 파티 참여시 장소
  MarkerInfo? _partymarker;
  double visibleditance = 500;
  int? pointRate = 1;    //파티에 따른 포인트 배율
  bool _isLoading = true;
  bool _inParty = false;    //파티 참여를 시작했는가
  bool _isParty = false;    //파티 중인가
  bool _isRequest = false;  //산책 요청을 눌렀는가
  bool _canWalking = false; //산책 가능한가
  bool _isWalking = false;  //산책 중인가
  Timer? movementTimer;
  Timer? participantTimer;
  LatLng? _currentPosition; // 기본 위치
  Set<Marker> _markers = {}; //지도에 표시될 마커 리스트
  Set<Circle> _circles = {}; // 가시 거리 원
  UserProvider? userProvider; // 초기화 이전에는 null 허용
  List<LatLng> userPositions = []; // 사용자 위치 리스트
  List<MarkerInfo> _userMarkers = []; //사용자 마커 리스트
  List<MarkerInfo> _markerInfos = []; //구조물 마커 리스트
  List<ReviewInfo> _reviewInfos = []; //리뷰 정보 리스트
  List<String> _userParticipant = []; //파티 참가자 리스트
  List<int> partyRequest = []; //파티 요청 응답 리스트
  //폴리라인 변수들
  double _totalDistance = 0.0; // 총 거리
  bool _isPaused = false; // 일시 정지 여부
  Timer? _timer; // 타이머
  int _secondsElapsed = 0; // 경과 시간
  List<LatLng> _routePoints = []; // 경로 포인트를 저장할 리스트
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  Polyline _polyline = Polyline(
    polylineId: PolylineId('route'),
    color: Color(0xFFAAD5D1),
    width: 5,
  );

  StreamController<List<String>> _participantStreamController = StreamController<List<String>>.broadcast();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider로부터 userProvider를 가져옴
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }
  
  //맵 만들어질 때 함수 설정
  void _onMapCreated(GoogleMapController controller) async{
    // 위치 권한 요청
    LocationPermission permission =  await Geolocator.checkPermission(); //안되면 함수 앞에 await
    if (permission == LocationPermission.denied) {
      permission =  Geolocator.requestPermission() as LocationPermission;
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return; // 권한이 없으면 종료
      }
    }

    mapController = controller;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 17),
    ));
    _addCircle();
    //유저 정보 업데이트
    userProvider?.updatePosition(_currentPosition!.latitude, _currentPosition!.longitude); //DB에 내 위치 저장
    await _fetchUserPositions();
    await _fetchLocations();
    await _addMarkers();
    _startTime();
  }

  Future<void> _initialize() async {
    await _getCurrentLocation(); // 현재 위치 가져오기
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
    participantTimer?.cancel();
    super.dispose();
  }
  
  //주기적으로 실행되는 함수 설정
  Future<void> _move() async {
    _getCurrentLocation();
    _fetchUserPositions();
    _fetchLocations();
    _addMarkers();
  }
  
  //주기적인 시간으로 함수 작동
  void _startTime() {
    movementTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await _move();
      if (mounted) {
        setState(() {});
      }
    });

    participantTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      if (_inParty) {
        await _updateParticipants();
        if(_isRequest && !_canWalking) {
            await userProvider?.request(userProvider!.email!, _partyplace);
            _canWalking = await _checkPartyRequest();
            if (_canWalking == true) {
              Navigator.of(context).pop();
              _showMarkerInfo(_partymarker!, _inParty, true);
            }
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }
  
  //현재 위치로 카메라 이동 함수
  Future<void> _currentCamera() async {
    await mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 17),
    ));
  }
  
  //범위 원 만들기
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

  void _startWalking() {
    setState(() {
      _isWalking = true; // 산책 중으로 설정
      _isPaused = false; // 일시 정지 해제
    });

    // 타이머 시작
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++; // 경과 시간 증가
        });
      }
    });
  }

  void _pauseWalking() {
    setState(() {
      _isPaused = true; // 일시 정지 상태로 설정
    });
  }

  void _restartWalking() {
    setState(() {
      _isPaused = false; // 일시 정지 해제
    });
  }

  void _stopWalking() {
    // 산책 거리, 시간 출력
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int earnedCoins = (_totalDistance / 10).floor() * pointRate!; // (10미터당 1코인) * 포인트 배율

        return AlertDialog(
          title: Text('산책 종료'),
          content: Text(
            '경과 시간: ${_secondsElapsed ~/ 60}:${_secondsElapsed % 60 < 10 ? '0' : ''}${_secondsElapsed % 60}\n'
                '거리: ${_totalDistance.toStringAsFixed(2)} m\n'
                '획득한 코인: $earnedCoins',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // UserProvider를 통해 업데이트
                double newTotalDistance = (userProvider?.totaldistance ?? 0.0) + _totalDistance;
                await userProvider?.updateUserCoinsAndDistance(
                  (userProvider?.coins ?? 0) + earnedCoins,
                  newTotalDistance,
                );
                await userProvider?.setparty(userProvider!.email!, -1);
                setState(() {
                  userProvider?.coins = (userProvider?.coins ?? 0) +
                      earnedCoins; // 여기서 coins 값을 업데이트합니다.
                  userProvider?.totaldistance =
                      (userProvider?.totaldistance ?? 0) + newTotalDistance;
                });

                Navigator.of(context).pop(); // 다이얼로그 닫기
                MaterialPageRoute(builder: (context) => Home());
              },
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(
                      ),
                    ),
                  );
                },
                child: Text("확인"),
              ),
            ),
          ],
        );
      },
    );

    // 상태 초기화
    setState(() {
      // 아래 값을 초기화하는 대신 UI에서 보여줄 필요가 없는 경우에만 초기화
      _isWalking = false;
      _isPaused = false; // 일시 정지 상태 해제
      // _totalDistance, _secondsElapsed, _routePoints, _markers, _polyline은 다음 산책 시작 시 필요할 수 있음
      // 초기화하지 않도록 주석 처리
      // _totalDistance = 0.0; // 총 거리 초기화
      // _secondsElapsed = 0; // 경과 시간 초기화
      // _routePoints.clear(); // 경로 포인트 초기화
      // _markers.clear(); // 마커 초기화
      // _polyline = Polyline(
      //   polylineId: PolylineId('route'),
      //   color: Color(0xFFAAD5D1),
      //   width: 5,
      //   points: [], // 폴리라인 포인트 초기화
      // );
    });
    _timer?.cancel(); // 타이머 중지
  }

  //request를 하나씩 보고 전부 -1 이면 산책 가능
  Future<bool> _checkPartyRequest() async {
    partyRequest = List.from(userProvider?.partyRequest ?? []);

    if (partyRequest != null && partyRequest!.isNotEmpty) {
      for(var request in partyRequest){
        //print("-----------------request check : ${request}-----------------");
        if(request != 1)
          return false;
      }
    }
    print("----------산책 시작 가능-----------");
    return true;
  }
  
  //장소와의 거리를 체크하는 함수
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

  //현재위치 가져오기 & pollyline 설정
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      print("내 위치 갱신");

      if(mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);

          if (_isWalking && !_isPaused) {
            _routePoints.add(_currentPosition!);

            // 새로운 Polyline 객체 생성
            _polyline = Polyline(
              polylineId: PolylineId('route'),
              color: Color(0xFFAAD5D1),
              width: 5,
              points: _routePoints, // 경로 업데이트
            );

            // 총 거리 계산
            if (_routePoints.length > 1) {
              _totalDistance += Geolocator.distanceBetween(
                _routePoints[_routePoints.length - 2].latitude,
                _routePoints[_routePoints.length - 2].longitude,
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              );
            }
          }
        });
      }

      _circles.clear();
      userProvider?.updatePosition(_currentPosition!.latitude, _currentPosition!.longitude);
      _addCircle();
    } catch (e) {
      print(e); // 오류 처리
    }
  }

  //파티원 정보 가져오기 0: 파티 요청하기 전 1: 파티 요청하기 후
  Future<void> _updateParticipants() async {
    //실시간 파티원 업데이트
    _userParticipant.clear();
    if(_partyplace == ""){
      print("파티 장소가 지정되지 않았음");
    }
    if(_isRequest)
      await userProvider?.participant(_partyplace,1);
    if(!_isRequest)
      await userProvider?.participant(_partyplace,0);

    _userParticipant = List.from(userProvider?.userParticipant ?? []);
    print("파티원 : ${_userParticipant}");

    if(mounted)
    setState(() {
      if (_userParticipant != null && _userParticipant!.isNotEmpty) {
        _participantStreamController.add(_userParticipant);
      }
    });
  }

  //장소 위치 갱신 저장
  Future<void> _fetchLocations() async {
    try {
      List<MarkerInfo>? locations = await userProvider?.fetchLocations();
      // mounted 체크 후 setState 호출
      if (mounted) {
        setState(() {
          _markerInfos = List.from(locations ?? []); // _markerInfos에 저장
        });
        // print('Fetched locations: $_markerInfos');
        // await _addMarkers();
      }
    } catch (e) {
      print('Error in _fetchLocations: $e');
    }
  }

  //유저들 위치를 갱신하고 리스트에 저장
  Future <void> _fetchUserPositions() async {
    await userProvider?.fetchUsersPosition();

    if (mounted) {
      setState(() {
        userPositions = List.from(userProvider?.userPositions ?? []);
        _userMarkers = List.from(userProvider?.userMarkers ?? []);
      });
    }
  }
  
  //현재 유저 / 장소 리스트에 있는 마커들을 화면에 표시
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
        onTap: () {
        },
      ));

      // 구조물 마커 (파란색)
      for (var markerInfo in _markerInfos) {
        bool _party = await _checkProximityToMarkers(markerInfo);
        int? colorValue = await userProvider?.locationColor(markerInfo.title);

        // 색상을 적절한 hue 값으로 변환
        double hue;
        if (colorValue != null) {
          if (colorValue <= 10) {
            hue = BitmapDescriptor.hueBlue;
          } else if (colorValue > 10 && colorValue <= 20) {
            hue = BitmapDescriptor.hueGreen;
          } else {
            hue = BitmapDescriptor.hueAzure;
          }
        } else {
          hue = BitmapDescriptor.hueRed; // 기본 색상 설정
        }

        _markers.add(Marker(
          markerId: MarkerId(markerInfo.title),
          position: markerInfo.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          onTap: () {
            _onMarkerTapped(markerInfo, _party, true);
          },
        ));
        // print('public marker: ${markerInfo.title} at ${markerInfo.position}'); // 마커 추가 로그
      }

      // 사용자 마커 (visible 동적 설정)
      for (var userMarker in _userMarkers) {

        bool isInParty = _userParticipant.any((participant) => participant == userMarker.title);

        _markers.add(Marker(
          markerId: MarkerId(userMarker.title),
          position: userMarker.position,
          visible: isInParty, // 같이 파티면 보임
          icon: customIcon, // 커스텀 아이콘
          onTap: () {
            _onMarkerTapped(userMarker, false, false);
          },
        ));
        //print('public marker: ${userMarker.title} at ${userMarker.position}'); // 마커 추가 로그
      }
      setState(() {}); // 변경사항 반영
    } catch (e) {
      print('Error loading custom icon: $e'); // 오류 처리
    }
  }

  //마커를 탭 했을 때 작동함수
  void _onMarkerTapped(MarkerInfo markerInfo, bool _party, bool _isStructure) {
    userProvider?.incrementlocation(markerInfo.title);  //조회수 증가
    _showMarkerInfo(markerInfo, _party, _isStructure); // 마커 정보를 보여주며 party 상태 전달
  }

  //산책하기 눌렀을 때 메세지
  Future <void> message(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: Text('파티 시작'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {});

                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: Text("확인"),
              ),
            ),
          ],
        );
      },
    );
  }
  // !!탭 했을 때 나타나는 바 설정!!----------------------------------------------------------------------------------
  void _showMarkerInfo(MarkerInfo markerInfo, bool partyStatus, bool _isStructure) async {
    await userProvider?.getReview(markerInfo.title);
    _reviewInfos = List.from(userProvider?.userReviews ?? []);

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
            border: Border.all(color: Color(0xFFAAD5D1), width: 4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    markerInfo.title,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 2,
                    color: Color(0xFFAAD5D1),
                    margin: EdgeInsets.only(bottom: 8),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFAAD5D1), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/location/${markerInfo.title}.jpg',
                            width: 150,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              // .jpg 파일이 존재하지 않을 경우 .png 파일 시도
                              return Image.asset(
                                'assets/location/${markerInfo.title}.png',
                                width: 150,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  // 두 이미지 모두 실패할 경우 에러 아이콘 표시
                                  return SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Icon(Icons.error),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          markerInfo.description,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 2,
                    color: Color(0xFFAAD5D1),
                    margin: EdgeInsets.symmetric(vertical: 4),
                  ),
                ],
              ),
              // 리뷰 부분 숨기기 (파티 상태일 때 리뷰 부분을 숨기도록 조건 추가)
              if (!_inParty && !_isParty && _reviewInfos.isNotEmpty && _isStructure == true)
                Expanded(
                  child: ListView.builder(
                    itemCount: _reviewInfos.length,
                    itemBuilder: (context, index) {
                      var review = _reviewInfos[index];
                      return Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ...List.generate(review.review ?? 0, (starIndex) =>
                                    Icon(Icons.star, color: Color(0xFFAAD5D1))),
                                SizedBox(width: 8),
                                Text(review.content),
                              ],
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              // 파티하기 버튼 (파티 상태가 아닌 경우에만 표시)
              if (!_inParty && !_isParty && partyStatus && (_isStructure == true))
                Container(
                  width: 200,
                  child: FloatingActionButton(
                    backgroundColor: Color(0xFFAAD5D1),
                    child: Text(
                      '파티하기',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      await userProvider?.party(userProvider!.email!, markerInfo.title);
                      await userProvider?.participant(markerInfo.title, 0);
                      if (mounted) {
                        setState(() {
                          _inParty = true;
                          if (markerInfo != null) {
                            _partyplace = markerInfo.title;
                            _partymarker = markerInfo;
                          }
                          _userParticipant = List.from(userProvider?.userParticipant ?? []);
                        });
                      }
                      Navigator.of(context).pop();
                      _showMarkerInfo(markerInfo, partyStatus, true);
                    },
                  ),
                ),
              // 나머지 파티 관련 UI
              if (_isStructure == false)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/profile/${markerInfo.title}.jpg',
                      width: 250,
                      height: 250,
                      alignment: Alignment.center,
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        print("error: ${error} , name: ${markerInfo.title}");
                        return Text("사진이 없습니다.");
                      },
                    ),
                    Text("${markerInfo.title}의 설명입니다."),
                  ],
                ),
              if (_inParty && _isStructure == true) ...[
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(_isRequest == false ? "현재 파티원" : "수락한 파티원"),
                  ),
                ),
                StreamBuilder<List<String>>(
                  stream: _participantStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text("오류 발생: ${snapshot.error}");
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("파티원이 없습니다.");
                    }

                    return Wrap(
                      spacing: 8,  // 항목 간 수평 간격
                      runSpacing: 8,  // 세로 간격
                      children: snapshot.data!.map((participantName) {
                        return Container(
                          width: (MediaQuery.of(context).size.width / 2) - 24,  // 한 줄에 2명씩 나오도록 너비 설정
                          child: Row(
                            children: [
                              // 파티원 이미지
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Color(0xFFAAD5D1), width: 2),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/profile/$participantName.jpg',
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                      return Icon(Icons.error, size: 50);
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),  // 이미지와 텍스트 사이의 수평 공간
                              // 파티원 이름
                              Expanded(
                                child: Text(
                                  participantName,
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
              // 파티 요청 버튼
              if(_isStructure)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,  // 버튼 간에 최대한 공간을 나누어 배치
                  children: [
                    // 파티 요청 버튼
                    if (_inParty && !_isRequest && !_isParty) // 파티에 참여하지 않았고 요청하지 않은 경우에만 표시
                      Container(
                        width: 175, // 원하는 너비 설정
                        child: FloatingActionButton(
                          backgroundColor: Color(0xFFAAD5D1),
                          child: Text(
                            '파티 요청',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            await userProvider?.request(userProvider!.email!, _partyplace);
                            setState(() {
                              _isRequest = true;
                            });
                            Navigator.of(context).pop();
                            _showMarkerInfo(markerInfo, partyStatus, true);
                          },
                        ),
                      ),
                    // 파티 나가기 버튼
                    if ((_inParty || _isParty) && _isStructure)
                      Container(
                        width: 175, // 원하는 너비 설정
                        child: FloatingActionButton(
                          backgroundColor: Color(0xFFAAD5D1),
                          child: Text(
                            '파티 나가기',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            await userProvider?.setparty(userProvider!.email!, -1);
                            Navigator.of(context).pop();
                            if (mounted) {
                              setState(() {
                                pointRate = 1;
                                _inParty = false;
                                _isRequest = false;
                                _canWalking = false;
                                _isParty = false;
                                _userParticipant.clear();
                                message('파티가 해제되었습니다');
                              });
                            }
                            _showMarkerInfo(markerInfo, partyStatus, true);
                          },
                        ),
                      ),
                    // -------------- 산책 시작 ----------------
                    if (_isRequest && _canWalking)
                      Container(
                        width: 175, // 원하는 너비 설정
                        child: FloatingActionButton(
                          backgroundColor: Color(0xFFAAD5D1),
                          child: Text(
                            '파티 시작',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            if (mounted) { // mounted 체크
                              setState(() {
                                message('파티가 시작되었습니다. 추가 포인트 x${pointRate!*10}%');
                                _inParty = false;
                                _isRequest = false;
                                _canWalking = false;
                                _isParty = true;
                                pointRate = _userParticipant.length;
                              });
                            }
                          },
                        ),
                      ),
                  ],
                ),
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

//----------------------------------------- !!구글 맵 !!--------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도 화면'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: Column(
        children: [
          Flexible(
            child: Stack(
              children: [
                _isLoading
                    ? Center(
                    child: CircularProgressIndicator()) // userProvider 초기화 전 로딩 표시
                    : GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 17,
                      ),
                      markers: _markers,
                      circles: _circles,
                      polylines: Set<Polyline>.of(polylines.values).union({_polyline}),
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
            )
          ),
          Container(
            height: 3, // 라인의 높이
            color: Color(0xFFAAD5D1), // 민트색 라인
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            child: Column(
              children: [
                Text(
                  '산책시간: ${_secondsElapsed ~/ 60}:${_secondsElapsed % 60 < 10 ? '0' : ''}${_secondsElapsed % 60}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFAAD5D1), // 텍스트 색상
                    fontWeight: FontWeight.bold, // 볼드체 설정
                  ),
                ),
                Text(
                  '산책거리: ${_totalDistance.toStringAsFixed(2)} m',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFAAD5D1), // 텍스트 색상
                    fontWeight: FontWeight.bold, // 볼드체 설정
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFAAD5D1), // 배경색
                        foregroundColor: Colors.white, // 텍스트 색상
                      ),
                      onPressed:_isWalking ? null : _startWalking,
                      child: Text('산책시작'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFAAD5D1), // 배경색
                        foregroundColor: Colors.white, // 텍스트 색상
                      ),
                      onPressed:_isWalking && !_isPaused ? _pauseWalking : null,
                      child: Text('멈춤'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFAAD5D1), // 배경색
                        foregroundColor: Colors.white, // 텍스트 색상
                      ),
                      onPressed:_isPaused ? _restartWalking : null,
                      child: Text('재시작'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFAAD5D1), // 배경색
                        foregroundColor: Colors.white, // 텍스트 색상
                      ),
                      onPressed:_isWalking ? _stopWalking : null,
                      child: Text('산책종료'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
