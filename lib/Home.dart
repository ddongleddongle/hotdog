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
  int currentSteps = 0; // 초기 걸음 수
  int stepGoal = 2000; // 목표 걸음 수
  UserProvider? userProvider;
  double? lat;
  double? lng;
  late SharedPreferences prefs;
  String? _status = 'Idle';

  @override
  void initState() {
    super.initState();
    // _initPedometer(); // pedometer 초기화
    // _requestLocationPermission();
    // _loadStepData();
    //_checkPermissions();  // SharedPreferences에서 데이터 로드
  }

  // _checkPermissions() async {
  //   PermissionStatus status = await Permission.activityRecognition.request();
  // }

  //권한요청
  // _requestLocationPermission() async {
  //   var status = await Permission.location.status;
  //   if (!status.isGranted) {
  //     await Permission.location.request();
  //   }
  // }

  // Future<void> _updatePosition() async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //
  //     // 위치 정보를 업데이트하기 전에 setState를 호출
  //     setState(() {
  //       lat = position.latitude;
  //       lng = position.longitude;
  //       print('Latitude: $lat, Longitude: $lng'); // 문자열 보간을 사용하여 출력
  //     });
  //
  //     // UI 업데이트 후 비동기 작업 수행
  //     final userProvider = Provider.of<UserProvider>(context, listen: false);
  //     await userProvider.updatePosition(lat, lng);
  //
  //   } catch (e) {
  //     print('Error occurred while fetching location: $e');
  //   }
  // }

  // _initPedometer() async {
  //   Pedometer.stepCountStream.listen((stepCount) {
  //     setState(() {
  //       currentSteps = stepCount.steps; // StepCount 객체에서 실제 걸음 수 가져오기
  //     });
  //     _saveStepData(); // SharedPreferences에 저장
  //   }, onError: (error) {
  //     setState(() {
  //       _status = 'Error: $error';
  //     });
  //   });
  // }

  _loadStepData(double currentSteps) async {
    prefs = await SharedPreferences.getInstance();
    String? lastDate = prefs.getString('lastDate');
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(lastDate);
    if (lastDate == null || lastDate != today) {
      currentSteps = 0;
      prefs.setString('lastDate', today);
      final user = Provider.of<UserProvider>(context);
      int currentCoins = user.coins ?? 0;
      userProvider?.updateUserCoinsAndDistance(currentCoins, currentSteps);
    }
  }

  _saveStepData() async {
    await prefs.setInt('currentSteps', currentSteps);
  }

  _resetSteps() async {
    await prefs.setInt('currentSteps', 0);
    setState(() {
      currentSteps = 1000; // UI에서 값도 초기화
    });
  }

  String _formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate == '0000') {
      return '로그인 하시옵소서';
    }
    DateTime date = DateTime.parse(birthDate);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // double _convertToKm(double meter) {
  //   double km = meter / 1000;
  //   return km;
  // }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    double totalDistance = user.totaldistance ?? 0.0;
    _loadStepData(totalDistance);
    double progress = totalDistance / stepGoal;
    progress = progress > 1.0 ? 1.0 : progress;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double radius = screenWidth * 0.3;
    double heightLimit = screenHeight * 0.3;
    radius = radius > heightLimit ? heightLimit : radius;


    return Scaffold(
        appBar: _buildAppBar(context),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            // 좌우 스와이프 시 화면 전환
            if (details.primaryVelocity! < 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Shop()),
              );
            }
          },
          child: Container(
            width: double.infinity, // 화면 너비에 맞추기
            height: double.infinity, // 화면 높이에 맞추기
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/back.jpg'), // 배경 이미지 경로
                fit: BoxFit.cover, // 이미지를 화면 크기에 맞게 조정 (확대/축소)
              ),
            ),
            //margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
            //color: Colors.white,
            child: Column(
              children: [
                _buildProfileSection(user),
                Flexible(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(24, 150, 24, 24),
                      child: SingleChildScrollView(
                        child: CircularPercentIndicator(
                          circularStrokeCap:
                              CircularStrokeCap.round, // 원 모양의 끝 처리
                          percent: progress,
                          radius: radius,
                          lineWidth: 25,
                          animation: true,
                          animateFromLastPercent: true,
                          progressColor: Colors.black,
                          backgroundColor: Color(0xFFF1F4F8),
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(totalDistance/ 1000).toStringAsFixed(2)} km',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '목표: ${(stepGoal / 1000).toStringAsFixed(2)} km',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          child: _buildBottomNavigationBar(context),
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.settings, color: Colors.black54),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Start()));
        },
      ),
      title: Text("Hot Dog",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFAAD5D1))),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(2.0), // 경계선의 두께
        child: Container(
          color: Color(0xFFAAD5D1),  // 경계선 색상
          height: 4,  // 경계선의 두께
        ),
      ),
    );
  }

  // 프로필 섹션 (로그인 상태에 따라 다르게 표시)
  Widget _buildProfileSection(UserProvider user) {
    return Container(
      height: 150,
      margin: EdgeInsets.fromLTRB(20, 50, 10, 0), // 프로필 영역 상하 마진 줄임
      padding: EdgeInsets.all(10), // 패딩 줄임
      decoration: BoxDecoration(
        color: Colors.white, // 배경 색상
        borderRadius: BorderRadius.circular(10), // 모서리 둥글게
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // 그림자 색상
            spreadRadius: 2, // 그림자 확산 정도
            blurRadius: 5, // 흐림 정도
            offset: Offset(0, 3), // 그림자 위치
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 25),
          Container(
            width: 110, // 이미지 너비 줄이기
            height: 110, // 이미지 높이 줄이기
            child: Image.asset('assets/images/pet.png', fit: BoxFit.cover),
          ),
          SizedBox(width: 60), // 이미지와 텍스트 간 간격 조정
          // 텍스트 영역
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoggedIn
                    ? _buildProfileText('이름: ${user.petName}')
                    : _buildProfileText('로그인 하세요'),
                isLoggedIn
                    ? _buildProfileText(
                        '생일: ${_formatBirthDate(user.petBirthDay)}')
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
    );
  }

  Widget _buildProfileText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2), // 텍스트 간 간격 좁힘
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF62807D),
          fontSize: 16, // 폰트 크기 줄이기
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Widget _buildButton(String label, VoidCallback onPressed) {
  //   return Container(
  //     decoration: ShapeDecoration(
  //       color: Color(0xFFAAD5D1),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //     ),
  //     child: ElevatedButton(
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: Colors.transparent,
  //         shadowColor: Colors.transparent,
  //         padding: EdgeInsets.zero,
  //       ),
  //       onPressed: onPressed,
  //       child: Center(
  //         child: Text(
  //           label,
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: 25,
  //             fontFamily: 'Inter',
  //             fontWeight: FontWeight.w700,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  BottomNavigationBar _buildBottomNavigationBar(context) {
    final user = Provider.of<UserProvider>(context);
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
            print('홈 선택됨');
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home()));
            break;
          case 1:
            print('쇼핑 선택됨');
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Shop()));
            break;
          case 2:
            print('산책 선택됨');
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen(),
                ));
            break;
          case 3:
            print('내정보 선택됨');
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MyInfo()));
            break;
        }
      },
    );
  }
}
