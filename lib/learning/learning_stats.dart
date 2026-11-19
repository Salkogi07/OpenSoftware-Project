// 학습 기록 계산 (화면 코드와 분리된 순수 함수). 김동우 담당
// - 연속 출석일, 복습 문제 뽑기, 기록 탭 주간 통계
// 날짜는 모두 한국 시간 기준입니다.

/// 문제 하나를 푼 기록 (수파베이스 attempts 표 1줄)
class AttemptRecord {
  const AttemptRecord({
    required this.questionId,
    required this.isCorrect,
    required this.timeSpentMs,
    required this.answeredAt,
  });

  factory AttemptRecord.fromRow(Map<String, dynamic> row) => AttemptRecord(
    questionId: row['question_id'] as String,
    isCorrect: row['is_correct'] as bool,
    timeSpentMs: row['time_spent_ms'] as int,
    answeredAt: DateTime.parse(row['answered_at'] as String),
  );

  final String questionId;
  final bool isCorrect;
  final int timeSpentMs;
  final DateTime answeredAt;
}

/// 한국 날짜(시간 없이). 서버 시간은 UTC라서 9시간을 더해 날짜를 정함
DateTime koreanDate(DateTime time) {
  final kst = time.toUtc().add(const Duration(hours: 9));
  return DateTime.utc(kst.year, kst.month, kst.day);
}

/// 연속 출석일. 오늘 아직 학습 전이어도 어제까지 이어졌으면 그 기록을 보여 줌
int currentStreak(Iterable<DateTime> attendedDays, DateTime now) {
  final days = attendedDays
      .map((d) => DateTime.utc(d.year, d.month, d.day))
      .toSet();
  var day = koreanDate(now);
  if (!days.contains(day)) day = day.subtract(const Duration(days: 1));
  var streak = 0;
  while (days.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

/// 복습 문제 뽑기: 최근 7일 안에 틀렸거나 평균보다 오래 걸린 문제를 최대 [count]개
/// 틀린 횟수가 많은 문제 → 오래 걸린 문제 순서로 고름
List<String> pickReviewQuestionIds(
  List<AttemptRecord> attempts,
  DateTime now, {
  int count = 3,
}) {
  final since = now.subtract(const Duration(days: 7));
  final recent = attempts.where((a) => a.answeredAt.isAfter(since)).toList();
  if (recent.isEmpty) return const [];

  final average =
      recent.fold<int>(0, (sum, a) => sum + a.timeSpentMs) / recent.length;
  final wrongCount = <String, int>{};
  final slowest = <String, int>{};
  for (final a in recent) {
    if (!a.isCorrect) {
      wrongCount[a.questionId] = (wrongCount[a.questionId] ?? 0) + 1;
    }
    if (a.timeSpentMs > average) {
      final prev = slowest[a.questionId] ?? 0;
      if (a.timeSpentMs > prev) slowest[a.questionId] = a.timeSpentMs;
    }
  }

  final candidates = {...wrongCount.keys, ...slowest.keys}.toList()
    ..sort((x, y) {
      final byWrong = (wrongCount[y] ?? 0).compareTo(wrongCount[x] ?? 0);
      if (byWrong != 0) return byWrong;
      return (slowest[y] ?? 0).compareTo(slowest[x] ?? 0);
    });
  return candidates.take(count).toList();
}

/// 기록 탭 주간 통계
class WeeklyStats {
  const WeeklyStats({
    required this.dailyCounts,
    required this.accuracy,
    required this.topWrongQuestionIds,
  });

  /// 최근 7일 학습량(푼 문제 수). [0]이 6일 전, [6]이 오늘
  final List<int> dailyCounts;

  /// 최근 7일 정답률(0~1). 푼 문제가 없으면 null
  final double? accuracy;

  /// 최근 7일 자주 틀린 문제 TOP 3 (틀린 횟수 많은 순, 같으면 최근에 틀린 순)
  final List<String> topWrongQuestionIds;
}

WeeklyStats weeklyStats(List<AttemptRecord> attempts, DateTime now) {
  final today = koreanDate(now);
  final firstDay = today.subtract(const Duration(days: 6));
  final dailyCounts = List<int>.filled(7, 0);
  var correct = 0;
  var total = 0;
  final wrongCount = <String, int>{};
  final lastWrong = <String, DateTime>{};

  for (final a in attempts) {
    final index = koreanDate(a.answeredAt).difference(firstDay).inDays;
    if (index < 0 || index > 6) continue;
    dailyCounts[index]++;
    total++;
    if (a.isCorrect) {
      correct++;
    } else {
      wrongCount[a.questionId] = (wrongCount[a.questionId] ?? 0) + 1;
      final prev = lastWrong[a.questionId];
      if (prev == null || a.answeredAt.isAfter(prev)) {
        lastWrong[a.questionId] = a.answeredAt;
      }
    }
  }

  final top = wrongCount.keys.toList()
    ..sort((x, y) {
      final byCount = wrongCount[y]!.compareTo(wrongCount[x]!);
      if (byCount != 0) return byCount;
      return lastWrong[y]!.compareTo(lastWrong[x]!);
    });

  return WeeklyStats(
    dailyCounts: dailyCounts,
    accuracy: total == 0 ? null : correct / total,
    topWrongQuestionIds: top.take(3).toList(),
  );
}
