import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/frontend_screens.dart';
import 'package:opensoftware_project/record_screen.dart';

Future<void> pumpPhone(WidgetTester tester, Widget screen) async {
  // 갤럭시 에뮬레이터와 같은 1080 x 2340 화면
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(theme: frontendTheme, home: screen));
}

void main() {
  testWidgets('기록 탭: 실제 데이터를 넘침 없이 보여 주고 정답률로 전환된다', (tester) async {
    await pumpPhone(
      tester,
      const RecordScreen(
        accuracyPercent: 67,
        weeklyRecords: [
          DailyRecord(day: '토', solvedCount: 0, accuracy: null),
          DailyRecord(day: '일', solvedCount: 0, accuracy: null),
          DailyRecord(day: '월', solvedCount: 0, accuracy: null),
          DailyRecord(day: '화', solvedCount: 0, accuracy: null),
          DailyRecord(day: '수', solvedCount: 0, accuracy: null),
          DailyRecord(day: '목', solvedCount: 5, accuracy: 100),
          DailyRecord(day: '금', solvedCount: 10, accuracy: 50),
        ],
        topWrongWords: [
          WrongWordRank(
            word: '과실',
            topic: '공식 석상',
            meaning: '잘못',
            wrongCount: 3,
          ),
          WrongWordRank(
            word: '원칙',
            topic: '공식 석상',
            meaning: '기본 규칙',
            wrongCount: 1,
          ),
        ],
      ),
    );

    expect(tester.takeException(), isNull); // 화면이 넘치면 오류가 남
    expect(find.text('15문제'), findsOneWidget); // 이번 주 풀이 합계
    expect(find.text('67%'), findsOneWidget); // 이번 주 정답률
    expect(find.text('과실'), findsOneWidget);
    expect(find.text('3회'), findsOneWidget);

    await tester.tap(find.text('정답률').last);
    await tester.pumpAndSettle();
    expect(find.text('50%'), findsOneWidget); // 금요일 정답률
    expect(find.text('-'), findsNWidgets(5)); // 푼 문제 없는 날
    expect(tester.takeException(), isNull);
  });

  testWidgets('기록 탭: 기록이 없으면 안내 문구를 보여 준다', (tester) async {
    await pumpPhone(
      tester,
      RecordScreen(
        accuracyPercent: null,
        status: '로그인하면 기록이 저장돼요',
        weeklyRecords: [
          for (final day in ['토', '일', '월', '화', '수', '목', '금'])
            DailyRecord(day: day, solvedCount: 0, accuracy: null),
        ],
        topWrongWords: const [],
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('0문제'), findsOneWidget);
    expect(find.text('로그인하면 기록이 저장돼요'), findsOneWidget);
    expect(find.textContaining('이번 주에 푼 문제가 없어요'), findsOneWidget);
  });
}
