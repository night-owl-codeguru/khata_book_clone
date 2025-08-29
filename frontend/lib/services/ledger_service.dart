import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class LedgerService {
  // Base URL for API - should match AuthService
  static const String _baseUrl = 'https://khata-book-clone.onrender.com/api';

  // Create a new ledger entry (credit or debit)
  static Future<Map<String, dynamic>> createLedgerEntry({
    required int customerId,
    required String type, // 'credit' or 'debit'
    required double amount,
    required String method, // 'cash', 'upi', 'bank'
    String? note,
    DateTime? date,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final requestBody = {
        'customer_id': customerId,
        'type': type,
        'amount': amount,
        'method': method,
        if (note != null && note.isNotEmpty) 'note': note,
        if (date != null)
          'date': date
              .toUtc()
              .toIso8601String(), // RFC3339 format for Go backend
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/ledger'),
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
          'message': 'Ledger entry created successfully',
          'entry': data['entry'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create ledger entry',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get ledger entries with optional filters
  static Future<Map<String, dynamic>> getLedgerEntries({
    int? customerId,
    String? type, // 'credit' or 'debit'
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final queryParams = <String, String>{};
      if (customerId != null)
        queryParams['customer_id'] = customerId.toString();
      if (type != null) queryParams['type'] = type;
      queryParams['limit'] = limit.toString();
      queryParams['offset'] = offset.toString();

      final uri = Uri.parse(
        '$_baseUrl/ledger',
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
          'entries': data['entries'] ?? [],
          'count': data['count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get ledger entries',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get a specific ledger entry by ID
  static Future<Map<String, dynamic>> getLedgerEntry(int entryId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No authentication token found'};
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/ledger/$entryId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        return {'success': true, 'entry': data['entry']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get ledger entry',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Helper method to create a credit entry
  static Future<Map<String, dynamic>> createCreditEntry({
    required int customerId,
    required double amount,
    required String method,
    String? note,
    DateTime? date,
  }) {
    return createLedgerEntry(
      customerId: customerId,
      type: 'credit',
      amount: amount,
      method: method,
      note: note,
      date: date,
    );
  }

  // Helper method to create a debit entry
  static Future<Map<String, dynamic>> createDebitEntry({
    required int customerId,
    required double amount,
    required String method,
    String? note,
    DateTime? date,
  }) {
    return createLedgerEntry(
      customerId: customerId,
      type: 'debit',
      amount: amount,
      method: method,
      note: note,
      date: date,
    );
  }
}
