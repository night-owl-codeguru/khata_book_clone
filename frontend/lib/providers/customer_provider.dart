import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class CustomerProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final ApiService _apiService = ApiService();

  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load customers from local database
  Future<void> loadCustomers({String? search}) async {
    _setLoading(true);
    _clearError();

    try {
      _customers = await _dbService.getCustomers(search: search);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load customers: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Add new customer
  Future<bool> addCustomer(Customer customer) async {
    _setLoading(true);
    _clearError();

    try {
      // Save to local database first
      final id = await _dbService.insertCustomer(customer);

      // Create customer with the new ID
      final newCustomer = customer.copyWith(id: id);

      // Add to local list
      _customers.add(newCustomer);
      _customers.sort((a, b) => a.name.compareTo(b.name));

      notifyListeners();

      // Try to sync with server (optional for MVP)
      _syncCustomerToServer(newCustomer);

      return true;
    } catch (e) {
      _error = 'Failed to add customer: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update customer
  Future<bool> updateCustomer(Customer customer) async {
    _setLoading(true);
    _clearError();

    try {
      // Update in local database
      await _dbService.updateCustomer(customer);

      // Update in local list
      final index = _customers.indexWhere((c) => c.id == customer.id);
      if (index != -1) {
        _customers[index] = customer;
        _customers.sort((a, b) => a.name.compareTo(b.name));
      }

      // Update selected customer if it's the same
      if (_selectedCustomer?.id == customer.id) {
        _selectedCustomer = customer;
      }

      notifyListeners();

      // Try to sync with server (optional for MVP)
      _syncCustomerToServer(customer);

      return true;
    } catch (e) {
      _error = 'Failed to update customer: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete customer
  Future<bool> deleteCustomer(int customerId) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete from local database
      await _dbService.deleteCustomer(customerId);

      // Remove from local list
      _customers.removeWhere((c) => c.id == customerId);

      // Clear selected customer if it's the deleted one
      if (_selectedCustomer?.id == customerId) {
        _selectedCustomer = null;
      }

      notifyListeners();

      // Try to sync with server (optional for MVP)
      _deleteCustomerFromServer(customerId);

      return true;
    } catch (e) {
      _error = 'Failed to delete customer: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select customer
  void selectCustomer(Customer customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  // Clear selected customer
  void clearSelectedCustomer() {
    _selectedCustomer = null;
    notifyListeners();
  }

  // Get customer by ID
  Future<Customer?> getCustomer(int id) async {
    try {
      return await _dbService.getCustomer(id);
    } catch (e) {
      _error = 'Failed to get customer: ${e.toString()}';
      return null;
    }
  }

  // Get customer by ID
  Customer? getCustomerById(int id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  // Search customers
  Future<void> searchCustomers(String query) async {
    await loadCustomers(search: query);
  }

  // Get customers with positive balance (customers who owe money)
  List<Customer> get customersWithCredit {
    return _customers.where((customer) => customer.balance > 0).toList();
  }

  // Get customers with negative balance (customers you owe money)
  List<Customer> get customersWithDebit {
    return _customers.where((customer) => customer.balance < 0).toList();
  }

  // Get total amount to receive
  double get totalToReceive {
    return _customers
        .where((customer) => customer.balance > 0)
        .fold(0.0, (sum, customer) => sum + customer.balance);
  }

  // Get total amount to pay
  double get totalToPay {
    return _customers
        .where((customer) => customer.balance < 0)
        .fold(0.0, (sum, customer) => sum + customer.balance.abs());
  }

  // Get net balance
  double get netBalance {
    return _customers.fold(0.0, (sum, customer) => sum + customer.balance);
  }

  // Get total balance across all customers
  double get totalBalance {
    return _customers.fold(0.0, (sum, customer) => sum + customer.balance);
  }

  // Refresh customer balance
  Future<void> refreshCustomerBalance(int customerId) async {
    try {
      final balance = await _dbService.getCustomerBalance(customerId);
      final index = _customers.indexWhere((c) => c.id == customerId);

      if (index != -1) {
        _customers[index] = _customers[index].copyWith(balance: balance);

        if (_selectedCustomer?.id == customerId) {
          _selectedCustomer = _customers[index];
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to refresh customer balance: $e');
    }
  }

  // Get customer count
  int get customerCount => _customers.length;

  // Check if customer exists by name
  bool customerExistsByName(String name, {int? excludeId}) {
    return _customers.any((customer) =>
        customer.name.toLowerCase() == name.toLowerCase() &&
        customer.id != excludeId);
  }

  // Check if customer exists by phone
  bool customerExistsByPhone(String phone, {int? excludeId}) {
    return _customers
        .any((customer) => customer.phone == phone && customer.id != excludeId);
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

  // Server sync methods (for future implementation)
  void _syncCustomerToServer(Customer customer) async {
    try {
      if (customer.id != null) {
        // Update existing customer
        await _apiService.put(
            '${ApiEndpoints.customers}/${customer.id}', customer.toJson());
      } else {
        // Create new customer
        await _apiService.post(ApiEndpoints.customersCreate, customer.toJson());
      }
    } catch (e) {
      debugPrint('Failed to sync customer to server: $e');
    }
  }

  void _deleteCustomerFromServer(int customerId) async {
    try {
      await _apiService.delete('${ApiEndpoints.customers}/$customerId');
    } catch (e) {
      debugPrint('Failed to delete customer from server: $e');
    }
  }

  // Sync with server (for future implementation)
  Future<void> syncWithServer() async {
    try {
      final response = await _apiService.get(ApiEndpoints.customers);
      if (response['success'] == true) {
        final serverCustomers = (response['data'] as List)
            .map((json) => Customer.fromJson(json))
            .toList();

        // Simple sync: replace local data with server data
        // In a real app, you'd implement conflict resolution
        _customers = serverCustomers;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to sync with server: $e');
    }
  }
}
