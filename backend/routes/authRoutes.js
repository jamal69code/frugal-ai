const express = require('express');
const { validateRegister, validateLogin } = require('../middleware/validation');
const authController = require('../controllers/authController');
const { verify } = require('../middleware/authMiddleware');

const router = express.Router();

/**
 * Public routes
 */
router.post('/register', validateRegister, authController.register);
router.post('/login', validateLogin, authController.login);
router.post('/forgot-password', authController.requestPasswordReset);
router.post('/google-signin', authController.googleSignIn);

/**
 * Protected routes
 */
router.post('/verify-email', verify, authController.verifyEmail);
router.post('/change-password', verify, authController.changePassword);

module.exports = router;
