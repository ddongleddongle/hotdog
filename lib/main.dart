import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Start.dart';
import 'User_Provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  // await DBconnector.connect(); // DB 연결

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Observer 등록
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Observer 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // 앱이 종료되거나 백그라운드로 가기 직전 실행할 코드
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.logout();
      _onAppExit();
    }
  }

  void _onAppExit() {
    // 앱이 종료될 때 실행할 코드
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.logout();
    // 필요한 추가 작업을 여기에 추가하세요
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Start());
  }
}
