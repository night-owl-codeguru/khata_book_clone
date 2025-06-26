class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }

    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional in most cases
    }

    final phoneRegex = RegExp(r'^[+]?[0-9]{10,13}$');
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!phoneRegex.hasMatch(cleanPhone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Required phone validation
  static String? validateRequiredPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    return validatePhone(value);
  }

  // Amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount > 9999999) {
      return 'Amount is too large';
    }

    return null;
  }

  // Description validation
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.trim().length < 3) {
      return 'Description must be at least 3 characters long';
    }

    if (value.length > 255) {
      return 'Description is too long (max 255 characters)';
    }

    return null;
  }

  // Optional description validation
  static String? validateOptionalDescription(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length > 255) {
      return 'Description is too long (max 255 characters)';
    }

    return null;
  }

  // Customer name validation
  static String? validateCustomerName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Customer name is required';
    }

    if (value.trim().length < 2) {
      return 'Customer name must be at least 2 characters long';
    }

    if (value.length > 100) {
      return 'Customer name is too long (max 100 characters)';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Address is optional
    }

    if (value.length > 500) {
      return 'Address is too long (max 500 characters)';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Generic required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Credit limit validation
  static String? validateCreditLimit(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Credit limit is optional
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid credit limit';
    }

    if (amount < 0) {
      return 'Credit limit cannot be negative';
    }

    if (amount > 99999999) {
      return 'Credit limit is too large';
    }

    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    final now = DateTime.now();
    final maxDate = DateTime(now.year + 1, now.month, now.day);
    final minDate = DateTime(2020, 1, 1);

    if (value.isAfter(maxDate)) {
      return 'Date cannot be in the future';
    }

    if (value.isBefore(minDate)) {
      return 'Date is too old';
    }

    return null;
  }
}
