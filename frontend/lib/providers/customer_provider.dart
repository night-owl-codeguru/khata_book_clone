import 'package:flutter/foundation.dart';
import '../services/customer_service.dart';

class CustomerProvider with ChangeNotifier {
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get filtered customers based on search query
  List<Map<String, dynamic>> getFilteredCustomers(String query) {
    if (query.isEmpty) {
      return _customers;
    }
    return _customers.where((customer) {
      final name = customer['name'].toString().toLowerCase();
      final phone = customer['phone'].toString();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || phone.contains(searchQuery);
    }).toList();
  }

  // Load customers from API
  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await CustomerService.getCustomers();

      if (result['success']) {
        _customers = List<Map<String, dynamic>>.from(result['customers'] ?? []);
      } else {
        _error = result['message'] ?? 'Failed to load customers';
        // Fallback to mock data if API fails
        _customers = CustomerService.getMockCustomers();
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      // Fallback to mock data if network fails
      _customers = CustomerService.getMockCustomers();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new customer
  Future<bool> createCustomer({
    required String name,
    String? phone,
    String? note,
  }) async {
    try {
      final result = await CustomerService.createCustomer(
        name: name,
        phone: phone,
        note: note,
      );

      if (result['success']) {
        // Reload customers to get the updated list
        await loadCustomers();
        return true;
      } else {
        _error = result['message'] ?? 'Failed to create customer';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // Get a specific customer by ID
  Future<Map<String, dynamic>?> getCustomer(int customerId) async {
    try {
      final result = await CustomerService.getCustomer(customerId);

      if (result['success']) {
        return result['customer'];
      } else {
        _error = result['message'] ?? 'Failed to get customer';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
