import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 🔔 Notification and Permission Service
/// Manages real-time notifications and permission access
class NotificationPermissionService {
  static final NotificationPermissionService _instance =
      NotificationPermissionService._internal();

  factory NotificationPermissionService() {
    return _instance;
  }

  NotificationPermissionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ===== NOTIFICATION MANAGEMENT =====

  /// Enable notifications for user
  Future<bool> enableNotifications() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(uid).update({
        'notificationsEnabled': true,
        'notificationPreferences': {
          'expenseReminders': true,
          'budgetAlerts': true,
          'billPayments': true,
          'investmentUpdates': true,
        },
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Notifications enabled');
      return true;
    } catch (e) {
      print('❌ Error enabling notifications: $e');
      return false;
    }
  }

  /// Disable notifications
  Future<bool> disableNotifications() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(uid).update({
        'notificationsEnabled': false,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Notifications disabled');
      return true;
    } catch (e) {
      print('❌ Error disabling notifications: $e');
      return false;
    }
  }

  /// Get notification preferences
  Future<Map<String, dynamic>> getNotificationPreferences() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data() ?? {};

      return {
        'enabled': data['notificationsEnabled'] ?? true,
        'preferences': data['notificationPreferences'] ?? {},
      };
    } catch (e) {
      print('❌ Error getting notification preferences: $e');
      return {'enabled': false, 'preferences': {}};
    }
  }

  /// Update notification preference
  Future<bool> updateNotificationPreference({
    required String category,
    required bool enabled,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final userDoc = _firestore.collection('users').doc(uid);
      final currentPrefs =
          (await userDoc.get()).data()?['notificationPreferences'] ?? {};

      currentPrefs[category] = enabled;

      await userDoc.update({
        'notificationPreferences': currentPrefs,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Notification preference updated: $category = $enabled');
      return true;
    } catch (e) {
      print('❌ Error updating notification preference: $e');
      return false;
    }
  }

  // ===== PERMISSION MANAGEMENT =====

  /// Grant permission for data access
  Future<bool> grantPermission({
    required String permissionType,
    required String resource,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore.collection('permissions').add({
        'uid': uid,
        'permissionType': permissionType,
        'resource': resource,
        'grantedAt': DateTime.now().toIso8601String(),
        'status': 'active',
      });

      print('✅ Permission granted: $permissionType for $resource');
      return true;
    } catch (e) {
      print('❌ Error granting permission: $e');
      return false;
    }
  }

  /// Revoke permission
  Future<bool> revokePermission({required String permissionId}) async {
    try {
      await _firestore.collection('permissions').doc(permissionId).update({
        'status': 'revoked',
        'revokedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Permission revoked: $permissionId');
      return true;
    } catch (e) {
      print('❌ Error revoking permission: $e');
      return false;
    }
  }

  /// Get user permissions
  Future<List<Map<String, dynamic>>> getUserPermissions() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('permissions')
          .where('uid', isEqualTo: uid)
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error getting user permissions: $e');
      return [];
    }
  }

  // ===== REAL-TIME UPDATES =====

  /// Listen to permission changes in real-time
  Stream<QuerySnapshot> listenToPermissions() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('permissions')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  /// Listen to notification settings changes
  Stream<DocumentSnapshot> listenToNotificationSettings() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore.collection('users').doc(uid).snapshots();
  }
}
