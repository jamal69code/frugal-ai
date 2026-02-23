const profileService = require('../services/profileService');
const { db } = require('../config/firebase');

/**
 * Get user profile
 */
exports.getProfile = async (req, res, next) => {
  try {
    const userId = req.userId;
    const profile = await profileService.getUserProfile(userId);

    res.json({
      success: true,
      data: profile
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update profile
 */
exports.updateProfile = async (req, res, next) => {
  try {
    const userId = req.userId;
    const updateData = req.body;

    const updated = await profileService.updateUserProfile(userId, updateData);

    res.json({
      success: true,
      data: updated
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Upload profile photo
 */
exports.uploadProfilePhoto = async (req, res, next) => {
  try {
    const userId = req.userId;

    if (!req.file) {
      return res.status(400).json({ error: 'No file provided' });
    }

    const result = await profileService.uploadProfilePhoto(userId, req.file.path);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete profile photo
 */
exports.deleteProfilePhoto = async (req, res, next) => {
  try {
    const userId = req.userId;
    const result = await profileService.deleteProfilePhoto(userId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Add bank account
 */
exports.addBankAccount = async (req, res, next) => {
  try {
    const userId = req.userId;
    const accountData = req.body;

    // Validate required fields
    const required = ['accountName', 'accountNumber', 'bankName', 'accountType'];
    for (const field of required) {
      if (!accountData[field]) {
        return res.status(400).json({ error: `${field} is required` });
      }
    }

    const result = await profileService.addBankAccount(userId, accountData);

    res.status(201).json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get bank accounts
 */
exports.getBankAccounts = async (req, res, next) => {
  try {
    const userId = req.userId;
    const accounts = await profileService.getBankAccounts(userId);

    res.json({
      success: true,
      data: accounts
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update bank account
 */
exports.updateBankAccount = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { accountId } = req.params;
    const updateData = req.body;

    const result = await profileService.updateBankAccount(userId, accountId, updateData);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete bank account
 */
exports.deleteBankAccount = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { accountId } = req.params;

    const result = await profileService.deleteBankAccount(userId, accountId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};
