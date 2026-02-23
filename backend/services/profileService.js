const { storage, rtdb } = require('../config/firebase');
const path = require('path');
const fs = require('fs').promises;
const sharp = require('sharp');
const { v4: uuidv4 } = require('uuid');
const { getUserProfile: getUserProfileDb, updateUserProfile: updateUserProfileDb, getUserBankAccounts, saveBankAccount } = require('./databaseService');

/**
 * Get user profile
 */
const getUserProfile = async (userId) => {
  try {
    const userDoc = await getUserProfileDb(userId);
    
    if (!userDoc) {
      throw new Error('User not found');
    }

    return userDoc;
  } catch (error) {
    throw error;
  }
};

/**
 * Update user profile
 */
const updateUserProfile = async (userId, profileData) => {
  try {
    const updateData = {
      ...profileData,
      updatedAt: new Date().toISOString()
    };

    await updateUserProfileDb(userId, updateData);

    const updatedDoc = await getUserProfileDb(userId);
    return updatedDoc;
  } catch (error) {
    throw error;
  }
};

/**
 * Upload profile photo
 */
const uploadProfilePhoto = async (userId, filePath) => {
  try {
    // Optimize image with Sharp
    const optimizedBuffer = await sharp(filePath)
      .resize(300, 300, { fit: 'cover' })
      .jpeg({ quality: 80 })
      .toBuffer();

    // Upload to Firebase Storage
    const filename = `profile-${userId}-${uuidv4()}.jpg`;
    const bucket = storage.bucket();
    const file = bucket.file(`profiles/${filename}`);

    await file.save(optimizedBuffer, {
      metadata: {
        contentType: 'image/jpeg'
      }
    });

    // Get download URL
    const [url] = await file.getSignedUrl({
      version: 'v4',
      action: 'read',
      expires: Date.now() + 365 * 24 * 60 * 60 * 1000, // 1 year
    });

    // Update user document in RTDB
    await updateUserProfileDb(userId, {
      photoUrl: url,
      updatedAt: new Date().toISOString()
    });

    // Clean up local file
    await fs.unlink(filePath);

    return { url, message: 'Profile photo uploaded successfully' };
  } catch (error) {
    throw error;
  }
};

/**
 * Delete profile photo
 */
const deleteProfilePhoto = async (userId) => {
  try {
    const userDoc = await getUserProfileDb(userId);
    const photoUrl = userDoc.photoUrl;

    if (photoUrl) {
      const bucket = storage.bucket();
      // Extract filename from URL
      try {
        const filename = photoUrl.split('/').pop().split('?')[0];
        await bucket.file(`profiles/${filename}`).delete();
      } catch (err) {
        // Silently continue if file not found
      }
    }

    // Update user document
    await updateUserProfileDb(userId, {
      photoUrl: null,
      updatedAt: new Date().toISOString()
    });

    return { message: 'Profile photo deleted successfully' };
  } catch (error) {
    throw error;
  }
};

/**
 * Add bank account
 */
const addBankAccount = async (userId, accountData) => {
  try {
    const accountId = await saveBankAccount(userId, {
      ...accountData,
      createdAt: new Date().toISOString()
    });

    return {
      id: accountId,
      ...accountData,
      message: 'Bank account added successfully'
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Get bank accounts
 */
const getBankAccounts = async (userId) => {
  try {
    const accounts = await getUserBankAccounts(userId);
    return accounts;
  } catch (error) {
    throw error;
  }
};

/**
 * Update bank account
 */
const updateBankAccount = async (userId, accountId, updateData) => {
  try {
    const accountRef = rtdb.ref(`bankAccounts/${userId}/${accountId}`);
    await accountRef.update({
      ...updateData,
      updatedAt: new Date().toISOString()
    });

    return { message: 'Bank account updated successfully' };
  } catch (error) {
    throw error;
  }
};

/**
 * Delete bank account
 */
const deleteBankAccount = async (userId, accountId) => {
  try {
    const accountRef = rtdb.ref(`bankAccounts/${userId}/${accountId}`);
    await accountRef.remove();

    return { message: 'Bank account deleted successfully' };
  } catch (error) {
    throw error;
  }
};

module.exports = {
  getUserProfile,
  updateUserProfile,
  uploadProfilePhoto,
  deleteProfilePhoto,
  addBankAccount,
  getBankAccounts,
  updateBankAccount,
  deleteBankAccount
};
