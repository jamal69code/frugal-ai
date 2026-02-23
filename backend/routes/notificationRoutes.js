const express = require('express');
const notificationController = require('../controllers/notificationController');

const router = express.Router();

/**
 * Notification routes
 */
router.post('/fcm-token', notificationController.registerFCMToken);
router.get('/', notificationController.getNotifications);
router.put('/:notificationId/read', notificationController.markAsRead);
router.delete('/', notificationController.clearAllNotifications);
router.post('/test', notificationController.sendTestNotification);

module.exports = router;
