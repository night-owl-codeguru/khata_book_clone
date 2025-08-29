import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { needsOnboarding, needsSignup, needsLogin, authenticated }

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isSignedUpKey = 'is_signed_up';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  // Base URL for API - update this to match your backend URL
  static const String _baseUrl =
      'https://khata-book-clone.onrender.com/api'; // Deployed backend URL

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Store token
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get stored user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  // Store user data
  static Future<void> setUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Check if user has signed up
  static Future<bool> isSignedUp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isSignedUpKey) ?? false;
  }

  // Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  // Mark user as signed up
  static Future<void> setSignedUp(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isSignedUpKey, value);
  }

  // Mark user as logged in
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  // Mark onboarding as completed
  static Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, value);
  }

  // Sign up user
  static Future<Map<String, dynamic>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
    String? address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'address': address,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        // Store token and user data
        await setToken(data['token']);
        await setUserData(data['user']);
        await setSignedUp(true);
        await setLoggedIn(true);

        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        // Handle specific error types
        String errorMessage = data['message'] ?? 'Signup failed';
        String errorType = data['error'] ?? 'unknown_error';

        switch (errorType) {
          case 'email_exists':
            errorMessage =
                'An account with this email already exists. Please use a different email or try logging in.';
            break;
          case 'phone_exists':
            errorMessage =
                'An account with this phone number already exists. Please use a different phone number.';
            break;
          case 'invalid_email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'invalid_phone':
            errorMessage = 'Please enter a valid phone number.';
            break;
          case 'weak_password':
            errorMessage = 'Password must be at least 8 characters long.';
            break;
          case 'invalid_request':
            errorMessage = 'Please check your input and try again.';
            break;
          case 'server_error':
            errorMessage = 'Server error occurred. Please try again later.';
            break;
          default:
            errorMessage = 'Signup failed. Please try again.';
        }

        return {
          'success': false,
          'message': errorMessage,
          'error_type': errorType,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error_type': 'network_error',
      };
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Store token and user data
        await setToken(data['token']);
        await setUserData(data['user']);
        await setLoggedIn(true);

        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        // Handle specific error types
        String errorMessage = data['message'] ?? 'Login failed';
        String errorType = data['error'] ?? 'unknown_error';

        switch (errorType) {
          case 'invalid_credentials':
            errorMessage =
                'Invalid email or password. Please check your credentials and try again.';
            break;
          case 'invalid_request':
            errorMessage = 'Please check your input and try again.';
            break;
          case 'server_error':
            errorMessage = 'Server error occurred. Please try again later.';
            break;
          default:
            errorMessage = 'Login failed. Please try again.';
        }

        return {
          'success': false,
          'message': errorMessage,
          'error_type': errorType,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error_type': 'network_error',
      };
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final requestBody = {};
      if (name != null && name.isNotEmpty) requestBody['name'] = name;
      if (phone != null && phone.isNotEmpty) requestBody['phone'] = phone;
      if (address != null && address.isNotEmpty)
        requestBody['address'] = address;

      if (requestBody.isEmpty) {
        return {'success': false, 'message': 'No fields to update'};
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        // Update stored user data with fresh data from server
        await setUserData(data['user']);
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Get user authentication status
  static Future<AuthStatus> getAuthStatus() async {
    final signedUp = await isSignedUp();
    final loggedIn = await isLoggedIn();
    final onboardingCompleted = await isOnboardingCompleted();

    if (!onboardingCompleted) {
      return AuthStatus.needsOnboarding;
    } else if (!signedUp) {
      return AuthStatus.needsSignup;
    } else if (!loggedIn) {
      return AuthStatus.needsLogin;
    } else {
      return AuthStatus.authenticated;
    }
  }

  // Validate current token and refresh user data if needed
  static Future<bool> validateAndRefreshSession() async {
    try {
      final result = await getProfile();
      if (result['success'] == true) {
        // Update stored user data with fresh data from server
        await setUserData(result['user']);
        return true;
      } else {
        // Token is invalid, clear stored data
        await logout();
        return false;
      }
    } catch (e) {
      // Network error, keep current session but log the issue
      return await isLoggedIn();
    }
  }

  // Test backend connection
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('https://khata-book-clone.onrender.com/'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'message': 'Backend connection successful',
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Backend returned error',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: ${e.toString()}',
      };
    }
  }

  // Wake up call to check if server is ready
  static Future<Map<String, dynamic>> wakeUpServer() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'healthy') {
        return {
          'success': true,
          'message': 'Server is ready',
          'data': data,
          'debug': 'Status: ${response.statusCode}, Response: ${response.body}',
        };
      } else {
        return {
          'success': false,
          'message': 'Server not ready',
          'data': data,
          'debug': 'Status: ${response.statusCode}, Response: ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection failed: ${e.toString()}',
        'debug': 'Error: ${e.toString()}',
      };
    }
  }

  // Debug method to test API endpoints
  Future<Map<String, dynamic>> debugApiCall(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      return {
        'success': true,
        'statusCode': response.statusCode,
        'body': response.body,
        'headers': response.headers,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
