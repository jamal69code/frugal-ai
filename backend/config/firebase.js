const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK
const firebaseConfig = {
  projectId: process.env.FIREBASE_PROJECT_ID,
  privateKeyId: process.env.FIREBASE_PRIVATE_KEY_ID,
  privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
  clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
  clientId: process.env.FIREBASE_CLIENT_ID,
  authUri: process.env.FIREBASE_AUTH_URI,
  tokenUri: process.env.FIREBASE_TOKEN_URI,
  authProviderX509CertUrl: process.env.FIREBASE_AUTH_PROVIDER_X509_CERT_URL,
  clientX509CertUrl: process.env.FIREBASE_CLIENT_X509_CERT_URL,
};

// Mock Firebase objects for demo mode
const mockDb = {
  collection: () => ({
    doc: () => ({
      set: async (data) => data,
      get: async () => ({ data: () => ({}), exists: false }),
      update: async (data) => data,
      delete: async () => true,
    }),
    add: async (data) => ({ id: 'mock-' + Date.now() }),
    where: () => ({
      get: async () => ({ docs: [] }),
    }),
    get: async () => ({ docs: [] }),
  }),
};

const mockAuth = {
  createUser: async (data) => ({ uid: 'mock-' + Date.now(), ...data }),
  getUser: async (uid) => ({ uid, email: 'demo@example.com' }),
  getUserByEmail: async (email) => ({ uid: 'mock-user-123', email, emailVerified: false }),
  updateUser: async (uid, data) => ({ uid, ...data }),
  deleteUser: async (uid) => true,
  signInWithEmailAndPassword: async (email, password) => ({ user: { uid: 'mock-uid' } }),
  setCustomUserClaims: async (uid, claims) => true,
  generatePasswordResetLink: async (email) => 'https://example.com/reset?token=mock',
};

const mockStorage = {
  bucket: () => ({
    file: (path) => ({
      save: async (data) => true,
      delete: async () => true,
      download: async () => [Buffer.from('demo')],
    }),
  }),
};

const mockMessaging = {
  send: async (message) => 'mock-message-id',
  sendMulticast: async (message) => ({ successCount: 1 }),
  sendAll: async (messages) => ({ successCount: messages.length }),
};

// Initialize Firebase Admin (or use mocks in demo mode)
let db, auth, storage, messaging, rtdb;

if (process.env.NODE_ENV === 'demo' || !process.env.FIREBASE_PRIVATE_KEY || process.env.FIREBASE_PRIVATE_KEY.includes('DEMO_KEY')) {
  console.log('🎭 Running in DEMO MODE - Using mock Firebase services');
  db = mockDb;
  auth = mockAuth;
  storage = mockStorage;
  messaging = mockMessaging;
  rtdb = {
    ref: (path) => ({
      set: async (data) => data,
      update: async (data) => data,
      push: async (data) => ({ key: 'mock-' + Date.now() }),
      once: async () => ({ val: () => {} }),
      on: (event, callback) => {},
      off: (event, callback) => {},
    }),
  };
} else {
  if (!admin.apps.length) {
    admin.initializeApp({
      credential: admin.credential.cert(firebaseConfig),
      storageBucket: `${process.env.FIREBASE_PROJECT_ID}.appspot.com`,
      databaseURL: process.env.FIREBASE_RTDB_URL,
    });
    console.log('✅ Firebase initialized successfully');
  }
  db = admin.firestore();
  auth = admin.auth();
  storage = admin.storage();
  messaging = admin.messaging();
  rtdb = admin.database();
}

module.exports = {
  admin,
  db,
  auth,
  storage,
  messaging,
  rtdb,
  firebaseConfig
};
