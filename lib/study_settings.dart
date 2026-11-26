// 학습 설정(하루 목표, 학습 알림)을 기기에 저장하고, 매일 정한 시각에 학습 알림을 예약
// 화면에서는 이 파일의 함수만 부름
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class StudySettings {
  const StudySettings({
    required this.dailyGoal,
    required this.reminderTime,
    required this.reminderOn,
  });

  static const defaults = StudySettings(
    dailyGoal: 10,
    reminderTime: TimeOfDay(hour: 20, minute: 0),
    reminderOn: false,
  );

  final int dailyGoal;
  final TimeOfDay reminderTime;
  final bool reminderOn;
}

const _goalKey = 'daily_goal';
const _reminderMinuteKey = 'reminder_minute';
const _reminderOnKey = 'reminder_on';

Future<StudySettings> loadStudySettings() async {
  final prefs = SharedPreferencesAsync();
  final minute = await prefs.getInt(_reminderMinuteKey);
  return StudySettings(
    dailyGoal: await prefs.getInt(_goalKey) ?? StudySettings.defaults.dailyGoal,
    reminderTime: minute == null
        ? StudySettings.defaults.reminderTime
        : TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    reminderOn: await prefs.getBool(_reminderOnKey) ?? false,
  );
}

Future<void> saveDailyGoal(int goal) =>
    SharedPreferencesAsync().setInt(_goalKey, goal);

Future<void> _saveReminder(TimeOfDay time, bool on) async {
  final prefs = SharedPreferencesAsync();
  await prefs.setInt(_reminderMinuteKey, time.hour * 60 + time.minute);
  await prefs.setBool(_reminderOnKey, on);
}

final _notifications = FlutterLocalNotificationsPlugin();
const _reminderId = 1;
var _ready = false;

Future<void> _init() async {
  if (_ready) return;
  tz_data.initializeTimeZones();
  // ponytail: 한국 사용자용 앱이라 한국 시간으로 고정. 해외 지원이 필요하면 기기 시간대 패키지 추가
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  await _notifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  _ready = true;
}

/// 다음 [time] 시각 (이미 지났으면 내일)
tz.TZDateTime nextReminderAt(TimeOfDay time, tz.TZDateTime now) {
  var at = tz.TZDateTime(
    now.location,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
  if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
  return at;
}

/// 매일 [time]에 학습 알림을 켬. 알림 권한을 거절하면 false
Future<bool> turnOnReminder(TimeOfDay time) async {
  await _init();
  final android = _notifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  final ios = _notifications
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();
  final granted =
      await android?.requestNotificationsPermission() ??
      await ios?.requestPermissions(alert: true, sound: true) ??
      true;
  if (!granted) return false;

  // 정확한 알람 권한이 없으면 안드로이드가 알림을 최대 1시간까지 늦춤 (휴대폰에서 "안 온다"의 원인)
  // 안드로이드 14부터는 기본으로 꺼져 있어서, 없으면 설정 화면을 열어 허용을 부탁함. 거절하면 늦게라도 오는 방식으로
  final exact =
      android == null ||
      (await android.canScheduleExactNotifications() ?? false) ||
      (await android.requestExactAlarmsPermission() ?? false);

  await _notifications.cancel(id: _reminderId);
  await _notifications.zonedSchedule(
    id: _reminderId,
    title: '오늘의 어휘 학습 시간이에요',
    body: '5문제만 풀어도 연속 학습이 이어져요.',
    scheduledDate: nextReminderAt(time, tz.TZDateTime.now(tz.local)),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'study_reminder',
        '학습 알림',
        channelDescription: '매일 정한 시각에 학습을 알려 줘요.',
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시각
  );
  await _saveReminder(time, true);
  return true;
}

Future<void> turnOffReminder(TimeOfDay time) async {
  await _init();
  await _notifications.cancel(id: _reminderId);
  await _saveReminder(time, false);
}
