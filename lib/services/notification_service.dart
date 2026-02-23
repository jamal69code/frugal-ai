import 'package:frugal_ai/services/api_client.dart';

class NotificationService {
  /// Register FCM token
  static Future<Map<String, dynamic>> registerFCMToken(String fcmToken) async {
    return await ApiClient.post('/notifications/fcm-token', {
      'fcmToken': fcmToken,
    });
  }

  /// Get notifications
  static Future<Map<String, dynamic>> getNotifications({int limit = 50}) async {
    return await ApiClient.get('/notifications?limit=$limit');
  }

  /// Mark notification as read
  static Future<Map<String, dynamic>> markAsRead(String notificationId) async {
    return await ApiClient.put('/notifications/$notificationId/read', {});
  }

  /// Clear all notifications
  static Future<Map<String, dynamic>> clearAllNotifications() async {
    return await ApiClient.delete('/notifications');
  }

  /// Send test notification
  static Future<Map<String, dynamic>> sendTestNotification({
    required String title,
    required String message,
  }) async {
    return await ApiClient.post('/notifications/test', {
      'title': title,
      'message': message,
    });
  }
}
