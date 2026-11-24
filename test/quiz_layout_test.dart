import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/frontend_screens.dart';
import 'package:opensoftware_project/theme.dart';

const _guidance = '빈칸에 알맞은 표현을 골라보세요.';

void main() {
  testWidgets('미리보기의 모든 주제와 난이도에서 같은 퀴즈 카드를 표시한다', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(theme: appTheme, home: MainScreen(preview: true)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('이어 학습하기'));
    await tester.pumpAndSettle();

    for (final topic in [
      '공식 석상에서 자주 쓰는 단어',
      '현재는 상대적으로 드문 격식어',
      '뜻을 혼동하기 쉬운 표현',
    ]) {
      for (final (difficulty, label) in [
        ('하', '하 · 표현을 보고 뜻 고르기'),
        ('중', '중 · 상황에 맞는 표현 고르기'),
        ('상', '상 · 정의에 맞는 표현 고르기'),
      ]) {
        await tester.tap(find.widgetWithText(ChoiceChip, topic));
        await tester.tap(find.widgetWithText(ChoiceChip, label));
        await tester.pump();
        await tester.tap(find.text('5문제 시작하기'));
        await tester.pumpAndSettle();

        final quiz = tester.widget<QuizScreen>(find.byType(QuizScreen));
        final word = quiz.words.first;
        expect(word.topic, topic);
        expect(word.difficulty, difficulty);
        expect(find.text('1 / 5'), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        final guidance = find.text(_guidance);
        expect(guidance, findsOneWidget);
        expect(find.textContaining('뜻:'), findsNothing);
        expect(find.textContaining('안내:'), findsNothing);
        final guidanceText = tester.widget<Text>(guidance);
        expect(guidanceText.maxLines, 1);
        expect(guidanceText.softWrap, isFalse);
        final fittedGuidance = find
            .ancestor(of: guidance, matching: find.byType(FittedBox))
            .first;
        expect(tester.widget<FittedBox>(fittedGuidance).fit, BoxFit.scaleDown);
        final title = find.text('어휘 퀴즈');
        final titleContainer = find
            .ancestor(of: title, matching: find.byType(Container))
            .first;
        final titleBox = find
            .descendant(of: titleContainer, matching: find.byType(DecoratedBox))
            .first;
        final guidanceBox = find
            .ancestor(of: guidance, matching: find.byType(Container))
            .first;
        final guidanceBounds = tester.getRect(guidanceBox);
        final textBounds = tester.getRect(guidance);
        expect(textBounds.left, greaterThan(guidanceBounds.left));
        expect(textBounds.right, lessThan(guidanceBounds.right));
        final promptBox = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints?.minHeight == 108 &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.white,
        );
        expect(
          tester.getTopLeft(titleBox).dx,
          greaterThan(tester.getTopLeft(guidanceBox).dx),
        );
        expect(
          tester.getSize(titleBox).width,
          lessThan(tester.getSize(guidanceBox).width),
        );
        expect(
          tester.getTopLeft(guidanceBox).dy - tester.getBottomLeft(titleBox).dy,
          closeTo(
            tester.getTopLeft(promptBox).dy -
                tester.getBottomLeft(guidanceBox).dy,
            1,
          ),
        );
        final confirm = find.widgetWithText(FilledButton, '정답 확인하기');
        expect(confirm.hitTestable(), findsOneWidget);
        expect(tester.widget<FilledButton>(confirm).onPressed, isNull);
        expect(tester.takeException(), isNull);
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(NavigationBar), findsOneWidget);
      }
    }
  });
  testWidgets('문제 은행에서 기존 질문과 공통 안내 문구를 표시한다', (tester) async {
    rootBundle.evict('assets/questions.json');
    final words = (await tester.runAsync(loadQuestionBank))!;
    final examples = <(String, String), Word>{};
    for (final word in words) {
      examples.putIfAbsent((word.topic, word.difficulty!), () => word);
    }
    expect(examples, hasLength(9));
    for (final word in examples.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: QuizScreen(key: ValueKey(word.id), words: [word]),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(word.prompt!, findRichText: true), findsOneWidget);
      expect(find.text(_guidance), findsOneWidget);
      expect(find.textContaining('뜻:'), findsNothing);
      expect(find.textContaining('안내:'), findsNothing);
    }
  });
}
