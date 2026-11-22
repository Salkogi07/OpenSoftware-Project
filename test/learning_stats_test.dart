import 'package:flutter_test/flutter_test.dart';

import 'package:opensoftware_project/learning/learning_stats.dart';

// 한국 시간 2026-11-19 12:00 (= UTC 03:00)
final now = DateTime.utc(2026, 11, 19, 3);

AttemptRecord attempt(String id, bool correct, int ms, DateTime at) =>
    AttemptRecord(
      questionId: id,
      isCorrect: correct,
      timeSpentMs: ms,
      answeredAt: at,
    );

DateTime daysAgo(int days) => now.subtract(Duration(days: days));

void main() {
  group('한국 날짜', () {
    test('UTC 15시 이후는 한국에서 다음 날', () {
      expect(
        koreanDate(DateTime.utc(2026, 11, 18, 14, 59)),
        DateTime.utc(2026, 11, 18),
      );
      expect(
        koreanDate(DateTime.utc(2026, 11, 18, 15, 0)),
        DateTime.utc(2026, 11, 19),
      );
    });
  });

  group('연속 출석', () {
    DateTime day(int d) => DateTime.utc(2026, 11, d);

    test('오늘까지 3일 연속', () {
      expect(currentStreak([day(17), day(18), day(19)], now), 3);
    });
    test('오늘 아직 안 했으면 어제까지 이어진 기록', () {
      expect(currentStreak([day(17), day(18)], now), 2);
    });
    test('어제 빠지면 끊김', () {
      expect(currentStreak([day(16), day(17)], now), 0);
    });
    test('중간에 빠진 날 이전은 세지 않음', () {
      expect(currentStreak([day(14), day(15), day(18), day(19)], now), 2);
    });
    test('기록이 없으면 0', () {
      expect(currentStreak([], now), 0);
    });
  });

  group('복습 문제 뽑기', () {
    test('틀린 문제와 평균보다 오래 걸린 문제를 고르고, 많이 틀린 순', () {
      final picked = pickReviewQuestionIds([
        attempt('A', false, 1000, daysAgo(1)),
        attempt('A', false, 1000, daysAgo(2)),
        attempt('B', false, 1000, daysAgo(1)),
        attempt('C', true, 9000, daysAgo(1)), // 맞혔지만 오래 걸림
        attempt('D', true, 1000, daysAgo(1)), // 맞혔고 빠름 → 제외
      ], now);
      expect(picked, ['A', 'B', 'C']);
    });
    test('7일보다 오래된 기록은 제외', () {
      expect(
        pickReviewQuestionIds([attempt('A', false, 1000, daysAgo(8))], now),
        isEmpty,
      );
    });
    test('최대 개수를 넘지 않음', () {
      final many = [
        for (var i = 0; i < 10; i++) attempt('Q$i', false, 1000, daysAgo(1)),
      ];
      expect(pickReviewQuestionIds(many, now, count: 2), hasLength(2));
    });
    test('기록이 없으면 빈 목록', () {
      expect(pickReviewQuestionIds([], now), isEmpty);
    });
  });

  group('주간 통계', () {
    test('요일별 학습량, 정답률, 자주 틀린 TOP 3', () {
      final stats = weeklyStats([
        attempt('A', false, 1, daysAgo(0)),
        attempt('A', false, 1, daysAgo(1)),
        attempt('A', true, 1, daysAgo(1)),
        attempt('B', false, 1, daysAgo(2)),
        attempt('C', false, 1, daysAgo(3)),
        attempt('D', false, 1, daysAgo(0)), // D와 C는 1번씩 → 최근에 틀린 D가 앞
        attempt('E', true, 1, daysAgo(6)),
        attempt('Z', false, 1, daysAgo(7)), // 7일 전 → 제외
      ], now);
      expect(stats.dailyCounts, [1, 0, 0, 1, 1, 2, 2]);
      expect(stats.accuracy, closeTo(2 / 7, 1e-9));
      expect(stats.topWrongQuestionIds, ['A', 'D', 'B']);
      expect(stats.topWrongCounts, [2, 1, 1]);
      expect(stats.dailyCorrect, [1, 0, 0, 0, 0, 1, 0]);
      expect(stats.dailyAccuracyPercent(5), 50); // 어제: 2문제 중 1문제
      expect(stats.dailyAccuracyPercent(6), 0); // 오늘: 2문제 모두 틀림
      expect(stats.dailyAccuracyPercent(1), isNull); // 푼 문제 없음
    });
    test('기록이 없으면 정답률 null', () {
      final stats = weeklyStats([], now);
      expect(stats.dailyCounts, List.filled(7, 0));
      expect(stats.accuracy, isNull);
      expect(stats.topWrongQuestionIds, isEmpty);
    });
  });

  group('요약 숫자와 레벨', () {
    test('정답률과 경험치', () {
      const summary = LearningSummary(
        totalAnswers: 10,
        correctAnswers: 7,
        learnedWords: 8,
        todayAnswers: 5,
      );
      expect(summary.accuracy, closeTo(0.7, 1e-9));
      expect(summary.xp, 21);
    });
    test('푼 문제가 없으면 정답률 null, 경험치 0', () {
      expect(LearningSummary.empty.accuracy, isNull);
      expect(LearningSummary.empty.xp, 0);
    });
    test('100 XP마다 1레벨 (디자인 예시: 320 XP = Lv.4, 다음 400)', () {
      expect(levelFor(0), (level: 1, xpInLevel: 0, xpForNext: 100));
      expect(levelFor(99), (level: 1, xpInLevel: 99, xpForNext: 100));
      expect(levelFor(100), (level: 2, xpInLevel: 0, xpForNext: 200));
      expect(levelFor(320), (level: 4, xpInLevel: 20, xpForNext: 400));
    });
  });

  test('오늘의 단어 순번은 한국 날짜가 바뀔 때 다음으로 넘어감', () {
    // 한국 11월 21일 23:59 과 같은 날 00:00 은 같은 단어
    final late = DateTime.utc(2026, 11, 21, 14, 59);
    final early = DateTime.utc(2026, 11, 20, 15, 0);
    expect(dailyIndex(500, late), dailyIndex(500, early));
    // 다음 날(한국 11월 22일 00:00)은 다음 단어, 끝에 닿으면 처음으로
    final next = DateTime.utc(2026, 11, 21, 15, 0);
    expect(dailyIndex(500, next), (dailyIndex(500, late) + 1) % 500);
    expect(dailyIndex(1, next), 0);
  });
}
