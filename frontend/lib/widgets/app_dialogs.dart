import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

/// Shows a standardized modal error pop-up dialog with app design aesthetics.
Future<T?> showAppErrorDialog<T>({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = 'Dismiss',
  IconData icon = Icons.error_outline_rounded,
  Color iconColor = const Color(0xFFD32F2F),
  Color? iconBgColor,
  VoidCallback? onConfirm,
  List<Widget>? extraActions,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: iconBgColor ?? iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color(0xFF141414),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Text(
          message,
          style: GoogleFonts.urbanist(
            fontSize: 14.5,
            height: 1.5,
            color: const Color(0xFF4A4A4A),
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      actions: [
        if (extraActions != null) ...extraActions,
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF141414),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          ),
          onPressed: () {
            Navigator.pop(ctx);
            if (onConfirm != null) onConfirm();
          },
          child: Text(
            buttonText,
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Specifically handles Gemini rate limit / request quota errors with a dedicated pop-up dialog.
Future<T?> showRateLimitDialog<T>({
  required BuildContext context,
  String? message,
  VoidCallback? onRetry,
}) {
  const highlightText = 'Try again after some time limit hit';
  final detailText = (message != null &&
          message.isNotEmpty &&
          message.trim() != highlightText)
      ? message.trim()
      : 'The Gemini AI request quota has temporarily been reached. Please wait a short while and try your request again.';

  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              color: Color(0xFFD97706),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Limit Hit',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color(0xFF141414),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFED7AA), width: 1.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, color: Color(0xFFC2410C), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      highlightText,
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9A3412),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              detailText,
              style: GoogleFonts.urbanist(
                fontSize: 14.5,
                height: 1.5,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Dismiss',
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF141414),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onRetry();
            },
            child: Text(
              'Try Again',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Specifically handles Backend Connection Errors with a clean, user-friendly pop-up dialog.
Future<T?> showBackendConnectionDialog<T>({
  required BuildContext context,
  String? message,
  List<String> testedUrls = const [],
  VoidCallback? onRetry,
  VoidCallback? onOpenSettings,
}) {
  return showDialog<T>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: const BoxDecoration(
              color: Color(0xFFFEE2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFDC2626),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Connection Error',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: const Color(0xFF141414),
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Could not connect to backend server',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Please check your internet connection or verify that the backend server is running and try again.',
              style: GoogleFonts.urbanist(
                fontSize: 14,
                height: 1.5,
                color: const Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Dismiss',
            style: GoogleFonts.urbanist(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF141414),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onRetry();
            },
            child: Text(
              'Retry',
              style: GoogleFonts.urbanist(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}



/// Standardized dialog allowing the user to configure and test the backend host IP/URL.
Future<void> showServerSettingsDialog({
  required BuildContext context,
  VoidCallback? onSaved,
}) async {
  final currentCustom = await _getCustomUrlSafe();
  final controller = TextEditingController(text: currentCustom ?? '');
  bool isTesting = false;
  String? testResult;
  bool? testSuccess;

  if (!context.mounted) return;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: const BoxDecoration(
                  color: Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.dns_rounded,
                  color: Color(0xFF5A4E80),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Backend Server',
                  style: GoogleFonts.urbanist(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: const Color(0xFF141414),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your computer\'s IP or custom server URL (e.g. http://192.168.1.39:8000 via Wi-Fi or http://127.0.0.1:8000 via USB):',
                  style: GoogleFonts.urbanist(
                    fontSize: 13,
                    height: 1.4,
                    color: const Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'e.g. http://192.168.1.39:8000',
                    hintStyle: GoogleFonts.urbanist(color: Colors.grey[400], fontSize: 14),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF5A4E80), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Test Connection live button
                Row(
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        side: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      onPressed: isTesting
                          ? null
                          : () async {
                              setDialogState(() {
                                isTesting = true;
                                testResult = null;
                                testSuccess = null;
                              });

                              final target = controller.text.trim();
                              bool alive = false;
                              if (target.isNotEmpty) {
                                alive = await _pingUrlSafe(target);
                              } else {
                                final autoUrl = await _findReachableUrlSafe();
                                alive = autoUrl != null;
                              }

                              setDialogState(() {
                                isTesting = false;
                                testSuccess = alive;
                                testResult = alive
                                    ? 'Connected successfully!'
                                    : 'Unable to connect to server.';
                              });
                            },
                      icon: isTesting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.network_check_rounded, size: 16),
                      label: Text(
                        'Test Connection',
                        style: GoogleFonts.urbanist(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (testResult != null)
                      Expanded(
                        child: Text(
                          testResult!,
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: testSuccess == true
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _setCustomUrlSafe('');
                if (ctx.mounted) Navigator.pop(ctx);
                if (onSaved != null) onSaved();
              },
              child: Text(
                'Auto Detect',
                style: GoogleFonts.urbanist(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF141414),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                await _setCustomUrlSafe(controller.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (onSaved != null) onSaved();
              },
              child: Text(
                'Save',
                style: GoogleFonts.urbanist(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

// Helpers for dialog without circular dependencies
Future<String?> _getCustomUrlSafe() async {
  try {
    return await ApiService.getCustomBaseUrl();
  } catch (_) {
    return null;
  }
}

Future<void> _setCustomUrlSafe(String url) async {
  try {
    await ApiService.setCustomBaseUrl(url);
  } catch (_) {}
}

Future<bool> _pingUrlSafe(String url) async {
  try {
    return await ApiService.ping(url);
  } catch (_) {
    return false;
  }
}

Future<String?> _findReachableUrlSafe() async {
  try {
    return await ApiService.findReachableUrl(forceRefresh: true);
  } catch (_) {
    return null;
  }
}
