// 학습 기록을 수파베이스에 저장하고 불러오기. 김동우 담당
// 화면에서는 이 파일의 함수만 부르고, 계산은 learning_stats.dart가 맡습니다.
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'learning_stats.dart';

class LearningRepository {
  // 저장 요청을 순서대로 처리. 화면을 새로 그리기 전에 flush()로 밀린 저장을 기다림
  Future<void> _pendingWrites = Future.value();

  void _enqueue(Future<void> Function() write) {
    _pendingWrites = _pendingWrites.then((_) => write());
  }

  /// 아직 끝나지 않은 저장 요청을 모두 기다림
  Future<void> flush() => _pendingWrites;

  /// 로그인해서 수파베이스에 저장·불러오기가 가능한지
  bool get isLoggedIn => _client != null;

  /// 로그인한 사용자의 이메일
  String? get email => _client?.auth.currentUser?.email;

  /// 가입한 날
  DateTime? get signedUpAt {
    final createdAt = _client?.auth.currentUser?.createdAt;
    return createdAt == null ? null : DateTime.tryParse(createdAt)?.toLocal();
  }

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
  void recordAnswer({
    required String questionId,
    required bool isCorrect,
    required int timeSpentMs,
  }) {
    final client = _client;
    if (client == null) return;
    _enqueue(() async {
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
    });
  }

  /// 오늘 출석 남기기 (학습을 한 번 끝냈을 때). 같은 날 여러 번 불러도 1번만 저장됨
  void markAttendance() {
    final client = _client;
    if (client == null) return;
    _enqueue(() async {
      try {
        await client.rpc('mark_attendance');
      } catch (e) {
        debugPrint('출석 저장 실패: $e');
      }
    });
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

  /// (지금 연속 출석일, 가장 길었던 연속 출석일)
  Future<(int, int)> fetchStreaks() async {
    final days = await fetchAttendanceDays();
    return (currentStreak(days, DateTime.now()), longestStreak(days));
  }

  /// 프로필 사진 값 ('mascot:<이름>' 또는 'photo:<주소>'), 없으면 null
  Future<String?> fetchAvatar() async {
    final client = _client;
    if (client == null) return null;
    final row = await client
        .from('profiles')
        .select('avatar')
        .eq('id', client.auth.currentUser!.id)
        .maybeSingle();
    return row?['avatar'] as String?;
  }

  /// 프로필 사진 값 저장. 사진을 바꾸면 예전에 올린 사진 파일은 지움
  Future<void> updateAvatar(String avatar) async {
    final client = _client;
    if (client == null) return;
    final userId = client.auth.currentUser!.id;
    await client.from('profiles').upsert({'id': userId, 'avatar': avatar});
    final keep = avatar.startsWith('photo:') ? avatar.split('/').last : null;
    await _removeAvatarPhotos(client, except: keep);
  }

  /// 갤러리에서 고른 사진을 올리고 'photo:<공개 주소>' 값을 돌려줌
  Future<String?> uploadAvatarPhoto(Uint8List bytes, String extension) async {
    final client = _client;
    if (client == null) return null;
    final ext = extension.toLowerCase() == 'png' ? 'png' : 'jpg';
    // 같은 이름에 덮어쓰면 캐시 때문에 예전 사진이 보일 수 있어 매번 새 이름으로 올림
    final path =
        '${client.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final bucket = client.storage.from('avatars');
    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        contentType: 'image/${ext == 'png' ? 'png' : 'jpeg'}',
      ),
    );
    return 'photo:${bucket.getPublicUrl(path)}';
  }

  /// 본인이 올린 프로필 사진 파일 지우기 (회원 탈퇴 때도 사용)
  Future<void> removeAvatarPhotos() async {
    final client = _client;
    if (client != null) await _removeAvatarPhotos(client);
  }

  Future<void> _removeAvatarPhotos(
    SupabaseClient client, {
    String? except,
  }) async {
    final userId = client.auth.currentUser!.id;
    final bucket = client.storage.from('avatars');
    final files = await bucket.list(path: userId);
    final paths = [
      for (final file in files)
        if (file.name != except) '$userId/${file.name}',
    ];
    if (paths.isNotEmpty) await bucket.remove(paths);
  }

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

  /// 홈·마이페이지 요약 숫자 (DB 함수 my_learning_summary)
  Future<LearningSummary> fetchSummary() async {
    final client = _client;
    if (client == null) return LearningSummary.empty;
    final rows = await client.rpc('my_learning_summary') as List<dynamic>;
    return LearningSummary.fromRow(rows.first as Map<String, dynamic>);
  }

  /// 가입할 때 정한 닉네임 (profiles 표)
  Future<String?> fetchNickname() async {
    final client = _client;
    if (client == null) return null;
    final row = await client
        .from('profiles')
        .select('nickname')
        .eq('id', client.auth.currentUser!.id)
        .maybeSingle();
    return row?['nickname'] as String?;
  }

  /// 프로필 편집에서 바꾼 닉네임 저장
  void updateNickname(String nickname) {
    final client = _client;
    if (client == null) return;
    _enqueue(() async {
      try {
        await client.from('profiles').upsert({
          'id': client.auth.currentUser!.id,
          'nickname': nickname,
        });
      } catch (e) {
        debugPrint('닉네임 저장 실패: $e');
      }
    });
  }

  /// 어휘장(틀린 문제) 문제 내용. 최근에 틀린 순. questions.json과 같은 칸으로 돌려줌
  Future<List<Map<String, dynamic>>> fetchWrongQuestionRows() async {
    final client = _client;
    if (client == null) return const [];
    final rows = await client
        .from('wrong_answers')
        .select('questions(*)')
        .order('last_wrong_at', ascending: false);
    return [for (final row in rows) row['questions'] as Map<String, dynamic>];
  }

  /// 문제 번호들로 문제 내용 가져오기 (기록 탭 TOP 3 단어 이름 표시용)
  Future<List<Map<String, dynamic>>> fetchQuestionRows(List<String> ids) async {
    final client = _client;
    if (client == null || ids.isEmpty) return const [];
    return client.from('questions').select().inFilter('id', ids);
  }
}

final learningRepository = LearningRepository();
