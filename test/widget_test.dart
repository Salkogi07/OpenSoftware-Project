import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:opensoftware_project/main.dart' as app;
import 'package:opensoftware_project/main_navigation_screen.dart';
import 'package:opensoftware_project/record_screen.dart' as team_record;
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
    await tester.pumpWidget(const app.ErreApp());

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

    expect(find.text('사뿐사뿐'), findsOneWidget);
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
    expect(find.byType(team_record.RecordScreen), findsOneWidget);

    await tester.tap(find.text('학습'));
    await tester.pump();

    expect(find.text('오늘의 추천 어휘'), findsOneWidget);
    expect(find.text('사뿐사뿐'), findsNothing);

    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    final mistakes = find.text('오답노트');
    await tester.ensureVisible(mistakes);
    await tester.tap(mistakes);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, '오답노트'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Supabase 없이 5문제를 풀고 마이 탭의 두 상태를 확인한다', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(360, 780);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.text('학습'));
    await tester.pumpAndSettle();
    final preview = find.text('학습 주제 미리보기');
    final official = find.text('공식적인\n자리에서 쓰는 말');
    final related = find.text('원래 알던 단어에서\n뻗어 나온 말');
    final uncommon = find.text('요즘 잘\n안 쓰는 말');
    Finder tile(Finder label) =>
        find.ancestor(of: label, matching: find.byType(InkWell)).first;
    final officialPosition = tester.getCenter(tile(official));
    final relatedPosition = tester.getCenter(tile(related));
    final uncommonPosition = tester.getCenter(tile(uncommon));
    expect(officialPosition.dy, greaterThan(tester.getCenter(preview).dy));
    expect(officialPosition.dy, closeTo(uncommonPosition.dy, 1));
    expect(
      relatedPosition.dx - officialPosition.dx,
      closeTo(uncommonPosition.dx - relatedPosition.dx, 1),
    );
    expect(
      uncommonPosition.dy,
      lessThan(tester.getTopLeft(find.byType(NavigationBar)).dy),
    );
    await tester.tap(official);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(
            find.widgetWithText(ChoiceChip, '공식 석상에서 자주 쓰는 단어'),
          )
          .selected,
      isTrue,
    );
    await tester.tap(find.text('학습'));
    await tester.pumpAndSettle();
    expect(find.text('오늘의 추천 어휘'), findsOneWidget);
    expect(find.text('5문제 시작하기'), findsNothing);
    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    expect(find.text('로그인이 필요해요'), findsOneWidget);
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();
    expect(find.text('어휘새싹'), findsOneWidget);
    final dailyGoal = find.text('하루 학습 목표');
    await tester.scrollUntilVisible(dailyGoal, 140);
    await tester.ensureVisible(dailyGoal);
    await tester.tap(dailyGoal);
    await tester.pumpAndSettle();
    await tester.tap(find.text('직접 입력'));
    await tester.pumpAndSettle();
    final goalInput = find.byType(TextFormField);
    await tester.enterText(goalInput, '0');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('1 이상의 정수를 입력해 주세요.'), findsOneWidget);
    await tester.enterText(goalInput, '13');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('13문제'), findsOneWidget);
    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    expect(find.text('7 / 13'), findsOneWidget);
    await tester.tap(find.text('마이'));
    await tester.pumpAndSettle();
    final signOut = find.text('미리보기 로그아웃');
    await tester.scrollUntilVisible(signOut, 180);
    await tester.ensureVisible(signOut);
    await tester.pumpAndSettle();
    await tester.tap(signOut);
    await tester.pumpAndSettle();
    expect(find.text('로그인이 필요해요'), findsOneWidget);

    await tester.tap(find.text('홈'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('이어 학습하기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('공식 석상에서 자주 쓰는 단어'));
    await tester.tap(find.text('중 · 상황에 맞는 표현 고르기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5문제 시작하기'));
    await tester.pumpAndSettle();

    const choices = ['폐회', '상정', '표결', '가결', '폐회'];
    const correctWords = ['개회', '상정', '표결', '가결', '폐회'];
    for (final (index, choice) in choices.indexed) {
      expect(find.text('${index + 1} / 5'), findsOneWidget);
      final check = find.widgetWithText(FilledButton, '정답 확인하기');
      expect(tester.widget<FilledButton>(check).onPressed, isNull);
      await tester.tap(find.text(choice));
      await tester.pump();
      expect(find.text('정답 단어'), findsNothing);
      await tester.tap(check);
      await tester.pumpAndSettle();
      expect(find.text(index == 0 ? '아쉬워요!' : '정답이에요!'), findsOneWidget);
      expect(find.text(correctWords[index]), findsOneWidget);
      expect(find.text('예문'), findsOneWidget);
      expect(find.text('언제 쓰나요?'), findsOneWidget);
      await tester.tap(find.text(index == 4 ? '학습 마치기' : '다음 문제'));
      await tester.pumpAndSettle();
    }
    expect(find.widgetWithText(AppBar, '학습 완료'), findsOneWidget);
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
