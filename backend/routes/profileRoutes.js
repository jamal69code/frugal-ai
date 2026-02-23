const express = require('express');
const { validateProfileUpdate, validateBankAccount } = require('../middleware/validation');
const profileController = require('../controllers/profileController');
const upload = require('../middleware/uploadMiddleware');

const router = express.Router();

/**
 * Profile routes
 */
router.get('/', profileController.getProfile);
router.put('/', validateProfileUpdate, profileController.updateProfile);
router.post('/photo', upload.single('photo'), profileController.uploadProfilePhoto);
router.delete('/photo', profileController.deleteProfilePhoto);

/**
 * Bank account routes
 */
router.get('/banks', profileController.getBankAccounts);
router.post('/banks', validateBankAccount, profileController.addBankAccount);
router.put('/banks/:accountId', profileController.updateBankAccount);
router.delete('/banks/:accountId', profileController.deleteBankAccount);

module.exports = router;
