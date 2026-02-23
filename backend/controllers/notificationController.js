const notificationService = require('../services/notificationService');

/**
 * Register FCM token
 */
exports.registerFCMToken = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({ error: 'FCM token is required' });
    }

    const result = await notificationService.registerFCMToken(userId, fcmToken);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get notifications
 */
exports.getNotifications = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { limit } = req.query;

    const notifications = await notificationService.getUserNotifications(userId, limit || 50);

    res.json({
      success: true,
      data: notifications
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Mark notification as read
 */
exports.markAsRead = async (req, res, next) => {
  try {
    const { notificationId } = req.params;

    const result = await notificationService.markAsRead(notificationId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Clear all notifications
 */
exports.clearAllNotifications = async (req, res, next) => {
  try {
    const userId = req.userId;

    const result = await notificationService.clearAllNotifications(userId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Send test notification
 */
exports.sendTestNotification = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { title, message } = req.body;

    const result = await notificationService.sendBankingNotification(userId, {
      title: title || 'Test Notification',
      message: message || 'This is a test notification'
    });

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};
