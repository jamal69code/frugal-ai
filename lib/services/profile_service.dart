import 'package:frugal_ai/services/api_client.dart';

class ProfileService {
  /// Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiClient.get('/profile');
  }

  /// Update profile
  static Future<Map<String, dynamic>> updateProfile({
    required Map<String, dynamic> profileData,
  }) async {
    return await ApiClient.put('/profile', profileData);
  }

  /// Upload profile photo
  static Future<Map<String, dynamic>> uploadProfilePhoto(
    String filePath,
  ) async {
    return await ApiClient.uploadFile(
      '/profile/photo',
      filePath,
      fileKey: 'photo',
    );
  }

  /// Delete profile photo
  static Future<Map<String, dynamic>> deleteProfilePhoto() async {
    return await ApiClient.delete('/profile/photo');
  }

  /// Get bank accounts
  static Future<Map<String, dynamic>> getBankAccounts() async {
    return await ApiClient.get('/profile/banks');
  }

  /// Add bank account
  static Future<Map<String, dynamic>> addBankAccount({
    required String accountName,
    required String accountNumber,
    required String bankName,
    required String accountType,
  }) async {
    return await ApiClient.post('/profile/banks', {
      'accountName': accountName,
      'accountNumber': accountNumber,
      'bankName': bankName,
      'accountType': accountType,
    });
  }

  /// Update bank account
  static Future<Map<String, dynamic>> updateBankAccount({
    required String accountId,
    required Map<String, dynamic> updateData,
  }) async {
    return await ApiClient.put('/profile/banks/$accountId', updateData);
  }

  /// Delete bank account
  static Future<Map<String, dynamic>> deleteBankAccount(
    String accountId,
  ) async {
    return await ApiClient.delete('/profile/banks/$accountId');
  }
}
