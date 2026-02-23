import 'package:frugal_ai/services/api_client.dart';

class TransactionService {
  /// Add transaction
  static Future<Map<String, dynamic>> addTransaction({
    required double amount,
    required String category,
    required String type,
    required DateTime date,
    String? description,
  }) async {
    return await ApiClient.post('/transactions', {
      'amount': amount,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
      'description': description ?? '',
    });
  }

  /// Get all transactions
  static Future<Map<String, dynamic>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String query = '';
    if (startDate != null) {
      query += '?startDate=${startDate.toIso8601String()}';
    }
    if (endDate != null) {
      query +=
          (query.isEmpty ? '?' : '&') + 'endDate=${endDate.toIso8601String()}';
    }

    return await ApiClient.get('/transactions$query');
  }

  /// Get transaction by ID
  static Future<Map<String, dynamic>> getTransactionById(
    String transactionId,
  ) async {
    return await ApiClient.get('/transactions/$transactionId');
  }

  /// Update transaction
  static Future<Map<String, dynamic>> updateTransaction({
    required String transactionId,
    required Map<String, dynamic> updateData,
  }) async {
    return await ApiClient.put('/transactions/$transactionId', updateData);
  }

  /// Delete transaction
  static Future<Map<String, dynamic>> deleteTransaction(
    String transactionId,
  ) async {
    return await ApiClient.delete('/transactions/$transactionId');
  }

  /// Get transaction summary
  static Future<Map<String, dynamic>> getTransactionSummary({
    DateTime? month,
  }) async {
    String query = '';
    if (month != null) {
      query = '?month=${month.toIso8601String()}';
    }
    return await ApiClient.get('/transactions/summary$query');
  }
}
