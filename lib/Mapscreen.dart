import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:software/User_Provider.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class MarkerInfo {
  late String title;
  late String description;
  late LatLng position;

  MarkerInfo({
    required this.title,
    required this.description,
    required this.position,
  });
}

class _MapScreenState extends State<MapScreen> {

  late GoogleMapController mapController;
  bool _isLoading = true;
  bool _party = false;
  Timer? positionTimer;
  Timer? movementTimer;
  LatLng? _currentPosition; // 기본 위치
  Set<Marker> _markers = {};
  UserProvider? userProvider; // 초기화 이전에는 null 허용
  List<LatLng> userPositions = []; // 사용자 위치 리스트 초기화
  List<MarkerInfo> _userMarkers = []; //사용자 마커 리스트 초기화

  List<MarkerInfo> _markerInfos = [
    MarkerInfo(
      title: '장소 1',
      description: '장소 1의 설명입니다.',
      position: LatLng(35.2191, 129.0102),
    ),
    MarkerInfo(
      title: '장소 2',
      description: '장소 2의 설명입니다.',
      position: LatLng(35.2200, 129.0150),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider로부터 userProvider를 가져옴
    userProvider = Provider.of<UserProvider>(context, listen: false);
  }

  Future<void> _initialize() async {
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
    positionTimer?.cancel();
    movementTimer?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition =
            LatLng(position.latitude, position.longitude); // 현재 위치 설정
        _markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: '현재 위치'),
        ));
        //_checkProximityToMarkers();    실제는 여기서 장소에 접근했는지 확인
      });
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 17),
      ));
    } catch (e) {
      print(e); // 오류 처리
    }
  }

  void _onMarkerTapped(MarkerInfo markerInfo) {
    _checkProximityToMarkers(markerInfo); // 마커와의 거리 체크
    _showMarkerInfo(markerInfo, _party); // 마커 정보를 보여주며 party 상태 전달
  }

  void _checkProximityToMarkers(MarkerInfo markerInfo) {
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      markerInfo.position.latitude,
      markerInfo.position.longitude,
    );

    _party = distance <= 1000; // 파티 범위 이내면 true, 아니면 false
  }

  void _showMarkerInfo(MarkerInfo markerInfo, bool partyStatus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                markerInfo.title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(markerInfo.description),
              if(partyStatus)
              FloatingActionButton(
                child: Text('파티하기'),
                  onPressed: () => print('파티')
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

  void startMarkerMovement() {
    movementTimer = Timer.periodic(Duration(seconds: 2), (timer) {

      setState(() {
        _userMarkers = _userMarkers.map((usermarker) {
          // 현재 위치와의 차이를 계산
          double deltaLat = _currentPosition!.latitude - usermarker.position.latitude;
          double deltaLng = _currentPosition!.longitude - usermarker.position.longitude;

          // 마커가 현재 위치로 점진적으로 이동하도록 업데이트
          LatLng newPosition = LatLng(
            usermarker.position.latitude + (deltaLat * 0.1), // 10% 이동
            usermarker.position.longitude + (deltaLng * 0.1), // 10% 이동
          );

          return MarkerInfo(
            title: usermarker.title,
            description: usermarker.description,
            position: newPosition, // 새로운 위치로 변경
          );
        }).toList();

        _addMarkers();
      });
    });
  }

  void _fetchUserPositions() async {
    // userProvider가 초기화된 후 데이터를 가져옴
    await userProvider?.fetchUsersPosition();
    await userProvider?.updatePosition(_currentPosition!.latitude, _currentPosition!.longitude);
    setState(() {
      userPositions = List.from(userProvider?.userPositions ?? []);
      _userMarkers = List.from(userProvider?.userMarkers ?? []);
      _addMarkers();
    });
  }

  Future<void> _addMarkers() async {
    _markers.clear();

    try {
      // 아이콘 생성
      final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(82, 82)), // 아이콘 크기 설정
        'assets/images/public_office_icon.png',       // 이미지 경로
      );

      // 구조물 마커 추가(파란색)
      for (var markerInfo in _markerInfos) {
        _markers.add(Marker(
          markerId: MarkerId(markerInfo.title),
          position: markerInfo.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          onTap: () {
            _onMarkerTapped(markerInfo);
          },
        ));
      }
      //사용자(개 사진)
      for (var userMarker in _userMarkers) {
        _markers.add(Marker(
          markerId: MarkerId(userMarker.title),
          position: userMarker.position,
          icon: customIcon, // 파란색
          onTap: () {
            _onMarkerTapped(userMarker);
          },
        ));
      }

      setState(() {}); // 변경사항 반영
    } catch (e) {
      print('Error loading custom icon: $e'); // 오류 처리
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 17),
    ));
    //유저 정보 업데이트
    userProvider?.updatePosition(_currentPosition!.latitude, _currentPosition!.longitude);
    _fetchUserPositions();
    startMarkerMovement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도 화면'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // userProvider 초기화 전 로딩 표시
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 17,
        ),
        markers: _markers,
      ),
    );
  }
}
