import 'package:universal_io/io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';

class ApiClient {
  // ✅ NODE.JS BACKEND ENABLED - Dart backend disabled
  // Resolved API base (includes trailing /api)
  static String? _resolvedBaseUrl;

  // Primary base detection (returns a prefix without /api)
  // ✅ Configured for Node.js backend on port 5001
  static String get _primaryPrefix {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001'; // Android emulator -> Node.js backend
    } else if (Platform.isIOS) {
      return 'http://localhost:5001'; // iOS simulator -> Node.js backend
    }
    return 'http://localhost:5001'; // Web/Windows/Mac -> Node.js backend
  }

  // Ensure we detect a reachable backend and set `_resolvedBaseUrl` to a URL ending with `/api`.
  static Future<void> _ensureBaseUrl() async {
    if (_resolvedBaseUrl != null) return;

    final candidates = <String>[_primaryPrefix, 'http://localhost:5001'];

    for (final prefix in candidates) {
      try {
        // Try both /health and /api/health
        final health1 = Uri.parse('$prefix/health');
        final health2 = Uri.parse('$prefix/api/health');

        final responses = <http.Response>[];
        try {
          responses.add(
            await http.get(health1).timeout(const Duration(seconds: 2)),
          );
        } catch (_) {}
        try {
          responses.add(
            await http.get(health2).timeout(const Duration(seconds: 2)),
          );
        } catch (_) {}

        for (final r in responses) {
          if (r.statusCode >= 200 && r.statusCode < 500) {
            // prefer /api prefix if available
            _resolvedBaseUrl = '$prefix/api';
            return;
          }
        }
      } catch (_) {
        // ignore and try next candidate
      }
    }

    // Fallback to the last candidate's /api
    _resolvedBaseUrl = '${candidates.last}/api';
  }

  static String? _token;
  static String? _userId;

  // Feedback callback
  static Function(ResponseFeedback)? onFeedback;

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> setUserId(String userId) async {
    _userId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getString('user_id');
  }

  static Future<void> clearToken() async {
    _token = null;
    _userId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
    'X-Device-Type': Platform.operatingSystem,
  };

  /// GET Request
  static Future<dynamic> get(String endpoint) async {
    try {
      await _ensureBaseUrl();
      final base = _resolvedBaseUrl ?? '$_primaryPrefix/api';
      final url = Uri.parse('$base$endpoint');
      print('GET $url');
      final response = await http
          .get(url, headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'Unable to connect to server. Check your internet connection.',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// POST Request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      await _ensureBaseUrl();
      final base = _resolvedBaseUrl ?? '$_primaryPrefix/api';
      final url = Uri.parse('$base$endpoint');
      print('POST $url with body: $body');
      final response = await http
          .post(url, headers: _headers, body: jsonEncode(body))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'Unable to connect to server. Check your internet connection.',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// PUT Request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      await _ensureBaseUrl();
      final base = _resolvedBaseUrl ?? '$_primaryPrefix/api';
      final url = Uri.parse('$base$endpoint');
      print('PUT $url');
      final response = await http
          .put(url, headers: _headers, body: jsonEncode(body))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'Unable to connect to server. Check your internet connection.',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// DELETE Request
  static Future<dynamic> delete(String endpoint) async {
    try {
      await _ensureBaseUrl();
      final base = _resolvedBaseUrl ?? '$_primaryPrefix/api';
      final url = Uri.parse('$base$endpoint');
      print('DELETE $url');
      final response = await http
          .delete(url, headers: _headers)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timeout'),
          );
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'Unable to connect to server. Check your internet connection.',
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Upload File
  static Future<dynamic> uploadFile(
    String endpoint,
    String filePath, {
    String fileKey = 'file',
    Map<String, String>? additionalFields,
  }) async {
    try {
      await _ensureBaseUrl();
      final base = _resolvedBaseUrl ?? '$_primaryPrefix/api';
      final url = Uri.parse('$base$endpoint');
      final request = http.MultipartRequest('POST', url);

      request.headers.addAll(_headers);
      request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));

      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      print('Uploading file to: $url');
      final streamResponse = await request.send();
      final response = await http.Response.fromStream(streamResponse);
      return _handleResponse(response);
    } on SocketException {
      throw Exception(
        'Unable to connect to server. Check your internet connection.',
      );
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  /// Handle Response - Parse response and trigger feedback callbacks
  static dynamic _handleResponse(http.Response response) {
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      final jsonResponse = jsonDecode(response.body);

      // Trigger feedback callback if available
      if (jsonResponse['feedback'] != null && onFeedback != null) {
        final feedback = ResponseFeedback.fromJson(jsonResponse['feedback']);
        onFeedback!(feedback);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonResponse;
      } else if (response.statusCode == 401) {
        _token = null;
        _userId = null;
        throw Exception('Unauthorized - Please login again');
      } else {
        final errorMessage =
            jsonResponse['error'] ?? jsonResponse['message'] ?? 'Unknown error';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e.toString().contains('FormatException')) {
        throw Exception('Invalid response from server');
      }
      rethrow;
    }
  }

  // clearToken already defined earlier
}
