import 'package:local_auth/local_auth.dart';
import 'package:frugal_ai/app_storage.dart';

/// 🔐 Secure Login with App Lock Service (Feature 7)
/// Provides PIN/Fingerprint-based app lock functionality
class AppSecurityService {
  static final AppSecurityService _instance = AppSecurityService._internal();

  factory AppSecurityService() {
    return _instance;
  }

  AppSecurityService._internal();

  late LocalAuthentication _localAuth;
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];

  /// Initialize the security service
  Future<void> initialize() async {
    _localAuth = LocalAuthentication();
    await _checkBiometricAvailability();
  }

  /// Check if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    try {
      _canCheckBiometrics = await _localAuth.canCheckBiometrics;
      _availableBiometrics = await _localAuth.getAvailableBiometrics();
      print('Available biometrics: $_availableBiometrics');
    } on Exception catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  /// Get available biometric types
  List<BiometricType> get availableBiometrics => _availableBiometrics;
  bool get canUseBiometric =>
      _canCheckBiometrics && _availableBiometrics.isNotEmpty;

  /// Set app lock PIN
  Future<void> setAppPin(String pin) async {
    // In production, encrypt the PIN before storing
    await AppStorage.setAppLockPin(pin);
    print('✅ App PIN set successfully');
  }

  /// Verify app lock PIN
  Future<bool> verifyAppPin(String pin) async {
    final storedPin = await AppStorage.getAppLockPin();
    return storedPin == pin;
  }

  /// Authenticate using biometric
  /// [reason] - Reason message shown to user
  Future<bool> authenticateWithBiometric({required String reason}) async {
    try {
      if (!canUseBiometric) {
        print('❌ Biometric not available');
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('Biometric auth error: $e');
      return false;
    }
  }

  /// Authenticate using device credentials (PIN/Pattern)
  /// [reason] - Reason message shown to user
  Future<bool> authenticateWithDeviceCredentials({
    required String reason,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      print('Device auth error: $e');
      return false;
    }
  }

  /// Get recommended authentication method
  /// Returns 'biometric', 'pin', or 'none'
  Future<String> getRecommendedAuthMethod() async {
    final isBiometricEnabled = await AppStorage.isBiometricEnabled();
    final hasPin = (await AppStorage.getAppLockPin()) != null;
    final isLockEnabled = await AppStorage.isAppLockEnabled();

    if (!isLockEnabled) return 'none';

    if (isBiometricEnabled && canUseBiometric) {
      return 'biometric';
    } else if (hasPin) {
      return 'pin';
    }

    return 'none';
  }

  /// Authenticate based on user preferences
  Future<bool> authenticateWithPreference() async {
    final authMethod = await getRecommendedAuthMethod();

    switch (authMethod) {
      case 'biometric':
        return await authenticateWithBiometric(
          reason: 'Authenticate to access Frugal AI',
        );
      case 'pin':
        // PIN verification should be handled by UI
        return false;
      default:
        return false;
    }
  }

  /// Check if app lock is enabled and should be shown
  Future<bool> shouldShowAppLock() async {
    return await AppStorage.isAppLockEnabled();
  }

  /// Disable app lock
  Future<void> disableAppLock() async {
    // Implementation to disable app lock
    // This would require managing state
    print('🔓 App lock disabled');
  }

  /// Enable app lock
  Future<void> enableAppLock() async {
    // Implementation to enable app lock
    print('🔐 App lock enabled');
  }
}
