import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 📋 App Suggestions Service
/// Manages feature suggestions and app improvements
class SuggestionsService {
  static final SuggestionsService _instance = SuggestionsService._internal();

  factory SuggestionsService() {
    return _instance;
  }

  SuggestionsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== SUGGESTIONS CATEGORIES =====
  static const List<String> SUGGESTIONS_CATEGORIES = [
    'UI/UX Improvement',
    'Performance',
    'New Feature',
    'Data Visualization',
    'Integration',
    'Security',
    'Accessibility',
    'Other',
  ];

  // ===== SUBMIT SUGGESTION =====

  /// Submit app improvement suggestion
  Future<bool> submitSuggestion({
    required String category,
    required String title,
    required String description,
    String? attachmentUrl,
    int? priority, // 1-5
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore.collection('suggestions').add({
        'uid': uid,
        'userEmail': _auth.currentUser?.email,
        'userName': _auth.currentUser?.displayName ?? 'Anonymous',
        'category': category,
        'title': title,
        'description': description,
        'attachmentUrl': attachmentUrl,
        'priority': priority ?? 3,
        'status': 'pending',
        'votes': 0,
        'submittedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Suggestion submitted: $title');
      return true;
    } catch (e) {
      print('❌ Error submitting suggestion: $e');
      return false;
    }
  }

  // ===== GET SUGGESTIONS =====

  /// Get all suggestions
  Future<List<Map<String, dynamic>>> getAllSuggestions({
    String? category,
    String? status,
  }) async {
    try {
      Query query = _firestore.collection('suggestions');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (status != null && status.isNotEmpty) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query.orderBy('votes', descending: true).get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('❌ Error getting suggestions: $e');
      return [];
    }
  }

  /// Get user suggestions
  Future<List<Map<String, dynamic>>> getUserSuggestions() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('suggestions')
          .where('uid', isEqualTo: uid)
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('❌ Error getting user suggestions: $e');
      return [];
    }
  }

  // ===== VOTE ON SUGGESTIONS =====

  /// Vote for a suggestion (send upvote)
  Future<bool> voteForSuggestion({required String suggestionId}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      // Check if user already voted
      final voteDoc = await _firestore
          .collection('suggestions')
          .doc(suggestionId)
          .collection('votes')
          .doc(uid)
          .get();

      if (voteDoc.exists) {
        return false; // Already voted
      }

      // Add vote
      await _firestore
          .collection('suggestions')
          .doc(suggestionId)
          .collection('votes')
          .doc(uid)
          .set({'votedAt': DateTime.now().toIso8601String()});

      // Increment vote count
      await _firestore.collection('suggestions').doc(suggestionId).update({
        'votes': FieldValue.increment(1),
      });

      print('✅ Voted for suggestion: $suggestionId');
      return true;
    } catch (e) {
      print('❌ Error voting for suggestion: $e');
      return false;
    }
  }

  // ===== SUGGESTION MANAGEMENT =====

  /// Update suggestion status (admin)
  Future<bool> updateSuggestionStatus({
    required String suggestionId,
    required String
    newStatus, // 'pending', 'in_progress', 'completed', 'rejected'
    String? adminNote,
  }) async {
    try {
      await _firestore.collection('suggestions').doc(suggestionId).update({
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
        if (adminNote != null) 'adminNote': adminNote,
      });

      print('✅ Suggestion status updated: $newStatus');
      return true;
    } catch (e) {
      print('❌ Error updating suggestion status: $e');
      return false;
    }
  }

  // ===== REAL-TIME SUGGESTIONS =====

  /// Listen to all suggestions
  Stream<QuerySnapshot> listenToAllSuggestions() {
    return _firestore
        .collection('suggestions')
        .orderBy('votes', descending: true)
        .snapshots();
  }

  /// Listen to user suggestions
  Stream<QuerySnapshot> listenToUserSuggestions() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('suggestions')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  // ===== SUGGESTIONS STATISTICS =====

  /// Get suggestions statistics
  Future<Map<String, dynamic>> getSuggestionsStats() async {
    try {
      final snapshot = await _firestore.collection('suggestions').get();
      final allSuggestions = snapshot.docs;

      final stats = <String, int>{};
      for (var doc in allSuggestions) {
        final category = doc['category'];
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return {
        'totalSuggestions': allSuggestions.length,
        'byCategory': stats,
        'totalVotes': allSuggestions.fold<int>(
          0,
          (total, doc) => total + (doc['votes'] as int),
        ),
      };
    } catch (e) {
      print('❌ Error getting suggestions stats: $e');
      return {};
    }
  }
}
