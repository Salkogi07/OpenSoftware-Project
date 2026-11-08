import 'package:flutter/material.dart';
import 'theme.dart';
import 'main_navigation_screen.dart';

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
      home: const MainNavigationScreen(),
    );
  }
}