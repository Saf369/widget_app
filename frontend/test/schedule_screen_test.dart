import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_syllabus/models/schedule.dart';
import 'package:custom_syllabus/screens/schedule_screen.dart';

void main() {
  testWidgets('ScheduleScreen month view calendar displays dynamic underlines and subject legend', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Set initial custom timetable
    updateGlobalTimetable([
      TimetableEntry(
        id: '1',
        day: 'MON',
        startTime: '09:00',
        endTime: '10:00',
        subject: 'Algorithms',
        colorCode: '0xFFD7A1A7',
      ),
      TimetableEntry(
        id: '2',
        day: 'MON',
        startTime: '10:30',
        endTime: '11:30',
        subject: 'Database Systems',
        colorCode: '0xFFBDE4C9',
      ),
      TimetableEntry(
        id: '3',
        day: 'TUE',
        startTime: '13:00',
        endTime: '14:00',
        subject: 'Cyber Security',
        colorCode: '0xFFC4B9DC',
      ),
    ]);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScheduleScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify dynamic subjects in the legend
    expect(find.text('Algorithms'), findsWidgets);
    expect(find.text('Database Systems'), findsWidgets);
    expect(find.text('Cyber Security'), findsWidgets);

    // Simulate uploading a new timetable with completely different subjects
    updateGlobalTimetable([
      TimetableEntry(
        id: '4',
        day: 'WED',
        startTime: '08:00',
        endTime: '09:00',
        subject: 'Quantum Physics',
        colorCode: '0xFFB5E2FA',
      ),
      TimetableEntry(
        id: '5',
        day: 'THU',
        startTime: '11:00',
        endTime: '12:00',
        subject: 'Machine Learning',
        colorCode: '0xFFF6C6A2',
      ),
    ]);

    await tester.pumpAndSettle();

    // Verify legend dynamically updated to the new uploaded subjects
    expect(find.text('Quantum Physics'), findsWidgets);
    expect(find.text('Machine Learning'), findsWidgets);
    expect(find.text('Algorithms'), findsNothing);
  });
}
