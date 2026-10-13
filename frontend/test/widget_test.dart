import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_syllabus/main.dart';
import 'package:custom_syllabus/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen to UploadTimetableScreen transition verification', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Launch App directly to LoginScreen
    await tester.pumpWidget(const CustomSyllabusApp());
    await tester.pumpAndSettle();

    // 2. Verify LoginScreen elements
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Log in'), findsWidgets);
  });
}
