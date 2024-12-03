import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'User_Provider.dart';
import 'Home.dart';

class test extends StatefulWidget {
  final String? petName;
  final int? coins;
  final double? totaldistance;
  final LatLng? desitinationPosition;

  test({
    required this.petName,
    required this.coins,
    required this.totaldistance,
    this.desitinationPosition,
  });

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<test> {
  late GoogleMapController mapController;
  UserProvider? userProvider;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  List<LatLng> _routePoints = []; // 경로 포인트를 저장할 리스트
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  Polyline _polyline = Polyline(
    polylineId: PolylineId('route'),
    color: Color(0xFFAAD5D1),
    width: 5,
  );

  double _totalDistance = 0.0; // 총 거리
  bool _isWalking = false; // 산책 중 여부
  bool _isPaused = false; // 일시 정지 여부
  Timer? _timer; // 타이머
  int _secondsElapsed = 0; // 경과 시간

  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();
    polylineCoordinates = [];

    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: 'AIzaSyDenPclJquav9-fQFtHsjnSIvMN1ORoOq0', // Google Maps API Key
      request: PolylineRequest(
        origin: PointLatLng(startLatitude, startLongitude),
        destination: PointLatLng(destinationLatitude, destinationLongitude),
        mode: TravelMode.transit,
        transitMode: 'bus',
      ),
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      // Defining an ID
      PolylineId id = PolylineId('poly');

      // Initializing Polyline
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.grey,
        points: polylineCoordinates,
        width: 3,
      );

      // Adding the polyline to the map
      setState(() {
        polylines[id] = polyline; // 폴리라인 상태 업데이트
      });
    } else {
      print("No route found");
    }
  }


  @override
  void initState() {
    super.initState();
    _startLocationStream();
  }

  void _startLocationStream() async{
    final LocationSettings locationSettings =  await LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // 3미터마다 위치 업데이트
    );

    setState(() async{
      await Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (Position position) {
          if (position != null) {
            setState(() {
              _currentPosition = LatLng(position.latitude, position.longitude);
              _markers.add(Marker(
                markerId: MarkerId('currentLocation'),
                position: _currentPosition!,
              ));

              // 산책 중이고 일시 정지 상태가 아닐 때만 경로 포인트 추가
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

            // 카메라를 현재 위치로 이동
            mapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: _currentPosition!, zoom: 17), // 확대된 줌 값
            ));
          }
        },
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 17), // 확대된 줌 값
    ));
    _createPolylines(_currentPosition!.latitude,_currentPosition!.longitude,widget.desitinationPosition!.latitude,widget.desitinationPosition!.longitude);
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
        int earnedCoins = (_totalDistance / 10).floor(); // 10미터당 1코인

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
                final userProvider =
                Provider.of<UserProvider>(context, listen: false);
                double newTotalDistance =
                    (userProvider.totaldistance ?? 0.0) + _totalDistance;
                await userProvider.updateUserCoinsAndDistance(
                  (userProvider.coins ?? 0) + earnedCoins,
                  newTotalDistance,
                );
                await userProvider.setparty(userProvider!.email!, -1);
                setState(() {
                  userProvider.coins = (userProvider.coins ?? 0) +
                      earnedCoins; // 여기서 coins 값을 업데이트합니다.
                  userProvider.totaldistance =
                      (userProvider.totaldistance ?? 0) + newTotalDistance;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFAAD5D1), // 앱바 배경색 설정
        title: Text(
          'HOTDOG WALKING SYSTEM',
          style: TextStyle(
            color: Colors.white, // 텍스트 색상
            fontWeight: FontWeight.bold, // 볼드체 설정
          ),
        ),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator()) // 위치가 null일 경우 로딩 인디케이터 표시
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 17, // 확대된 줌 값
              ),
              markers: _markers,
              polylines: Set<Polyline>.of(polylines.values).union({_polyline}),// 폴리라인 추가
            ),
          ),
          Column(
            children: [
              Container(
                height: 3, // 라인의 높이
                color: Color(0xFFAAD5D1), // 민트색 라인
              ),
              Container(
                padding: EdgeInsets.all(16.0),
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFAAD5D1), // 배경색
                            foregroundColor: Colors.white, // 텍스트 색상
                          ),
                          onPressed: _isWalking ? null : _startWalking,
                          child: Text('산책시작'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFAAD5D1), // 배경색
                            foregroundColor: Colors.white, // 텍스트 색상
                          ),
                          onPressed:
                          _isWalking && !_isPaused ? _pauseWalking : null,
                          child: Text('멈춤'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFAAD5D1), // 배경색
                            foregroundColor: Colors.white, // 텍스트 색상
                          ),
                          onPressed: _isPaused ? _restartWalking : null,
                          child: Text('재시작'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFAAD5D1), // 배경색
                            foregroundColor: Colors.white, // 텍스트 색상
                          ),
                          onPressed: _isWalking ? _stopWalking : null,
                          child: Text('산책종료'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
