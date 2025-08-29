import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class SecurityService {
  static const _secureStorage = FlutterSecureStorage();
  static const _pinKey = 'user_pin';
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _pinAttemptsKey = 'pin_attempts';
  static const _lockoutTimeKey = 'lockout_time';
  static const _maxAttempts = 3;
  static const _lockoutDuration = Duration(minutes: 5);

  static final LocalAuthentication _localAuth = LocalAuthentication();

  // PIN Management
  static Future<bool> setPin(String pin) async {
    try {
      if (pin.length < 4) {
        throw Exception('PIN must be at least 4 digits');
      }

      // Validate PIN format (numeric only)
      if (!RegExp(r'^\d+$').hasMatch(pin)) {
        throw Exception('PIN must contain only numbers');
      }

      await _secureStorage.write(key: _pinKey, value: pin);
      await _secureStorage.write(key: _pinAttemptsKey, value: '0');
      await _secureStorage.delete(key: _lockoutTimeKey);
      return true;
    } catch (e) {
      throw Exception('Failed to set PIN: $e');
    }
  }

  static Future<bool> verifyPin(String pin) async {
    try {
      // Check if user is locked out
      if (await _isLockedOut()) {
        throw Exception('Too many failed attempts. Please try again later.');
      }

      final storedPin = await _secureStorage.read(key: _pinKey);
      if (storedPin == null) {
        throw Exception('No PIN set');
      }

      if (storedPin == pin) {
        // Reset attempts on successful verification
        await _secureStorage.write(key: _pinAttemptsKey, value: '0');
        await _secureStorage.delete(key: _lockoutTimeKey);
        return true;
      } else {
        // Increment failed attempts
        await _incrementFailedAttempts();
        return false;
      }
    } catch (e) {
      throw Exception('PIN verification failed: $e');
    }
  }

  static Future<bool> hasPin() async {
    final pin = await _secureStorage.read(key: _pinKey);
    return pin != null && pin.isNotEmpty;
  }

  static Future<void> changePin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) {
      throw Exception('Current PIN is incorrect');
    }

    await setPin(newPin);
  }

  static Future<void> removePin() async {
    await _secureStorage.delete(key: _pinKey);
    await _secureStorage.delete(key: _pinAttemptsKey);
    await _secureStorage.delete(key: _lockoutTimeKey);
  }

  // Biometric Authentication
  static Future<bool> isBiometricAvailable() async {
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics && canAuthenticate;
    } catch (e) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  static Future<bool> authenticateWithBiometrics({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      final available = await isBiometricAvailable();
      if (!available) {
        throw Exception('Biometric authentication not available');
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated;
    } on PlatformException catch (e) {
      throw Exception('Biometric authentication failed: ${e.message}');
    } catch (e) {
      throw Exception('Biometric authentication failed: $e');
    }
  }

  static Future<bool> isBiometricEnabled() async {
    final enabled = await _secureStorage.read(key: _biometricEnabledKey);
    return enabled == 'true';
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _biometricEnabledKey,
      value: enabled.toString(),
    );
  }

  // Combined Authentication (PIN or Biometric)
  static Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool allowBiometric = true,
  }) async {
    try {
      final hasPinSet = await hasPin();
      final biometricEnabled = allowBiometric && await isBiometricEnabled();
      final biometricAvailable = await isBiometricAvailable();

      // If biometric is enabled and available, try biometric first
      if (biometricEnabled && biometricAvailable) {
        try {
          final biometricSuccess = await authenticateWithBiometrics(
            reason: reason,
          );
          if (biometricSuccess) {
            return true;
          }
        } catch (e) {
          // Biometric failed, fall back to PIN
        }
      }

      // Fall back to PIN if biometric fails or is not available
      if (hasPinSet) {
        // This would typically show a PIN input dialog
        // For now, we'll return false to indicate PIN is required
        return false;
      }

      // No authentication method available
      return true; // Allow access if no security is set up
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  // Lockout Management
  static Future<bool> _isLockedOut() async {
    final lockoutTimeStr = await _secureStorage.read(key: _lockoutTimeKey);
    if (lockoutTimeStr == null) {
      return false;
    }

    final lockoutTime = DateTime.parse(lockoutTimeStr);
    final now = DateTime.now();

    if (now.isAfter(lockoutTime.add(_lockoutDuration))) {
      // Lockout period has expired
      await _secureStorage.delete(key: _lockoutTimeKey);
      await _secureStorage.write(key: _pinAttemptsKey, value: '0');
      return false;
    }

    return true;
  }

  static Future<void> _incrementFailedAttempts() async {
    final attemptsStr = await _secureStorage.read(key: _pinAttemptsKey) ?? '0';
    final attempts = int.parse(attemptsStr) + 1;

    await _secureStorage.write(
      key: _pinAttemptsKey,
      value: attempts.toString(),
    );

    if (attempts >= _maxAttempts) {
      // Lock out the user
      final lockoutTime = DateTime.now();
      await _secureStorage.write(
        key: _lockoutTimeKey,
        value: lockoutTime.toIso8601String(),
      );
    }
  }

  static Future<Map<String, dynamic>> getSecurityStatus() async {
    final pinSet = await hasPin();
    final biometricEnabled = await isBiometricEnabled();
    final biometricAvailable = await isBiometricAvailable();
    final availableBiometrics = await getAvailableBiometrics();
    final isLockedOut = await _isLockedOut();

    final attemptsStr = await _secureStorage.read(key: _pinAttemptsKey) ?? '0';
    final attempts = int.parse(attemptsStr);

    DateTime? lockoutTime;
    if (isLockedOut) {
      final lockoutTimeStr = await _secureStorage.read(key: _lockoutTimeKey);
      if (lockoutTimeStr != null) {
        lockoutTime = DateTime.parse(lockoutTimeStr);
      }
    }

    return {
      'hasPin': pinSet,
      'biometricEnabled': biometricEnabled,
      'biometricAvailable': biometricAvailable,
      'availableBiometrics': availableBiometrics,
      'isLockedOut': isLockedOut,
      'lockoutTime': lockoutTime,
      'remainingAttempts': _maxAttempts - attempts,
      'lockoutDuration': _lockoutDuration,
    };
  }

  static Future<Duration?> getRemainingLockoutTime() async {
    final lockoutTimeStr = await _secureStorage.read(key: _lockoutTimeKey);
    if (lockoutTimeStr == null) {
      return null;
    }

    final lockoutTime = DateTime.parse(lockoutTimeStr);
    final endTime = lockoutTime.add(_lockoutDuration);
    final now = DateTime.now();

    if (now.isAfter(endTime)) {
      return null;
    }

    return endTime.difference(now);
  }
}
