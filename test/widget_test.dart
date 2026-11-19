import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/main.dart';

void main() {
  testWidgets('로그인 후 하단 탭으로 화면을 전환한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ErreApp());

    // 시작 화면은 로그인 화면
    expect(find.text('에르 (Erre)'), findsOneWidget);

    // 빈 값으로 로그인하면 넘어가지 않음
    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pump();
    expect(find.text('이메일을 입력해 주세요.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'test@univ.ac.kr');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.widgetWithText(ElevatedButton, '로그인'));
    await tester.pumpAndSettle();

    expect(find.text('에르 - 홈'), findsOneWidget);

    await tester.tap(find.text('학습'));
    await tester.pump();

    expect(find.text('학습 탭'), findsOneWidget);
    expect(find.text('에르 - 홈'), findsNothing);
  });
}
