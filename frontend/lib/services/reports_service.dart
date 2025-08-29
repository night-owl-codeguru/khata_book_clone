import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ReportsService {
  // Base URL for API - should match AuthService
  static const String _baseUrl = 'https://khata-book-clone.onrender.com/api';

  // Get monthly reports
  static Future<Map<String, dynamic>> getMonthlyReports({
    int? year,
    int? month,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final queryParams = <String, String>{};
      if (year != null) queryParams['year'] = year.toString();
      if (month != null) queryParams['month'] = month.toString();

      final uri = Uri.parse(
        '$_baseUrl/reports/monthly',
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
        return {'success': true, 'reports': data['reports'] ?? []};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get monthly reports',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get category-wise reports (by customer)
  static Future<Map<String, dynamic>> getCategoryReports({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final queryParams = <String, String>{};
      if (startDate != null)
        queryParams['start_date'] = startDate.toUtc().toIso8601String().split(
          'T',
        )[0];
      if (endDate != null)
        queryParams['end_date'] = endDate.toUtc().toIso8601String().split(
          'T',
        )[0];

      final uri = Uri.parse(
        '$_baseUrl/reports/categories',
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
        return {'success': true, 'reports': data['reports'] ?? []};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get category reports',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get payment method reports
  static Future<Map<String, dynamic>> getPaymentMethodReports({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final queryParams = <String, String>{};
      if (startDate != null)
        queryParams['start_date'] = startDate.toUtc().toIso8601String().split(
          'T',
        )[0];
      if (endDate != null)
        queryParams['end_date'] = endDate.toUtc().toIso8601String().split(
          'T',
        )[0];

      final uri = Uri.parse(
        '$_baseUrl/reports/payment-methods',
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
        return {'success': true, 'reports': data['reports'] ?? []};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get payment method reports',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Mock data for development/testing when backend is not available
  static List<Map<String, dynamic>> getMockMonthlyReports() {
    return [
      {
        'month': '2024-08',
        'total_credit': 12500.0,
        'total_debit': 8750.0,
        'balance': 3750.0,
      },
      {
        'month': '2024-07',
        'total_credit': 11800.0,
        'total_debit': 9200.0,
        'balance': 2600.0,
      },
      {
        'month': '2024-06',
        'total_credit': 13200.0,
        'total_debit': 10100.0,
        'balance': 3100.0,
      },
    ];
  }

  static List<Map<String, dynamic>> getMockCategoryReports() {
    return [
      {
        'customer_id': 1,
        'customer_name': 'Ramesh Traders',
        'total_credit': 8500.0,
        'total_debit': 6200.0,
        'balance': 2300.0,
        'transaction_count': 15,
      },
      {
        'customer_id': 2,
        'customer_name': 'Mohan Kirana',
        'total_credit': 4200.0,
        'total_debit': 5800.0,
        'balance': -1600.0,
        'transaction_count': 12,
      },
      {
        'customer_id': 3,
        'customer_name': 'Sita Textiles',
        'total_credit': 6800.0,
        'total_debit': 4500.0,
        'balance': 2300.0,
        'transaction_count': 18,
      },
    ];
  }

  static List<Map<String, dynamic>> getMockPaymentMethodReports() {
    return [
      {
        'method': 'cash',
        'transaction_count': 45,
        'total_amount': 28500.0,
        'average_amount': 633.33,
      },
      {
        'method': 'upi',
        'transaction_count': 32,
        'total_amount': 19800.0,
        'average_amount': 618.75,
      },
      {
        'method': 'bank',
        'transaction_count': 23,
        'total_amount': 14200.0,
        'average_amount': 617.39,
      },
    ];
  }
}
