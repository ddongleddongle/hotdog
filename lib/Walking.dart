import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  runApp(const Walking());
}

class Walking extends StatelessWidget {
  const Walking({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Map',
      home: MapWiget(),
    );
  }
}

class MapWiget extends StatefulWidget {
  @override
  State<MapWiget> createState() => MapSampleState();
}

class MapSampleState extends State<MapWiget> {
  Position? _currentPosition; // Position을 nullable로 변경
  GoogleMapController? mapController; // GoogleMapController를 nullable로 변경

  @override
  Widget build(BuildContext context) {
    // 화면의 너비와 높이 결정
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

    Future<void> _requestLocationPermission() async {
      var status = await Permission.location.status;
      if (!status.isGranted) {
        // 권한이 없으면 요청
        await Permission.location.request();
      }
    }

    Future<void> _getCurrentLocation() async {
      // 위치 권한 요청
      await _requestLocationPermission();

      if (mapController != null) { // mapController가 초기화된 경우에만 위치를 가져옴
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
            .then((Position position) {
          setState(() {
            _currentPosition = position;

            print('CURRENT POS: $_currentPosition');

            // 현재 위치로 카메라 이동
            mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 14.0,
                ),
              ),
            );
          });
        }).catchError((e) {
          print(e);
        });
      } else {
        print('MapController is not initialized yet.');
      }
    }

    @override
    void initState() {
      super.initState();
      // mapController가 초기화된 후에 위치 가져오기
    }

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            // 지도 표시
            GoogleMap(
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                // 초기 줌 설정
                mapController!.animateCamera(CameraUpdate.zoomIn());
                mapController!.animateCamera(CameraUpdate.zoomOut());
                // 맵이 생성된 후 현재 위치 가져오기
                _getCurrentLocation(); // 여기서 위치를 가져옵니다.
              },
            ),
            Align(
              alignment: Alignment(0.9, 0.9),
              child: ClipOval(
                child: Material(
                  color: Colors.orange.shade100, // 버튼 색상
                  child: InkWell(
                    splashColor: Colors.orange, // 스플래시 색상
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.my_location),
                    ),
                    onTap: () {
                      // 버튼 클릭 시 현재 위치로 이동
                      _getCurrentLocation();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
