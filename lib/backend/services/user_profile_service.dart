import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_io/io.dart';

/// 👤 User Profile Service
/// Manages user profile and bill image uploads
class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();

  factory UserProfileService() {
    return _instance;
  }

  UserProfileService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ===== PROFILE MANAGEMENT =====

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile({
    required String fullName,
    required String phone,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      await _firestore.collection('users').doc(uid).update({
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'city': city,
        'country': country,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Profile updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating profile: $e');
      return false;
    }
  }

  // ===== PROFILE PICTURE MANAGEMENT =====

  /// Upload profile picture
  Future<bool> uploadProfilePicture({required String imagePath}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final fileName = 'profile_$uid.jpg';
      final ref = _storage.ref().child('profile_pictures/$fileName');

      await ref.putFile(File(imagePath));
      final url = await ref.getDownloadURL();

      await _firestore.collection('users').doc(uid).update({
        'photoUrl': url,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Profile picture uploaded');
      return true;
    } catch (e) {
      print('❌ Error uploading profile picture: $e');
      return false;
    }
  }

  // ===== CAPTURED BILLS MANAGEMENT =====

  /// Upload bill image to profile
  Future<bool> uploadBillImage({
    required String imagePath,
    required String billCategory,
    required String description,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final fileName = 'bill_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('user_bills/$uid/$fileName');

      await ref.putFile(File(imagePath));
      final url = await ref.getDownloadURL();

      // Save bill reference in Firestore
      await _firestore.collection('users').doc(uid).collection('bills').add({
        'imageUrl': url,
        'fileName': fileName,
        'category': billCategory,
        'description': description,
        'uploadedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Bill image uploaded');
      return true;
    } catch (e) {
      print('❌ Error uploading bill image: $e');
      return false;
    }
  }

  /// Get user's bill images
  Future<List<Map<String, dynamic>>> getUserBills() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .orderBy('uploadedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('❌ Error getting bills: $e');
      return [];
    }
  }

  /// Delete bill image
  Future<bool> deleteBill({required String billId}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception('User not authenticated');

      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(billId)
          .get();

      final fileName = doc.data()?['fileName'];
      if (fileName != null) {
        await _storage.ref().child('user_bills/$uid/$fileName').delete();
      }

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(billId)
          .delete();

      print('✅ Bill deleted');
      return true;
    } catch (e) {
      print('❌ Error deleting bill: $e');
      return false;
    }
  }

  // ===== ACCOUNT STATISTICS =====

  /// Get user account statistics
  Future<Map<String, dynamic>> getAccountStats() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return {};

      final billsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .get();

      final profile = await getUserProfile();

      return {
        'totalBills': billsSnapshot.docs.length,
        'accountCreated': profile?['createdAt'],
        'lastLogin': profile?['lastLogin'],
        'accountStatus': profile?['accountStatus'],
        'notificationsEnabled': profile?['notificationsEnabled'],
      };
    } catch (e) {
      print('❌ Error getting account stats: $e');
      return {};
    }
  }

  // ===== REAL-TIME PROFILE UPDATES =====

  /// Listen to profile changes
  Stream<DocumentSnapshot> listenToProfile() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Listen to bills
  Stream<QuerySnapshot> listenToBills() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('bills')
        .snapshots();
  }
}
