# Frugal AI Backend

Complete Node.js backend for Frugal AI Flutter application with Firebase integration, Plaid banking API, and comprehensive notification system.

## Features

- **Authentication**: User registration, login, password reset
- **Profile Management**: User profiles with photo uploads
- **Transaction Tracking**: Add, update, and retrieve transactions
- **Banking Integration**: Plaid API for bank account connections
- **Notifications**: Push notifications, email notifications, in-app notifications
- **Security**: JWT authentication, input validation, error handling

## Project Structure

```
backend/
├── config/              # Configuration files (Firebase)
├── controllers/         # Business logic handlers
├── middleware/          # Authentication, validation, error handling
├── models/              # Data models (if using database)
├── routes/              # API routes
├── services/            # Business logic and external API calls
├── utils/               # Helper functions
├── server.js            # Entry point
├── package.json         # Dependencies
└── .env.example         # Environment variables template
```

## Installation

1. **Clone the repository**
   ```bash
   cd backend
   npm install
   ```

2. **Configure Firebase**
   - Get your Firebase credentials from Firebase Console
   - Create `.env` file from `.env.example`
   - Add your Firebase and Plaid credentials

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Start the server**
   ```bash
   # Development (with auto-reload)
   npm run dev

   # Production
   npm start
   ```

Server will run on `http://localhost:5000`

## Environment Variables

```env
# Firebase
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_PRIVATE_KEY="your-private-key"
FIREBASE_CLIENT_EMAIL=your_client_email

# Server
PORT=5000
NODE_ENV=development
JWT_SECRET=your-secret-key

# Email (Nodemailer)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# Plaid Banking API
PLAID_CLIENT_ID=your_plaid_client_id
PLAID_SECRET=your_plaid_secret
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/verify-email` - Verify email
- `POST /api/auth/change-password` - Change password

### Profile
- `GET /api/profile` - Get user profile
- `PUT /api/profile` - Update profile
- `POST /api/profile/photo` - Upload profile photo
- `DELETE /api/profile/photo` - Delete profile photo

### Bank Accounts
- `GET /api/profile/banks` - Get bank accounts
- `POST /api/profile/banks` - Add bank account
- `PUT /api/profile/banks/:accountId` - Update bank account
- `DELETE /api/profile/banks/:accountId` - Delete bank account

### Transactions
- `GET /api/transactions` - Get all transactions
- `POST /api/transactions` - Add transaction
- `GET /api/transactions/summary` - Get transaction summary
- `GET /api/transactions/:transactionId` - Get transaction details
- `PUT /api/transactions/:transactionId` - Update transaction
- `DELETE /api/transactions/:transactionId` - Delete transaction

### Banking
- `POST /api/banking/link-token` - Create Plaid link token
- `POST /api/banking/exchange-token` - Exchange public token
- `GET /api/banking/banks` - Get connected banks
- `POST /api/banking/sync` - Sync bank transactions
- `DELETE /api/banking/banks/:bankId` - Disconnect bank

### Notifications
- `POST /api/notifications/fcm-token` - Register FCM token
- `GET /api/notifications` - Get notifications
- `PUT /api/notifications/:notificationId/read` - Mark as read
- `DELETE /api/notifications` - Clear all notifications

## Authentication

All protected endpoints require JWT token in Authorization header:

```
Authorization: Bearer <token>
```

## Error Handling

Consistent error responses:

```json
{
  "error": "Error message",
  "status": 400
}
```

## Database Schema (Firestore)

### Users Collection
```
users/
├── uid/
│   ├── email
│   ├── name
│   ├── phone
│   ├── profilePhoto
│   ├── bio
│   ├── dateOfBirth
│   ├── bankAccounts
│   ├── fcmTokens
│   ├── notificationSettings
│   ├── createdAt
│   └── updatedAt
```

### Transactions Collection
```
transactions/
├── userId
├── transactionId
├── amount
├── category
├── type (income/expense)
├── description
├── date
├── status
├── createdAt
└── updatedAt
```

### Notifications Collection
```
notifications/
├── notificationId
├── userId
├── type (transaction/banking)
├── title
├── body
├── data
├── read
├── createdAt
└── timestamp
```

## Flutter Integration

Import the services in your Flutter app:

```dart
import 'package:frugal_ai/services/auth_service.dart';
import 'package:frugal_ai/services/profile_service.dart';
import 'package:frugal_ai/services/transaction_service.dart';
import 'package:frugal_ai/services/banking_service.dart';
import 'package:frugal_ai/services/notification_service.dart';
```

### Example Usage

```dart
// Register user
final response = await AuthService.register(
  email: 'user@example.com',
  password: 'password123',
  confirmPassword: 'password123',
  name: 'John Doe',
);

// Add transaction
await TransactionService.addTransaction(
  amount: 50.0,
  category: 'Groceries',
  type: 'expense',
  date: DateTime.now(),
);

// Connect bank
await BankingService.createLinkToken();
```

## Security Best Practices

1. **Environment Variables**: Never commit `.env` file
2. **JWT Secret**: Use strong, unique secret in production
3. **HTTPS**: Always use HTTPS in production
4. **Input Validation**: All inputs are validated
5. **Error Handling**: Never expose sensitive error information

## Testing

Run tests with:
```bash
npm test
```

## Deployment

### Firebase Deployment
```bash
firebase deploy --only functions
```

### Heroku Deployment
```bash
heroku create frugal-ai-backend
git push heroku main
```

### Docker Deployment
```bash
docker build -t frugal-ai-backend .
docker run -p 5000:5000 frugal-ai-backend
```

## Contributing

1. Create feature branch
2. Commit changes
3. Push to branch
4. Create Pull Request

## Support

For issues and questions, please open an issue on GitHub.

## License

MIT License - see LICENSE file for details
