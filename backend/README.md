# Khata Book Backend API

A PHP REST API backend for the Khata Book Flutter application, using Aiven MySQL database.

## Setup Instructions

### 1. Environment Configuration

1. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file and add your Aiven MySQL credentials:
   ```
   DB_HOST=khatabook-adit-ef94.j.aivencloud.com
   DB_PORT=10570
   DB_USER=avnadmin
   DB_PASSWORD=your_actual_password_here
   DB_NAME=defaultdb
   DB_SSL_MODE=REQUIRED
   ```

### 2. Database Setup

1. Download the CA certificate from your Aiven dashboard
2. Place it in the `config/` folder (e.g., `config/ca-cert.pem`)
3. Update the path in `config/database.php` if necessary

2. Connect to your Aiven MySQL database and run the SQL commands from `schema.sql`:
   ```sql
   -- Copy and paste the contents of schema.sql
   ```

### 3. Web Server Configuration

This API is designed to work with any PHP-compatible web server. Here are configurations for common servers:

#### Apache (.htaccess)
```apache
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ api/index.php [QSA,L]
```

#### Nginx
```nginx
location /api {
    try_files $uri $uri/ /api/index.php?$query_string;
}
```

### 4. API Endpoints

#### Users

- `GET /api/users` - Get all users
- `GET /api/users/{id}` - Get user by ID (includes balance)
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user

#### Transactions

- `GET /api/transactions` - Get all transactions
- `GET /api/transactions/{id}` - Get transaction by ID
- `GET /api/transactions?user_id={id}` - Get transactions for specific user
- `GET /api/transactions?start_date=2024-01-01&end_date=2024-01-31` - Get transactions by date range
- `GET /api/transactions?summary=1` - Get summary statistics
- `POST /api/transactions` - Create new transaction
- `PUT /api/transactions/{id}` - Update transaction
- `DELETE /api/transactions/{id}` - Delete transaction

### 5. Request/Response Format

All API responses are in JSON format:

```json
{
  "success": true,
  "data": {...},
  "message": "Optional message"
}
```

#### Create User Request
```json
{
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "address": "123 Main St"
}
```

#### Create Transaction Request
```json
{
  "user_id": 1,
  "type": "credit",
  "amount": 100.00,
  "description": "Payment received",
  "date": "2024-01-15 10:00:00"
}
```

### 6. Flutter Integration

Use the following Dart code to connect to the API:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = 'http://your-server.com/api';

  Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> createUser(String name, String phone, {String? email, String? address}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create user');
    }
  }
}
```

### 7. Security Notes

- This is a basic implementation. For production use, consider adding:
  - Authentication (JWT tokens)
  - Input validation and sanitization
  - Rate limiting
  - HTTPS enforcement
  - API versioning

### 8. Troubleshooting

- **Database connection errors**: Verify your `.env` credentials and SSL certificate path
- **CORS errors**: Check that CORS headers are properly set in the API responses
- **404 errors**: Ensure your web server is configured to route requests to `index.php`

## Project Structure

```
backend/
├── config/
│   └── database.php          # Database connection configuration
├── models/
│   ├── User.php             # User model
│   └── Transaction.php      # Transaction model
├── controllers/
│   ├── UserController.php   # User API endpoints
│   └── TransactionController.php # Transaction API endpoints
├── routes/
│   └── api.php              # API routing
├── index.php                # Main entry point
├── schema.sql               # Database schema
├── .env.example             # Environment template
└── README.md                # This file
```