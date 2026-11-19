// 학습 기록을 수파베이스에 저장하고 불러오기. 김동우 담당
// 화면에서는 이 파일의 함수만 부르고, 계산은 learning_stats.dart가 맡습니다.
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'learning_stats.dart';

class LearningRepository {
  const LearningRepository();

  /// 로그인한 사용자의 클라이언트. 키가 없어 수파베이스를 안 켰거나(화면 작업·테스트) 로그아웃 상태면 null
  SupabaseClient? get _client {
    try {
      final client = Supabase.instance.client;
      return client.auth.currentUser == null ? null : client;
    } catch (_) {
      return null; // Supabase.initialize 전에는 instance 접근이 오류를 냄
    }
  }

  /// 답 하나 저장: 기록을 남기고, 틀리면 어휘장에 넣고 맞히면 뺌 (DB 함수 record_answer)
  /// 퀴즈 진행을 막지 않도록 실패해도 오류를 던지지 않고 로그만 남김
  // ponytail: 인터넷이 끊기면 그 답은 저장되지 않음. 필요하면 나중에 다시 보내는 대기열 추가
  Future<void> recordAnswer({
    required String questionId,
    required bool isCorrect,
    required int timeSpentMs,
  }) async {
    final client = _client;
    if (client == null) return;
    try {
      await client.rpc(
        'record_answer',
        params: {
          'p_question_id': questionId,
          'p_is_correct': isCorrect,
          'p_time_spent_ms': timeSpentMs,
        },
      );
    } catch (e) {
      debugPrint('푼 결과 저장 실패: $e');
    }
  }

  /// 오늘 출석 남기기 (학습을 한 번 끝냈을 때). 같은 날 여러 번 불러도 1번만 저장됨
  Future<void> markAttendance() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.rpc('mark_attendance');
    } catch (e) {
      debugPrint('출석 저장 실패: $e');
    }
  }

  /// 최근 [days]일 동안 푼 기록. 불러오기 실패는 화면에서 오류 상태로 보여 주도록 그대로 던짐
  Future<List<AttemptRecord>> fetchRecentAttempts({int days = 7}) async {
    final client = _client;
    if (client == null) return const [];
    final since = DateTime.now().toUtc().subtract(Duration(days: days));
    final rows = await client
        .from('attempts')
        .select('question_id, is_correct, time_spent_ms, answered_at')
        .gte('answered_at', since.toIso8601String())
        .order('answered_at');
    return rows.map(AttemptRecord.fromRow).toList();
  }

  /// 출석한 날짜들 (최근 것부터 최대 400일)
  Future<List<DateTime>> fetchAttendanceDays() async {
    final client = _client;
    if (client == null) return const [];
    final rows = await client
        .from('attendance')
        .select('attended_on')
        .order('attended_on', ascending: false)
        .limit(400);
    return rows
        .map((row) => DateTime.parse('${row['attended_on']}T00:00:00Z'))
        .toList();
  }

  /// 연속 출석일
  Future<int> fetchStreak() async =>
      currentStreak(await fetchAttendanceDays(), DateTime.now());

  /// 오늘의 복습 문제 번호 (최대 3개)
  Future<List<String>> fetchReviewQuestionIds({int count = 3}) async =>
      pickReviewQuestionIds(
        await fetchRecentAttempts(),
        DateTime.now(),
        count: count,
      );

  /// 기록 탭 주간 통계
  Future<WeeklyStats> fetchWeeklyStats() async =>
      weeklyStats(await fetchRecentAttempts(), DateTime.now());
}

const learningRepository = LearningRepository();
