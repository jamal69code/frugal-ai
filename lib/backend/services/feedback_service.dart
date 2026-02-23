import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 💬 Feedback Service
/// Manages user feedback and suggestions
class FeedbackService {
  static final FeedbackService _instance = FeedbackService._internal();

  factory FeedbackService() {
    return _instance;
  }

  FeedbackService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== FEEDBACK CATEGORIES =====
  static const List<String> FEEDBACK_CATEGORIES = [
    'Bug Report',
    'Feature Request',
    'Performance Issue',
    'UI/UX Improvement',
    'Suggestion',
    'Other',
  ];

  // ===== SUBMIT FEEDBACK =====

  /// Submit user feedback
  Future<bool> submitFeedback({
    required String category,
    required String title,
    required String description,
    String? screenshots,
    int? rating,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore.collection('feedback').add({
        'uid': uid,
        'userEmail': _auth.currentUser?.email,
        'userName': _auth.currentUser?.displayName ?? 'Anonymous',
        'category': category,
        'title': title,
        'description': description,
        'screenshots': screenshots,
        'rating': rating,
        'status': 'pending',
        'submittedAt': DateTime.now().toIso8601String(),
        'responses': [],
      });

      print('✅ Feedback submitted: $category');
      return true;
    } catch (e) {
      print('❌ Error submitting feedback: $e');
      return false;
    }
  }

  // ===== RETRIEVE FEEDBACK =====

  /// Get user's feedback history
  Future<List<Map<String, dynamic>>> getUserFeedback() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('feedback')
          .where('uid', isEqualTo: uid)
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('❌ Error getting user feedback: $e');
      return [];
    }
  }

  /// Get all feedback (admin only)
  Future<List<Map<String, dynamic>>> getAllFeedback({
    String? category,
    String? status,
  }) async {
    try {
      Query query = _firestore.collection('feedback');

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      final snapshot = await query
          .orderBy('submittedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('❌ Error getting all feedback: $e');
      return [];
    }
  }

  // ===== FEEDBACK MANAGEMENT =====

  /// Add response to feedback (admin)
  Future<bool> addFeedbackResponse({
    required String feedbackId,
    required String response,
  }) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).update({
        'responses': FieldValue.arrayUnion([
          {
            'response': response,
            'respondedAt': DateTime.now().toIso8601String(),
            'respondedBy': 'admin',
          },
        ]),
        'status': 'responded',
      });

      print('✅ Response added to feedback: $feedbackId');
      return true;
    } catch (e) {
      print('❌ Error adding response: $e');
      return false;
    }
  }

  /// Update feedback status
  Future<bool> updateFeedbackStatus({
    required String feedbackId,
    required String newStatus,
  }) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).update({
        'status': newStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Feedback status updated: $newStatus');
      return true;
    } catch (e) {
      print('❌ Error updating feedback status: $e');
      return false;
    }
  }

  // ===== REAL-TIME FEEDBACK TRACKING =====

  /// Listen to feedback real-time
  Stream<QuerySnapshot> listenToUserFeedback() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('feedback')
        .where('uid', isEqualTo: uid)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  /// Get feedback statistics
  Future<Map<String, dynamic>> getFeedbackStats() async {
    try {
      final snapshot = await _firestore.collection('feedback').get();
      final allFeedback = snapshot.docs;

      final stats = <String, int>{};
      for (var doc in allFeedback) {
        final category = doc['category'];
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return {
        'totalFeedback': allFeedback.length,
        'byCategory': stats,
        'avgRating': _calculateAverageRating(allFeedback),
      };
    } catch (e) {
      print('❌ Error getting feedback stats: $e');
      return {};
    }
  }

  /// Calculate average rating
  double _calculateAverageRating(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return 0;
    final ratings = docs
        .map((doc) => (doc['rating'] as int?) ?? 0)
        .where((r) => r > 0)
        .toList();
    if (ratings.isEmpty) return 0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }
}
