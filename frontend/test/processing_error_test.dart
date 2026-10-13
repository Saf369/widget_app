import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:custom_syllabus/widgets/app_dialogs.dart';

void main() {
  group('Processing Error Handling', () {
    testWidgets('showAppErrorDialog automatically normalizes internal server errors to Processing error',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showAppErrorDialog(
                    context: context,
                    title: 'Upload Failed',
                    message: 'Server error (500): 503 UNAVAILABLE internal error',
                  );
                },
                child: const Text('Trigger Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Error'));
      await tester.pumpAndSettle();

      // Verify that user only sees "Processing Error" and "Processing error"
      expect(find.text('Processing Error'), findsOneWidget);
      expect(find.text('Processing error'), findsOneWidget);

      // Verify no raw internal trace or 503 is displayed
      expect(find.textContaining('503 UNAVAILABLE'), findsNothing);
      expect(find.textContaining('Server error (500)'), findsNothing);
    });

    testWidgets('showAppErrorDialog normalizes Internal Server Error text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showAppErrorDialog(
                    context: context,
                    title: 'Failed',
                    message: 'Internal server error',
                  );
                },
                child: const Text('Trigger Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Error'));
      await tester.pumpAndSettle();

      expect(find.text('Processing Error'), findsOneWidget);
      expect(find.text('Processing error'), findsOneWidget);
    });
  });
}
