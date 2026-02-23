const { saveTransaction, getUserTransactions, deleteTransaction: deleteTransactionDb, getTransactionSummary } = require('./databaseService');
const { v4: uuidv4 } = require('uuid');

/**
 * Add transaction
 */
const addTransaction = async (userId, transactionData) => {
  try {
    const transactionId = await saveTransaction(userId, {
      ...transactionData,
      status: 'completed'
    });

    return {
      id: transactionId,
      message: 'Transaction added successfully'
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get all transactions
 */
const getAllTransactions = async (userId, filters = {}) => {
  try {
    let transactions = await getUserTransactions(userId, 500);

    // Apply date range filter
    if (filters.startDate || filters.endDate) {
      const startDate = filters.startDate ? new Date(filters.startDate) : null;
      const endDate = filters.endDate ? new Date(filters.endDate) : null;

      transactions = transactions.filter(t => {
        const tDate = new Date(t.date || t.timestamp);
        if (startDate && tDate < startDate) return false;
        if (endDate && tDate > endDate) return false;
        return true;
      });
    }

    // Apply category filter
    if (filters.category) {
      transactions = transactions.filter(t => t.category === filters.category);
    }

    return transactions;
  } catch (error) {
    throw error;
  }
};

/**
 * Get transaction details
 */
const getTransactionById = async (transactionId, userId) => {
  try {
    const transactions = await getUserTransactions(userId);
    const transaction = transactions.find(t => t.id === transactionId);

    if (!transaction) {
      throw new Error('Transaction not found');
    }

    return transaction;
  } catch (error) {
    throw error;
  }
};

/**
 * Update transaction
 */
const updateTransaction = async (transactionId, userId, updateData) => {
  try {
    const transactions = await getUserTransactions(userId);
    const transaction = transactions.find(t => t.id === transactionId);

    if (!transaction) {
      throw new Error('Transaction not found');
    }

    const updateRef = require('../config/firebase').rtdb.ref(`transactions/${userId}/${transactionId}`);
    await updateRef.update({
      ...updateData,
      updatedAt: new Date().toISOString()
    });

    return { message: 'Transaction updated successfully' };
  } catch (error) {
    throw error;
  }
};

/**
 * Delete transaction
 */
const deleteTransaction = async (transactionId, userId) => {
  try {
    await deleteTransactionDb(userId, transactionId);
    return { message: 'Transaction deleted successfully' };
  } catch (error) {
    throw error;
  }
};

/**
 * Get transaction summary
 */
const getTransactionSummary__new = async (userId, startDate = null, endDate = null) => {
  try {
    const start = startDate ? new Date(startDate) : new Date(new Date().getFullYear(), new Date().getMonth(), 1);
    const end = endDate ? new Date(endDate) : new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0);

    const summary = await getTransactionSummary(userId, start, end);

    return {
      ...summary,
      startDate: start.toISOString().split('T')[0],
      endDate: end.toISOString().split('T')[0]
    };
  } catch (error) {
    throw error;
  }
};

module.exports = {
  addTransaction,
  getAllTransactions,
  getTransactionById,
  updateTransaction,
  deleteTransaction,
  getTransactionSummary: getTransactionSummary__new
};
