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

    // Verify COMING SOON badges (Notifications, Study reminders, AI Tutor)
    expect(find.text('COMING SOON'), findsNWidgets(3));

    // Verify all three are wrapped in Opacity (grayed out)
    final opacityFinders = find.byType(Opacity);
    expect(opacityFinders, findsWidgets);

    // Verify SharedPreferences remains false (disabled)
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('settings_notifications') ?? false, isFalse);
    expect(prefs.getBool('settings_study_reminders') ?? false, isFalse);

    // Tapping has no effect on toggling on
    await tester.tap(find.text('Notifications'));
    await tester.tap(find.text('Study reminders'));
    await tester.pumpAndSettle();

    expect(prefs.getBool('settings_notifications') ?? false, isFalse);
    expect(prefs.getBool('settings_study_reminders') ?? false, isFalse);
  });
}
