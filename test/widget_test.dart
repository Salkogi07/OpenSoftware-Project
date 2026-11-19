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
          persistSession: false,
          pkceAsyncStorage: _TestPkceStorage(),
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
    // 학습 탭이 questions.json을 읽는 동안 로딩 스피너가 돌아서, 실제 시간으로 잠깐 기다림
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await tester.pumpAndSettle();

    expect(find.text('하루어휘 - 홈'), findsOneWidget);
    final recordsButton = find.text('나의 기록');
    // 버튼이 화면 아래에 있어 아직 그려지지 않았을 수 있으므로 스크롤해서 찾음
    await tester.scrollUntilVisible(
      recordsButton,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(recordsButton);
    await tester.pumpAndSettle();
    expect(find.text('기록 탭'), findsOneWidget);

    await tester.tap(find.text('학습'));
    await tester.pump();

    expect(find.text('학습 탭'), findsOneWidget);
    expect(find.text('하루어휘 - 홈'), findsNothing);

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

class _TestPkceStorage extends GotrueAsyncStorage {
  const _TestPkceStorage();

  @override
  Future<String?> getItem({required String key}) async => null;

  @override
  Future<void> removeItem({required String key}) async {}

  @override
  Future<void> setItem({required String key, required String value}) async {}
}
