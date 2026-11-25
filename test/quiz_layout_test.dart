import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/frontend_screens.dart';
import 'package:opensoftware_project/theme.dart';

const _blankGuidance = '빈칸에 알맞은 표현을 골라보세요.';
const _choiceGuidance = '가장 알맞은 답을 골라보세요.';

void main() {
  testWidgets('학습 완료 버튼의 간격과 정렬을 유지하고 짧은 화면에서는 스크롤한다', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(360, 780);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const word = Word(
      topic: '',
      name: '개회',
      meaning: '모임이나 회의를 시작함.',
      distractor: '',
      example: '',
      alternative: '',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: frontendTheme,
        home: CompletionScreen(
          words: List.filled(5, word),
          answers: const [true, false, false, false, false],
          isReview: false,
          nextBatch: () => [word],
        ),
      ),
    );
    final retry = find.widgetWithText(OutlinedButton, '틀린 문제 다시 풀기');
    final next = find.widgetWithText(FilledButton, '같은 주제로 다음 5문제 풀기');
    final home = find.widgetWithText(OutlinedButton, '홈으로');
    final heading = find.text('다시 확인할 단어');
    expect(tester.getTopLeft(retry).dx, tester.getTopLeft(heading).dx);
    expect(tester.getRect(next).top - tester.getRect(retry).bottom, 5);
    expect(tester.getRect(home).top - tester.getRect(next).bottom, 5);
    expect(780 - tester.getRect(home).bottom, 46);

    tester.view.physicalSize = const Size(360, 220);
    await tester.pump();
    await tester.scrollUntilVisible(home, 100);
    await Scrollable.ensureVisible(tester.element(home), alignment: 0.5);
    await tester.pump();
    expect(home.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
      for (final difficulty in ['하', '중', '상']) {
        // 주제는 위쪽, 난이도는 아래쪽에 있어 각각 그쪽으로 스크롤해서 고름
        for (final (option, delta) in [
          (find.text(topic), -150.0),
          (find.text(difficulty), 150.0),
        ]) {
          await tester.scrollUntilVisible(option, delta);
          await tester.pumpAndSettle();
          await tester.tap(option);
          await tester.pump();
        }
        await tester.tap(find.text('5문제 시작하기'));
        await tester.pumpAndSettle();

        final quiz = tester.widget<QuizScreen>(find.byType(QuizScreen));
        final word = quiz.words.first;
        expect(word.topic, topic);
        expect(word.difficulty, difficulty);
        expect(find.text('1 / 5'), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
        // 하·중은 빈칸 문장, 상은 뜻풀이 문제
        final guidance = find.text(
          difficulty == '상' ? _choiceGuidance : _blankGuidance,
        );
        expect(guidance, findsOneWidget);
        expect(
          find.text('힌트 · ${word.meaning}'),
          difficulty == '하' ? findsOneWidget : findsNothing,
        );
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
        await tester.tap(find.text('나가기'));
        await tester.pumpAndSettle();
        expect(find.byType(NavigationBar), findsOneWidget);
        ScaffoldMessenger.of(tester.element(find.byType(NavigationBar)))
            .clearSnackBars();
        await tester.pumpAndSettle();
      }
    }
  });
  testWidgets('문제 은행에서 기존 질문과 뜻 고르기 안내 문구를 표시한다', (tester) async {
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
      expect(find.text(_choiceGuidance), findsOneWidget);
      expect(find.text(_blankGuidance), findsNothing);
      expect(find.textContaining('뜻:'), findsNothing);
      expect(find.textContaining('안내:'), findsNothing);
    }
  });
}
