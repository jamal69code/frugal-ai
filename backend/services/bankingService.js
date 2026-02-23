const axios = require('axios');
const { db } = require('../config/firebase');
const { v4: uuidv4 } = require('uuid');

// Plaid API client
const plaidClient = axios.create({
  baseURL: 'https://api.plaid.com',
  timeout: 10000
});

/**
 * Create Plaid link token for bank connection
 */
const createPlaidLinkToken = async (userId) => {
  try {
    const response = await plaidClient.post('/link/token/create', {
      user: { client_user_id: userId },
      client_name: 'Frugal AI',
      language: 'en',
      country_codes: ['US'],
      products: ['auth', 'transactions'],
      client_id: process.env.PLAID_CLIENT_ID,
      secret: process.env.PLAID_SECRET
    });

    return { linkToken: response.data.link_token };
  } catch (error) {
    console.error('Plaid error:', error.response?.data || error.message);
    throw new Error('Failed to create Plaid link token');
  }
};

/**
 * Exchange Plaid public token for access token
 */
const exchangePlaidToken = async (userId, publicToken) => {
  try {
    const response = await plaidClient.post('/item/public_token/exchange', {
      client_id: process.env.PLAID_CLIENT_ID,
      secret: process.env.PLAID_SECRET,
      public_token: publicToken
    });

    const accessToken = response.data.access_token;
    const itemId = response.data.item_id;

    // Store in Firestore
    await db.collection('plaidItems').add({
      userId,
      accessToken,
      itemId,
      createdAt: new Date(),
      lastSync: null
    });

    return { itemId, message: 'Bank connected successfully' };
  } catch (error) {
    console.error('Plaid exchange error:', error.response?.data || error.message);
    throw new Error('Failed to connect bank account');
  }
};

/**
 * Get bank transactions from Plaid
 */
const getBankTransactions = async (userId, accessToken, startDate, endDate) => {
  try {
    const response = await plaidClient.post('/transactions/get', {
      client_id: process.env.PLAID_CLIENT_ID,
      secret: process.env.PLAID_SECRET,
      access_token: accessToken,
      start_date: startDate,
      end_date: endDate
    });

    return response.data.transactions;
  } catch (error) {
    console.error('Plaid transactions error:', error.response?.data || error.message);
    throw new Error('Failed to fetch transactions');
  }
};

/**
 * Get connected banks
 */
const getConnectedBanks = async (userId) => {
  try {
    const snapshot = await db.collection('plaidItems')
      .where('userId', '==', userId)
      .get();

    const banks = [];
    snapshot.forEach(doc => {
      banks.push({
        id: doc.id,
        ...doc.data(),
        accessToken: undefined // Don't expose access token
      });
    });

    return banks;
  } catch (error) {
    throw error;
  }
};

/**
 * Sync bank transactions
 */
const syncBankTransactions = async (userId) => {
  try {
    const plaidSnapshot = await db.collection('plaidItems')
      .where('userId', '==', userId)
      .get();

    let totalSynced = 0;

    for (const doc of plaidSnapshot.docs) {
      const { accessToken } = doc.data();
      const endDate = new Date().toISOString().split('T')[0];
      const startDate = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

      const transactions = await getBankTransactions(userId, accessToken, startDate, endDate);

      for (const transaction of transactions) {
        // Create transaction record
        await db.collection('bankTransactions').add({
          userId,
          transactionId: uuidv4(),
          plaidId: transaction.transaction_id,
          amount: transaction.amount,
          merchant: transaction.merchant_name || transaction.name,
          date: transaction.date,
          category: transaction.personal_finance_category?.primary || 'Other',
          description: transaction.name,
          status: 'synced',
          createdAt: new Date()
        });

        totalSynced++;
      }

      // Update last sync time
      await doc.ref.update({ lastSync: new Date() });
    }

    return { synced: totalSynced, message: `${totalSynced} transactions synced` };
  } catch (error) {
    console.error('Sync error:', error);
    throw error;
  }
};

/**
 * Disconnect bank account
 */
const disconnectBank = async (userId, bankId) => {
  try {
    const doc = await db.collection('plaidItems').doc(bankId).get();

    if (!doc.exists || doc.data().userId !== userId) {
      throw new Error('Bank account not found');
    }

    await doc.ref.delete();
    return { message: 'Bank account disconnected' };
  } catch (error) {
    throw error;
  }
};

module.exports = {
  createPlaidLinkToken,
  exchangePlaidToken,
  getBankTransactions,
  getConnectedBanks,
  syncBankTransactions,
  disconnectBank
};
