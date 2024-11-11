import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'User_Provider.dart';
import 'test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  //변수 설정
  String APIKEY = 'AIzaSyDenPclJquav9-fQFtHsjnSIvMN1ORoOq0';
  CameraPosition? _currentCameraPosition;
  GoogleMapController? mapController;
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  String _currentAddress = "";
  String _startAddress = "";
  String _destinationAddress = "";
  Set<Marker> markers = {};
  Marker? selectedMarker;
  Marker? _startMarker;
  Marker? _destinationMarker;
  bool searchstatus = true;
  bool isSettingStartAddress = true; // 출발지/목적지 설정 구분자
  bool isRouteSearchActive = false; // 상단바 온 오프
  bool isMarkerTapEnabled = true; // 마커 추가 기능 활성화 여부
  bool hasStartText = false;
  bool hasDestinationText = false;
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  List<dynamic> suggestions = [];
  List<dynamic> startSuggestions = []; // 출발지 제안 목록
  List<dynamic> destinationSuggestions = []; // 목적지 제안 목록

  //권한요청
  _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  // Google Places API 호출
  _fetchSuggestions(String query) async {
    final apiKey = APIKEY; // 여기에 실제 API 키를 입력하세요.
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&components=country:kr&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      setState(() {
        if (searchstatus) {
          startSuggestions = data['predictions'];
          suggestions = startSuggestions;
        } else {
          destinationSuggestions = data['predictions'];
          suggestions = destinationSuggestions;
        }
      });
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  _fitCameraToPolyline(LatLng start, LatLng end) {
    // LatLngBounds를 사용하여 경로를 포함하는 카메라 경계 생성
    LatLngBounds bounds;
    if (start.latitude > end.latitude && start.longitude > end.longitude) {
      bounds = LatLngBounds(
        southwest: end,
        northeast: start,
      );
    } else if (start.latitude < end.latitude && start.longitude < end.longitude) {
      bounds = LatLngBounds(
        southwest: start,
        northeast: end,
      );
    } else {
      bounds = LatLngBounds(
        southwest: LatLng(
          start.latitude < end.latitude ? start.latitude : end.latitude,
          start.longitude < end.longitude ? start.longitude : end.longitude,
        ),
        northeast: LatLng(
          start.latitude > end.latitude ? start.latitude : end.latitude,
          start.longitude > end.longitude ? start.longitude : end.longitude,
        ),
      );
    }

    // 카메라를 폴리라인에 맞게 애니메이션
    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 120), // 100은 여백
    );
  }

  _getAddress() async {
    if (_currentCameraPosition == null) {
      print("Current camera position is not available.");
      return;
    }
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentCameraPosition!.target.latitude, _currentCameraPosition!.target.longitude);
      Placemark place = p[0];
      setState(() {
        _currentAddress =
        "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
        _destinationAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  _getAddressFromCoordinates(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude, coordinates.longitude,
      );
      Placemark place = placemarks[0];
      return "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      print(e);
      return "";
    }
  }

  _getCurrentLocation() async {
    await _requestLocationPermission();
    if (mapController != null) {
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position position) async {
        setState(() {
          _currentCameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17.0,
          );
          mapController!.animateCamera(
            CameraUpdate.newCameraPosition(_currentCameraPosition!),
          );
        });
        await _getAddress(); // 현재 위치 주소 가져오기
        if(isMarkerTapEnabled)
          await _addMarkerOnTap(
              LatLng(_currentCameraPosition!.target.latitude, _currentCameraPosition!.target.longitude)
          );
      }).catchError((e) {
        print(e);
      });
    } else {
      print('MapController is not initialized yet.');
    }
  }

  _checkForPublicFacilities(LatLng location) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=300&type=public+facility&key=$APIKEY';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'].isNotEmpty; // 결과가 있으면 true 반환
    } else {
      print('Failed to load public facilities');
      return false; // 실패 시 false 반환
    }
  }

  _addMarkerOnTap(LatLng tappedPoint) async {

    String address = await _getAddressFromCoordinates(tappedPoint);
    bool hasPublicFacility = await _checkForPublicFacilities(tappedPoint);

    Marker marker = Marker(
      markerId: MarkerId(tappedPoint.toString()),
      position: tappedPoint,
      infoWindow: InfoWindow(
        //title: hasPublicFacility?'공공시설' : (isSettingStartAddress ? '출발지' : '목적지'),
        title: isSettingStartAddress ? '출발지' : '목적지',
        snippet: address,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    setState(() {
      polylines = {};
      // 설정하려는 위치에 맞는 마커를 설정하고 업데이트
      if (isSettingStartAddress) {
        _startMarker = marker;
        _startAddress = address;
        startAddressController.text = address;
      } else {
        _destinationMarker = marker;
        _destinationAddress = address;
        destinationAddressController.text = address;
      }

      // 현재의 마커 리스트를 업데이트
      markers.clear();
      if (_startMarker != null) markers.add(_startMarker!);
      if (_destinationMarker != null) markers.add(_destinationMarker!);

      selectedMarker = marker;
    });
  }

  // 주소 선택 시 호출되는 함수
  _onSuggestionSelected(String address) async {
    // 주소를 좌표로 변환
    List<Location> locations = await locationFromAddress(address);
    LatLng selectedLatLng = LatLng(locations.first.latitude, locations.first.longitude);

    // 마커 추가
    await _addMarkerOnTap(selectedLatLng);

    // 선택된 주소를 TextField에 설정
    if (searchstatus) {
      startAddressController.text = address;
    } else {
      destinationAddressController.text = address;
    }
  }

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
        color: Colors.red,
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

  _drawRoute() {
    if (markers.length < 2) {
      print("Both start and destination markers must be set.");
      return;
    }

    LatLng start = markers.first.position;
    LatLng end = markers.last.position;

    // 출발지와 목적지가 설정된 경우에만 경로를 그립니다.
    if (_startMarker != null && _destinationMarker != null) {
      _createPolylines(start.latitude, start.longitude, end.latitude, end.longitude);
      _fitCameraToPolyline(start, end); // 카메라를 폴리라인에 맞춰 조정
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    startAddressController.addListener(() {
      setState(() {
        hasStartText = startAddressController.text.isNotEmpty;
        hasDestinationText = destinationAddressController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    startAddressController.dispose(); // Controller 메모리 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    CameraPosition _initialLocation = CameraPosition(target: LatLng(129.0756416, 35.1795543));

    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                _getCurrentLocation();
              },
              markers: markers,
              polylines: Set<Polyline>.of(polylines.values),
              onTap: isMarkerTapEnabled ? _addMarkerOnTap : null,
            ),
            // 현위치 버튼
            Align(
              alignment: Alignment(0.9, 0.85),
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
                      _getCurrentLocation();
                    },
                  ),
                ),
              ),
            ),
            // 줌 아웃 버튼
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => mapController!.animateCamera(
                      CameraUpdate.zoomIn(),
                    ),
                    icon: Icon(Icons.add, size: 50),
                  ),
                  IconButton(
                    onPressed: () => mapController!.animateCamera(
                      CameraUpdate.zoomOut(),
                    ),
                    icon: Icon(Icons.remove_outlined, size: 50),
                  ),
                ],
              ),
            ),
            // 출발지 입력지
            if (!isRouteSearchActive)
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Column(
                  children: [
                    TextField(
                      controller: startAddressController,
                      onChanged: (value) {
                        searchstatus = true;
                        _fetchSuggestions(value);
                      },
                      decoration: InputDecoration(
                        hintText: "출발지 입력",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear), // x 버튼 아이콘
                          onPressed: () {
                            // 텍스트 필드 내용 지우기
                            startAddressController.clear();
                            setState(() {
                              // 필요 시 상태 업데이트
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // 목적지 입력지
            if (!isRouteSearchActive)
              Positioned(
                top: 110,
                left: 20,
                right: 20,
                child: TextField(
                  controller: destinationAddressController,
                  onChanged: (value) {
                    searchstatus = false;
                    _fetchSuggestions(value);
                  },
                  decoration: InputDecoration(
                    hintText: "목적지 입력",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear), // x 버튼 아이콘
                      onPressed: () {
                        // 텍스트 필드 내용 지우기
                        destinationAddressController.clear();
                        setState(() {
                          // 필요 시 상태 업데이트
                        });
                      },
                    ),
                  ),
                ),
              ),
            // 출발지 설정 버튼
            if (!isRouteSearchActive)
              Positioned(
                top: 170,
                left: 20,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSettingStartAddress = true;
                    });
                  },
                  child: Text("출발지 설정"),
                ),
              ),
            // 목적지 설정 버튼
            if (!isRouteSearchActive)
              Positioned(
                top: 170,
                right: 20,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isSettingStartAddress = false;
                    });
                  },
                  child: Text("목적지 설정"),
                ),
              ),
            // 경로 버튼
            if (!isRouteSearchActive)
              Positioned(
                top: 230,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: () {
                    _drawRoute();
                    setState(() {
                      isRouteSearchActive = true; // 경로 검색 활성화
                      isMarkerTapEnabled = false;
                    });
                  },
                  child: Text("경로"),
                ),
              ),
            // 경로 검색 취소 버튼
            if (isRouteSearchActive)
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isRouteSearchActive = false; // 경로 검색 비활성화
                      isMarkerTapEnabled = true;
                    });
                  },
                  child: Text("경로 검색 취소"),
                ),
              ),
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => test(
                              petName : user.petName,
                              coins : user.coins,
                              totaldistance : user.totaldistance,
                              desitinationPosition : LatLng(_destinationMarker!.position.latitude, _destinationMarker!.position.longitude),
                    )));
                  });
                },
                child: Text("산책 시작"),
              ),
            ),
            // 자동완성 제안 목록 표시 (가장 위에 위치)
            if (suggestions.isNotEmpty)
              Positioned(
                top : searchstatus ? 110 : 170, // TextField 바로 아래에 위치
                left: 20,
                right: 20,
                child: Container(
                  height: 200, // 제안 목록의 높이
                  decoration: BoxDecoration(
                    color: Colors.white, // 배경색
                    border: Border.all(color: Colors.black), // 검정색 테두리
                    borderRadius: BorderRadius.circular(10), // 모서리 둥글게
                  ),
                  child: ListView.builder(
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(suggestions[index]['description']),
                        onTap: () {
                          _onSuggestionSelected(suggestions[index]['description']); // 주소 선택 시 호출
                          if (searchstatus) {
                            startAddressController.text = suggestions[index]['description'];
                          } else {
                            destinationAddressController.text = suggestions[index]['description'];
                          }
                          setState(() {
                            suggestions = []; // 선택 후 제안 목록 초기화
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );

  }
}
