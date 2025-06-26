# KhataBook Clone Backend

A comprehensive PHP backend API for the KhataBook Clone digital ledger application.

## Features

- **User Authentication**: JWT-based authentication with secure login/register
- **Customer Management**: CRUD operations for customer data
- **Transaction Management**: Credit/debit transaction handling
- **Reports & Analytics**: Balance reports, summaries, and customer reports
- **Security**: Input validation, SQL injection protection, CORS handling
- **RESTful API**: Clean and organized API endpoints

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Users
- `GET /api/users` - Get current user profile
- `GET /api/users/{id}` - Get specific user
- `PUT /api/users/{id}` - Update user profile
- `DELETE /api/users/{id}` - Delete user account

### Customers
- `GET /api/customers` - Get all customers
- `GET /api/customers/{id}` - Get specific customer
- `POST /api/customers` - Create new customer
- `PUT /api/customers/{id}` - Update customer
- `DELETE /api/customers/{id}` - Delete customer

### Transactions
- `GET /api/transactions` - Get all transactions (with filters)
- `GET /api/transactions/{id}` - Get specific transaction
- `POST /api/transactions` - Create new transaction
- `PUT /api/transactions/{id}` - Update transaction
- `DELETE /api/transactions/{id}` - Delete transaction

### Reports
- `GET /api/reports/balance` - Get balance report
- `GET /api/reports/summary` - Get transaction summary
- `GET /api/reports/customer` - Get customer-specific report

## Setup Instructions

1. **Install Dependencies**
   ```bash
   cd backend
   composer install
   ```

2. **Environment Configuration**
   ```bash
   cp .env.example .env
   # Edit .env with your database credentials
   ```

3. **Database Setup**
   ```bash
   mysql -u username -p
   CREATE DATABASE khatabook_db;
   mysql -u username -p khatabook_db < database/schema.sql
   ```

4. **Web Server Configuration**
   - Point document root to `backend/` directory
   - Enable URL rewriting for clean URLs
   - Ensure PHP 8.0+ is installed

## Environment Variables

```env
DB_HOST=localhost
DB_NAME=khatabook_db
DB_USER=your_username
DB_PASS=your_password
JWT_SECRET=your_secret_key_here
JWT_EXPIRE_TIME=3600
BCRYPT_COST=12
```

## Security Features

- JWT token-based authentication
- Password hashing with bcrypt
- Input validation and sanitization
- SQL injection prevention
- CORS handling
- Rate limiting ready

## Testing

Sample data is included in the schema for testing purposes:
- Test user: `john@example.com` / `password123`
- Pre-populated customers and transactions

## API Response Format

```json
{
  "success": true,
  "message": "Success message",
  "data": { ... }
}
```

Error responses:
```json
{
  "success": false,
  "error": "Error message",
  "details": [ ... ]
}
```
