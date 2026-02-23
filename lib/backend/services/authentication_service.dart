import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔐 Firebase Authentication Service
/// Handles user authentication including email/password and Google Sign-In
class AuthenticationService {
  static final AuthenticationService _instance =
      AuthenticationService._internal();

  factory AuthenticationService() {
    return _instance;
  }

  AuthenticationService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;

  GoogleSignIn? get _googleSignInInstance {
    if (_googleSignIn != null) return _googleSignIn;
    try {
      _googleSignIn = GoogleSignIn();
    } catch (e) {
      // GoogleSignIn can throw on web if clientId is not configured.
      // Defer failure to sign-in call to avoid crashing the app during startup.
      // ignore: avoid_print
      print('GoogleSignIn init failed: $e');
      _googleSignIn = null;
    }
    return _googleSignIn;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _firebaseAuth.currentUser != null;
  }

  // ===== EMAIL/PASSWORD AUTHENTICATION =====

  /// Sign up with email and password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Validate email format
      if (!_isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      // Validate password strength
      if (!_isValidPassword(password)) {
        throw Exception(
          'Password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      // Create user account
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update user profile
      await userCredential.user?.updateDisplayName(fullName);
      await userCredential.user?.updatePhotoURL(
        'https://ui-avatars.com/api/?name=$fullName',
      );

      // Save user data to Firestore
      await _saveUserToFirestore(
        uid: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        authProvider: 'email',
      );

      print('✅ User signed up successfully: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Sign up error: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ User signed in successfully: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('❌ No user found with this email');
      } else if (e.code == 'wrong-password') {
        print('❌ Wrong password');
      } else {
        print('❌ Authentication error: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  // ===== GOOGLE AUTHENTICATION =====

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      final googleSignIn = _googleSignInInstance;
      if (googleSignIn == null) {
        print('❌ Google Sign-In unavailable on this platform');
        return false;
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print('⚠️  Google sign-in cancelled by user');
        return false;
      }

      // Get authentication credentials
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null && googleAuth.idToken == null) {
        print('❌ Failed to get Google authentication tokens');
        return false;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      // Save user to Firestore if new user
      final docExists = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!docExists.exists) {
        await _saveUserToFirestore(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          fullName: userCredential.user!.displayName ?? 'Google User',
          authProvider: 'google',
          photoUrl: userCredential.user!.photoURL,
        );
      }

      print('✅ Google sign-in successful: ${googleUser.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('❌ Google sign-in error: $e');
      return false;
    }
  }

  /// Sign out
  Future<bool> signOut() async {
    try {
      final googleSignIn = _googleSignInInstance;
      if (googleSignIn != null) {
        await googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
      print('✅ User signed out');
      return true;
    } catch (e) {
      print('❌ Sign out error: $e');
      return false;
    }
  }

  // ===== PASSWORD MANAGEMENT =====

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not authenticated');
      }

      // Validate new password
      if (!_isValidPassword(newPassword)) {
        throw Exception(
          'Password must be at least 8 characters with uppercase, lowercase, and number',
        );
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      print('✅ Password changed successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Password change error: ${e.message}');
      return false;
    } catch (e) {
      print('❌ Error: $e');
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent to $email');
      return true;
    } catch (e) {
      print('❌ Password reset error: $e');
      return false;
    }
  }

  // ===== HELPER METHODS =====

  /// Validate email format
  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  /// Validate password strength
  /// Requirements: 8+ chars, uppercase, lowercase, number
  bool _isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore({
    required String uid,
    required String email,
    required String fullName,
    required String authProvider,
    String? photoUrl,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'authProvider': authProvider,
        'photoUrl': photoUrl ?? '',
        'createdAt': DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
        'notificationsEnabled': true,
        'accountStatus': 'active',
      });

      print('✅ User data saved to Firestore');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) return null;

      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// Update last login time
  Future<void> updateLastLogin() async {
    try {
      final uid = _firebaseAuth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).update({
        'lastLogin': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error updating last login: $e');
    }
  }
}
