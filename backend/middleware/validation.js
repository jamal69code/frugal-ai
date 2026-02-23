const { body, validationResult } = require('express-validator');

/**
 * Validation error handler
 */
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

/**
 * User registration validation
 */
const validateRegister = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  body('confirmPassword').custom((value, { req }) => value === req.body.password).withMessage('Passwords do not match'),
  body('name').trim().notEmpty().withMessage('Name is required'),
  body('phone').optional().isMobilePhone(),
  validate
];

/**
 * User login validation
 */
const validateLogin = [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
  validate
];

/**
 * Profile update validation
 */
const validateProfileUpdate = [
  body('name').optional().trim().notEmpty(),
  body('phone').optional().isMobilePhone(),
  body('bio').optional().trim(),
  body('dateOfBirth').optional().isISO8601(),
  validate
];

/**
 * Transaction validation
 */
const validateTransaction = [
  body('amount').isFloat({ gt: 0 }).withMessage('Amount must be greater than 0'),
  body('category').notEmpty().withMessage('Category is required'),
  body('type').isIn(['income', 'expense']).withMessage('Type must be income or expense'),
  body('description').optional().trim(),
  body('date').isISO8601().withMessage('Valid date is required'),
  validate
];

/**
 * Banking validation
 */
const validateBankAccount = [
  body('accountName').notEmpty(),
  body('accountNumber').notEmpty(),
  body('bankName').notEmpty(),
  body('accountType').isIn(['checking', 'savings', 'credit']).withMessage('Invalid account type'),
  validate
];

module.exports = {
  validate,
  validateRegister,
  validateLogin,
  validateProfileUpdate,
  validateTransaction,
  validateBankAccount
};
