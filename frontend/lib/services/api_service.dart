import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _kCustomUrlKey = 'custom_backend_base_url';
  static String? _cachedWorkingUrl;

  static List<String> get defaultCandidateUrls {
    if (kIsWeb) {
      return const [
        'http://127.0.0.1:8000',
        'http://localhost:8000',
      ];
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return const [
        'http://127.0.0.1:8000',      // Physical Android device via USB (adb reverse)
        'http://192.168.1.39:8000',   // Physical Android device via Wi-Fi network
        'http://10.0.2.2:8000',       // Android Emulator host loopback
        'http://localhost:8000',
      ];
    }
    return const [
      'http://127.0.0.1:8000',
      'http://localhost:8000',
      'http://192.168.1.39:8000',
    ];
  }

  static Future<String?> getCustomBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kCustomUrlKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setCustomBaseUrl(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final clean = url.trim().replaceAll(RegExp(r'/+$'), '');
      if (clean.isEmpty) {
        await prefs.remove(_kCustomUrlKey);
      } else {
        await prefs.setString(_kCustomUrlKey, clean);
      }
      _cachedWorkingUrl = clean.isNotEmpty ? clean : null;
    } catch (_) {}
  }

  static Future<bool> ping(String baseUrl) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(milliseconds: 2000));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Finds the first reachable server endpoint in milliseconds
  static Future<String?> findReachableUrl() async {
    if (_cachedWorkingUrl != null && await ping(_cachedWorkingUrl!)) {
      return _cachedWorkingUrl;
    }

    final customUrl = await getCustomBaseUrl();
    final candidates = <String>[
      if (customUrl != null && customUrl.isNotEmpty) customUrl,
      ...defaultCandidateUrls,
    ];

    for (final url in candidates) {
      debugPrint('Probing backend health at $url...');
      if (await ping(url)) {
        debugPrint('Found reachable backend at $url');
        _cachedWorkingUrl = url;
        return url;
      }
    }
    return null;
  }

  /// Sends the uploaded timetable PDF or PNG/JPG image to the backend for AI extraction.
  static Future<Map<String, dynamic>> uploadTimetable(PlatformFile file) async {
    // 1. Fast probe to find which server is actually reachable
    final workingUrl = await findReachableUrl();
    if (workingUrl == null) {
      final customUrl = await getCustomBaseUrl();
      final urls = <String>[
        if (customUrl != null && customUrl.isNotEmpty) customUrl,
        ...defaultCandidateUrls,
      ];
      throw Exception(
        'Could not reach backend server at any endpoint.\n\n'
        'Tested:\n${urls.map((u) => '• $u').join('\n')}\n\n'
        'Troubleshooting:\n'
        '1. Ensure phone & PC are on the same Wi-Fi (PC IP: 192.168.1.39)\n'
        '2. Or if using USB: run "adb reverse tcp:8000 tcp:8000"\n'
        '3. Tap "Server Settings" above to enter your PC\'s Wi-Fi IP address.'
      );
    }

    // 2. Perform the upload to the verified endpoint with 90s timeout for AI processing
    debugPrint('Uploading timetable to verified server $workingUrl...');
    return await _performUpload(workingUrl, file);
  }

  static Future<Map<String, dynamic>> _performUpload(String baseUrl, PlatformFile file) async {
    final uri = Uri.parse('$baseUrl/analyze-timetable/');
    final request = http.MultipartRequest('POST', uri);

    Uint8List? rawBytes = file.bytes;
    if ((rawBytes == null || rawBytes.isEmpty) && file.path != null && !kIsWeb) {
      try {
        final f = io.File(file.path!);
        if (await f.exists()) {
          rawBytes = await f.readAsBytes();
        }
      } catch (e) {
        debugPrint('Could not read bytes from file path: $e');
      }
    }

    String filename = file.name;
    if (!filename.contains('.')) {
      final ext = file.extension ?? 'png';
      filename = '$filename.$ext';
    }

    if (rawBytes != null && rawBytes.isNotEmpty) {
      debugPrint('Uploading ${rawBytes.length} bytes for $filename');
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        rawBytes,
        filename: filename,
      ));
    } else if (file.path != null && !kIsWeb) {
      debugPrint('Uploading from path ${file.path!} for $filename');
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path!,
        filename: filename,
      ));
    } else {
      throw Exception('Selected file has no readable data or path.');
    }

    debugPrint('Sending POST request to $uri...');
    final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('Server responded with HTTP ${response.statusCode}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded;
    } else {
      String errorMessage = 'Server error (${response.statusCode})';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson is Map && errJson.containsKey('detail')) {
          errorMessage = errJson['detail'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
