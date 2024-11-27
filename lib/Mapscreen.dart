import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

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

  final List<MarkerInfo> _markerInfos = [
    MarkerInfo(
      title: '장소 1',
      description: '장소 1의 설명입니다.',
      position: LatLng(35.2191, 129.0102), // 예시 위치
    ),
    MarkerInfo(
      title: '장소 2',
      description: '장소 2의 설명입니다.',
      position: LatLng(35.2200, 129.0150), // 예시 위치
    ),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // 사용자 위치 가져오기
    _addMarkers(); // 마커 추가
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
        )); // 현재 위치 마커 추가
      });
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 17),
      ));
    } catch (e) {
      print(e); // 오류 처리
    }
  }

  void _addMarkers() {
    for (var markerInfo in _markerInfos) {
      _markers.add(Marker(
        markerId: MarkerId(markerInfo.title),
        position: markerInfo.position,
        onTap: () {
          _showMarkerInfo(markerInfo); // 마커 클릭 시 정보 표시
        },
      ));
    }
  }

  void _showMarkerInfo(MarkerInfo markerInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // BottomSheet 높이 조정 가능
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 200, // BottomSheet의 높이 설정
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(16.0)), // 위쪽 모서리 둥글게
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
                  Navigator.of(context).pop(); // BottomSheet 닫기
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
      CameraPosition(target: _currentPosition, zoom: 17),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('지도 화면'),
        backgroundColor: Color(0xFFAAD5D1),
      ),
      body: GoogleMap(
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
