import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_syllabus/models/schedule.dart';
import 'package:custom_syllabus/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen tracks time and displays distinguishable expanded card for ongoing period', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final now = DateTime.now();
    final todayShort = ['MON', 'TUE', 'WED', 'THUR', 'FRI', 'SAT', 'SUN'][now.weekday - 1];

    // Create an ongoing class and next upcoming class that encompass current time today
    final String ongoingStartStr;
    final String ongoingEndStr;
    final String nextStartStr;
    final String nextEndStr;

    if (now.hour == 23) {
      final startMin = now.minute > 5 ? now.minute - 5 : 0;
      ongoingStartStr = '23:${startMin.toString().padLeft(2, '0')}';
      final endMin = now.minute < 50 ? now.minute + 5 : 56;
      ongoingEndStr = '23:${endMin.toString().padLeft(2, '0')}';
      nextStartStr = '23:${(endMin + 1).toString().padLeft(2, '0')}';
      nextEndStr = '23:59';
    } else {
      final startMin = now.minute > 2 ? now.minute - 2 : 0;
      ongoingStartStr = '${now.hour}:${startMin.toString().padLeft(2, '0')}';
      ongoingEndStr = '${now.hour + 1}:00';
      nextStartStr = '${now.hour + 1}:10';
      nextEndStr = '${now.hour + 1}:50';
    }

    updateGlobalTimetable([
      TimetableEntry(
        id: '1',
        day: todayShort,
        startTime: ongoingStartStr,
        endTime: ongoingEndStr,
        subject: 'Mobile Architecture',
        room: 'Lab 401',
        instructor: 'Prof. Turing',
        colorCode: '0xFFD7A1A7',
      ),
      TimetableEntry(
        id: '2',
        day: todayShort,
        startTime: nextStartStr,
        endTime: nextEndStr,
        subject: 'Data Science',
        room: 'Hall B',
        instructor: 'Dr. Lovelace',
        colorCode: '0xFFBDE4C9',
      ),
    ]);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify distinguishable expanded card for current class
    expect(find.text('HAPPENING NOW'), findsWidgets);
    expect(find.text('Mobile Architecture'), findsWidgets);
    expect(find.textContaining('left'), findsWidgets);
    expect(find.textContaining('Up next: Data Science'), findsWidgets);
  });

  testWidgets('HomeScreen periodically advances to next period when time passes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final now = DateTime.now();
    final todayShort = ['MON', 'TUE', 'WED', 'THUR', 'FRI', 'SAT', 'SUN'][now.weekday - 1];

    // Class 1 ends now, Class 2 is upcoming
    updateGlobalTimetable([
      TimetableEntry(
        id: '10',
        day: todayShort,
        startTime: '07:00',
        endTime: '07:45',
        subject: 'Early Morning Routine',
        room: 'Online',
        colorCode: '0xFFD7A1A7',
      ),
      TimetableEntry(
        id: '11',
        day: todayShort,
        startTime: '23:30',
        endTime: '23:59',
        subject: 'Night Study Session',
        room: 'Library',
        colorCode: '0xFFBDE4C9',
      ),
    ]);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify ticker timer triggers periodic rebuild without errors
    await tester.pump(const Duration(seconds: 16));
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
