import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// 📈 Investment Service
/// Manages investment tracking with real-time API data
class InvestmentService {
  static final InvestmentService _instance = InvestmentService._internal();

  factory InvestmentService() {
    return _instance;
  }

  InvestmentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // API Configuration - Replace with your actual API keys
  static const String STOCK_API_BASE = 'https://api.example.com/stocks';
  static const String CRYPTO_API_BASE = 'https://api.coingecko.com/api/v3';

  // ===== INVESTMENT PORTFOLIO =====

  /// Add investment to portfolio
  Future<bool> addInvestment({
    required String type, // 'stock', 'crypto', 'mutual_fund', 'fds'
    required String symbol,
    required String name,
    required double amount,
    required double currentPrice,
    required int quantity,
    String? apiKey,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('investments')
          .add({
            'type': type,
            'symbol': symbol,
            'name': name,
            'amount': amount,
            'currentPrice': currentPrice,
            'quantity': quantity,
            'apiKey': apiKey ?? '',
            'createdAt': DateTime.now().toIso8601String(),
            'updatedAt': DateTime.now().toIso8601String(),
            'returns': 0.0,
            'percentageChange': 0.0,
          });

      print('✅ Investment added: $name ($symbol)');
      return true;
    } catch (e) {
      print('❌ Error adding investment: $e');
      return false;
    }
  }

  /// Get user investments
  Future<List<Map<String, dynamic>>> getUserInvestments() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('investments')
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('❌ Error getting investments: $e');
      return [];
    }
  }

  // ===== REAL-TIME INVESTMENT TRACKING =====

  /// Get real-time stock price
  Future<Map<String, dynamic>?> getStockPrice({
    required String symbol,
    String? apiKey,
  }) async {
    try {
      // Example using a free stock API
      final response = await http.get(
        Uri.parse('$STOCK_API_BASE?symbol=$symbol&apikey=${apiKey ?? ""}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'symbol': symbol,
          'price': data['price'],
          'change': data['change'],
          'percentChange': data['percentChange'],
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      print('❌ Error fetching stock price: $e');
      return null;
    }
  }

  /// Get real-time cryptocurrency price
  Future<Map<String, dynamic>?> getCryptoPrice({
    required String cryptoId,
  }) async {
    try {
      // Using CoinGecko free API
      final response = await http.get(
        Uri.parse(
          '$CRYPTO_API_BASE/simple/price?ids=$cryptoId&vs_currencies=inr&include_24hr_change=true',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cryptoData = data[cryptoId];

        return {
          'cryptoId': cryptoId,
          'price': cryptoData['inr'],
          'change_24h': cryptoData['inr_24h_change'],
          'timestamp': DateTime.now().toIso8601String(),
        };
      }
      return null;
    } catch (e) {
      print('❌ Error fetching crypto price: $e');
      return null;
    }
  }

  /// Update investment with current price
  Future<bool> updateInvestmentPrice({
    required String investmentId,
    required double currentPrice,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Get investment details
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('investments')
          .doc(investmentId)
          .get();

      final data = doc.data();
      if (data == null) throw Exception('Investment not found');

      final quantity = data['quantity'] as int;
      final originalAmount = data['amount'] as double;
      final currentValue = currentPrice * quantity;
      final returns = currentValue - originalAmount;
      final percentageChange = (returns / originalAmount) * 100;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('investments')
          .doc(investmentId)
          .update({
            'currentPrice': currentPrice,
            'updatedAt': DateTime.now().toIso8601String(),
            'returns': returns,
            'percentageChange': percentageChange,
          });

      print('✅ Investment price updated');
      return true;
    } catch (e) {
      print('❌ Error updating investment price: $e');
      return false;
    }
  }

  // ===== PORTFOLIO ANALYTICS =====

  /// Get portfolio summary
  Future<Map<String, dynamic>> getPortfolioSummary() async {
    try {
      final investments = await getUserInvestments();

      double totalInvested = 0;
      double totalCurrentValue = 0;
      double totalReturns = 0;

      for (var inv in investments) {
        totalInvested += (inv['amount'] as num).toDouble();
        totalCurrentValue +=
            ((inv['currentPrice'] as num) * (inv['quantity'] as num));
        totalReturns += (inv['returns'] as num).toDouble();
      }

      final percentageReturn = totalInvested > 0
          ? (totalReturns / totalInvested) * 100
          : 0;

      return {
        'totalInvested': totalInvested,
        'totalCurrentValue': totalCurrentValue,
        'totalReturns': totalReturns,
        'percentageReturn': percentageReturn,
        'investmentCount': investments.length,
        'topPerformer': _getTopPerformer(investments),
      };
    } catch (e) {
      print('❌ Error getting portfolio summary: $e');
      return {};
    }
  }

  /// Get top performing investment
  Map<String, dynamic>? _getTopPerformer(
    List<Map<String, dynamic>> investments,
  ) {
    if (investments.isEmpty) return null;

    var topPerformer = investments[0];
    var maxPercentage = (topPerformer['percentageChange'] as num).toDouble();

    for (var inv in investments) {
      final percentage = (inv['percentageChange'] as num).toDouble();
      if (percentage > maxPercentage) {
        topPerformer = inv;
        maxPercentage = percentage;
      }
    }

    return topPerformer;
  }

  // ===== REAL-TIME PORTFOLIO UPDATES =====

  /// Listen to investment updates
  Stream<QuerySnapshot> listenToInvestments() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('investments')
        .snapshots();
  }

  /// Remove investment from portfolio
  Future<bool> removeInvestment({required String investmentId}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('investments')
          .doc(investmentId)
          .delete();

      print('✅ Investment removed');
      return true;
    } catch (e) {
      print('❌ Error removing investment: $e');
      return false;
    }
  }
}
