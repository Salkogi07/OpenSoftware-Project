import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/theme.dart';
import 'package:opensoftware_project/vocabulary_screen.dart';

void main() {
  testWidgets('휴대폰 화면 크기에서 어휘장 글자가 넘치지 않는다', (WidgetTester tester) async {
    // 갤럭시 에뮬레이터와 같은 1080 x 2340 화면
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(theme: appTheme, home: const VocabularyScreen()));

    // 화면이 넘치면 Flutter가 오류를 던져 이 테스트가 실패함
    expect(tester.takeException(), isNull);
    expect(find.text('ubiquitous'), findsOneWidget);
  });
}
