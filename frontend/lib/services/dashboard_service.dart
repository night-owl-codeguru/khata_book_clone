import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class DashboardService {
  // Base URL for API - should match AuthService
  static const String _baseUrl = 'https://khata-book-clone.onrender.com/api';

  // Get dashboard summary data
  static Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/dashboard'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get dashboard data',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Mock data for development/testing when backend is not available
  static Map<String, dynamic> getMockDashboardData() {
    return {
      'total_credit': 12500.0,
      'total_debit': 8750.0,
      'balance': 3750.0,
      'latest_entries': [
        {
          'id': 1,
          'customer': 'Ramesh Traders',
          'type': 'credit',
          'amount': 2500.0,
          'date': '2024-08-29',
          'method': 'cash',
        },
        {
          'id': 2,
          'customer': 'Mohan Kirana',
          'type': 'debit',
          'amount': 1200.0,
          'date': '2024-08-28',
          'method': 'upi',
        },
        {
          'id': 3,
          'customer': 'Sita Textiles',
          'type': 'credit',
          'amount': 1800.0,
          'date': '2024-08-27',
          'method': 'bank',
        },
      ],
    };
  }
}
