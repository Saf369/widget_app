import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';

class TimetableEntry {
  final String id;
  final String day;
  final String startTime;
  final String endTime;
  final String subject;
  final String room;
  final String instructor;
  final String colorCode;
  final String dayOfWeek;

  TimetableEntry({
    this.id = '',
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.room = '',
    this.instructor = '',
    this.colorCode = '0xFFE8CACF',
    this.dayOfWeek = '',
  });

  static String normalizeDay(String raw) {
    final s = raw.trim().toUpperCase();
    if (s.startsWith('MON')) return 'MON';
    if (s.startsWith('TUE')) return 'TUE';
    if (s.startsWith('WED')) return 'WED';
    if (s.startsWith('THU')) return 'THUR';
    if (s.startsWith('FRI')) return 'FRI';
    if (s.startsWith('SAT')) return 'SAT';
    if (s.startsWith('SUN')) return 'SUN';
    return s.isNotEmpty ? s : 'MON';
  }

  static String toFullDay(String day) {
    switch (normalizeDay(day)) {
      case 'MON': return 'Monday';
      case 'TUE': return 'Tuesday';
      case 'WED': return 'Wednesday';
      case 'THUR': return 'Thursday';
      case 'FRI': return 'Friday';
      case 'SAT': return 'Saturday';
      case 'SUN': return 'Sunday';
      default: return 'Monday';
    }
  }

  DateTime startDateTime(DateTime baseDate) {
    return parseClassTimeToDate(baseDate, startTime, isEnd: false);
  }

  DateTime endDateTime(DateTime baseDate) {
    final start = startDateTime(baseDate);
    var end = parseClassTimeToDate(baseDate, endTime, isEnd: true);
    if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
      end = start.add(const Duration(minutes: 60));
    }
    return end;
  }

  bool isHappeningNow(DateTime now) {
    final start = startDateTime(now);
    final end = endDateTime(now);
    return now.isAfter(start) && now.isBefore(end);
  }

  bool isCompleted(DateTime now) {
    final end = endDateTime(now);
    return now.isAfter(end);
  }

  bool isUpcoming(DateTime now) {
    final start = startDateTime(now);
    return now.isBefore(start);
  }

  double progress(DateTime now) {
    final start = startDateTime(now);
    final end = endDateTime(now);
    if (now.isBefore(start)) return 0.0;
    if (now.isAfter(end)) return 1.0;
    final totalSec = end.difference(start).inSeconds;
    if (totalSec <= 0) return 1.0;
    final elapsedSec = now.difference(start).inSeconds;
    return (elapsedSec / totalSec).clamp(0.0, 1.0);
  }

  int minutesRemaining(DateTime now) {
    final end = endDateTime(now);
    if (now.isAfter(end)) return 0;
    return end.difference(now).inMinutes;
  }

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    final rawDay = json['day'] ?? json['day_of_week'] ?? '';
    final normDay = normalizeDay(rawDay.toString());
    final subjectVal = (json['subject'] ?? json['course_name'] ?? json['title'] ?? 'Class').toString().trim();
    
    return TimetableEntry(
      id: (json['id'] ?? '').toString(),
      day: normDay,
      startTime: (json['start_time'] ?? json['startTime'] ?? '').toString().trim(),
      endTime: (json['end_time'] ?? json['endTime'] ?? '').toString().trim(),
      subject: subjectVal.isNotEmpty ? subjectVal : 'Class',
      room: (json['room'] ?? json['location'] ?? '').toString().trim(),
      instructor: (json['instructor'] ?? '').toString().trim(),
      colorCode: (json['color_code'] ?? json['color'] ?? '0xFFE8CACF').toString(),
      dayOfWeek: (json['day_of_week'] ?? toFullDay(normDay)).toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'start_time': startTime,
      'end_time': endTime,
      'subject': subject,
      'room': room,
      'instructor': instructor,
      'color_code': colorCode,
      'day_of_week': dayOfWeek,
    };
  }
}

DateTime parseClassTimeToDate(DateTime baseDate, String timeStr, {bool isEnd = false}) {
  int hour = isEnd ? 10 : 9;
  int minute = 0;
  try {
    String clean = timeStr.trim().toUpperCase();
    bool isPm = clean.contains('PM');
    bool isAm = clean.contains('AM');
    clean = clean.replaceAll(RegExp(r'[A-Z\s]'), '');
    final parts = clean.split(':');
    if (parts.isNotEmpty) {
      hour = int.tryParse(parts[0]) ?? hour;
      if (parts.length > 1) {
        minute = int.tryParse(parts[1]) ?? 0;
      }
      if (isPm && hour < 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      if (!isPm && !isAm && hour >= 1 && hour <= 6) {
        hour += 12;
      }
    }
  } catch (_) {}
  return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
}

// Initial default timetable
final List<TimetableEntry> _initialDefaultTimetable = [
  // MONDAY
  TimetableEntry(day: 'MON', startTime: '8:30', endTime: '9:30', subject: 'MATH', room: 'Room 302', instructor: 'Dr. Euler', colorCode: '0xFFE8CACF'),
  TimetableEntry(day: 'MON', startTime: '9:30', endTime: '10:30', subject: 'PDHPE', room: 'Gym', instructor: 'Coach Taylor', colorCode: '0xFFCDE6E2'),
  TimetableEntry(day: 'MON', startTime: '10:30', endTime: '11:30', subject: 'ENGLISH', room: 'Hall 2', instructor: 'Ms. Austen', colorCode: '0xFFDBD3EE'),
  TimetableEntry(day: 'MON', startTime: '11:30', endTime: '12:30', subject: 'VISUAL ART', room: 'Studio A', instructor: 'Mr. Monet', colorCode: '0xFFEFCCB8'),
  TimetableEntry(day: 'MON', startTime: '1:30', endTime: '2:30', subject: 'HISTORY', room: 'Room 105', instructor: 'Dr. Herodotus', colorCode: '0xFFE9CCAA'),
  TimetableEntry(day: 'MON', startTime: '2:30', endTime: '3:30', subject: 'DRAMA', room: 'Theater', instructor: 'Ms. Shakespeare', colorCode: '0xFFBDE4C9'),

  // TUESDAY
  TimetableEntry(day: 'TUE', startTime: '8:30', endTime: '9:30', subject: 'LOTE', room: 'Lab B', instructor: 'Mme. Curie', colorCode: '0xFFB5E2FA'),
  TimetableEntry(day: 'TUE', startTime: '9:30', endTime: '10:30', subject: 'PDHPE', room: 'Gym', instructor: 'Coach Taylor', colorCode: '0xFFCDE6E2'),
  TimetableEntry(day: 'TUE', startTime: '10:30', endTime: '11:30', subject: 'GEOGRAPHY', room: 'Hall 1', instructor: 'Dr. Darwin', colorCode: '0xFFE8CACF'),
  TimetableEntry(day: 'TUE', startTime: '11:30', endTime: '12:30', subject: 'MUSIC', room: 'Audio Lab', instructor: 'Prof. Mozart', colorCode: '0xFFDBD3EE'),
  TimetableEntry(day: 'TUE', startTime: '1:30', endTime: '2:30', subject: 'MATH', room: 'Room 302', instructor: 'Dr. Euler', colorCode: '0xFFEFCCB8'),
  TimetableEntry(day: 'TUE', startTime: '2:30', endTime: '3:30', subject: 'SCIENCE', room: 'Lab 1', instructor: 'Dr. Franklin', colorCode: '0xFFBDE4C9'),

  // WEDNESDAY
  TimetableEntry(day: 'WED', startTime: '8:30', endTime: '9:30', subject: 'SCIENCE', room: 'Lab 1', instructor: 'Dr. Franklin', colorCode: '0xFFBDE4C9'),
  TimetableEntry(day: 'WED', startTime: '9:30', endTime: '10:30', subject: 'LOTE', room: 'Lab B', instructor: 'Mme. Curie', colorCode: '0xFFB5E2FA'),
  TimetableEntry(day: 'WED', startTime: '10:30', endTime: '11:30', subject: 'ENGLISH', room: 'Hall 2', instructor: 'Ms. Austen', colorCode: '0xFFDBD3EE'),
  TimetableEntry(day: 'WED', startTime: '11:30', endTime: '12:30', subject: 'DRAMA', room: 'Theater', instructor: 'Ms. Shakespeare', colorCode: '0xFFE8CACF'),
  TimetableEntry(day: 'WED', startTime: '1:30', endTime: '2:30', subject: 'MATH', room: 'Room 302', instructor: 'Dr. Euler', colorCode: '0xFFEFCCB8'),
  TimetableEntry(day: 'WED', startTime: '2:30', endTime: '3:30', subject: 'GEOGRAPHY', room: 'Hall 1', instructor: 'Dr. Darwin', colorCode: '0xFFE9CCAA'),

  // THURSDAY
  TimetableEntry(day: 'THUR', startTime: '8:30', endTime: '9:30', subject: 'HISTORY', room: 'Room 105', instructor: 'Dr. Herodotus', colorCode: '0xFFE9CCAA'),
  TimetableEntry(day: 'THUR', startTime: '9:30', endTime: '10:30', subject: 'SCIENCE', room: 'Lab 1', instructor: 'Dr. Franklin', colorCode: '0xFFBDE4C9'),
  TimetableEntry(day: 'THUR', startTime: '10:30', endTime: '11:30', subject: 'MUSIC', room: 'Audio Lab', instructor: 'Prof. Mozart', colorCode: '0xFFDBD3EE'),
  TimetableEntry(day: 'THUR', startTime: '11:30', endTime: '12:30', subject: 'GEOGRAPHY', room: 'Hall 1', instructor: 'Dr. Darwin', colorCode: '0xFFCDE6E2'),
  TimetableEntry(day: 'THUR', startTime: '1:30', endTime: '2:30', subject: 'ENGLISH', room: 'Hall 2', instructor: 'Ms. Austen', colorCode: '0xFFEFCCB8'),
  TimetableEntry(day: 'THUR', startTime: '2:30', endTime: '3:30', subject: 'LOTE', room: 'Lab B', instructor: 'Mme. Curie', colorCode: '0xFFB5E2FA'),

  // FRIDAY
  TimetableEntry(day: 'FRI', startTime: '8:30', endTime: '9:30', subject: 'VISUAL ART', room: 'Studio A', instructor: 'Mr. Monet', colorCode: '0xFFEFCCB8'),
  TimetableEntry(day: 'FRI', startTime: '9:30', endTime: '10:30', subject: 'SCIENCE', room: 'Lab 1', instructor: 'Dr. Franklin', colorCode: '0xFFBDE4C9'),
  TimetableEntry(day: 'FRI', startTime: '10:30', endTime: '11:30', subject: 'MATH', room: 'Room 302', instructor: 'Dr. Euler', colorCode: '0xFFE8CACF'),
  TimetableEntry(day: 'FRI', startTime: '11:30', endTime: '12:30', subject: 'DRAMA', room: 'Theater', instructor: 'Ms. Shakespeare', colorCode: '0xFFDBD3EE'),
  TimetableEntry(day: 'FRI', startTime: '1:30', endTime: '2:30', subject: 'ENGLISH', room: 'Hall 2', instructor: 'Ms. Austen', colorCode: '0xFFE9CCAA'),
  TimetableEntry(day: 'FRI', startTime: '2:30', endTime: '3:30', subject: 'LOTE', room: 'Lab B', instructor: 'Mme. Curie', colorCode: '0xFFB5E2FA'),
];

// Active timetable in memory
List<TimetableEntry> globalTimetable = List<TimetableEntry>.from(_initialDefaultTimetable);

// Notifier to broadcast timetable updates to all screens
final ValueNotifier<List<TimetableEntry>> timetableNotifier = ValueNotifier<List<TimetableEntry>>(globalTimetable);

const String _kPrefsTimetableKey = 'saved_timetable_entries';

/// Updates globalTimetable, notifies listeners, and persists to local storage and HomeWidget
Future<void> updateGlobalTimetable(List<TimetableEntry> entries) async {
  globalTimetable = List<TimetableEntry>.from(entries);
  timetableNotifier.value = List<TimetableEntry>.from(entries);

  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_kPrefsTimetableKey, jsonEncode(jsonList));

    // Also update HomeWidget data if on mobile
    if (!kIsWeb) {
      await HomeWidget.saveWidgetData<String>('timetable_entries', jsonEncode(jsonList));
      await HomeWidget.updateWidget(name: 'TimetableWidgetProvider');
      await HomeWidget.updateWidget(name: 'TimetableGlanceWidgetReceiver');
    }
  } catch (e) {
    debugPrint('Error saving timetable to storage: $e');
  }
}

/// Loads timetable from local storage if available
Future<void> loadSavedTimetable() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_kPrefsTimetableKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(jsonString);
      final entries = decoded.map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>)).toList();
      if (entries.isNotEmpty) {
        globalTimetable = entries;
        timetableNotifier.value = List<TimetableEntry>.from(entries);
      }
    }

    // Immediately sync active timetable to HomeWidget so the Android widget is in sync from app launch
    if (!kIsWeb) {
      final jsonList = globalTimetable.map((e) => e.toJson()).toList();
      await HomeWidget.saveWidgetData<String>('timetable_entries', jsonEncode(jsonList));
      await HomeWidget.updateWidget(name: 'TimetableWidgetProvider');
      await HomeWidget.updateWidget(name: 'TimetableGlanceWidgetReceiver');
    }
  } catch (e) {
    debugPrint('Error loading saved timetable: $e');
  }
}
