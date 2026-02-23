const express = require('express');
const bankingController = require('../controllers/bankingController');

const router = express.Router();

/**
 * Banking routes
 */
router.post('/link-token', bankingController.createLinkToken);
router.post('/exchange-token', bankingController.exchangePublicToken);
router.get('/banks', bankingController.getConnectedBanks);
router.post('/sync', bankingController.syncTransactions);
router.delete('/banks/:bankId', bankingController.disconnectBank);

module.exports = router;
