// 풀던 문제 이어서 하기: 진행 상황을 기기에 저장하고 불러옴
// 화면에서는 이 파일의 함수만 부름
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 풀다가 나간 문제 묶음. 문제 은행의 문제 번호로 저장
class QuizSession {
  const QuizSession({
    required this.questionIds,
    required this.index,
    required this.answers,
    this.isReview = false,
    this.topic,
    this.difficulty,
  });

  final List<String> questionIds;

  /// 지금 풀 차례인 문제 위치 (0부터)
  final int index;

  /// 앞에서 푼 문제의 정답 여부
  final List<bool> answers;
  final bool isReview;
  final String? topic;
  final String? difficulty;

  int get count => questionIds.length;

  Map<String, Object?> toJson() => {
    'ids': questionIds,
    'index': index,
    'answers': answers,
    'review': isReview,
    'topic': topic,
    'difficulty': difficulty,
  };

  static QuizSession? fromJson(Map<String, Object?> json) {
    final ids = (json['ids'] as List?)?.cast<String>();
    final index = json['index'] as int?;
    final answers = (json['answers'] as List?)?.cast<bool>();
    if (ids == null || ids.isEmpty || index == null || answers == null) {
      return null;
    }
    if (index < 0 || index >= ids.length || answers.length != index) {
      return null;
    }
    return QuizSession(
      questionIds: ids,
      index: index,
      answers: answers,
      isReview: json['review'] as bool? ?? false,
      topic: json['topic'] as String?,
      difficulty: json['difficulty'] as String?,
    );
  }
}

const _sessionKey = 'quiz_session';

Future<QuizSession?> loadQuizSession() async {
  final raw = await SharedPreferencesAsync().getString(_sessionKey);
  if (raw == null) return null;
  try {
    return QuizSession.fromJson(jsonDecode(raw) as Map<String, Object?>);
  } on FormatException {
    return null;
  }
}

Future<void> saveQuizSession(QuizSession? session) async {
  final prefs = SharedPreferencesAsync();
  if (session == null) return prefs.remove(_sessionKey);
  await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
}

/// [queue]에서 [count]개를 꺼냄. 비어 있으면 [refill]로 다시 채우고 섞음
List<T> takeBatch<T>(List<T> queue, int count, Iterable<T> Function() refill) {
  if (queue.isEmpty) queue.addAll(refill().toList()..shuffle());
  final batch = queue.take(count).toList();
  queue.removeRange(0, batch.length);
  return batch;
}
