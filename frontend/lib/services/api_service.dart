import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/schedule.dart';

class GeminiRateLimitException implements Exception {
  final String message;
  const GeminiRateLimitException([this.message = 'Try again after some time limit hit']);

  @override
  String toString() => message;
}

class BackendConnectionException implements Exception {
  final String message;
  final List<String> testedUrls;
  const BackendConnectionException([
    this.message = 'Could not reach backend server at any endpoint.',
    this.testedUrls = const [],
  ]);

  @override
  String toString() => message;
}

class ApiService {
  static const String _kCustomUrlKey = 'custom_backend_base_url';
  static String? _cachedWorkingUrl;

  static bool isRateLimit(dynamic error) {
    if (error is GeminiRateLimitException) return true;
    final str = error.toString().toLowerCase();
    return str.contains('limit hit') ||
        str.contains('rate limit') ||
        str.contains('ratelimit') ||
        str.contains('resource_exhausted') ||
        str.contains('quota') ||
        str.contains('429') ||
        str.contains('too many requests') ||
        str.contains('try again after some time');
  }

  static bool isConnectionError(dynamic error) {
    if (error is BackendConnectionException) return true;
    if (error is io.SocketException || error is http.ClientException) return true;
    final str = error.toString().toLowerCase();
    return str.contains('could not reach backend') ||
        str.contains('backend server is not reachable') ||
        str.contains('backend not reachable') ||
        str.contains('connection refused') ||
        str.contains('connection reset') ||
        str.contains('socketexception') ||
        str.contains('clientexception') ||
        str.contains('failed host lookup') ||
        str.contains('network is unreachable') ||
        str.contains('connection timed out') ||
        str.contains('timeoutexception');
  }

  static Exception _parseErrorResponse(http.Response response) {
    String errorMessage = 'Processing error';
    try {
      final errJson = jsonDecode(response.body);
      if (errJson is Map && errJson.containsKey('detail')) {
        errorMessage = errJson['detail'].toString();
      }
    } catch (_) {}

    if (response.statusCode == 429 || isRateLimit(errorMessage)) {
      return GeminiRateLimitException(
        errorMessage.isNotEmpty && !errorMessage.startsWith('Server error')
            ? errorMessage
            : 'Try again after some time limit hit',
      );
    }

    if (response.statusCode >= 500 ||
        errorMessage.toLowerCase().contains('internal server error') ||
        errorMessage.toLowerCase().contains('server error') ||
        errorMessage.toLowerCase().contains('500') ||
        errorMessage.toLowerCase().contains('503') ||
        errorMessage.toLowerCase().contains('unavailable') ||
        errorMessage.toLowerCase().contains('failed to process') ||
        errorMessage.toLowerCase().contains('failed to check file') ||
        errorMessage.toLowerCase().contains('processing error')) {
      return Exception('Processing error');
    }

    return Exception(errorMessage);
  }

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

  static Future<List<String>> getCandidateUrls() async {
    final customUrl = await getCustomBaseUrl();
    final list = <String>[
      if (customUrl != null && customUrl.isNotEmpty) customUrl,
      ...defaultCandidateUrls,
    ];
    return list.toSet().toList();
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
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Concurrently tests all candidate endpoints and returns the fastest reachable endpoint.
  static Future<String?> findReachableUrl({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedWorkingUrl != null && await ping(_cachedWorkingUrl!)) {
      return _cachedWorkingUrl;
    }

    final candidates = await getCandidateUrls();
    if (candidates.isEmpty) return null;

    final completer = Completer<String?>();
    int pending = candidates.length;

    for (final url in candidates) {
      ping(url).then((alive) {
        if (!completer.isCompleted) {
          if (alive) {
            debugPrint('Found reachable backend at $url');
            _cachedWorkingUrl = url;
            completer.complete(url);
          } else {
            pending--;
            if (pending <= 0) {
              _cachedWorkingUrl = null;
              completer.complete(null);
            }
          }
        }
      }).catchError((_) {
        if (!completer.isCompleted) {
          pending--;
          if (pending <= 0) {
            _cachedWorkingUrl = null;
            completer.complete(null);
          }
        }
      });
    }

    return completer.future;
  }

  /// Live test connection method returning status, active URL, and all probed endpoints.
  static Future<Map<String, dynamic>> testConnection() async {
    final workingUrl = await findReachableUrl(forceRefresh: true);
    final testedUrls = await getCandidateUrls();
    return {
      'connected': workingUrl != null,
      'workingUrl': workingUrl,
      'testedUrls': testedUrls,
    };
  }

  /// Step 1 — Upload the file to the server and get a short-lived file_token.
  static Future<Map<String, dynamic>> sendFile(PlatformFile file) async {
    final workingUrl = await findReachableUrl();
    if (workingUrl == null) {
      final urls = await getCandidateUrls();
      throw BackendConnectionException(
        'Could not reach backend server at any endpoint.',
        urls,
      );
    }
    debugPrint('Step 1: Sending file to $workingUrl/send-file/');
    try {
      return await _doFilePost('$workingUrl/send-file/', file);
    } on io.SocketException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on http.ClientException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on TimeoutException {
      _cachedWorkingUrl = null;
      throw const BackendConnectionException('Connection timed out. Server is not responding.');
    }
  }

  /// Step 2 — Check if the staged file is actually a timetable.
  /// Returns {is_timetable, reasoning, file_token}.
  static Future<Map<String, dynamic>> checkFile(String fileToken) async {
    final workingUrl = await findReachableUrl();
    if (workingUrl == null) {
      final urls = await getCandidateUrls();
      throw BackendConnectionException(
        'Backend server is not reachable.',
        urls,
      );
    }

    debugPrint('Step 2: Checking file token $fileToken at $workingUrl/check-file/');
    final uri = Uri.parse('$workingUrl/check-file/');
    final headers = <String, String>{'Content-Type': 'application/json'};

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (e) {
      debugPrint('Notice: unable to fetch Firebase token: $e');
    }

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: '{"file_token":"$fileToken"}',
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _parseErrorResponse(response);
      }
    } on io.SocketException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on http.ClientException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on TimeoutException {
      _cachedWorkingUrl = null;
      throw const BackendConnectionException('Connection timed out while verifying timetable.');
    }
  }

  /// Step 3 — Run full AI extraction using the staged file_token.
  static Future<Map<String, dynamic>> analyzeTimetableWithToken(String fileToken) async {
    final workingUrl = await findReachableUrl();
    if (workingUrl == null) {
      final urls = await getCandidateUrls();
      throw BackendConnectionException(
        'Backend server is not reachable.',
        urls,
      );
    }

    debugPrint('Step 3: Analyzing timetable token $fileToken');
    final uri = Uri.parse('$workingUrl/analyze-timetable/?file_token=$fileToken');
    final request = http.MultipartRequest('POST', uri);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (e) {
      debugPrint('Notice: unable to fetch Firebase token: $e');
    }

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Step 3 server responded with HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _parseErrorResponse(response);
      }
    } on io.SocketException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on http.ClientException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on TimeoutException {
      _cachedWorkingUrl = null;
      throw const BackendConnectionException('AI timetable extraction timed out.');
    }
  }

  /// Legacy: single-call upload (kept for backwards compatibility).
  static Future<Map<String, dynamic>> uploadTimetable(PlatformFile file) async {
    final workingUrl = await findReachableUrl();
    if (workingUrl == null) {
      final urls = await getCandidateUrls();
      throw BackendConnectionException(
        'Could not reach backend server at any endpoint.',
        urls,
      );
    }

    debugPrint('Uploading timetable to verified server $workingUrl...');
    return await _performUpload(workingUrl, file);
  }


  static Future<Map<String, dynamic>> _performUpload(String baseUrl, PlatformFile file) async {
    final uri = Uri.parse('$baseUrl/analyze-timetable/');
    final request = http.MultipartRequest('POST', uri);

    // Attach Firebase ID token so the backend auth middleware accepts the upload
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (e) {
      debugPrint('Notice: unable to fetch Firebase token: $e');
    }

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
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Server responded with HTTP ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded;
      } else {
        throw _parseErrorResponse(response);
      }
    } on io.SocketException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on http.ClientException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on TimeoutException {
      _cachedWorkingUrl = null;
      throw const BackendConnectionException('Upload request timed out.');
    }
  }

  /// Generic multipart POST for a PlatformFile to any [url].
  static Future<Map<String, dynamic>> _doFilePost(String url, PlatformFile file) async {
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null && idToken.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $idToken';
        }
      }
    } catch (e) {
      debugPrint('Notice: unable to fetch Firebase token: $e');
    }

    Uint8List? rawBytes = file.bytes;
    if ((rawBytes == null || rawBytes.isEmpty) && file.path != null && !kIsWeb) {
      try {
        final f = io.File(file.path!);
        if (await f.exists()) rawBytes = await f.readAsBytes();
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
      request.files.add(http.MultipartFile.fromBytes('file', rawBytes, filename: filename));
    } else if (file.path != null && !kIsWeb) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path!, filename: filename));
    } else {
      throw Exception('Selected file has no readable data or path.');
    }

    debugPrint('POST $uri (${rawBytes?.length ?? 0} bytes)');
    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Response HTTP ${response.statusCode} from $uri');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw _parseErrorResponse(response);
      }
    } on io.SocketException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on http.ClientException catch (e) {
      _cachedWorkingUrl = null;
      throw BackendConnectionException('Connection failed: ${e.message}');
    } on TimeoutException {
      _cachedWorkingUrl = null;
      throw const BackendConnectionException('Upload request timed out.');
    }
  }


  static Future<bool> saveTimetable(List<TimetableEntry> entries, {String summary = ''}) async {
    final workingUrl = await findReachableUrl();
    if (workingUrl == null) return false;

    try {
      final uri = Uri.parse('$workingUrl/api/timetable/save');
      final user = FirebaseAuth.instance.currentUser;
      String? idToken;
      if (user != null) {
        idToken = await user.getIdToken();
      }

      final body = jsonEncode({
        'entries': entries.map((e) => e.toJson()).toList(),
        'summary': summary.isNotEmpty ? summary : 'Extracted timetable',
      });

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Timetable saved to Firestore response: $data');
        return data['saved_to_cloud'] == true;
      }
    } catch (e) {
      debugPrint('Error saving timetable to cloud: $e');
    }
    return false;
  }

  /// Fetches the user's active timetable from Firestore via /api/timetable/
  static Future<List<TimetableEntry>?> getTimetable() async {
    final workingUrl = await findReachableUrl();
    if (workingUrl == null) return null;

    try {
      final uri = Uri.parse('$workingUrl/api/timetable/');
      final user = FirebaseAuth.instance.currentUser;
      String? idToken;
      if (user != null) {
        idToken = await user.getIdToken();
      }

      final response = await http.get(
        uri,
        headers: {
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['found'] == true && data['entries'] is List) {
          final list = (data['entries'] as List)
              .map((e) => TimetableEntry.fromJson(e as Map<String, dynamic>))
              .toList();
          return list;
        }
      }
    } catch (e) {
      debugPrint('Error fetching timetable from Firestore: $e');
    }
    return null;
  }
}
