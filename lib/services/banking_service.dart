import 'package:frugal_ai/services/api_client.dart';

class BankingService {
  /// Create Plaid link token
  static Future<Map<String, dynamic>> createLinkToken() async {
    return await ApiClient.post('/banking/link-token', {});
  }

  /// Exchange public token
  static Future<Map<String, dynamic>> exchangePublicToken(
    String publicToken,
  ) async {
    return await ApiClient.post('/banking/exchange-token', {
      'publicToken': publicToken,
    });
  }

  /// Get connected banks
  static Future<Map<String, dynamic>> getConnectedBanks() async {
    return await ApiClient.get('/banking/banks');
  }

  /// Sync transactions
  static Future<Map<String, dynamic>> syncTransactions() async {
    return await ApiClient.post('/banking/sync', {});
  }

  /// Disconnect bank
  static Future<Map<String, dynamic>> disconnectBank(String bankId) async {
    return await ApiClient.delete('/banking/banks/$bankId');
  }
}
