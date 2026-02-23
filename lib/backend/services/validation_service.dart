/// 🔍 Form Validation Service
/// Handles validation for login, signup, and other forms
class ValidationService {
  // ===== EMAIL VALIDATION =====
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // ===== PASSWORD VALIDATION =====
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false; // uppercase
    if (!password.contains(RegExp(r'[a-z]'))) return false; // lowercase
    if (!password.contains(RegExp(r'[0-9]'))) return false; // number
    return true;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    return null;
  }

  // ===== NAME VALIDATION =====
  static bool isValidName(String name) {
    return name.isNotEmpty && name.length >= 2;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters';
    }
    return null;
  }

  // ===== PHONE VALIDATION =====
  static bool isValidPhone(String phone) {
    return RegExp(
      r'^[0-9]{10}$',
    ).hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length != 10) {
      return 'Phone number must be 10 digits';
    }
    return null;
  }

  // ===== AMOUNT VALIDATION =====
  static bool isValidAmount(String amount) {
    try {
      final double value = double.parse(amount);
      return value > 0;
    } catch (e) {
      return false;
    }
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    try {
      final double amount = double.parse(value);
      if (amount <= 0) {
        return 'Amount must be greater than 0';
      }
      if (amount > 999999999) {
        return 'Amount is too large';
      }
    } catch (e) {
      return 'Enter a valid amount';
    }
    return null;
  }

  // ===== USERNAME VALIDATION =====
  static bool isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,}$').hasMatch(username);
  }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscore';
    }
    return null;
  }

  // ===== confirm PASSWORD VALIDATION =====
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // ===== COMBINED LOGIN VALIDATION =====
  static Map<String, String?> validateLoginForm({
    required String email,
    required String password,
  }) {
    return {
      'email': validateEmail(email),
      'password': validatePassword(password),
    };
  }

  // ===== COMBINED SIGNUP VALIDATION =====
  static Map<String, String?> validateSignupForm({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    return {
      'fullName': validateName(fullName),
      'email': validateEmail(email),
      'password': validatePassword(password),
      'confirmPassword': validateConfirmPassword(confirmPassword, password),
    };
  }

  // ===== PROFILE UPDATE VALIDATION =====
  static Map<String, String?> validateProfileForm({
    required String fullName,
    required String phone,
    required String address,
    required String city,
  }) {
    return {
      'fullName': validateName(fullName),
      'phone': validatePhone(phone),
      'address': address.isEmpty ? 'Address is required' : null,
      'city': city.isEmpty ? 'City is required' : null,
    };
  }

  // ===== PASSWORD CHANGE VALIDATION =====
  static Map<String, String?> validatePasswordChange({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return {
      'currentPassword': currentPassword.isEmpty
          ? 'Current password is required'
          : null,
      'newPassword': validatePassword(newPassword),
      'confirmPassword': validateConfirmPassword(confirmPassword, newPassword),
    };
  }

  // ===== CHECK IF FORM IS VALID =====
  static bool isFormValid(Map<String, String?> validationMap) {
    return validationMap.values.every((error) => error == null);
  }
}
