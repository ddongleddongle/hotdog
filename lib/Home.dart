import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'Shop/Shop.dart';
import 'Walking.dart';
import 'test.dart';
import 'Start.dart';
import 'package:intl/intl.dart';
import 'MyInfo.dart';
import 'package:provider/provider.dart';
import 'User_Provider.dart';
import 'Mapscreen.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoggedIn = true;
  int currentSteps = 1000; // Initial step count
  int stepGoal = 2660; // Step goal
  double? lat;
  double? lng;
  late SharedPreferences prefs;
  String? _status = 'Idle';

  @override
  void initState() {
    super.initState();
    _initPedometer(); // Initialize pedometer
    _requestLocationPermission();
    _loadStepData();
  }

  _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> _updatePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        lat = position.latitude;
        lng = position.longitude;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updatePosition(lat, lng);

    } catch (e) {
      print('Error occurred while fetching location: $e');
    }
  }

  _initPedometer() async {
    Pedometer.stepCountStream.listen((stepCount) {
      setState(() {
        currentSteps = stepCount.steps;
      });
      _saveStepData();
    }, onError: (error) {
      setState(() {
        _status = 'Error: $error';
      });
    });
  }

  _loadStepData() async {
    prefs = await SharedPreferences.getInstance();
    String? lastDate = prefs.getString('lastDate');
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastDate == null || lastDate != today) {
      currentSteps = 0;
      prefs.setString('lastDate', today);
    } else {
      currentSteps = prefs.getInt('currentSteps') ?? 0;
    }
  }

  _saveStepData() async {
    await prefs.setInt('currentSteps', currentSteps);
  }

  String _formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate == '0000') {
      return '로그인 하시옵소서';
    }
    DateTime date = DateTime.parse(birthDate);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  double _convertStepsToKm(int steps) {
    double stepLength = 0.75;
    double km = (steps * stepLength) / 1000;
    return km;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    double progress = 1000 / stepGoal;
    progress = progress > 1.0 ? 1.0 : progress;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          double radius = screenWidth * 0.30;
          double heightLimit = screenHeight * 0.3;
          radius = radius > heightLimit ? heightLimit : radius;

          return GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Shop()),
                );
              }
            },
            child: Stack(
              children: [
                // Background image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/back.jpg',
                    fit: BoxFit.cover, // Fill the screen with the image
                  ),
                ),
                // Overlay (semi-transparent)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3), // Overlay with transparency
                  ),
                ),
                // White sliding panel at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: screenHeight * 0.75, // The slide panel takes up 55% of the screen height
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: Color(0xFFAAD5D1), // Border color
                        width: 4, // Border width
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 20), // Added space to make room for the image above the panel
                          Row(
                            children: [
                              SizedBox(width: 5),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    isLoggedIn
                                        ? _buildProfileText('이름: ${user.petName}')
                                        : _buildProfileText('로그인 하세요'),
                                    isLoggedIn
                                        ? _buildProfileText('생일: ${_formatBirthDate(user.petBirthDay)}')
                                        : SizedBox(),
                                    isLoggedIn
                                        ? _buildProfileText('보유 포인트: ${user.coins}')
                                        : SizedBox(),
                                    !isLoggedIn
                                        ? _buildProfileText('로그인을 하여 정보를 확인하세요')
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 2, // 경계선의 두께
                            color: Color(0xFFAAD5D1), // 경계선 색상
                          ),
                          SizedBox(height: 25),
                          // Circular progress for steps
                          CircularPercentIndicator(
                            circularStrokeCap: CircularStrokeCap.round,
                            percent: progress,
                            radius: radius,
                            lineWidth: 25,
                            animation: true,
                            animateFromLastPercent: true,
                            progressColor: Color(0xFFAAD5D1),
                            backgroundColor: Color(0xFFF1F4F8),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_convertStepsToKm(currentSteps).toStringAsFixed(2)} km',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '목표: ${(stepGoal * 0.75 / 1000).toStringAsFixed(2)} km',
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Profile image positioned at the top boundary of the slide panel with border
                Positioned(
                  top: screenHeight * 0.15, // This ensures the image is just above the slide panel
                  left: (screenWidth - 120) / 2, // Center horizontally
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // Circle shape
                      border: Border.all(
                        color: Color(0xFFAAD5D1), // Border color around the image
                        width: 5, // Border width
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60, // Size of the circle (profile image)
                      backgroundImage: AssetImage('assets/profile/${user.petName}.jpg'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFAAD5D1),
      leading: IconButton(
        icon: Icon(Icons.settings, color: Colors.black54),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Start()));
        },
      ),
      title: Text("Hot Dog",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildProfileText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        textAlign: TextAlign.start,
        style: TextStyle(
          color: Color(0xFF62807D),
          fontSize: 19,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: '쇼핑',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: '산책',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '내정보',
        ),
      ],
      backgroundColor: Color(0xFFAAD5D1),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      iconSize: 30,
      selectedFontSize: 16,
      unselectedFontSize: 14,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
            break;
          case 1:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Shop()));
            break;
          case 2:
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()));
            break;
          case 3:
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyInfo()));
            break;
        }
      },
    );
  }
}
