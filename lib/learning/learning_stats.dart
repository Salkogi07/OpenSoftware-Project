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

/// 날마다 하나씩 바뀌는 순번 (한국 날짜 기준). 오늘의 단어를 고를 때 씀
int dailyIndex(int length, DateTime now) =>
    koreanDate(now).difference(DateTime.utc(2026)).inDays % length;

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
    required this.dailyCorrect,
    required this.accuracy,
    required this.topWrongQuestionIds,
    required this.topWrongCounts,
  });

  /// 최근 7일 학습량(푼 문제 수). [0]이 6일 전, [6]이 오늘
  final List<int> dailyCounts;

  /// 최근 7일 맞힌 문제 수 (dailyCounts와 같은 순서)
  final List<int> dailyCorrect;

  /// 그날 정답률(0~100, 반올림). 푼 문제가 없는 날은 null
  int? dailyAccuracyPercent(int index) => dailyCounts[index] == 0
      ? null
      : (dailyCorrect[index] * 100 / dailyCounts[index]).round();

  /// 최근 7일 정답률(0~1). 푼 문제가 없으면 null
  final double? accuracy;

  /// 최근 7일 자주 틀린 문제 TOP 3 (틀린 횟수 많은 순, 같으면 최근에 틀린 순)
  final List<String> topWrongQuestionIds;

  /// TOP 3 각각의 최근 7일 틀린 횟수 (topWrongQuestionIds와 같은 순서)
  final List<int> topWrongCounts;
}

WeeklyStats weeklyStats(List<AttemptRecord> attempts, DateTime now) {
  final today = koreanDate(now);
  final firstDay = today.subtract(const Duration(days: 6));
  final dailyCounts = List<int>.filled(7, 0);
  final dailyCorrect = List<int>.filled(7, 0);
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
      dailyCorrect[index]++;
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

  final top3 = top.take(3).toList();
  return WeeklyStats(
    dailyCounts: dailyCounts,
    dailyCorrect: dailyCorrect,
    accuracy: total == 0 ? null : correct / total,
    topWrongQuestionIds: top3,
    topWrongCounts: [for (final id in top3) wrongCount[id]!],
  );
}

/// 홈·마이페이지 요약 숫자 (DB 함수 my_learning_summary 결과)
class LearningSummary {
  const LearningSummary({
    required this.totalAnswers,
    required this.correctAnswers,
    required this.learnedWords,
    required this.todayAnswers,
  });

  factory LearningSummary.fromRow(Map<String, dynamic> row) => LearningSummary(
    totalAnswers: row['total_answers'] as int,
    correctAnswers: row['correct_answers'] as int,
    learnedWords: row['learned_words'] as int,
    todayAnswers: row['today_answers'] as int,
  );

  static const empty = LearningSummary(
    totalAnswers: 0,
    correctAnswers: 0,
    learnedWords: 0,
    todayAnswers: 0,
  );

  final int totalAnswers;
  final int correctAnswers;

  /// 한 번이라도 푼 단어 수 (중복 제외)
  final int learnedWords;

  /// 오늘(한국 날짜) 푼 문제 수
  final int todayAnswers;

  /// 전체 정답률(0~1). 푼 문제가 없으면 null
  double? get accuracy =>
      totalAnswers == 0 ? null : correctAnswers / totalAnswers;

  /// 경험치: 맞힌 문제당 3 XP (학습 완료 화면의 보상 기준과 같음)
  int get xp => correctAnswers * xpPerCorrect;
}

const xpPerCorrect = 3;
const xpPerLevel = 100;

/// 경험치로 레벨 계산: 100 XP마다 1레벨 (0 XP = Lv.1)
({int level, int xpInLevel, int xpForNext}) levelFor(int xp) => (
  level: xp ~/ xpPerLevel + 1,
  xpInLevel: xp % xpPerLevel,
  xpForNext: (xp ~/ xpPerLevel + 1) * xpPerLevel,
);
