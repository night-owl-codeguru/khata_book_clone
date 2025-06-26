import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/transaction.dart' as app_models;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'khatabook.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Create customers table
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        balance REAL DEFAULT 0.0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        type TEXT NOT NULL CHECK (type IN ('credit', 'debit')),
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        category TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    // Create indices for better performance
    await db.execute('CREATE INDEX idx_customer_name ON customers (name)');
    await db.execute(
        'CREATE INDEX idx_transaction_customer ON transactions (customer_id)');
    await db
        .execute('CREATE INDEX idx_transaction_date ON transactions (date)');
    await db
        .execute('CREATE INDEX idx_transaction_type ON transactions (type)');
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  // Customer operations
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    final data = customer.toJson();
    data.remove('id'); // Remove id for auto-increment
    return await db.insert('customers', data);
  }

  Future<List<Customer>> getCustomers({String? search}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: search != null && search.isNotEmpty
          ? 'name LIKE ? OR phone LIKE ? OR email LIKE ?'
          : null,
      whereArgs: search != null && search.isNotEmpty
          ? ['%$search%', '%$search%', '%$search%']
          : null,
      orderBy: 'name ASC',
    );

    return maps.map((map) => Customer.fromJson(map)).toList();
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toJson(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    // Also delete all transactions for this customer
    await db.delete('transactions', where: 'customer_id = ?', whereArgs: [id]);
    return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  // Transaction operations
  Future<int> insertTransaction(app_models.Transaction transaction) async {
    final db = await database;
    final data = transaction.toJson();
    data.remove('id'); // Remove id for auto-increment

    // Start a transaction to update customer balance
    return await db.transaction((txn) async {
      final transactionId = await txn.insert('transactions', data);
      await _updateCustomerBalance(txn, transaction.customerId);
      return transactionId;
    });
  }

  Future<List<app_models.Transaction>> getTransactions({
    int? customerId,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    String query = 'SELECT * FROM transactions';
    List<dynamic> arguments = [];
    List<String> conditions = [];

    if (customerId != null) {
      conditions.add('customer_id = ?');
      arguments.add(customerId);
    }

    if (type != null) {
      conditions.add('type = ?');
      arguments.add(type);
    }

    if (startDate != null) {
      conditions.add('date >= ?');
      arguments.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      conditions.add('date <= ?');
      arguments.add(endDate.toIso8601String().split('T')[0]);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY date DESC, created_at DESC';

    if (limit != null) {
      query += ' LIMIT $limit';
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(query, arguments);
    return maps.map((map) => app_models.Transaction.fromJson(map)).toList();
  }

  Future<app_models.Transaction?> getTransaction(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return app_models.Transaction.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateTransaction(app_models.Transaction transaction) async {
    final db = await database;
    return await db.transaction((txn) async {
      final result = await txn.update(
        'transactions',
        transaction.toJson(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
      await _updateCustomerBalance(txn, transaction.customerId);
      return result;
    });
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.transaction((txn) async {
      // Get the transaction to find customer ID
      final transaction = await getTransaction(id);
      if (transaction != null) {
        final result =
            await txn.delete('transactions', where: 'id = ?', whereArgs: [id]);
        await _updateCustomerBalance(txn, transaction.customerId);
        return result;
      }
      return 0;
    });
  }

  // Update customer balance based on transactions
  Future<void> _updateCustomerBalance(
      DatabaseExecutor db, int customerId) async {
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) as total_credit,
        SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END) as total_debit
      FROM transactions 
      WHERE customer_id = ?
    ''', [customerId]);

    final totalCredit =
        (result.first['total_credit'] as num?)?.toDouble() ?? 0.0;
    final totalDebit = (result.first['total_debit'] as num?)?.toDouble() ?? 0.0;
    final balance = totalCredit - totalDebit;

    await db.update(
      'customers',
      {'balance': balance, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  // Get customer balance
  Future<double> getCustomerBalance(int customerId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) as total_credit,
        SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END) as total_debit
      FROM transactions 
      WHERE customer_id = ?
    ''', [customerId]);

    final totalCredit =
        (result.first['total_credit'] as num?)?.toDouble() ?? 0.0;
    final totalDebit = (result.first['total_debit'] as num?)?.toDouble() ?? 0.0;
    return totalCredit - totalDebit;
  }

  // Get total business balance
  Future<Map<String, double>> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END) as total_credit,
        SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END) as total_debit
      FROM transactions
    ''');

    final totalCredit =
        (result.first['total_credit'] as num?)?.toDouble() ?? 0.0;
    final totalDebit = (result.first['total_debit'] as num?)?.toDouble() ?? 0.0;
    final netBalance = totalCredit - totalDebit;

    return {
      'total_credit': totalCredit,
      'total_debit': totalDebit,
      'net_balance': netBalance,
    };
  }

  // Search transactions
  Future<List<app_models.Transaction>> searchTransactions(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'description LIKE ? OR customer_name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'date DESC, created_at DESC',
    );

    return maps.map((map) => app_models.Transaction.fromJson(map)).toList();
  }

  // Get transaction count for customer
  Future<int> getCustomerTransactionCount(int customerId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE customer_id = ?',
      [customerId],
    );
    return result.first['count'] as int;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('transactions');
    await db.delete('customers');
  }
}
