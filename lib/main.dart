import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Start.dart';
import 'User_Provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  //await DBconnector.connect(); // DB 연결

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Start());
  }
}
