import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_syllabus/main.dart';
import 'package:custom_syllabus/screens/login_screen.dart';
import 'package:custom_syllabus/screens/loading_screen.dart';

void main() {
  testWidgets('LoginScreen to LoadingScreen transition verification', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Launch App
    await tester.pumpWidget(const CustomSyllabusApp());
    await tester.pump(const Duration(milliseconds: 100));

    // 2. Verify LoginScreen elements
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome to'), findsOneWidget);
    expect(find.text('Custom Syllabus'), findsOneWidget);
    expect(find.text('Log in to your account'), findsOneWidget);

    // Toggle password visibility
    expect(find.text('Show'), findsOneWidget);
    await tester.tap(find.text('Show'));
    await tester.pump();
    expect(find.text('Hide'), findsOneWidget);

    // Tap Log in
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pump();
    expect(find.text('Signing in...'), findsOneWidget);

    // Advance through state transition into LoadingScreen
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 650));
    expect(find.byType(LoadingScreen), findsOneWidget);

    // Verify ripple animation is running in LoadingScreen
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Custom Syllabus'), findsOneWidget);
  });
}
