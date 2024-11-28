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
  final String title;
  final String description;
  final LatLng position;

  MarkerInfo({
    required this.title,
    required this.description,
    required this.position,
  });
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  LatLng _currentPosition = LatLng(35.2191, 129.0102); // 기본 위치
  Set<Marker> _markers = {};
  UserProvider? userProvider; // 초기화 이전에는 null 허용
  List<LatLng> userPositions = []; // 사용자 위치 리스트 초기화
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
  Timer? positionTimer;
  Timer? movementTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Provider로부터 userProvider를 가져옴
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _fetchUserPositions(); // 위치 데이터를 가져옴
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    positionTimer?.cancel();
    movementTimer?.cancel();
    super.dispose();
  }

  void _fetchUserPositions() async {
    // userProvider가 초기화된 후 데이터를 가져옴
    await userProvider?.fetchUsersPosition();
    setState(() {
      userPositions = List.from(userProvider?.userPositions ?? []);
      _addMarkers();
    });
  }

  void startMarkerMovement() {
    movementTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        userPositions = userPositions.map((position) {
          return LatLng(
            position.latitude +
                ((position.latitude - _currentPosition.latitude) * 0.1),
            position.longitude +
                ((position.longitude - _currentPosition.longitude) * 0.1),
          );
        }).toList();
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
        _markers.add(Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition,
          infoWindow: InfoWindow(title: '현재 위치'),
        ));
      });
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 17),
      ));
    } catch (e) {
      print(e); // 오류 처리
    }
  }

  void _showMarkerInfo(MarkerInfo markerInfo) {
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
              Spacer(),
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

  void _addMarkers() {
    _markers.clear();

    for (var markerInfo in _markerInfos) {
      _markers.add(Marker(
        markerId: MarkerId(markerInfo.title),
        position: markerInfo.position,
        onTap: () {
          _showMarkerInfo(markerInfo);
        },
      ));
    }

    for (var userPosition in userPositions) {
      _markers.add(Marker(
        markerId: MarkerId('user_${userPosition.latitude}_${userPosition.longitude}'),
        position: userPosition,
        onTap: () {
          // 사용자 위치 클릭 시 동작 추가 가능
        },
      ));
    }

    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _currentPosition, zoom: 17),
    ));
    startMarkerMovement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도 화면'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: userProvider == null
          ? Center(child: CircularProgressIndicator()) // userProvider 초기화 전 로딩 표시
          : GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 17,
        ),
        markers: _markers,
      ),
    );
  }
}
