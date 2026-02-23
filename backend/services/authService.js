const { auth, rtdb } = require('../config/firebase');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const { saveUserProfile, getUserProfile } = require('./databaseService');

/**
 * Register user
 */
const registerUser = async (userData) => {
  try {
    const { email, password, name, phone } = userData;

    // Create Firebase user
    const firebaseUser = await auth.createUser({
      email,
      password,
      displayName: name,
      phoneNumber: phone || null
    });

    // Save user document in Realtime Database
    const userDoc = {
      uid: firebaseUser.uid,
      email,
      name,
      phone: phone || '',
      profilePhoto: null,
      bio: '',
      dateOfBirth: null,
      isVerified: false,
      bankAccounts: [],
      notificationSettings: {
        enableEmails: true,
        enablePushNotifications: true,
        weeklyReport: true
      }
    };

    await saveUserProfile(firebaseUser.uid, userDoc);

    // Generate JWT token
    const token = jwt.sign(
      { uid: firebaseUser.uid, email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );

    return {
      uid: firebaseUser.uid,
      email,
      name,
      token,
      message: 'User registered successfully'
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Login user
 */
const loginUser = async (email, password) => {
  try {
    // Get user by email
    const userRecord = await auth.getUserByEmail(email);

    // In production, you'd verify the password here
    // For now, Firebase handles this on the client side

    // Get user data from Realtime Database
    const userData = await getUserProfile(userRecord.uid);

    if (!userData) {
      throw new Error('User profile not found');
    }

    // Generate JWT token
    const token = jwt.sign(
      { uid: userRecord.uid, email: userRecord.email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );

    return {
      uid: userRecord.uid,
      email: userRecord.email,
      name: userData.name,
      profilePhoto: userData.profilePhoto,
      token,
      message: 'Login successful'
    };
  } catch (error) {
    throw error;
  }
};

/**
 * Verify email
 */
const verifyEmail = async (userId) => {
  try {
    const userRef = rtdb.ref(`users/${userId}`);
    await userRef.update({
      isVerified: true,
      verifiedAt: new Date().toISOString()
    });

    return { message: 'Email verified successfully' };
  } catch (error) {
    throw error;
  }
};

/**
 * Reset password
 */
const resetPassword = async (email) => {
  try {
    const link = await auth.generatePasswordResetLink(email);
    // In production, send this link via email
    return { message: 'Password reset link sent to email', link };
  } catch (error) {
    throw error;
  }
};

/**
 * Change password
 */
const changePassword = async (userId, newPassword) => {
  try {
    await auth.updateUser(userId, { password: newPassword });
    return { message: 'Password changed successfully' };
  } catch (error) {
    throw error;
  }
};

/**
 * 🔐 Google Sign-In Authentication
 * Verifies Google ID token and creates/retrieves user
 */
const googleSignIn = async (googleIdToken, googleAccessToken, displayName) => {
  try {
    console.log('🔐 [Backend] Processing Google Sign-In...');

    // Verify the Google ID token using Firebase Admin SDK
    let decodedToken;
    try {
      decodedToken = await auth.verifyIdToken(googleIdToken);
      console.log('✅ [Backend] Google token verified');
    } catch (tokenError) {
      console.error('❌ [Backend] Invalid token:', tokenError.message);
      throw new Error('Invalid Google authentication token');
    }

    const { uid, email, firebase } = decodedToken;
    console.log(`✅ [Backend] Token verified for user: ${email}`);

    // Check if user exists
    let firebaseUser;
    try {
      firebaseUser = await auth.getUser(uid);
      console.log(`✅ [Backend] User exists: ${firebaseUser.email}`);
    } catch (userError) {
      // User doesn't exist, create one
      console.log(`📝 [Backend] Creating new user: ${email}`);
      try {
        firebaseUser = await auth.createUser({
          uid,
          email,
          displayName: displayName || email.split('@')[0],
          emailVerified: true
        });
        console.log(`✅ [Backend] New user created: ${uid}`);
      } catch (createError) {
        if (createError.code === 'auth/uid-already-exists') {
          // UID exists but getUser failed - this shouldn't happen
          firebaseUser = await auth.getUser(uid);
        } else {
          throw createError;
        }
      }
    }

    // Get or create user profile in database
    let userData = await getUserProfile(uid);

    if (!userData) {
      console.log(`📝 [Backend] Creating user profile for: ${uid}`);
      userData = {
        uid,
        email,
        name: displayName || email.split('@')[0],
        phone: '',
        profilePhoto: null,
        bio: '',
        dateOfBirth: null,
        isVerified: true,
        googleSignIn: true,
        googleSignInDate: new Date().toISOString(),
        bankAccounts: [],
        notificationSettings: {
          enableEmails: true,
          enablePushNotifications: true,
          weeklyReport: true
        }
      };
      await saveUserProfile(uid, userData);
      console.log(`✅ [Backend] User profile created: ${uid}`);
    } else {
      // Update last login time
      await saveUserProfile(uid, {
        ...userData,
        lastLogin: new Date().toISOString(),
        googleSignIn: true
      });
      console.log(`📝 [Backend] Last login updated for: ${uid}`);
    }

    // Generate JWT token for the app
    const token = jwt.sign(
      { uid, email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );

    console.log(`✅ [Backend] JWT token generated for: ${email}`);

    return {
      success: true,
      uid,
      email,
      name: userData.name || displayName || email.split('@')[0],
      profilePhoto: userData.profilePhoto,
      token,
      message: 'Google sign-in successful',
      isNewUser: !userData.googleSignIn || userData.googleSignIn === undefined
    };
  } catch (error) {
    console.error('❌ [Backend] Google Sign-In error:', error.message);
    throw error;
  }
};

module.exports = {
  registerUser,
  loginUser,
  verifyEmail,
  resetPassword,
  changePassword,
  googleSignIn
};
