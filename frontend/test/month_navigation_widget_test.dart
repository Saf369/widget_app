import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_syllabus/widgets/home_widget_ui.dart';

void main() {
  testWidgets('Month view allows going forward and backward in months', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TimetableHomeWidgetUI(activeTab: TimetableWidgetTab.month),
        ),
      ),
    );

    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final now = DateTime.now();
    final currentMonthTitle = '${monthNames[now.month - 1]} ${now.year}';

    // Verify current month is displayed initially
    expect(find.text(currentMonthTitle), findsOneWidget);

    // Tap forward chevron ('>')
    final nextButton = find.byIcon(Icons.chevron_right);
    expect(nextButton, findsOneWidget);
    await tester.tap(nextButton);
    await tester.pumpAndSettle();

    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final nextMonthTitle = '${monthNames[nextMonth.month - 1]} ${nextMonth.year}';
    expect(find.text(nextMonthTitle), findsOneWidget);

    // Tap backward chevron twice ('<')
    final prevButton = find.byIcon(Icons.chevron_left);
    expect(prevButton, findsOneWidget);
    await tester.tap(prevButton);
    await tester.pumpAndSettle();
    expect(find.text(currentMonthTitle), findsOneWidget);

    await tester.tap(prevButton);
    await tester.pumpAndSettle();

    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final prevMonthTitle = '${monthNames[prevMonth.month - 1]} ${prevMonth.year}';
    expect(find.text(prevMonthTitle), findsOneWidget);
  });

  testWidgets('Hour, Day, Week, and Month tabs transition smoothly with AnimatedSwitcher', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TimetableHomeWidgetUI(activeTab: TimetableWidgetTab.hour),
        ),
      ),
    );

    // Verify initial hour view elements
    expect(find.text('Hour'), findsOneWidget);
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
    expect(find.text('10:00 - 11:00 AM'), findsOneWidget);

    // Tap Day tab
    await tester.tap(find.text('Day'));
    await tester.pump(); // Start animation
    await tester.pump(const Duration(milliseconds: 150)); // Halfway transition
    await tester.pumpAndSettle(); // Settle
    expect(find.text('Fri, 14 June 2026'), findsOneWidget);

    // Tap Week tab
    await tester.tap(find.text('Week'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('8 – 14 June 2026'), findsOneWidget);

    // Tap Month tab
    await tester.tap(find.text('Month'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('June 2026'), findsOneWidget);

    // Tap back to Hour tab
    await tester.tap(find.text('Hour'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('10:00 - 11:00 AM'), findsOneWidget);
  });
}
