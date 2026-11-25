import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/frontend_screens.dart';
import 'package:opensoftware_project/learning/learning_stats.dart';

RankingEntry entry(String name, int correct, int days, {bool me = false}) =>
    RankingEntry(
      nickname: name,
      avatar: null,
      correctAnswers: correct,
      attendanceDays: days,
      isMe: me,
    );

Future<void> pumpRanking(
  WidgetTester tester,
  Future<List<RankingEntry>> Function({required bool weekly}) load,
) async {
  // 갤럭시 에뮬레이터와 같은 1080 x 2340 화면
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: frontendTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: rankingSectionForTest(load),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('랭킹: 기준·기간을 바꾸면 순위가 바뀌고 내 줄이 보인다', (tester) async {
    await pumpRanking(
      tester,
      ({required weekly}) async => weekly
          ? [entry('하늘', 12, 2), entry('바다', 4, 5), entry('나야', 8, 1, me: true)]
          : [entry('하늘', 40, 9), entry('나야', 50, 3, me: true)],
    );

    expect(tester.takeException(), isNull);
    expect(find.text('12문제'), findsOneWidget);
    expect(find.text('나'), findsOneWidget); // 내 줄 표시

    await tester.tap(find.text('출석일'));
    await tester.pumpAndSettle();
    expect(find.text('5일'), findsOneWidget);

    await tester.tap(find.text('경험치'));
    await tester.pumpAndSettle();
    expect(find.text('Lv.1 · 36 XP'), findsOneWidget);

    await tester.tap(find.text('전체'));
    await tester.pumpAndSettle();
    expect(find.text('Lv.2 · 150 XP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('랭킹: 다른 사람이 없으면 안내, 실패하면 다시 시도', (tester) async {
    var fail = true;
    await pumpRanking(tester, ({required weekly}) async {
      if (fail) throw Exception('네트워크');
      return [entry('나야', 0, 0, me: true)];
    });
    expect(find.text('다시 시도'), findsOneWidget);

    fail = false;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.textContaining('아직 순위가 없어요'), findsOneWidget);
  });
}
