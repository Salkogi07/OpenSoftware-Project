import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/frontend_screens.dart';
import 'package:opensoftware_project/theme.dart';

// 홈 화면의 오늘의 단어는 앱 전체에서 한 번만 불러오므로, 홈을 여는 테스트는 파일을 나눔
void main() {
  testWidgets('풀다가 나가면 학습 탭에서 그 문제부터 이어서 풀고, 해설 화면에는 하단 탭이 없다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: appTheme, home: MainScreen(preview: true)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('이어 학습하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('공식 석상에서 자주 쓰는 단어'));
    await tester.ensureVisible(find.text('하'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('하'));
    await tester.pump();
    await tester.tap(find.text('5문제 시작하기'));
    await tester.pumpAndSettle();

    // 첫 문제를 풀고 해설로: 하단 탭 없음
    await tester.tap(find.byType(OutlinedButton).first);
    await tester.pump();
    await tester.tap(find.text('정답 확인하기'));
    await tester.pumpAndSettle();
    expect(find.byType(ExplanationScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.text('다음 문제'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 5'), findsOneWidget);

    // 나가기 → 하단 탭이 돌아오고 이어 풀기 카드가 보임
    await tester.tap(find.text('나가기'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.scrollUntilVisible(find.text('풀던 문제 이어서 풀기'), -200);
    await tester.pumpAndSettle();
    expect(find.text('풀던 문제 이어서 풀기'), findsOneWidget);
    await tester.tap(find.text('풀던 문제 이어서 풀기'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 5'), findsOneWidget);

    // 홈의 이어 학습하기도 같은 자리로 (안내 메시지가 하단 탭을 가리지 않게 닫고 누름)
    await tester.tap(find.text('나가기'));
    await tester.pumpAndSettle();
    ScaffoldMessenger.of(tester.element(find.byType(NavigationBar)))
        .clearSnackBars();
    await tester.pumpAndSettle();
    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('이어 학습하기'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 5'), findsOneWidget);
  });
}
