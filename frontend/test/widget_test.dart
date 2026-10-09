import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_syllabus/main.dart';
import 'package:custom_syllabus/screens/login_screen.dart';
import 'package:custom_syllabus/screens/upload_timetable_screen.dart';

void main() {
  testWidgets('LoginScreen to UploadTimetableScreen transition verification', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Launch App
    await tester.pumpWidget(const CustomSyllabusApp());
    await tester.pump(const Duration(milliseconds: 100));

    // 2. Verify LoginScreen elements
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsNWidgets(2));
    expect(find.text('Show'), findsOneWidget);

    // Tap Log in button
    await tester.ensureVisible(find.text('Log in').last);
    await tester.tap(find.text('Log in').last);
    await tester.pumpAndSettle();

    // Verify transition into UploadTimetableScreen
    expect(find.byType(UploadTimetableScreen), findsOneWidget);
    expect(find.text('Upload your\ntimetable'), findsOneWidget);
  });
}
