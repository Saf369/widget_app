import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_syllabus/services/api_service.dart';
import 'package:custom_syllabus/widgets/app_dialogs.dart';

void main() {
  group('ApiService Connection Error Detection', () {
    test('isConnectionError correctly identifies connection-related errors', () {
      expect(
        ApiService.isConnectionError(
          const BackendConnectionException('Could not reach backend', ['http://127.0.0.1:8000']),
        ),
        isTrue,
      );

      expect(
        ApiService.isConnectionError(const io.SocketException('OS Error: Connection refused, errno = 111')),
        isTrue,
      );

      expect(
        ApiService.isConnectionError(http.ClientException('Connection refused')),
        isTrue,
      );

      expect(
        ApiService.isConnectionError(Exception('Backend server is not reachable.')),
        isTrue,
      );

      expect(
        ApiService.isConnectionError(Exception('Failed host lookup: 192.168.1.39')),
        isTrue,
      );

      // Unrelated errors should return false
      expect(
        ApiService.isConnectionError(Exception('Invalid password')),
        isFalse,
      );

      expect(
        ApiService.isConnectionError(const GeminiRateLimitException()),
        isFalse,
      );
    });
  });

  group('showBackendConnectionDialog Widget Tests', () {
    testWidgets('renders clean Connection Error Dialog with Dismiss and Retry',
        (WidgetTester tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showBackendConnectionDialog(
                    context: context,
                    onRetry: () => retried = true,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      // Tap to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Verify title & banner
      expect(find.text('Connection Error'), findsOneWidget);
      expect(find.text('Could not connect to backend server'), findsOneWidget);
      expect(find.textContaining('Please check your internet connection'), findsOneWidget);

      // Verify buttons
      expect(find.text('Dismiss'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Server Settings'), findsNothing);

      // Tap Retry
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(retried, isTrue);
    });
  });

  group('showServerSettingsDialog Widget Tests', () {
    testWidgets('renders Server Settings dialog with IP configuration and test action',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showServerSettingsDialog(context: context),
                child: const Text('Open Settings'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Backend Server'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Connection'), findsOneWidget);
      expect(find.text('Auto Detect'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      await tester.tap(find.text('Auto Detect'));
      await tester.pumpAndSettle();
      expect(find.text('Backend Server'), findsNothing);
    });
  });
}
