/// API Response feedback classes for displaying user feedback

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? error;
  final ResponseFeedback? feedback;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.feedback,
    required this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'],
      error: json['error'],
      feedback: json['feedback'] != null
          ? ResponseFeedback.fromJson(json['feedback'])
          : null,
      statusCode: json['statusCode'] ?? 200,
    );
  }

  bool get isSuccess => success && error == null;
  bool get isError => !success || error != null;
  String get errorMessage => error ?? message ?? 'Unknown error occurred';

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, error: $error, statusCode: $statusCode)';
  }
}

class ResponseFeedback {
  final String type; // 'success', 'error', 'warning', 'info'
  final String title;
  final String body;
  final Duration? duration;

  ResponseFeedback({
    required this.type,
    required this.title,
    required this.body,
    this.duration,
  });

  factory ResponseFeedback.fromJson(Map<String, dynamic> json) {
    return ResponseFeedback(
      type: json['type'] ?? 'info',
      title: json['title'] ?? 'Notification',
      body: json['body'] ?? '',
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'])
          : null,
    );
  }

  bool get isSuccess => type == 'success';
  bool get isError => type == 'error';
  bool get isWarning => type == 'warning';
  bool get isInfo => type == 'info';
}

/// User profile data model
class UserProfile {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phone;
  final String? bio;
  final List<BankAccount>? bankAccounts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phone,
    this.bio,
    this.bankAccounts,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photoUrl'],
      phone: json['phone'],
      bio: json['bio'],
      bankAccounts: json['bankAccounts'] != null
          ? List<BankAccount>.from(
              (json['bankAccounts'] as List).map(
                (x) => BankAccount.fromJson(x as Map<String, dynamic>),
              ),
            )
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phone': phone,
      'bio': bio,
      'bankAccounts': bankAccounts?.map((x) => x.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String accountType;
  final double balance;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] ?? '',
      bankName: json['bankName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountType: json['accountType'] ?? 'checking',
      balance: (json['balance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
    };
  }
}

/// Auth response with token
class AuthResponse {
  final String uid;
  final String email;
  final String name;
  final String token;
  final UserProfile? profile;

  AuthResponse({
    required this.uid,
    required this.email,
    required this.name,
    required this.token,
    this.profile,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      token: json['token'] ?? '',
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'token': token,
      'profile': profile?.toJson(),
    };
  }
}
