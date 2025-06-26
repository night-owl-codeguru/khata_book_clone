import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAuthenticated => _isLoggedIn; // Add this getter
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize auth state
  Future<void> initialize() async {
    _setLoading(true);

    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        final user = await StorageService.getUser();
        if (user != null) {
          _user = user;
          _isLoggedIn = true;
        }
      }
    } catch (e) {
      _error = 'Failed to initialize auth: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService().post(
        ApiEndpoints.login,
        {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      if (response['success'] == true) {
        final userData = response['data']['user'];
        final token = response['data']['token'];

        _user = User.fromJson(userData);
        _isLoggedIn = true;

        // Save to storage
        await StorageService.saveToken(token);
        await StorageService.saveUser(_user!);

        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Login failed';
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Network error. Please try again.';
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService().post(
        ApiEndpoints.register,
        {
          'name': name,
          'email': email,
          'password': password,
          if (phone != null) 'phone': phone,
        },
        includeAuth: false,
      );

      if (response['success'] == true) {
        final userData = response['data']['user'];
        final token = response['data']['token'];

        _user = User.fromJson(userData);
        _isLoggedIn = true;

        // Save to storage
        await StorageService.saveToken(token);
        await StorageService.saveUser(_user!);

        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Registration failed';
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Network error. Please try again.';
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);

    try {
      // Call logout API
      await ApiService().post(ApiEndpoints.logout, {});
    } catch (e) {
      // Even if API call fails, we'll logout locally
      debugPrint('Logout API failed: $e');
    }

    // Clear local data
    await StorageService.logout();

    _user = null;
    _isLoggedIn = false;
    _clearError();

    _setLoading(false);
    notifyListeners();
  }

  // Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;

      final response = await ApiService().put('/user/profile', updateData);

      if (response['success'] == true) {
        final userData = response['data']['user'];
        _user = User.fromJson(userData);

        // Update storage
        await StorageService.saveUser(_user!);

        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Update failed';
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Network error. Please try again.';
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService().put('/user/change-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      if (response['success'] == true) {
        return true;
      } else {
        _error = response['message'] ?? 'Password change failed';
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Network error. Please try again.';
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if token is valid
  Future<bool> checkTokenValidity() async {
    try {
      final response = await ApiService().get('/auth/verify');
      return response['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    if (!_isLoggedIn) return;

    try {
      final response = await ApiService().get('/user/profile');
      if (response['success'] == true) {
        final userData = response['data']['user'];
        _user = User.fromJson(userData);
        await StorageService.saveUser(_user!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to refresh user: $e');
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
