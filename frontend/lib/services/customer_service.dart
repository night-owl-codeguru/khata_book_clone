import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CustomerService {
  // Base URL for API - should match AuthService
  static const String _baseUrl = 'https://khata-book-clone.onrender.com/api';

  // Get all customers for the authenticated user
  static Future<Map<String, dynamic>> getCustomers() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-User-ID':
              '1', // Temporary for testing - should be extracted from JWT
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'customers': data['customers'] ?? []};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get customers',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Create a new customer
  static Future<Map<String, dynamic>> createCustomer({
    required String name,
    String? phone,
    String? note,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final requestBody = {
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (note != null && note.isNotEmpty) 'note': note,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/customers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-User-ID':
              '1', // Temporary for testing - should be extracted from JWT
        },
        body: json.encode(requestBody),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success']) {
        return {
          'success': true,
          'message': 'Customer created successfully',
          'customer': data['customer'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create customer',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get a specific customer by ID
  static Future<Map<String, dynamic>> getCustomer(int customerId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/customers/$customerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-User-ID':
              '1', // Temporary for testing - should be extracted from JWT
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'customer': data['customer']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get customer',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Mock data for development/testing when backend is not available
  static List<Map<String, dynamic>> getMockCustomers() {
    return [
      {
        'id': 1,
        'name': 'Ramesh Traders',
        'phone': '9876543210',
        'balance': 3200.0,
        'lastTransaction': '2024-08-29',
      },
      {
        'id': 2,
        'name': 'Mohan Kirana',
        'phone': '9876501234',
        'balance': -500.0,
        'lastTransaction': '2024-08-28',
      },
      {
        'id': 3,
        'name': 'Sita Textiles',
        'phone': '9876587654',
        'balance': 1800.0,
        'lastTransaction': '2024-08-27',
      },
      {
        'id': 4,
        'name': 'Anand Dairy',
        'phone': '9876123456',
        'balance': 950.0,
        'lastTransaction': '2024-08-26',
      },
      {
        'id': 5,
        'name': 'Vijay Hardware',
        'phone': '9876987654',
        'balance': 4200.0,
        'lastTransaction': '2024-08-25',
      },
    ];
  }
}
