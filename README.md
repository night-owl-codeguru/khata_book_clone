# KhataBook Clone - Digital Ledger Application

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)](https://golang.org/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://mysql.com/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=for-the-badge)](CONTRIBUTING.md)

> A comprehensive digital ledger application that revolutionizes how small businesses and individuals manage their financial transactions, customer relationships, and business records.

**KhataBook Clone** is a production-ready, full-stack solution built with Flutter for cross-platform frontend and Go for the backend API, designed to replace traditional paper-based accounting with a modern, secure, and feature-rich digital platform.

## Project Overview

**KhataBook Clone** is a modern digital accounting solution specifically designed for small businesses, shopkeepers, freelancers, and service providers. It eliminates the hassle of maintaining paper ledgers by providing a comprehensive platform for tracking customer transactions, managing credit/debit records, generating insightful reports, and maintaining customer relationships.

### Why Choose KhataBook Clone?

- **Real-time Transaction Management** - Instant credit/debit tracking with live balance updates
- **Smart Customer Management** - Comprehensive customer profiles with payment history
- **Advanced Analytics** - Detailed reports and business insights
- **Intelligent Notifications** - Automated reminders and payment alerts
- **Enterprise Security** - Bank-level security with data encryption
- **Cross-Platform** - Works seamlessly on Android, iOS, and Web
- **Cloud Sync** - Real-time data synchronization across all devices
- **Offline Support** - Continue working even without internet connectivity

### Key Differentiators

- **User-Centric Design**: Intuitive interface designed for non-technical users
- **Scalable Architecture**: Handles everything from small shops to medium enterprises  
- **Customizable Reports**: Generate reports tailored to your business needs
- **Multi-Language Support**: Supports regional languages for wider accessibility
- **Voice Commands**: Add transactions using voice input for faster data entry
- **WhatsApp Integration**: Send payment reminders directly through WhatsApp

## Current Features

### Transaction Management
- Complete Credit/Debit Entries - Record money given (credit) or received (debit) with timestamps
- Transaction Categories - Organize by supplies, services, personal expenses, etc.
- Transaction Search & Filter - Advanced filtering by amount, date, customer, category
- Complete Transaction History - Detailed timeline with edit/delete capabilities
- Receipt Management - Attach photos of bills, receipts, and invoices
- Bulk Operations - Mass import/export transactions via CSV

### Customer Management
- Detailed Customer Profiles - Store contact info, addresses, and preferences
- Real-time Balance Tracking - Live credit/debit balance calculations
- Customer Categorization - Organize by VIP, regular, wholesale, retail
- Payment History - Complete transaction timeline per customer
- Credit Limit Management - Set and monitor customer credit limits
- Contact Integration - Sync with device contacts for easy management

### Reports & Analytics
- Balance Summary Dashboard - Overall business health at a glance
- Customer-wise Reports - Individual balance and transaction analysis
- Date Range Reports - Daily, weekly, monthly, yearly breakdowns
- Category Analysis - Transaction breakdown by business categories
- Payment Due Tracking - Monitor overdue payments and aging reports
- Export Functionality - Generate PDF and Excel reports

### Security & Authentication
- JWT-based Authentication - Secure login with token management
- Data Encryption - All sensitive data encrypted at rest and in transit
- Role-based Access - Different permission levels for team members
- Session Management - Automatic logout and security controls
- API Rate Limiting - Protection against abuse and unauthorized access

## Authentication System

The application includes a complete authentication system connecting Flutter frontend with PHP backend:

### Features
- **User Registration** - Sign up with name, phone, email, and password
- **Secure Login** - JWT-based authentication with password hashing
- **Token Management** - Automatic token storage and validation
- **Protected Routes** - Middleware for securing API endpoints
- **Session Persistence** - Maintain login state across app restarts
- **Logout Functionality** - Secure token cleanup

#### Backend Testing
```bash
# Run Go tests
go test ./...

# Run tests with coverage
go test -cover ./...

# Run specific package tests
go test ./handlers

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

### Frontend Authentication Setup

1. **Install Dependencies**
   ```bash
   cd frontend
   flutter pub get
   ```

2. **Configure API URL**
   ```dart
   // lib/services/auth_service.dart
   static const String _baseUrl = 'http://your-backend-url/api';
   ```

3. **Authentication Flow**
   - App checks authentication status on startup
   - Redirects to login/signup if not authenticated
   - Maintains session with JWT tokens
   - Automatic logout on token expiry

### Usage Example

```dart
// Login user
final result = await AuthService.login('user@example.com', 'password');
if (result['success']) {
  // Navigate to home screen
  context.go('/home');
}

// Check authentication status
final status = await AuthService.getAuthStatus();
if (status == AuthStatus.authenticated) {
  // User is logged in
}
```

### Security Features

- **Password Hashing** - Bcrypt with cost factor 12
- **JWT Tokens** - Secure token generation with expiry
- **Input Validation** - Server-side validation for all inputs
- **SQL Injection Protection** - Prepared statements
- **CORS Configuration** - Proper cross-origin handling
- **Token Validation** - Middleware for protected routes

### Business Operations
- Multi-device Sync - Real-time synchronization across devices
- Offline Mode - Continue working without internet connectivity
- Dark/Light Themes - Customizable interface for user preference
- Responsive Design - Optimized for mobile, tablet, and desktop
- RESTful API - Clean, documented API for integrations

## Upcoming Features (Roadmap)

### Enhanced User Experience
- Voice Command Integration - Add transactions using voice recognition
- Advanced Theming - Custom color schemes and branding options
- Multi-language Support - Support for Hindi, Gujarati, Marathi, Tamil, and more
- Smart Search - AI-powered search with auto-suggestions
- Widget Support - Quick actions from home screen widgets
- Quick Actions Menu - Speed dial for frequent operations

### Smart Notifications & Reminders
- Automated Payment Reminders - Smart scheduling based on customer behavior
- WhatsApp Integration - Send payment reminders via WhatsApp Business API
- SMS Notifications - Automated SMS alerts for payment dues
- Daily/Weekly Summaries - Business performance digest emails
- Low Balance Alerts - Notifications for negative balance thresholds
- Milestone Notifications - Customer achievement and anniversary alerts

### Advanced Analytics & AI
- AI-Powered Insights - Predictive analytics for cash flow forecasting
- Business Intelligence Dashboard - Advanced charts and trend analysis
- Recommendation Engine - Suggest optimal credit limits and payment terms
- Customer Segmentation - Automatic categorization based on behavior
- Profit/Loss Projections - AI-driven financial forecasting
- Seasonal Pattern Analysis - Identify business cycles and trends

### Financial Management
- Invoice Generation - Professional invoice creation and sharing
- Bank Account Integration - Connect with bank APIs for automatic reconciliation
- Digital Payment Links - Generate payment links for customers
- Tax Management - GST calculations and compliance reporting
- Multi-currency Support - Handle international transactions
- Budget Planning - Set and track business budgets

### Enterprise Features
- Multi-business Management - Handle multiple business entities
- Advanced User Roles - Granular permissions for team members
- Inventory Integration - Basic stock management and tracking
- Third-party Integrations - Connect with popular accounting software
- Mobile POS System - Point-of-sale functionality for retail
- API Marketplace - Developer ecosystem for custom integrations

### Cloud & Backup
- Cloud Backup & Restore - Automatic backup to Google Drive/iCloud
- Real-time Collaboration - Multiple users working simultaneously
- Web Dashboard - Full-featured web application
- Progressive Web App - Installable web app with offline capabilities
- Advanced Security - Two-factor authentication and biometric locks
- Marketplace Integration - Connect with e-commerce platforms

### Gamification & Engagement
- Achievement System - Badges for consistent usage and milestones
- Goal Setting - Set and track business objectives
- Progress Tracking - Visual progress indicators for targets
- Celebrations - Celebrate business milestones and achievements
- Referral Program - Reward users for bringing new customers
- Social Sharing - Share achievements on social media

### Developer & Integration
- Webhook Support - Real-time event notifications for integrations
- GraphQL API - Modern API with flexible data fetching
- A/B Testing Framework - Built-in feature flag and testing system
- Analytics SDK - Custom analytics for business intelligence
- Sync API - Robust synchronization with conflict resolution
- Plugin Architecture - Extensible system for custom features

## Technical Architecture

### Frontend Architecture (Flutter)
```
frontend/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── user.dart
│   │   ├── customer.dart
│   │   ├── transaction.dart
│   │   └── business.dart
│   ├── screens/                  # UI screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── customers/
│   │   │   ├── customer_list_screen.dart
│   │   │   └── add_customer_screen.dart
│   │   ├── transactions/
│   │   │   ├── transaction_list_screen.dart
│   │   │   └── add_transaction_screen.dart
│   │   ├── reports/
│   │   │   ├── balance_report_screen.dart
│   │   │   └── analytics_screen.dart
│   │   └── settings/
│   │       ├── profile_screen.dart
│   │       └── app_settings_screen.dart
│   ├── widgets/                  # Reusable components
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_dialog.dart
│   │   ├── transaction_card.dart
│   │   ├── customer_card.dart
│   │   └── balance_summary.dart
│   ├── services/                 # Business logic
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── database_service.dart
│   │   ├── notification_service.dart
│   │   └── sync_service.dart
│   ├── providers/                # State management
│   │   ├── auth_provider.dart
│   │   ├── customer_provider.dart
│   │   ├── transaction_provider.dart
│   │   └── theme_provider.dart
│   └── utils/                    # Utilities
│       ├── constants.dart
│       ├── helpers.dart
│       ├── validators.dart
│       └── date_utils.dart
├── assets/                       # Static assets
│   ├── images/
│   ├── icons/
│   └── fonts/
└── test/                         # Test files
    ├── unit/
    ├── widget/
    └── integration/
```

### Backend Architecture (Go)
```
backend/
├── main.go                     # Application entry point and server setup
├── go.mod                      # Go module definition
├── go.sum                      # Dependency checksums
├── .env                        # Environment variables
├── handlers/                   # HTTP request handlers
│   ├── auth.go                 # Authentication handlers (signup, login)
│   └── ...                     # Future handlers (users, transactions, etc.)
├── models/                     # Data models and structs
│   ├── user.go                 # User model and request/response types
│   └── ...                     # Future models
├── database/                   # Database connection and setup
│   └── db.go                   # MySQL connection and table creation
├── config/                     # Configuration management
│   └── config.go               # Configuration loading
├── middleware/                 # HTTP middleware
│   ├── cors.go                 # CORS handling
│   ├── auth.go                 # JWT authentication middleware
│   └── ...                     # Future middleware
└── utils/                      # Utility functions
    ├── jwt.go                  # JWT token generation and validation
    ├── validation.go           # Input validation helpers
    └── ...
```

### Database Schema

#### Core Tables

```sql
-- Users table
users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    profile_image VARCHAR(255) NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Customers table
customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NULL,
    address TEXT NULL,
    category VARCHAR(50) NULL,
    credit_limit DECIMAL(15,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Transactions table
transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    customer_id INT NOT NULL,
    type ENUM('credit', 'debit') NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NULL,
    date DATE NOT NULL,
    image_url VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE
);
```

### Technology Stack

#### Frontend Technologies
- Flutter SDK 3.4.1+ - Cross-platform mobile framework
- Dart 3.0+ - Programming language
- Provider - State management solution
- HTTP - REST API communication
- SQLite - Local database for offline support
- Shared Preferences - Local storage for settings
- Go Router - Navigation and routing
- Intl - Internationalization support

#### Backend Technologies
- **Go** 1.21+ - High-performance backend language
- **MySQL** 8.0+ - Relational database management
- **Gorilla Mux** - HTTP router and dispatcher
- **JWT** - JSON Web Token authentication
- **bcrypt** - Password hashing
- **godotenv** - Environment variable management
- **MySQL Driver** - Database connectivity

#### Development Tools
- VS Code - Primary IDE
- Android Studio - Android development
- Xcode - iOS development
- Postman - API testing
- MySQL Workbench - Database management
- Git - Version control system

### API Architecture

Our RESTful API follows industry standards with consistent response formats:

#### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Refresh JWT token
- `POST /api/auth/logout` - User logout

#### Users
- `GET /api/users` - Get current user profile
- `PUT /api/users` - Update user profile
- `DELETE /api/users` - Delete user account

#### Customers
- `GET /api/customers` - Get all customers (paginated)
- `GET /api/customers/{id}` - Get specific customer
- `POST /api/customers` - Create new customer
- `PUT /api/customers/{id}` - Update customer
- `DELETE /api/customers/{id}` - Delete customer

#### **Transactions**
- `GET /api/transactions` - Get all transactions (with filters)
- `GET /api/transactions/{id}` - Get specific transaction
- `POST /api/transactions` - Create new transaction
- `PUT /api/transactions/{id}` - Update transaction
- `DELETE /api/transactions/{id}` - Delete transaction

#### **Reports**
- `GET /api/reports/balance` - Get balance summary
- `GET /api/reports/customer/{id}` - Get customer-specific report
- `GET /api/reports/date-range` - Get date range reports
- `GET /api/reports/analytics` - Get business analytics

#### **Response Format**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {
    // Response data
  },
  "pagination": {
    "current_page": 1,
    "total_pages": 10,
    "total_records": 100,
    "per_page": 10
  }
}
```

#### **Error Response**
```json
{
  "success": false,
  "error": "Error message",
  "error_code": "VALIDATION_ERROR",
  "details": [
    {
      "field": "email",
      "message": "Email is required"
    }
  ]
}
```

## Database Schema

### Core Tables

#### users
```sql
- id (Primary Key)
- name
- email
- phone
- password_hash
- profile_image
- created_at
- updated_at
- is_active
```

#### businesses
```sql
- id (Primary Key)
- user_id (Foreign Key)
- name
- address
- phone
- email
- logo
- created_at
- updated_at
```

#### customers
```sql
- id (Primary Key)
- business_id (Foreign Key)
- name
- phone
- email
- address
- category
- credit_limit
- created_at
- updated_at
```

#### transactions
```sql
- id (Primary Key)
- business_id (Foreign Key)
- customer_id (Foreign Key)
- type (credit/debit)
- amount
- description
- category
- date
- image_url
- created_at
- updated_at
```

#### balances
```sql
- id (Primary Key)
- business_id (Foreign Key)
- customer_id (Foreign Key)
- balance_amount
- last_updated
```

## Getting Started

### **Prerequisites**

Before you begin, ensure you have the following installed on your development machine:

#### **For Frontend Development**
- **Flutter SDK** 3.4.1 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- **Dart SDK** 3.0+ (comes with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (API level 21+) for Android development
- **Xcode** (for iOS development on macOS)
- **Git** for version control

#### **For Backend Development**
#### For Backend Development
- **Go** 1.21 or higher ([Install Go](https://golang.org/dl/))
- **MySQL** 8.0 or higher
- **Git** for version control

#### **System Requirements**
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: At least 10GB free space
- **OS**: Windows 10+, macOS 10.14+, or Linux (Ubuntu 18.04+)

### **Quick Setup**

#### **1. Clone the Repository**
```bash
git clone https://github.com/yourusername/khata_book_clone.git
cd khata_book_clone
```

#### **2. Backend Setup**
```bash
#### 2. Backend Setup
```bash
# Navigate to backend directory
cd backend

# Install Go dependencies
go mod tidy

# Copy environment file
cp .env.example .env

# Edit .env with your database credentials
nano .env
```
```

#### **3. Database Setup**
```bash
# Create database
mysql -u root -p -e "CREATE DATABASE khatabook_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Import schema
mysql -u root -p khatabook_db < database/schema.sql
```

#### **4. Frontend Setup**
```bash
# Navigate to frontend directory
cd ../frontend

# Install Flutter dependencies
flutter pub get

# Run code generation (if needed)
flutter packages pub run build_runner build

# Check for any issues
flutter doctor
```

#### **5. Run the Application**
```bash
# Start backend (in backend directory)
go run main.go

# In a new terminal, start frontend (in frontend directory)
flutter run
```

### **Detailed Setup Instructions**

#### **Backend Configuration**

1. **Environment Variables Setup**
   
   Edit the `.env` file with your configuration:
   ```env
   # Database Configuration
   DB_HOST=khatabook-adit-ef94.j.aivencloud.com
   DB_PORT=10570
   DB_USER=avnadmin
   DB_PASSWORD=YOUR_PASSWORD_HERE
   DB_NAME=defaultdb
   DB_SSL_MODE=REQUIRED
   
   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
   SERVER_PORT=8080
   ```

2. **Deployment Configuration**

   **For Production Deployment:**
   ```bash
   # Build the Go binary
   go build -o khatabook-backend main.go
   
   # Run the binary
   ./khatabook-backend
   ```

   **Using Docker:**
   ```dockerfile
   FROM golang:1.21-alpine AS builder
   WORKDIR /app
   COPY go.mod go.sum ./
   RUN go mod download
   COPY . .
   RUN go build -o main .
   
   FROM alpine:latest
   RUN apk --no-cache add ca-certificates
   WORKDIR /root/
   COPY --from=builder /app/main .
   CMD ["./main"]
   ```

   **Using systemd (Linux):**
   ```bash
   # Create service file
   sudo nano /etc/systemd/system/khatabook-backend.service
   
   [Unit]
   Description=KhataBook Backend
   After=network.target
   
   [Service]
   Type=simple
   User=ubuntu
   WorkingDirectory=/home/ubuntu/khata_book_clone/backend
   ExecStart=/home/ubuntu/khata_book_clone/backend/khatabook-backend
   Restart=always
   
   [Install]
   WantedBy=multi-user.target
   
   # Enable and start service
   sudo systemctl enable khatabook-backend
   sudo systemctl start khatabook-backend
   ```

#### **Frontend Configuration**

1. **API Configuration**
   
   Edit `lib/utils/constants.dart`:
   ```dart
   class ApiConstants {
     static const String baseUrl = 'http://localhost:8080/api'; // Change for production
     static const int connectTimeout = 30000;
     static const int receiveTimeout = 30000;
   }
   ```

2. **Platform-specific Setup**

   **Android:**
   - Update `android/app/src/main/AndroidManifest.xml` for internet permissions
   - Configure `android/app/build.gradle` for minimum SDK version

   **iOS:**
   - Update `ios/Runner/Info.plist` for network permissions
   - Configure signing certificates in Xcode

### Testing Setup**

#### **Backend Testing**
```bash
# Install PHPUnit (if not already installed)
composer require --dev phpunit/phpunit

# Run tests
vendor/bin/phpunit tests/

# Run specific test
vendor/bin/phpunit tests/Unit/UserTest.php

# Generate code coverage report
vendor/bin/phpunit --coverage-html coverage/
```

#### **Frontend Testing**
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

### **Docker Setup (Optional)**

For a containerized development environment:

1. **Create docker-compose.yml:**
   ```yaml
   version: '3.8'
   services:
     mysql:
       image: mysql:8.0
       environment:
         MYSQL_ROOT_PASSWORD: root
         MYSQL_DATABASE: khatabook_db
       ports:
         - "3306:3306"
       volumes:
         - mysql_data:/var/lib/mysql
   
     backend:
       build: ./backend
       ports:
         - "8000:80"
       depends_on:
         - mysql
       volumes:
         - ./backend:/var/www/html
   
   volumes:
     mysql_data:
   ```

2. **Run with Docker:**
   ```bash
   docker-compose up -d
   ```

### Supported Platforms

- **Android** (API 21+ / Android 5.0+)
- **iOS** (iOS 12.0+)
- **Web** (Progressive Web App)
- **Windows** (Coming Soon)
- **macOS** (Coming Soon)
- **Linux** (Coming Soon)
   ```dart
   // lib/utils/constants.dart
   class ApiConstants {
     static const String baseUrl = 'http://your-backend-url/api';
   }
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Backend Setup (PHP)

1. **Navigate to backend directory**
   ```bash
   cd khata_book_clone/backend
   ```

2. **Install PHP dependencies**
   ```bash
   composer install
   ```

3. **Configure database**
   ```php
   // config/database.php
   define('DB_HOST', 'localhost');
   define('DB_NAME', 'khatabook_db');
   define('DB_USER', 'your_username');
   define('DB_PASS', 'your_password');
   ```

4. **Import database schema**
   ```bash
   mysql -u username -p khatabook_db < database/schema.sql
   ```

5. **Configure web server**
   - Point document root to `backend/` directory
   - Enable URL rewriting for clean URLs

## Required Dependencies

### Flutter Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  http: ^1.1.0
  provider: ^6.0.5
  shared_preferences: ^2.2.0
  sqflite: ^2.3.0
  image_picker: ^1.0.4
  permission_handler: ^11.0.1
  local_auth: ^2.1.6
  contacts_service: ^0.6.3
  url_launcher: ^6.1.12
  file_picker: ^5.5.0
  pdf: ^3.10.4
  excel: ^2.1.0
  intl: ^0.18.1
  cached_network_image: ^3.3.0
  connectivity_plus: ^5.0.1
  device_info_plus: ^9.1.0
  package_info_plus: ^4.2.0
  flutter_local_notifications: ^16.1.0
  workmanager: ^0.5.1
  speech_to_text: ^6.3.0
  qr_code_scanner: ^1.0.1
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
```

### Go Dependencies (go.mod)
```go
module khata-book-backend

go 1.21

require (
    github.com/gorilla/mux v1.8.1
    github.com/golang-jwt/jwt/v5 v5.3.0
    golang.org/x/crypto v0.41.0
    github.com/joho/godotenv v1.5.1
    github.com/go-sql-driver/mysql v1.9.3
)
```

## Testing

### Flutter Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Run widget tests
flutter test test/widget_test.dart
```

### Go Testing
```bash
# Run Go tests
go test ./...

# Run specific test class
go test -run TestSignUp ./handlers

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## Supported Platforms

- **Android** (API 21+)
- **iOS** (iOS 12+)
- **Web** (Progressive Web App)
- **Windows** (Coming Soon)
- **macOS** (Coming Soon)
- **Linux** (Coming Soon)

## Configuration

### Environment Variables
Create `.env` file in backend directory:
```env
DB_HOST=khatabook-adit-ef94.j.aivencloud.com
DB_PORT=10570
DB_USER=avnadmin
DB_PASSWORD=YOUR_PASSWORD_HERE
DB_NAME=defaultdb
DB_SSL_MODE=REQUIRED
JWT_SECRET=your_jwt_secret_key
SERVER_PORT=8080
```

### Firebase Configuration (for notifications)
1. Create Firebase project
2. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Place files in respective platform directories
4. Configure Firebase Cloud Messaging

## API Documentation

### Authentication Endpoints

#### POST /api/signup
```json
{
  "email": "john@example.com",
  "password": "securepassword"
}
```

#### POST /api/login
```json
{
  "email": "john@example.com",
  "password": "securepassword"
}
```

Response for login:
```json
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "email": "john@example.com",
    "created_at": "2025-01-01T00:00:00Z"
  }
}
```

### Transaction Endpoints

#### GET /api/transactions
Query Parameters:
- `customer_id`: Filter by customer
- `start_date`: Start date filter
- `end_date`: End date filter
- `type`: credit/debit
- `page`: Pagination
- `limit`: Items per page

#### POST /api/transactions
```json
{
  "customer_id": 1,
  "type": "credit",
  "amount": 1000.00,
  "description": "Product purchase",
  "category": "supplies",
  "date": "2025-06-26"
}
```

## UI/UX Design Guidelines

### Color Scheme
- **Primary**: #2E7D32 (Green)
- **Secondary**: #1976D2 (Blue)
- **Success**: #4CAF50 (Light Green)
- **Warning**: #FF9800 (Orange)
- **Error**: #F44336 (Red)
- **Background**: #FAFAFA (Light Gray)

### Typography
- **Headings**: Roboto Bold
- **Body Text**: Roboto Regular
- **Numbers**: Roboto Mono

### Design Principles
- **Simplicity**: Clean and intuitive interface
- **Accessibility**: Support for screen readers and high contrast
- **Responsive**: Adaptive layouts for different screen sizes
- **Consistency**: Uniform design patterns across the app

## Security Considerations

### Data Protection
- **Encryption**: AES-256 encryption for sensitive data
- **HTTPS**: All API communications over SSL/TLS
- **Input Validation**: Server-side validation for all inputs
- **SQL Injection Prevention**: Prepared statements and parameterized queries
- **XSS Protection**: Input sanitization and output encoding

### Authentication & Authorization
- **JWT Tokens**: Secure token-based authentication
- **Token Expiry**: Automatic token refresh mechanism
- **Rate Limiting**: API rate limiting to prevent abuse
- **Session Management**: Secure session handling

## Deployment

### Frontend Deployment

#### Android Release
```bash
flutter build apk --release
flutter build appbundle --release
```

#### iOS Release
```bash
flutter build ios --release
```

#### Web Deployment
```bash
flutter build web --release
```

### Backend Deployment

#### Go Application Deployment

1. **Build the Application**
   ```bash
   cd backend
   go build -o khatabook-backend main.go
   ```

2. **Production Environment**
   ```env
   # Production .env
   DB_HOST=khatabook-adit-ef94.j.aivencloud.com
   DB_PORT=10570
   DB_USER=avnadmin
   DB_PASSWORD=your_actual_password
   DB_NAME=defaultdb
   DB_SSL_MODE=REQUIRED
   JWT_SECRET=super-secure-jwt-secret-key-64-chars-minimum
   SERVER_PORT=8080
   ```

3. **Using Docker**
   ```bash
   # Build Docker image
   docker build -t khatabook-backend .
   
   # Run container
   docker run -d -p 8080:8080 --env-file .env khatabook-backend
   ```

4. **Using systemd**
   ```bash
   # Create service file
   sudo nano /etc/systemd/system/khatabook-backend.service
   
   [Unit]
   Description=KhataBook Backend Service
   After=network.target
   
   [Service]
   Type=simple
   User=ubuntu
   WorkingDirectory=/path/to/backend
   ExecStart=/path/to/backend/khatabook-backend
   Restart=always
   EnvironmentFile=/path/to/backend/.env
   
   [Install]
   WantedBy=multi-user.target
   
   # Enable and start
   sudo systemctl enable khatabook-backend
   sudo systemctl start khatabook-backend
   ```

## Performance Optimization

### Frontend Optimization
- **Lazy Loading**: Load screens and images on demand
- **State Management**: Efficient state management with Provider
- **Image Optimization**: Compress and cache images
- **Database Optimization**: Local SQLite optimization
- **Bundle Size**: Tree shaking and code splitting

### Backend Optimization
- **Database Indexing**: Proper indexing for query performance
- **Caching**: Redis/Memcached for frequently accessed data
- **API Optimization**: Pagination and response compression
- **CDN**: Content delivery network for static assets

## Contributing

We welcome contributions! Please follow these guidelines:

1. **Fork the repository**
2. **Create feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit changes**: `git commit -m 'Add amazing feature'`
4. **Push to branch**: `git push origin feature/amazing-feature`
5. **Open Pull Request**

### Code Standards
- **Flutter**: Follow Dart style guide and use `flutter analyze`
- **PHP**: Follow PSR-12 coding standards
- **Git Commits**: Use conventional commit messages
- **Documentation**: Update README for any new features

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [PHP Documentation](https://www.php.net/docs.php)
- [MySQL Documentation](https://dev.mysql.com/doc/)

### Community
- **GitHub Issues**: Report bugs and request features
- **Discussions**: Join community discussions
- **Email**: support@khatabookclone.com

### Troubleshooting

#### Common Issues

**Flutter Build Fails**
```bash
flutter clean
flutter pub get
flutter build apk
```

**Database Connection Error**
- Check database credentials in `config/database.php`
- Verify MySQL server is running
- Check firewall settings

**API Authentication Issues**
- Verify JWT secret key configuration
- Check token expiry settings
- Validate API endpoint URLs

## Required Dependencies

### **Flutter Dependencies (pubspec.yaml)**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # UI and Icons
  cupertino_icons: ^1.0.6
  
  # State Management
  provider: ^6.0.5
  
  # HTTP and API
  http: ^1.1.0
  dio: ^5.3.2  # Alternative HTTP client
  
  # Local Storage
  shared_preferences: ^2.2.0
  sqflite: ^2.3.0
  
  # Utilities
  intl: ^0.18.1
  uuid: ^4.0.0
  path_provider: ^2.1.0
  
  # Navigation
  go_router: ^13.0.0
  
  # Image and Media
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  
  # Security
  crypto: ^3.0.3
  flutter_secure_storage: ^9.0.0
  
  # Permissions
  permission_handler: ^11.0.1
  
  # UI Enhancements
  shimmer: ^3.0.0
  lottie: ^2.7.0
  pull_to_refresh: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.7
  json_annotation: ^4.8.1
  json_serializable: ^6.7.1
  mockito: ^5.4.2
```

### **PHP Dependencies (composer.json)**
```json
{
  "name": "khatabook/api",
  "description": "KhataBook Clone REST API",
  "type": "project",
  "require": {
    "php": ">=8.0",
    "firebase/php-jwt": "^6.0",
    "phpmailer/phpmailer": "^6.8",
    "vlucas/phpdotenv": "^5.5",
    "monolog/monolog": "^3.0",
    "guzzlehttp/guzzle": "^7.8",
    "respect/validation": "^2.2",
    "ramsey/uuid": "^4.7"
  },
  "require-dev": {
    "phpunit/phpunit": "^10.0",
    "squizlabs/php_codesniffer": "^3.7",
    "phpstan/phpstan": "^1.10",
    "friendsofphp/php-cs-fixer": "^3.21"
  },
  "autoload": {
    "psr-4": {
      "App\\": "src/",
      "App\\Models\\": "models/",
      "App\\Utils\\": "utils/",
      "App\\Middleware\\": "middleware/"
    }
  },
  "autoload-dev": {
    "psr-4": {
      "Tests\\": "tests/"
    }
  }
}
```

## Deployment

### **Production Deployment**

#### **Backend Deployment (Linux Server)**

1. **Server Requirements**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y
   
   # Install required packages
   sudo apt install -y nginx mysql-server php8.1 php8.1-fpm php8.1-mysql \
   php8.1-curl php8.1-json php8.1-mbstring php8.1-xml php8.1-zip
   
   # Install Composer
   curl -sS https://getcomposer.org/installer | php
   sudo mv composer.phar /usr/local/bin/composer
   ```

2. **SSL Certificate (Let's Encrypt)**
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d yourdomain.com
   ```

3. **Production Environment**
   ```env
   # Production .env
   APP_ENV=production
   DB_HOST=localhost
   DB_NAME=khatabook_production
   DB_USER=khatabook_user
   DB_PASS=secure_password_here
   JWT_SECRET=super-secure-jwt-secret-key-64-chars-minimum
   CORS_ORIGIN=https://yourdomain.com
   ```

#### **Frontend Deployment**

1. **Build for Production**
   ```bash
   # Build web version
   flutter build web --release
   
   # Build Android APK
   flutter build apk --release
   
   # Build iOS (on macOS)
   flutter build ios --release
   ```

2. **Deploy to Web Hosting**
   ```bash
   # Upload build/web/ to your web server
   scp -r build/web/* user@server:/var/www/html/
   ```

### **Cloud Deployment Options**

#### **AWS Deployment**
- **Backend**: AWS EC2 + RDS MySQL
- **Frontend**: AWS S3 + CloudFront CDN
- **Images**: AWS S3 for file storage

#### **Google Cloud Platform**
- **Backend**: Google Compute Engine + Cloud SQL
- **Frontend**: Firebase Hosting
- **Images**: Google Cloud Storage

#### **DigitalOcean**
- **Backend**: DigitalOcean Droplet + Managed Database
- **Frontend**: DigitalOcean Spaces + CDN

## Troubleshooting

### **Common Issues and Solutions**

#### **Backend Issues**

1. **Database Connection Issues**
   ```bash
   # Check MySQL service
   sudo systemctl status mysql
   
   # Test connection manually
   mysql -h khatabook-adit-ef94.j.aivencloud.com -P 10570 -u avnadmin -p defaultdb
   ```

2. **JWT Token Issues**
   ```go
   // Check token expiry in handlers/auth.go
   claims := jwt.MapClaims{
       "user_id": userID,
       "email":    email,
       "exp":      time.Now().Add(24 * time.Hour).Unix(),
   }
   ```

3. **Database Connection Issues**
   ```bash
   # Check MySQL service
   sudo systemctl status mysql
   
   # Restart MySQL
   sudo systemctl restart mysql
   
   # Check connection
   mysql -u username -p -e "SELECT 1;"
   ```

#### **Frontend Issues**

1. **API Connection Issues**
   ```dart
   // Check network connectivity
   import 'package:connectivity_plus/connectivity_plus.dart';
   
   final result = await Connectivity().checkConnectivity();
   if (result == ConnectivityResult.none) {
     // Handle offline state
   }
   ```

2. **Build Issues**
   ```bash
   # Clean build cache
   flutter clean
   flutter pub get
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Performance Issues**
   ```dart
   // Use pagination for large lists
   class PaginatedList<T> {
     final List<T> items;
     final int page;
     final int totalPages;
     final bool hasMore;
   }
   ```

### **Debug Mode**

Enable debug logging:

```env
# .env
DEBUG=true
LOG_LEVEL=debug
```

```dart
// Flutter
const bool kDebugMode = true;
```

## Contributing

We welcome contributions from the community! Here's how you can help:

### **Getting Started**

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
4. **Commit your changes**
   ```bash
   git commit -m 'Add some amazing feature'
   ```

5. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**

### **Development Guidelines**

#### **Code Style**
- **Flutter**: Follow [Dart style guide](https://dart.dev/guides/language/effective-dart)
- **PHP**: Follow [PSR-12](https://www.php-fig.org/psr/psr-12/) coding standard
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

#### **Commit Messages**
Follow [Conventional Commits](https://www.conventionalcommits.org/):
```
feat: add customer export functionality
fix: resolve transaction date validation issue
docs: update API documentation
test: add unit tests for user service
```

#### **Pull Request Guidelines**
- Ensure all tests pass
- Update documentation if needed
- Add screenshots for UI changes
- Keep PRs focused and atomic
- Write clear PR descriptions

### **Reporting Issues**

When reporting bugs, please include:
- Operating system and version
- Flutter/PHP version
- Steps to reproduce
- Expected vs actual behavior
- Screenshots (if applicable)
- Error logs

### **Feature Requests**

For feature requests, please:
- Check existing issues first
- Explain the use case
- Provide detailed requirements
- Consider implementation complexity

## Security

### **Security Best Practices**

- **Never commit sensitive data** (passwords, API keys, etc.)
- **Use environment variables** for configuration
- **Validate all inputs** on both client and server
- **Use HTTPS** in production
- **Implement rate limiting** to prevent abuse
- **Regular security updates** for dependencies

### **Reporting Security Issues**

Please report security vulnerabilities to: **security@khatabookclone.com**

Do not create public issues for security problems.

## Performance

### **Optimization Tips**

#### **Frontend Performance**
- Use `ListView.builder()` for large lists
- Implement image caching
- Minimize widget rebuilds
- Use `const` constructors where possible
- Implement lazy loading for data

#### **Backend Performance**
- Use database indexing
- Implement API caching
- Optimize SQL queries
- Use connection pooling
- Implement pagination

### **Monitoring**

- **Frontend**: Use Firebase Crashlytics
- **Backend**: Implement logging with Monolog
- **Database**: Monitor query performance
- **API**: Track response times and error rates

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

### **Third-party Licenses**
- Flutter: BSD 3-Clause License
- PHP: PHP License
- MySQL: GPL v2 License

## Acknowledgments

- **Flutter Team** for the amazing framework
- **PHP Community** for robust backend capabilities  
- **Contributors** who helped improve this project
- **Open Source Community** for inspiration and resources

## Roadmap

### Version 1.0 (Current)
- Basic transaction management
- Customer management
- Simple reports
- Authentication system

### Version 1.1 (Next Release)
- WhatsApp integration
- Advanced reports
- Backup & sync
- Multi-language support

### Version 2.0 (Future)
- Inventory management
- Team collaboration
- Advanced analytics
- Third-party integrations

### Version 3.0 (Long-term)
- AI-powered insights
- Blockchain integration
- IoT device support
- Advanced automation

## Contact & Support

### **Development Team**
- **Lead Developer**: [@yourusername](https://github.com/yourusername)
- **Project Email**: dev.khatabook@gmail.com
- **Website**: [https://khatabookclone.dev](https://khatabookclone.dev)

### **Community & Support**
- **GitHub Issues**: [Report bugs and request features](https://github.com/yourusername/khata_book_clone/issues)
- **Discussions**: [Community discussions](https://github.com/yourusername/khata_book_clone/discussions)
- **Documentation**: [Full documentation](https://docs.khatabookclone.dev)
- **Discord**: [Join our community](https://discord.gg/khatabook-clone)

### **Business Inquiries**
- **Enterprise Support**: enterprise@khatabookclone.dev
- **Partnership**: partners@khatabookclone.dev
- **Media Queries**: media@khatabookclone.dev

---

<div align="center">

## Show Your Support

If you find this project helpful, please consider:

[![Star on GitHub](https://img.shields.io/github/stars/yourusername/khata_book_clone?style=social)](https://github.com/yourusername/khata_book_clone)
[![Fork on GitHub](https://img.shields.io/github/forks/yourusername/khata_book_clone?style=social)](https://github.com/yourusername/khata_book_clone/fork)
[![Watch on GitHub](https://img.shields.io/github/watchers/yourusername/khata_book_clone?style=social)](https://github.com/yourusername/khata_book_clone)

**Built by developers, for small businesses**

*Empowering entrepreneurs with digital financial management*

**Last Updated: June 26, 2025** | **Version: 1.0.0** | **License: Apache 2.0**

</div>
