import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/ledger_service.dart';
import '../services/customer_service.dart';

class BackupService {
  static const _secureStorage = FlutterSecureStorage();
  static const _backupKey = 'backup_encryption_key';

  static Future<String> _getBackupDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir.path;
  }

  static Future<String> _getEncryptionKey() async {
    String? key = await _secureStorage.read(key: _backupKey);
    if (key == null) {
      // Generate a new encryption key (in a real app, you'd use proper encryption)
      key = DateTime.now().millisecondsSinceEpoch.toString();
      await _secureStorage.write(key: _backupKey, value: key);
    }
    return key;
  }

  static Future<String> createBackup({
    String? password,
    bool includeCustomers = true,
    bool includeTransactions = true,
  }) async {
    try {
      final backupData = <String, dynamic>{
        'version': '1.0',
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'ledger_backup',
      };

      // Collect customer data
      if (includeCustomers) {
        final customersResult = await CustomerService.getCustomers();
        if (customersResult['success']) {
          backupData['customers'] = customersResult['customers'];
        }
      }

      // Collect transaction data
      if (includeTransactions) {
        final transactionsResult = await LedgerService.getLedgerEntries(
          limit: 10000,
        );
        if (transactionsResult['success']) {
          backupData['transactions'] = transactionsResult['entries'];
        }
      }

      // Convert to JSON
      final jsonString = jsonEncode(backupData);

      // Simple encryption (in production, use proper encryption)
      final encryptionKey = await _getEncryptionKey();
      final encryptedData = _simpleEncrypt(jsonString, encryptionKey);

      // Save to file
      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'ledger_backup_$timestamp.lbk';
      final filePath = '$backupDir/$fileName';

      final file = File(filePath);
      await file.writeAsString(encryptedData);

      return filePath;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  static Future<void> restoreFromBackup(
    String filePath, {
    String? password,
  }) async {
    try {
      // Read backup file
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final encryptedData = await file.readAsString();

      // Decrypt data
      final encryptionKey = await _getEncryptionKey();
      final jsonString = _simpleDecrypt(encryptedData, encryptionKey);

      // Parse JSON
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup format
      if (backupData['type'] != 'ledger_backup') {
        throw Exception('Invalid backup file format');
      }

      // Restore customers
      if (backupData.containsKey('customers')) {
        final customers = List<Map<String, dynamic>>.from(
          backupData['customers'],
        );
        for (final customer in customers) {
          // Note: In a real implementation, you'd call your API to restore customers
          // For now, we'll just validate the data structure
          if (!customer.containsKey('name') || !customer.containsKey('phone')) {
            throw Exception('Invalid customer data in backup');
          }
        }
      }

      // Restore transactions
      if (backupData.containsKey('transactions')) {
        final transactions = List<Map<String, dynamic>>.from(
          backupData['transactions'],
        );
        for (final transaction in transactions) {
          // Note: In a real implementation, you'd call your API to restore transactions
          // For now, we'll just validate the data structure
          if (!transaction.containsKey('type') ||
              !transaction.containsKey('amount')) {
            throw Exception('Invalid transaction data in backup');
          }
        }
      }

      // In a real implementation, you would:
      // 1. Clear existing data
      // 2. Restore customers via API
      // 3. Restore transactions via API
      // 4. Validate restoration

      throw Exception('Restore functionality requires backend API integration');
    } catch (e) {
      throw Exception('Failed to restore backup: $e');
    }
  }

  static Future<void> shareBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(filePath)], text: 'Ledger Backup File');
      } else {
        throw Exception('Backup file not found');
      }
    } catch (e) {
      throw Exception('Failed to share backup: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getBackupHistory() async {
    try {
      final backupDir = await _getBackupDirectory();
      final directory = Directory(backupDir);

      if (!await directory.exists()) {
        return [];
      }

      final files = await directory.list().toList();
      final backupFiles = <Map<String, dynamic>>[];

      for (final file in files) {
        if (file is File && file.path.endsWith('.lbk')) {
          final stat = await file.stat();
          final fileName = file.path.split('/').last;

          // Try to read backup metadata
          try {
            final content = await file.readAsString();
            final encryptionKey = await _getEncryptionKey();
            final jsonString = _simpleDecrypt(content, encryptionKey);
            final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

            backupFiles.add({
              'filePath': file.path,
              'fileName': fileName,
              'timestamp':
                  backupData['timestamp'] ?? stat.modified.toIso8601String(),
              'size': stat.size,
              'version': backupData['version'] ?? 'Unknown',
            });
          } catch (e) {
            // If we can't read the file, add basic info
            backupFiles.add({
              'filePath': file.path,
              'fileName': fileName,
              'timestamp': stat.modified.toIso8601String(),
              'size': stat.size,
              'version': 'Unknown',
            });
          }
        }
      }

      // Sort by timestamp (newest first)
      backupFiles.sort((a, b) {
        final aTime = DateTime.parse(a['timestamp']);
        final bTime = DateTime.parse(b['timestamp']);
        return bTime.compareTo(aTime);
      });

      return backupFiles;
    } catch (e) {
      throw Exception('Failed to get backup history: $e');
    }
  }

  static Future<void> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }

  static Future<Map<String, dynamic>> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final stat = await file.stat();
      final content = await file.readAsString();
      final encryptionKey = await _getEncryptionKey();
      final jsonString = _simpleDecrypt(content, encryptionKey);
      final backupData = jsonDecode(jsonString) as Map<String, dynamic>;

      return {
        'filePath': filePath,
        'fileName': filePath.split('/').last,
        'timestamp': backupData['timestamp'],
        'version': backupData['version'],
        'size': stat.size,
        'customerCount': backupData['customers']?.length ?? 0,
        'transactionCount': backupData['transactions']?.length ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to read backup info: $e');
    }
  }

  // Simple encryption/decryption for demo purposes
  // In production, use proper encryption libraries
  static String _simpleEncrypt(String data, String key) {
    final bytes = utf8.encode(data);
    final keyBytes = utf8.encode(key);
    final encrypted = <int>[];

    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }

    return base64Encode(encrypted);
  }

  static String _simpleDecrypt(String encryptedData, String key) {
    final encrypted = base64Decode(encryptedData);
    final keyBytes = utf8.encode(key);
    final decrypted = <int>[];

    for (int i = 0; i < encrypted.length; i++) {
      decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
    }

    return utf8.decode(decrypted);
  }
}
