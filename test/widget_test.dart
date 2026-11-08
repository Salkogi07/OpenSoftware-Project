import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/main.dart';

void main() {
  testWidgets('하단 탭으로 화면을 전환한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ErreApp());

    expect(find.text('에르 - 홈'), findsOneWidget);

    await tester.tap(find.text('학습'));
    await tester.pump();

    expect(find.text('학습 탭'), findsOneWidget);
    expect(find.text('에르 - 홈'), findsNothing);
  });
}
