const express = require('express');
const { validateTransaction } = require('../middleware/validation');
const transactionController = require('../controllers/transactionController');

const router = express.Router();

/**
 * Transaction routes
 */
router.get('/', transactionController.getTransactions);
router.post('/', validateTransaction, transactionController.addTransaction);
router.get('/summary', transactionController.getTransactionSummary);
router.get('/:transactionId', transactionController.getTransactionById);
router.put('/:transactionId', transactionController.updateTransaction);
router.delete('/:transactionId', transactionController.deleteTransaction);

module.exports = router;
