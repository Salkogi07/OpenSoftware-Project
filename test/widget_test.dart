import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:opensoftware_project/main.dart';
import 'package:opensoftware_project/main_navigation_screen.dart';
import 'package:opensoftware_project/theme.dart';

void main() {
  testWidgets('로그인 화면에서 빈 이메일을 검증한다', (WidgetTester tester) async {
    await tester.runAsync(() async {
      final supabase = await Supabase.initialize(
        url: 'https://example.invalid',
        publishableKey: 'test-key',
        authOptions: const FlutterAuthClientOptions(
          autoRefreshToken: false,
          detectSessionInUri: false,
          localStorage: EmptyLocalStorage(),
        ),
      );
      addTearDown(supabase.dispose);
    });
    await tester.pumpWidget(const ErreApp());

    // 시작 화면은 로그인 화면
    expect(find.text('에르 (Erre)'), findsOneWidget);

    // 빈 값으로 로그인하면 넘어가지 않음
    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pump();
    expect(find.text('이메일을 입력해 주세요.'), findsOneWidget);
  });

  testWidgets('홈 버튼과 하단 탭에서 학습·기록·마이페이지를 연다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: appTheme, home: const MainNavigationScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('하루어휘 - 홈'), findsOneWidget);
    final recordsButton = find.text('나의 기록');
    await tester.ensureVisible(recordsButton);
    await tester.pumpAndSettle();
    await tester.tap(recordsButton);
    await tester.pumpAndSettle();
    expect(find.text('기록 탭'), findsOneWidget);

    await tester.tap(find.text('학습'));
    await tester.pump();

    expect(find.text('학습 탭'), findsOneWidget);
    expect(find.text('하루어휘 - 홈'), findsNothing);

    // 학습 탭 → 단어장 복습 → 어휘장 화면
    await tester.tap(find.text('단어장 복습'));
    await tester.pumpAndSettle();
    expect(find.text('나만의 어휘장'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    final mistakes = find.text('오답노트');
    await tester.ensureVisible(mistakes);
    await tester.tap(mistakes);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '오답노트'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
