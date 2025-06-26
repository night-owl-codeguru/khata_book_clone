import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/customer_provider.dart';
import '../../utils/constants.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  String _selectedFilter = 'all';
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          if (_selectedFilter != 'all' || _dateRange != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.background,
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedFilter != 'all')
                    Chip(
                      label: Text(_selectedFilter.toUpperCase()),
                      onDeleted: () {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                        _applyFilters();
                      },
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  if (_dateRange != null)
                    Chip(
                      label: Text(
                        '${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}',
                      ),
                      onDeleted: () {
                        setState(() {
                          _dateRange = null;
                        });
                        _applyFilters();
                      },
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                ],
              ),
            ),

          // Transaction List
          Expanded(
            child: Consumer2<TransactionProvider, CustomerProvider>(
              builder: (context, transactionProvider, customerProvider, child) {
                if (transactionProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                final transactions = transactionProvider.transactions;

                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first transaction to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      transactionProvider.loadTransactions(refresh: true),
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final customer = customerProvider
                          .getCustomerById(transaction.customerId);
                      final isCredit = transaction.type == 'credit';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isCredit
                                ? AppColors.warning
                                : AppColors.success,
                            child: Icon(
                              isCredit
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(customer?.name ?? 'Unknown Customer'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(transaction.description),
                              const SizedBox(height: 4),
                              Text(
                                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${transaction.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCredit
                                      ? AppColors.warning
                                      : AppColors.success,
                                ),
                              ),
                              Text(
                                isCredit ? 'CREDIT' : 'DEBIT',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isCredit
                                      ? AppColors.warning
                                      : AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          onTap: () =>
                              _showTransactionDetails(transaction, customer),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Transactions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Radio<String>(
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
            ),
            ListTile(
              title: const Text('Credit'),
              leading: Radio<String>(
                value: 'credit',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
            ),
            ListTile(
              title: const Text('Debit'),
              leading: Radio<String>(
                value: 'debit',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                  _applyFilters();
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Select Date Range'),
              leading: const Icon(Icons.date_range),
              onTap: () async {
                Navigator.pop(context);
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDateRange: _dateRange,
                );
                if (picked != null) {
                  setState(() {
                    _dateRange = picked;
                  });
                  _applyFilters();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    final transactionProvider = context.read<TransactionProvider>();
    transactionProvider.loadTransactions(
      type: _selectedFilter == 'all' ? null : _selectedFilter,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
      refresh: true,
    );
  }

  void _showTransactionDetails(dynamic transaction, dynamic customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer?.name ?? 'Unknown Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${transaction.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Type: ${transaction.type.toUpperCase()}'),
            const SizedBox(height: 8),
            Text('Description: ${transaction.description}'),
            const SizedBox(height: 8),
            Text(
                'Date: ${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
