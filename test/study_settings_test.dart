import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opensoftware_project/study_settings.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz_data.initializeTimeZones();
  final seoul = tz.getLocation('Asia/Seoul');

  test('알림 시각이 아직 안 지났으면 오늘, 지났으면 내일', () {
    final now = tz.TZDateTime(seoul, 2026, 11, 26, 19, 30);
    expect(
      nextReminderAt(const TimeOfDay(hour: 20, minute: 0), now),
      tz.TZDateTime(seoul, 2026, 11, 26, 20),
    );
    expect(
      nextReminderAt(const TimeOfDay(hour: 19, minute: 30), now),
      tz.TZDateTime(seoul, 2026, 11, 27, 19, 30),
    );
  });
}
