import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF1976D2);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onSurface = Color(0xFF212121);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}

class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://localhost/khatabook/api';
  static const int requestTimeout = 30;

  // App Information
  static const String appName = 'KhataBook Clone';
  static const String appVersion = '1.0.0';

  // Color Scheme
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF1976D2);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color backgroundColor = Color(0xFFFAFAFA);

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );

  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Local Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Transaction Categories
  static const List<String> transactionCategories = [
    'Supplies',
    'Services',
    'Personal',
    'Equipment',
    'Utilities',
    'Other',
  ];

  // Customer Categories
  static const List<String> customerCategories = [
    'Regular',
    'VIP',
    'Wholesale',
    'Retail',
    'Other',
  ];
}

class ApiEndpoints {
  // Authentication
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // Customers
  static const String customers = '/customers';
  static const String customersCreate = '/customers/create';
  static const String customersUpdate = '/customers/update';
  static const String customersDelete = '/customers/delete';

  // Transactions
  static const String transactions = '/transactions';
  static const String transactionsCreate = '/transactions/create';
  static const String transactionsUpdate = '/transactions/update';
  static const String transactionsDelete = '/transactions/delete';

  // Reports
  static const String reportsBalance = '/reports/balance';
  static const String reportsCustomer = '/reports/customer';
  static const String reportsDate = '/reports/date';
}
