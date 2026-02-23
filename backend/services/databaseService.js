const { rtdb, db } = require('../config/firebase');

/**
 * Initialize Realtime Database structure
 * Creates necessary nodes for users, transactions, and notifications
 */
const initializeDatabaseStructure = async () => {
  try {
    console.log('📊 Initializing Realtime Database structure...');
    
    // Create root nodes if they don't exist
    const rootRef = rtdb.ref();
    const snapshot = await rootRef.once('value');
    const data = snapshot.val();
    
    // Initialize main collections if empty
    const updates = {};
    
    if (!data || !data.users) {
      updates['users'] = {};
    }
    if (!data || !data.transactions) {
      updates['transactions'] = {};
    }
    if (!data || !data.notifications) {
      updates['notifications'] = {};
    }
    if (!data || !data.bankAccounts) {
      updates['bankAccounts'] = {};
    }
    
    if (Object.keys(updates).length > 0) {
      await rootRef.update(updates);
      console.log('✅ Database structure initialized');
    } else {
      console.log('✅ Database structure already exists');
    }
  } catch (error) {
    console.error('⚠️ Could not initialize database structure:', error.message);
  }
};

/**
 * Save user profile to Realtime Database
 */
const saveUserProfile = async (uid, userData) => {
  try {
    const userRef = rtdb.ref(`users/${uid}`);
    await userRef.set({
      ...userData,
      updatedAt: new Date().toISOString(),
    });
    console.log(`✅ User profile saved: ${uid}`);
  } catch (error) {
    console.error('Error saving user profile:', error);
    throw error;
  }
};

/**
 * Get user profile from Realtime Database
 */
const getUserProfile = async (uid) => {
  try {
    const userRef = rtdb.ref(`users/${uid}`);
    const snapshot = await userRef.once('value');
    return snapshot.val();
  } catch (error) {
    console.error('Error getting user profile:', error);
    return null;
  }
};

/**
 * Update user profile
 */
const updateUserProfile = async (uid, updates) => {
  try {
    const userRef = rtdb.ref(`users/${uid}`);
    await userRef.update({
      ...updates,
      updatedAt: new Date().toISOString(),
    });
    console.log(`✅ User profile updated: ${uid}`);
  } catch (error) {
    console.error('Error updating user profile:', error);
    throw error;
  }
};

/**
 * Save transaction to Realtime Database
 */
const saveTransaction = async (uid, transactionData) => {
  try {
    const transRef = rtdb.ref(`transactions/${uid}`).push();
    await transRef.set({
      id: transRef.key,
      ...transactionData,
      timestamp: new Date().toISOString(),
    });
    return transRef.key;
  } catch (error) {
    console.error('Error saving transaction:', error);
    throw error;
  }
};

/**
 * Get user transactions
 */
const getUserTransactions = async (uid, limit = 100) => {
  try {
    const transRef = rtdb.ref(`transactions/${uid}`);
    const snapshot = await transRef.limitToLast(limit).once('value');
    const transactions = [];
    
    snapshot.forEach((child) => {
      transactions.push({
        id: child.key,
        ...child.val(),
      });
    });
    
    return transactions.reverse();
  } catch (error) {
    console.error('Error getting transactions:', error);
    return [];
  }
};

/**
 * Delete transaction
 */
const deleteTransaction = async (uid, transactionId) => {
  try {
    const transRef = rtdb.ref(`transactions/${uid}/${transactionId}`);
    await transRef.remove();
    console.log(`✅ Transaction deleted: ${transactionId}`);
  } catch (error) {
    console.error('Error deleting transaction:', error);
    throw error;
  }
};

/**
 * Save bank account
 */
const saveBankAccount = async (uid, accountData) => {
  try {
    const accountRef = rtdb.ref(`bankAccounts/${uid}`).push();
    await accountRef.set({
      id: accountRef.key,
      ...accountData,
      createdAt: new Date().toISOString(),
    });
    return accountRef.key;
  } catch (error) {
    console.error('Error saving bank account:', error);
    throw error;
  }
};

/**
 * Get user bank accounts
 */
const getUserBankAccounts = async (uid) => {
  try {
    const accountRef = rtdb.ref(`bankAccounts/${uid}`);
    const snapshot = await accountRef.once('value');
    const accounts = [];
    
    snapshot.forEach((child) => {
      accounts.push({
        id: child.key,
        ...child.val(),
      });
    });
    
    return accounts;
  } catch (error) {
    console.error('Error getting bank accounts:', error);
    return [];
  }
};

/**
 * Save notification
 */
const saveNotification = async (uid, notificationData) => {
  try {
    const notifRef = rtdb.ref(`notifications/${uid}`).push();
    await notifRef.set({
      id: notifRef.key,
      ...notificationData,
      read: false,
      createdAt: new Date().toISOString(),
    });
    return notifRef.key;
  } catch (error) {
    console.error('Error saving notification:', error);
    throw error;
  }
};

/**
 * Get user notifications
 */
const getUserNotifications = async (uid, limit = 50) => {
  try {
    const notifRef = rtdb.ref(`notifications/${uid}`);
    const snapshot = await notifRef.limitToLast(limit).once('value');
    const notifications = [];
    
    snapshot.forEach((child) => {
      notifications.push({
        id: child.key,
        ...child.val(),
      });
    });
    
    return notifications.reverse();
  } catch (error) {
    console.error('Error getting notifications:', error);
    return [];
  }
};

/**
 * Mark notification as read
 */
const markNotificationAsRead = async (uid, notificationId) => {
  try {
    const notifRef = rtdb.ref(`notifications/${uid}/${notificationId}`);
    await notifRef.update({ read: true });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    throw error;
  }
};

/**
 * Get transaction summary for user
 */
const getTransactionSummary = async (uid, startDate, endDate) => {
  try {
    const transactions = await getUserTransactions(uid, 1000);
    
    let totalIncome = 0;
    let totalExpenses = 0;
    const byCategory = {};
    
    transactions.forEach((trans) => {
      const transDate = new Date(trans.date || trans.timestamp);
      
      if (transDate >= startDate && transDate <= endDate) {
        if (trans.type === 'income') {
          totalIncome += trans.amount || 0;
        } else if (trans.type === 'expense') {
          totalExpenses += trans.amount || 0;
          const category = trans.category || 'uncategorized';
          byCategory[category] = (byCategory[category] || 0) + trans.amount;
        }
      }
    });
    
    return {
      totalIncome,
      totalExpenses,
      netBalance: totalIncome - totalExpenses,
      byCategory,
    };
  } catch (error) {
    console.error('Error getting transaction summary:', error);
    throw error;
  }
};

module.exports = {
  initializeDatabaseStructure,
  saveUserProfile,
  getUserProfile,
  updateUserProfile,
  saveTransaction,
  getUserTransactions,
  deleteTransaction,
  saveBankAccount,
  getUserBankAccounts,
  saveNotification,
  getUserNotifications,
  markNotificationAsRead,
  getTransactionSummary,
};
