const transactionService = require('../services/transactionService');
const notificationService = require('../services/notificationService');

/**
 * Add transaction
 */
exports.addTransaction = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { amount, category, type, description, date } = req.body;

    if (!amount || !category || !type || !date) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const transactionData = {
      amount,
      category,
      type,
      description: description || '',
      date: new Date(date)
    };

    const result = await transactionService.addTransaction(userId, transactionData);

    // Send notification
    await notificationService.sendTransactionNotification(userId, transactionData);

    res.status(201).json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all transactions
 */
exports.getTransactions = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { startDate, endDate } = req.query;

    const filters = {};
    if (startDate) filters.startDate = new Date(startDate);
    if (endDate) filters.endDate = new Date(endDate);

    const transactions = await transactionService.getAllTransactions(userId, filters);

    res.json({
      success: true,
      data: transactions
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get transaction by ID
 */
exports.getTransactionById = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { transactionId } = req.params;

    const transaction = await transactionService.getTransactionById(transactionId, userId);

    res.json({
      success: true,
      data: transaction
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update transaction
 */
exports.updateTransaction = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { transactionId } = req.params;
    const updateData = req.body;

    const result = await transactionService.updateTransaction(transactionId, userId, updateData);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete transaction
 */
exports.deleteTransaction = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { transactionId } = req.params;

    const result = await transactionService.deleteTransaction(transactionId, userId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get transaction summary
 */
exports.getTransactionSummary = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { month } = req.query;

    const summary = await transactionService.getTransactionSummary(
      userId,
      month ? new Date(month) : new Date()
    );

    res.json({
      success: true,
      data: summary
    });
  } catch (error) {
    next(error);
  }
};
