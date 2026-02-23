import 'package:frugal_ai/services/api_client.dart';

class AuthService {
  /// Register user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    String? phone,
  }) async {
    return await ApiClient.post('/auth/register', {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'name': name,
      'phone': phone ?? '',
    });
  }

  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });

    if (response['data']['token'] != null) {
      await ApiClient.setToken(response['data']['token']);
    }

    return response;
  }

  /// Request password reset
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    return await ApiClient.post('/auth/forgot-password', {'email': email});
  }

  /// Change password
  static Future<Map<String, dynamic>> changePassword({
    required String newPassword,
  }) async {
    return await ApiClient.post('/auth/change-password', {
      'newPassword': newPassword,
    });
  }

  /// Verify email
  static Future<Map<String, dynamic>> verifyEmail() async {
    return await ApiClient.post('/auth/verify-email', {});
  }

  /// Logout
  static Future<void> logout() async {
    await ApiClient.clearToken();
  }
}
