import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ReminderService {
  // Base URL for API - should match AuthService
  static const String _baseUrl = 'https://khata-book-clone.onrender.com/api';

  // Get all reminders for the authenticated user
  static Future<Map<String, dynamic>> getReminders({
    String? status,
    int? customerId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final queryParams = <String, String>{};
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (customerId != null)
        queryParams['customer_id'] = customerId.toString();

      final uri = Uri.parse(
        '$_baseUrl/reminders',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {
          'success': true,
          'reminders': data['reminders'] ?? [],
          'count': data['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get reminders',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Create a new reminder
  static Future<Map<String, dynamic>> createReminder({
    required int customerId,
    required double dueAmount,
    required DateTime dueDate,
    required String channel, // 'sms', 'whatsapp', 'email'
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final requestBody = {
        'customer_id': customerId,
        'due_amount': dueAmount,
        'due_date': dueDate.toUtc().toIso8601String(),
        'channel': channel,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/reminders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'message': 'Reminder created successfully',
          'reminder': data['reminder'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create reminder',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update an existing reminder
  static Future<Map<String, dynamic>> updateReminder(
    int reminderId, {
    double? dueAmount,
    DateTime? dueDate,
    String? channel,
    String? status,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final requestBody = {};
      if (dueAmount != null) requestBody['due_amount'] = dueAmount;
      if (dueDate != null)
        requestBody['due_date'] = dueDate.toUtc().toIso8601String();
      if (channel != null && channel.isNotEmpty)
        requestBody['channel'] = channel;
      if (status != null && status.isNotEmpty) requestBody['status'] = status;

      if (requestBody.isEmpty) {
        return {'success': false, 'message': 'No fields to update'};
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/reminders/$reminderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'message': 'Reminder updated successfully'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update reminder',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Delete a reminder
  static Future<Map<String, dynamic>> deleteReminder(int reminderId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl/reminders/$reminderId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'message': 'Reminder deleted successfully'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete reminder',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Mock data for development/testing when backend is not available
  static List<Map<String, dynamic>> getMockReminders() {
    return [
      {
        'id': 1,
        'customer_id': 1,
        'customer_name': 'Ramesh Traders',
        'due_amount': 2500.0,
        'due_date': '2024-09-15',
        'channel': 'whatsapp',
        'status': 'pending',
        'created_at': '2024-08-29T10:00:00Z',
      },
      {
        'id': 2,
        'customer_id': 2,
        'customer_name': 'Mohan Kirana',
        'due_amount': 1200.0,
        'due_date': '2024-09-10',
        'channel': 'sms',
        'status': 'sent',
        'created_at': '2024-08-28T14:30:00Z',
      },
      {
        'id': 3,
        'customer_id': 3,
        'customer_name': 'Sita Textiles',
        'due_amount': 1800.0,
        'due_date': '2024-09-20',
        'channel': 'email',
        'status': 'snoozed',
        'created_at': '2024-08-27T09:15:00Z',
      },
    ];
  }
}
