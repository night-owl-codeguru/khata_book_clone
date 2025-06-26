import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ensure SharedPreferences is initialized
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Token management
  static Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.userTokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.userTokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.userTokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // User data management
  static Future<void> saveUser(User user) async {
    final prefs = await _instance;
    final userJson = json.encode(user.toJson());
    await prefs.setString(AppConstants.userDataKey, userJson);
  }

  static Future<User?> getUser() async {
    final prefs = await _instance;
    final userJson = prefs.getString(AppConstants.userDataKey);

    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        // If parsing fails, remove corrupted data
        await removeUser();
        return null;
      }
    }

    return null;
  }

  static Future<void> removeUser() async {
    final prefs = await _instance;
    await prefs.remove(AppConstants.userDataKey);
  }

  // Theme management
  static Future<void> saveThemeMode(String themeMode) async {
    final prefs = await _instance;
    await prefs.setString(AppConstants.themeKey, themeMode);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await _instance;
    return prefs.getString(AppConstants.themeKey);
  }

  // Generic data storage
  static Future<void> saveString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  static Future<void> saveInt(String key, int value) async {
    final prefs = await _instance;
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await _instance;
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  static Future<void> saveDouble(String key, double value) async {
    final prefs = await _instance;
    await prefs.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final prefs = await _instance;
    return prefs.getDouble(key);
  }

  static Future<void> saveStringList(String key, List<String> value) async {
    final prefs = await _instance;
    await prefs.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    final prefs = await _instance;
    return prefs.getStringList(key);
  }

  // Remove specific key
  static Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }

  // Clear all data
  static Future<void> clearAll() async {
    final prefs = await _instance;
    await prefs.clear();
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key);
  }

  // Get all keys
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _instance;
    return prefs.getKeys();
  }

  // Authentication helper methods
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && token.isNotEmpty && user != null;
  }

  static Future<void> logout() async {
    await removeToken();
    await removeUser();
    // Keep theme and other non-sensitive data
  }

  // First time app launch
  static Future<void> setFirstLaunch(bool isFirst) async {
    await saveBool('first_launch', isFirst);
  }

  static Future<bool> isFirstLaunch() async {
    final isFirst = await getBool('first_launch');
    return isFirst ?? true;
  }

  // App version tracking
  static Future<void> saveAppVersion(String version) async {
    await saveString('app_version', version);
  }

  static Future<String?> getAppVersion() async {
    return await getString('app_version');
  }
}
