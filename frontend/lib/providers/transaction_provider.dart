import 'package:flutter/foundation.dart';
import '../models/transaction.dart' as app_models;
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final ApiService _apiService = ApiService();

  List<app_models.Transaction> _transactions = [];
  app_models.Transaction? _selectedTransaction;
  bool _isLoading = false;
  String? _error;

  // Pagination
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  // Customer transactions
  List<app_models.Transaction> _customerTransactions = [];

  // Getters
  List<app_models.Transaction> get transactions => _transactions;
  app_models.Transaction? get selectedTransaction => _selectedTransaction;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;
  List<app_models.Transaction> get customerTransactions =>
      _customerTransactions;

  // Load transactions from local database
  Future<void> loadTransactions({
    int? customerId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _transactions.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final transactions = await _dbService.getTransactions(
        customerId: customerId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );

      if (refresh) {
        _transactions = transactions;
      } else {
        _transactions.addAll(transactions);
      }

      _hasMoreData = transactions.length == _pageSize;
      _currentPage++;

      notifyListeners();
    } catch (e) {
      _error = 'Failed to load transactions: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load more transactions (pagination)
  Future<void> loadMoreTransactions({
    int? customerId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_isLoading || !_hasMoreData) return;

    await loadTransactions(
      customerId: customerId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      refresh: false,
    );
  }

  // Add new transaction
  Future<bool> addTransaction(app_models.Transaction transaction) async {
    _setLoading(true);
    _clearError();

    try {
      // Save to local database first
      final id = await _dbService.insertTransaction(transaction);

      // Create transaction with the new ID
      final newTransaction = transaction.copyWith(id: id);

      // Add to local list at the beginning (most recent first)
      _transactions.insert(0, newTransaction);

      notifyListeners();

      // Try to sync with server (optional for MVP)
      _syncTransactionToServer(newTransaction);

      return true;
    } catch (e) {
      _error = 'Failed to add transaction: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update transaction
  Future<bool> updateTransaction(app_models.Transaction transaction) async {
    _setLoading(true);
    _clearError();

    try {
      // Update in local database
      await _dbService.updateTransaction(transaction);

      // Update in local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }

      // Update selected transaction if it's the same
      if (_selectedTransaction?.id == transaction.id) {
        _selectedTransaction = transaction;
      }

      notifyListeners();

      // Try to sync with server (optional for MVP)
      _syncTransactionToServer(transaction);

      return true;
    } catch (e) {
      _error = 'Failed to update transaction: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(int transactionId) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete from local database
      await _dbService.deleteTransaction(transactionId);

      // Remove from local list
      _transactions.removeWhere((t) => t.id == transactionId);

      // Clear selected transaction if it's the deleted one
      if (_selectedTransaction?.id == transactionId) {
        _selectedTransaction = null;
      }

      notifyListeners();

      // Try to sync with server (optional for MVP)
      _deleteTransactionFromServer(transactionId);

      return true;
    } catch (e) {
      _error = 'Failed to delete transaction: ${e.toString()}';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Select transaction
  void selectTransaction(app_models.Transaction transaction) {
    _selectedTransaction = transaction;
    notifyListeners();
  }

  // Clear selected transaction
  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }

  // Get transaction by ID
  Future<app_models.Transaction?> getTransaction(int id) async {
    try {
      return await _dbService.getTransaction(id);
    } catch (e) {
      _error = 'Failed to get transaction: ${e.toString()}';
      return null;
    }
  }

  // Search transactions
  Future<void> searchTransactions(String query) async {
    _setLoading(true);
    _clearError();

    try {
      _transactions = await _dbService.searchTransactions(query);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search transactions: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Get transactions for specific customer
  Future<void> loadCustomerTransactions(int customerId) async {
    await loadTransactions(customerId: customerId, refresh: true);
  }

  // Load transactions for a specific customer
  Future<void> loadTransactionsByCustomer(int customerId) async {
    _setLoading(true);
    _clearError();

    try {
      _customerTransactions =
          await _dbService.getTransactions(customerId: customerId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load customer transactions: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Get today's transactions
  List<app_models.Transaction> get todaysTransactions {
    final today = DateTime.now();
    return _transactions.where((transaction) {
      return transaction.date.year == today.year &&
          transaction.date.month == today.month &&
          transaction.date.day == today.day;
    }).toList();
  }

  // Get this week's transactions
  List<app_models.Transaction> get thisWeeksTransactions {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _transactions.where((transaction) {
      return transaction.date.isAfter(weekStart) ||
          transaction.date.isAtSameMomentAs(weekStart);
    }).toList();
  }

  // Get this month's transactions
  List<app_models.Transaction> get thisMonthsTransactions {
    final now = DateTime.now();
    return _transactions.where((transaction) {
      return transaction.date.year == now.year &&
          transaction.date.month == now.month;
    }).toList();
  }

  // Get credit transactions
  List<app_models.Transaction> get creditTransactions {
    return _transactions
        .where((t) => t.type == app_models.TransactionType.credit)
        .toList();
  }

  // Get debit transactions
  List<app_models.Transaction> get debitTransactions {
    return _transactions
        .where((t) => t.type == app_models.TransactionType.debit)
        .toList();
  }

  // Calculate totals
  double get totalCredit {
    return _transactions
        .where((t) => t.type == app_models.TransactionType.credit)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalDebit {
    return _transactions
        .where((t) => t.type == app_models.TransactionType.debit)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get netAmount {
    return totalCredit - totalDebit;
  }

  // Today's totals
  double get todaysTotalCredit {
    return todaysTransactions
        .where((t) => t.type == app_models.TransactionType.credit)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get todaysTotalDebit {
    return todaysTransactions
        .where((t) => t.type == app_models.TransactionType.debit)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double get todaysNetAmount {
    return todaysTotalCredit - todaysTotalDebit;
  }

  // Recent transactions
  List<app_models.Transaction> get recentTransactions {
    final sorted = [..._transactions];
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  // Transaction count
  int get transactionCount => _transactions.length;

  // Get total balance summary
  Future<Map<String, double>> getTotalBalance() async {
    try {
      return await _dbService.getTotalBalance();
    } catch (e) {
      return {
        'total_credit': 0.0,
        'total_debit': 0.0,
        'net_balance': 0.0,
      };
    }
  }

  // Get transactions by date range
  List<app_models.Transaction> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactions.where((transaction) {
      return transaction.date
              .isAfter(start.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get transactions by category
  List<app_models.Transaction> getTransactionsByCategory(String category) {
    return _transactions
        .where((transaction) => transaction.category == category)
        .toList();
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

  // Reset pagination
  void resetPagination() {
    _currentPage = 0;
    _hasMoreData = true;
  }

  // Server sync methods (for future implementation)
  void _syncTransactionToServer(app_models.Transaction transaction) async {
    try {
      if (transaction.id != null) {
        // Update existing transaction
        await _apiService.put('${ApiEndpoints.transactions}/${transaction.id}',
            transaction.toJson());
      } else {
        // Create new transaction
        await _apiService.post(
            ApiEndpoints.transactionsCreate, transaction.toJson());
      }
    } catch (e) {
      debugPrint('Failed to sync transaction to server: $e');
    }
  }

  void _deleteTransactionFromServer(int transactionId) async {
    try {
      await _apiService.delete('${ApiEndpoints.transactions}/$transactionId');
    } catch (e) {
      debugPrint('Failed to delete transaction from server: $e');
    }
  }

  // Sync with server (for future implementation)
  Future<void> syncWithServer() async {
    try {
      final response = await _apiService.get(ApiEndpoints.transactions);
      if (response['success'] == true) {
        final serverTransactions = (response['data'] as List)
            .map((json) => app_models.Transaction.fromJson(json))
            .toList();

        // Simple sync: replace local data with server data
        // In a real app, you'd implement conflict resolution
        _transactions = serverTransactions;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to sync with server: $e');
    }
  }
}
