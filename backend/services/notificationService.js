const { db, messaging } = require('../config/firebase');
const { v4: uuidv4 } = require('uuid');
const nodemailer = require('nodemailer');

// Configure Nodemailer
const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: process.env.SMTP_PORT,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS
  }
});

/**
 * Send transaction notification
 */
const sendTransactionNotification = async (userId, transactionData) => {
  try {
    const notification = {
      notificationId: uuidv4(),
      userId,
      type: 'transaction',
      title: `${transactionData.type === 'income' ? 'Income' : 'Expense'}: ${transactionData.category}`,
      body: `$${transactionData.amount.toFixed(2)} on ${transactionData.date}`,
      data: transactionData,
      read: false,
      createdAt: new Date(),
      timestamp: new Date().getTime()
    };

    await db.collection('notifications').add(notification);

    // Get user's FCM tokens
    const userDoc = await db.collection('users').doc(userId).get();
    const fcmTokens = userDoc.data().fcmTokens || [];

    // Send push notifications
    if (fcmTokens.length > 0) {
      const message = {
        notification: {
          title: notification.title,
          body: notification.body
        },
        data: {
          transactionId: transactionData.transactionId || '',
          type: transactionData.type
        }
      };

      for (const token of fcmTokens) {
        try {
          await messaging.send({
            token,
            ...message
          });
        } catch (error) {
          console.error(`Failed to send notification to token ${token}:`, error);
        }
      }
    }

    return { notificationId: notification.notificationId };
  } catch (error) {
    throw error;
  }
};

/**
 * Send banking notification
 */
const sendBankingNotification = async (userId, bankingData) => {
  try {
    const notification = {
      notificationId: uuidv4(),
      userId,
      type: 'banking',
      title: bankingData.title,
      body: bankingData.message,
      data: bankingData,
      read: false,
      createdAt: new Date(),
      timestamp: new Date().getTime()
    };

    await db.collection('notifications').add(notification);

    // Get user's FCM tokens
    const userDoc = await db.collection('users').doc(userId).get();
    const fcmTokens = userDoc.data().fcmTokens || [];

    // Send push notifications
    if (fcmTokens.length > 0) {
      for (const token of fcmTokens) {
        try {
          await messaging.send({
            token,
            notification: {
              title: notification.title,
              body: notification.body
            }
          });
        } catch (error) {
          console.error(`Failed to send notification:`, error);
        }
      }
    }

    return { notificationId: notification.notificationId };
  } catch (error) {
    throw error;
  }
};

/**
 * Send email notification
 */
const sendEmailNotification = async (email, subject, htmlContent) => {
  try {
    await transporter.sendMail({
      from: `${process.env.SENDER_NAME} <${process.env.SENDER_EMAIL}>`,
      to: email,
      subject,
      html: htmlContent
    });

    return { message: 'Email sent successfully' };
  } catch (error) {
    console.error('Error sending email:', error);
    throw error;
  }
};

/**
 * Get user notifications
 */
const getUserNotifications = async (userId, limit = 50) => {
  try {
    const snapshot = await db.collection('notifications')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    const notifications = [];
    snapshot.forEach(doc => {
      notifications.push({
        id: doc.id,
        ...doc.data()
      });
    });

    return notifications;
  } catch (error) {
    throw error;
  }
};

/**
 * Mark notification as read
 */
const markAsRead = async (notificationId) => {
  try {
    const notification = await db.collection('notifications').doc(notificationId).get();
    
    if (!notification.exists) {
      throw new Error('Notification not found');
    }

    await notification.ref.update({
      read: true,
      readAt: new Date()
    });

    return { message: 'Notification marked as read' };
  } catch (error) {
    throw error;
  }
};

/**
 * Clear all notifications
 */
const clearAllNotifications = async (userId) => {
  try {
    const snapshot = await db.collection('notifications')
      .where('userId', '==', userId)
      .get();

    const batch = db.batch();
    snapshot.docs.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    return { message: 'All notifications cleared' };
  } catch (error) {
    throw error;
  }
};

/**
 * Register FCM token
 */
const registerFCMToken = async (userId, fcmToken) => {
  try {
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();
    const fcmTokens = userDoc.data().fcmTokens || [];

    if (!fcmTokens.includes(fcmToken)) {
      fcmTokens.push(fcmToken);
      await userRef.update({ fcmTokens });
    }

    return { message: 'FCM token registered' };
  } catch (error) {
    throw error;
  }
};

module.exports = {
  sendTransactionNotification,
  sendBankingNotification,
  sendEmailNotification,
  getUserNotifications,
  markAsRead,
  clearAllNotifications,
  registerFCMToken
};
