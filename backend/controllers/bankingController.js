const bankingService = require('../services/bankingService');

/**
 * Create Plaid link token
 */
exports.createLinkToken = async (req, res, next) => {
  try {
    const userId = req.userId;

    const result = await bankingService.createPlaidLinkToken(userId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Exchange public token
 */
exports.exchangePublicToken = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { publicToken } = req.body;

    if (!publicToken) {
      return res.status(400).json({ error: 'Public token is required' });
    }

    const result = await bankingService.exchangePlaidToken(userId, publicToken);

    res.status(201).json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get connected banks
 */
exports.getConnectedBanks = async (req, res, next) => {
  try {
    const userId = req.userId;

    const banks = await bankingService.getConnectedBanks(userId);

    res.json({
      success: true,
      data: banks
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Sync bank transactions
 */
exports.syncTransactions = async (req, res, next) => {
  try {
    const userId = req.userId;

    const result = await bankingService.syncBankTransactions(userId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Disconnect bank
 */
exports.disconnectBank = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { bankId } = req.params;

    const result = await bankingService.disconnectBank(userId, bankId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};
