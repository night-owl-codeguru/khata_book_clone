import 'package:flutter/foundation.dart';
import '../services/reminder_service.dart';

class ReminderProvider with ChangeNotifier {
  List<Map<String, dynamic>> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get reminders filtered by status
  List<Map<String, dynamic>> getRemindersByStatus(String status) {
    if (status == 'all') {
      return _reminders;
    }
    return _reminders.where((reminder) {
      return reminder['status'] == status;
    }).toList();
  }

  // Load reminders from API
  Future<void> loadReminders({String? status, int? customerId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ReminderService.getReminders(
        status: status,
        customerId: customerId,
      );

      if (result['success']) {
        _reminders = List<Map<String, dynamic>>.from(result['reminders'] ?? []);
      } else {
        _error = result['message'] ?? 'Failed to load reminders';
        // Fallback to mock data if API fails
        _reminders = ReminderService.getMockReminders();
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      // Fallback to mock data if network fails
      _reminders = ReminderService.getMockReminders();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new reminder
  Future<bool> createReminder({
    required int customerId,
    required double dueAmount,
    required DateTime dueDate,
    required String channel,
  }) async {
    try {
      final result = await ReminderService.createReminder(
        customerId: customerId,
        dueAmount: dueAmount,
        dueDate: dueDate,
        channel: channel,
      );

      if (result['success']) {
        // Reload reminders to get the updated list
        await loadReminders();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to create reminder';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Update reminder status
  Future<bool> updateReminderStatus(int reminderId, String status) async {
    try {
      final result = await ReminderService.updateReminder(
        reminderId,
        status: status,
      );

      if (result['success']) {
        // Reload reminders to get the updated list
        await loadReminders();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to update reminder';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Delete a reminder
  Future<bool> deleteReminder(int reminderId) async {
    try {
      final result = await ReminderService.deleteReminder(reminderId);

      if (result['success']) {
        // Reload reminders to get the updated list
        await loadReminders();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to delete reminder';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
