const authService = require('../services/authService');

/**
 * Register
 */
exports.register = async (req, res, next) => {
  try {
    const { email, password, confirmPassword, name, phone } = req.body;

    if (password !== confirmPassword) {
      return res.status(400).json({ error: 'Passwords do not match' });
    }

    const result = await authService.registerUser({
      email,
      password,
      name,
      phone
    });

    res.status(201).json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Login
 */
exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const result = await authService.loginUser(email, password);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Verify email
 */
exports.verifyEmail = async (req, res, next) => {
  try {
    const userId = req.userId;
    const result = await authService.verifyEmail(userId);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Request password reset
 */
exports.requestPasswordReset = async (req, res, next) => {
  try {
    const { email } = req.body;
    const result = await authService.resetPassword(email);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Change password
 */
exports.changePassword = async (req, res, next) => {
  try {
    const userId = req.userId;
    const { newPassword } = req.body;

    const result = await authService.changePassword(userId, newPassword);

    res.json({
      success: true,
      data: result
    });
  } catch (error) {
    next(error);
  }
};

/**
 * 🔐 Google Sign-In Authentication
 * Verifies Google token and authenticates user
 */
exports.googleSignIn = async (req, res, next) => {
  try {
    console.log('🔐 [Backend] Received Google Sign-In request');
    
    const { idToken, accessToken, displayName } = req.body;

    if (!idToken) {
      return res.status(400).json({
        success: false,
        error: 'Missing Google ID token'
      });
    }

    console.log(`🔐 [Backend] Processing tokens from client...`);

    const result = await authService.googleSignIn(idToken, accessToken, displayName);

    console.log(`✅ [Backend] Google Sign-In successful for: ${result.email}`);

    res.status(200).json({
      success: true,
      data: result
    });
  } catch (error) {
    console.error('❌ [Backend] Google Sign-In controller error:', error.message);
    res.status(401).json({
      success: false,
      error: error.message || 'Google authentication failed'
    });
  }
};
