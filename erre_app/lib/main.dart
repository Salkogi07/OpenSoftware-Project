import 'package:flutter/material.dart';
import 'theme.dart';
// import 'main_navigation_screen.dart';
import 'auth_screen.dart'; // 👈 1. 로그인 화면 파일을 임포트합니다.
void main() {
  runApp(const ErreApp());
}

class ErreApp extends StatelessWidget {
  const ErreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '에르',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const AuthScreen(), // 👈 2. 시작 화면을 로그인 화면으로 변경합니다!
    );
  }
}