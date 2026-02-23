require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const helmet = require('helmet');
const path = require('path');

// Import Firebase and database service
const { rtdb } = require('./config/firebase');
const { initializeDatabaseStructure } = require('./services/databaseService');

// Import routes
const authRoutes = require('./routes/authRoutes');
const profileRoutes = require('./routes/profileRoutes');
const transactionRoutes = require('./routes/transactionRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const bankingRoutes = require('./routes/bankingRoutes');

// Import middleware
const { verify } = require('./middleware/authMiddleware');
const errorHandler = require('./middleware/errorHandler');

// Initialize Express app
const app = express();

// Security middleware
app.use(helmet());

// CORS configuration - Allow all origins in development
const corsOptions = {
  origin: function(origin, callback) {
    // Allow requests from mobile apps and all localhost variants
    const allowedOrigins = [
      'http://localhost:3000',
      'http://localhost:8080',
      'http://localhost:5000',
      'http://localhost:5001',
      'http://10.0.2.2:5001', // Android emulator
      'http://127.0.0.1:5001',
    ];
    
    // In development, allow all origins
    if (process.env.NODE_ENV === 'demo' || process.env.NODE_ENV === 'development') {
      callback(null, true);
    } else if (allowedOrigins.includes(origin) || !origin) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  optionsSuccessStatus: 200,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

app.use(cors(corsOptions));

// Body parser middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Logging middleware
app.use(morgan('combined'));

// Static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'Server is running', 
    timestamp: new Date(),
    environment: process.env.NODE_ENV,
    port: process.env.PORT
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/profile', verify, profileRoutes);
app.use('/api/transactions', verify, transactionRoutes);
app.use('/api/notifications', verify, notificationRoutes);
app.use('/api/banking', verify, bankingRoutes);

// 404 handler
// app.use((req, res) => {
//   res.status(404).json({ error: 'Route not found' });
// });
app.get("/", (req, res) => {
  res.json({
    message: "Frugal AI Backend Running 🚀",
    status: "OK"
  });
});

// Error handling middleware
app.use(errorHandler);

// Start server
// const PORT = 5001;
// app.listen(PORT, async () => {
//   console.log(`✅ Server running on http://localhost:${PORT}`);
//   console.log(`📝 Environment: ${process.env.NODE_ENV}`);
// const PORT = 5001;

// app.listen(PORT, '0.0.0.0',  () => {
//   console.log(`✅ Server running on http://localhost:${PORT}`);
//   console.log(`📝 Environment: ${process.env.NODE_ENV}`);
// });
  
//   // Initialize database structure if using production
//   if (process.env.NODE_ENV === 'production') {
//     try {
//       await initializeDatabaseStructure();
//     } catch (error) {
//       console.log('Database initialization failed - continuing with server startup');
//     }
//   }
const PORT = 5001;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
  console.log(`📝 Environment: ${process.env.NODE_ENV}`);

  if (process.env.NODE_ENV === 'production') {
    initializeDatabaseStructure()
      .then(() => console.log('Database initialized'))
      .catch(() =>
        console.log('Database initialization failed - continuing with server startup')
      );
  }
});


module.exports = app;
