import 'package:flutter/material.dart';
import 'frontend_screens.dart' as frontend;

// 로그인 뒤 화면: 디자인(frontend_screens.dart)의 하단 탭 화면을 디자인 테마로 보여줍니다.
// 홈·학습(주제 → 퀴즈 → 해설 → 완료)·기록·마이 탭과 오답노트 저장은 MainScreen이 맡습니다.
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(data: frontend.frontendTheme, child: const frontend.MainScreen());
  }
}
