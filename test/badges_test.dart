import 'package:flutter_test/flutter_test.dart';
import 'package:opensoftware_project/learning/learning_stats.dart';

void main() {
  test('가장 길게 이어진 연속 출석일 (중간에 끊겨도 최장 기록 유지)', () {
    DateTime d(int day) => DateTime.utc(2026, 11, day);
    expect(longestStreak([d(1), d(2), d(3), d(5), d(6)]), 3);
    expect(longestStreak([d(3), d(1), d(2), d(2)]), 3); // 순서·중복 무관
    expect(longestStreak(const []), 0);
  });

  test('배지는 목표에 닿으면 획득, 정답률 배지는 20문제 이상부터', () {
    const few = LearningSummary(
      totalAnswers: 10,
      correctAnswers: 10,
      learnedWords: 30,
      todayAnswers: 0,
    );
    final badges = {for (final b in studyBadges(few, 3)) b.title: b};
    expect(badges['첫 걸음']!.earned, isTrue);
    expect(badges['꾸준한 출석']!.earned, isTrue);
    expect(badges['일주일 완주']!.earned, isFalse);
    expect(badges['단어 수집가']!.earned, isTrue);
    expect(badges['정확한 눈']!.earned, isFalse); // 100%여도 10문제뿐

    const many = LearningSummary(
      totalAnswers: 20,
      correctAnswers: 16,
      learnedWords: 0,
      todayAnswers: 0,
    );
    final accurate = studyBadges(many, 0).firstWhere((b) => b.title == '정확한 눈');
    expect(accurate.earned, isTrue);
  });
}
