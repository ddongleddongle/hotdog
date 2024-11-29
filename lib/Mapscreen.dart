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
  double visibleditance = 500;
  bool _isLoading = true;
  Timer? positionTimer;
  Timer? movementTimer;
  LatLng? _currentPosition; // 기본 위치
  Set<Marker> _markers = {};
  Set<Circle> _circles = {}; // 가시 거리 원
  UserProvider? userProvider; // 초기화 이전에는 null 허용
  List<LatLng> userPositions = []; // 사용자 위치 리스트
  List<MarkerInfo> _userMarkers = []; //사용자 마커 리스트
  
  //시설 마커 리스트
  List<MarkerInfo> _markerInfos = [
    MarkerInfo(
      title: '장소 1',
      description: '장소 1의 설명입니다.',
      position: LatLng(35.2191, 129.0102),
      visible: true,
    ),
    MarkerInfo(
      title: '장소 2',
      description: '장소 2의 설명입니다.',
      position: LatLng(35.2200, 129.0150),
      visible: true,
    ),
    MarkerInfo(
      title: '금곡 도서관',
      description: '금곡 도서관의 설명입니다.',
      position: LatLng(35.263179, 129.016732),
      visible: true,
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
        radius: visibleditance/2,
        fillColor: Colors.blue.withOpacity(0.05), // 투명한 파란색
        strokeColor: Colors.blue, // 외곽선 파란색
        strokeWidth: 1, // 외곽선 두께
      ));
      setState(() {}); // 변경사항 반영
    }
  }

  void _onMarkerTapped(MarkerInfo markerInfo, bool _party) {
    //_checkProximityToMarkers(markerInfo); // 마커와의 거리 체크
    _showMarkerInfo(markerInfo, _party); // 마커 정보를 보여주며 party 상태 전달
  }

  Future<bool> _checkProximityToMarkers(MarkerInfo markerInfo) async {
    double distance = Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      markerInfo.position.latitude,
      markerInfo.position.longitude,
    );

    return distance <= visibleditance? true : false; // 파티 범위 이내면 true, 아니면 false
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

  void _startMove() {

    movementTimer = Timer.periodic(Duration(seconds: 2), (timer) async{
      await _move();

      setState(() {
        
        // _userMarkers = _userMarkers.map((usermarker) {
        //   // 현재 위치와의 차이를 계산
        //   double deltaLat = _currentPosition!.latitude - usermarker.position.latitude;
        //   double deltaLng = _currentPosition!.longitude - usermarker.position.longitude;
        //
        //   // 마커가 현재 위치로 점진적으로 이동하도록 업데이트
        //   LatLng newPosition = LatLng(
        //     usermarker.position.latitude + (deltaLat * 0.3), // 30% 이동
        //     usermarker.position.longitude + (deltaLng * 0.3), // 30% 이동
        //   );
        //
        //   return MarkerInfo(
        //     title: usermarker.title,
        //     description: usermarker.description,
        //     visible: usermarker.visible,
        //     position: newPosition, // 새로운 위치로 변경
        //   );
        // }).toList();     //demo 시험
        
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition =
            LatLng(position.latitude, position.longitude); // 현재 위치 설정
        //_checkProximityToMarkers();    실제는 여기서 장소에 접근했는지 확인
      });

      _circles.clear();
      _addCircle();
      //db에 내 위치 갱신
      await userProvider?.updatePosition(_currentPosition!.latitude, _currentPosition!.longitude);

    } catch (e) {
      print(e); // 오류 처리
    }
  }
  //유저들 위치를 갱신하고 맵에 표시
  void _fetchUserPositions() async {
    // userProvider가 초기화된 후 데이터를 가져옴
    await userProvider?.fetchUsersPosition();
    setState(() {
      userPositions = List.from(userProvider?.userPositions ?? []);  //혹시 몰라 가져옴
      _userMarkers = List.from(userProvider?.userMarkers ?? []);
    });
  }

  Future<void> _addMarkers() async {
    _markers.clear();

    try {
      // 아이콘 생성
      final BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(82, 82)), // 아이콘 크기 설정
        'assets/images/public_office_icon.png', // 이미지 경로
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
            _onMarkerTapped(userMarker,false);
          },
        ));
      }

      setState(() {}); // 변경사항 반영
    } catch (e) {
      print('Error loading custom icon: $e'); // 오류 처리
    }
  }

  Future<void> _move() async{
    _getCurrentLocation();
    _fetchUserPositions();
    _addMarkers();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition!, zoom: 17),
    ));
    _addCircle();
    //유저 정보 업데이트
    userProvider?.updatePosition(_currentPosition!.latitude, _currentPosition!.longitude);
    _fetchUserPositions();
    _startMove();
  }

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
              ? Center(child: CircularProgressIndicator()) // userProvider 초기화 전 로딩 표시
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
