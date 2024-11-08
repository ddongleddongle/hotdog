import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool isSettingStartAddress = true; // 출발지/목적지 설정 구분자
  late PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  //선 긋기 연습
  Map<PolylineId, Polyline> _polylines = {};

  void _addPolyline() {
    final PolylineId polylineId = PolylineId('polyline_id');
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      color: Colors.blue,
      points: [
        LatLng(35.263261, 129.016033),
        LatLng(35.264331, 129.016484),
        // Add more LatLng points for your polyline here
      ],
      width: 5,
    );

    setState(() {
      _polylines[polylineId] = polyline;
    });
  }//

  _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
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
      }).catchError((e) {
        print(e);
      });
    } else {
      print('MapController is not initialized yet.');
    }
  }

  _addMarkerOnTap(LatLng tappedPoint) async {
    String address = await _getAddressFromCoordinates(tappedPoint);
    Marker marker = Marker(
      markerId: MarkerId(tappedPoint.toString()),
      position: tappedPoint,
      infoWindow: InfoWindow(
        title: isSettingStartAddress ? '출발지' : '목적지',
        snippet: address,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    setState(() {
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
  _createPolylines(
      double startLatitude,
      double startLongitude,
      double destinationLatitude,
      double destinationLongitude,
      ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
          origin: PointLatLng(startLatitude, startLongitude),
          destination: PointLatLng(destinationLatitude, destinationLongitude),
          mode: TravelMode.transit) ,
      googleApiKey: 'AIzaSyDenPclJquav9-fQFtHsjnSIvMN1ORoOq0', // Google Maps API Key
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

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
    polylines[id] = polyline;
  }

  _drawRoute() {
    if (markers.length < 2) {
      print("Both start and destination markers must be set.");
      return;
    }

    LatLng start = markers.first.position;
    LatLng end = markers.last.position;

    _createPolylines(start.latitude, start.longitude, end.latitude, end.longitude);
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));

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
                _addPolyline();     //선 긋기 연습
              },
              polylines: Set<Polyline>.of(_polylines.values), //선 긋기 연습
              markers: markers,
              onTap: _addMarkerOnTap,
            ),
            Stack(
              children: [
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
              ],
            ),
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: TextField(
                controller: startAddressController,
                decoration: InputDecoration(
                  hintText: "출발지 입력",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 110,
              left: 20,
              right: 20,
              child: TextField(
                controller: destinationAddressController,
                decoration: InputDecoration(
                  hintText: "목적지 입력",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
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
            Positioned(
              top: 230,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: _drawRoute,
                child: Text("경로"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
