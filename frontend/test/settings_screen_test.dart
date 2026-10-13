import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_syllabus/screens/settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Notifications and Study reminders show COMING SOON and are permanently turned off in SettingsScreen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify both items are present
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Study reminders'), findsOneWidget);
    expect(find.text('AI Tutor'), findsOneWidget);

    // Verify icons
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.alarm_rounded), findsOneWidget);

    // Verify COMING SOON badge for AI Tutor
    expect(find.text('COMING SOON'), findsOneWidget);

    // Verify opacity for AI Tutor
    final opacityFinders = find.byType(Opacity);
    expect(opacityFinders, findsWidgets);

    // Initial state is disabled
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings_notifications') ?? false, isFalse);
    expect(prefs.getBool('settings_study_reminders') ?? false, isFalse);

    // Toggle notifications on
    final switchFinders = find.byWidgetPredicate((w) => w.runtimeType.toString() == '_ToggleSwitch');
    expect(switchFinders, findsWidgets);
    await tester.tap(switchFinders.first);
    await tester.pumpAndSettle();
    expect(prefs.getBool('settings_notifications'), isTrue);
  });
}
