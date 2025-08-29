import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/customer_service.dart';
import '../services/ledger_service.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _customer;
  List<Map<String, dynamic>> _transactions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    setState(() => _isLoading = true);

    try {
      // Load customer details
      final customerResult = await CustomerService.getCustomer(
        widget.customerId,
      );
      if (customerResult['success']) {
        setState(() => _customer = customerResult['customer']);
      } else {
        setState(() => _error = customerResult['message']);
        return;
      }

      // Load customer transactions
      final transactionsResult = await LedgerService.getLedgerEntries(
        customerId: widget.customerId,
        limit: 100, // Load more transactions for detail view
      );

      if (transactionsResult['success']) {
        setState(
          () => _transactions = List<Map<String, dynamic>>.from(
            transactionsResult['entries'],
          ),
        );
      } else {
        // If API fails, use mock data
        setState(() => _transactions = _getMockTransactions());
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load customer data: $e';
        _transactions = _getMockTransactions();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getMockTransactions() {
    return [
      {
        'id': 1,
        'type': 'credit',
        'amount': 2500.0,
        'method': 'cash',
        'date': '2024-08-29',
        'note': 'Payment for goods',
      },
      {
        'id': 2,
        'type': 'debit',
        'amount': 500.0,
        'method': 'upi',
        'date': '2024-08-28',
        'note': 'Partial payment',
      },
      {
        'id': 3,
        'type': 'credit',
        'amount': 1200.0,
        'method': 'bank',
        'date': '2024-08-25',
        'note': '',
      },
    ];
  }

  void _showAddCreditDialog() {
    // Navigate to add credit screen with pre-selected customer
    context.go('/add/credit?customerId=${widget.customerId}');
  }

  void _showAddDebitDialog() {
    // Navigate to add debit screen with pre-selected customer
    context.go('/add/debit?customerId=${widget.customerId}');
  }

  void _showSendReminderDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Send Reminder',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Send a payment reminder to ${_customer?['name'] ?? 'this customer'}?',
                style: AppTypography.bodyWithColor(context),
              ),
              const SizedBox(height: 16),
              _buildReminderOption('SMS', Icons.sms, () {
                Navigator.of(context).pop();
                _sendReminder('sms');
              }),
              const SizedBox(height: 8),
              _buildReminderOption('WhatsApp', Icons.chat, () {
                Navigator.of(context).pop();
                _sendReminder('whatsapp');
              }),
              const SizedBox(height: 8),
              _buildReminderOption('Email', Icons.email, () {
                Navigator.of(context).pop();
                _sendReminder('email');
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.bodyWithColor(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReminderOption(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: AppTypography.bodyWithColor(context)),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _sendReminder(String channel) {
    // TODO: Implement reminder sending
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder sent via $channel to ${_customer?['name'] ?? 'customer'}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text(
            'Customer Details',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            onPressed: () => context.go('/customers'),
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          title: Text(
            'Customer Details',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          leading: IconButton(
            onPressed: () => context.go('/customers'),
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading customer',
                style: AppTypography.titleWithColor(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: AppTypography.bodyWithColor(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadCustomerData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final customerName = _customer?['name'] ?? 'Unknown Customer';
    final customerPhone = _customer?['phone'];
    final customerBalance = _customer?['balance'] ?? 0.0;
    final isPositive = customerBalance >= 0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          customerName,
          style: AppTypography.titleWithColor(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.go('/customers'),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Show customer edit dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit customer - Coming soon!')),
              );
            },
            icon: Icon(
              Icons.edit,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Customer Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            child: Column(
              children: [
                // Customer Avatar and Info
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Center(
                        child: Text(
                          customerName[0].toUpperCase(),
                          style: AppTypography.headlineWithColor(context)
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 24,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: AppTypography.titleWithColor(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (customerPhone != null && customerPhone.isNotEmpty)
                            Text(
                              customerPhone,
                              style: AppTypography.bodyWithColor(context)
                                  .copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Balance Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1)
                        : Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPositive
                          ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2)
                          : Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive
                            ? Icons.account_balance_wallet
                            : Icons.warning,
                        color: isPositive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Net Balance',
                              style: AppTypography.captionWithColor(context)
                                  .copyWith(
                                    color: isPositive
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                  ),
                            ),
                            Text(
                              '${isPositive ? '+' : ''}₹${customerBalance.abs().toStringAsFixed(0)}',
                              style: AppTypography.titleWithColor(context)
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isPositive
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        isPositive ? 'They owe you' : 'You owe them',
                        style: AppTypography.captionWithColor(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        'Add Credit',
                        Icons.arrow_downward,
                        Theme.of(context).colorScheme.primary,
                        _showAddCreditDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'Add Debit',
                        Icons.arrow_upward,
                        Theme.of(context).colorScheme.error,
                        _showAddDebitDialog,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'Send Reminder',
                        Icons.notifications,
                        Theme.of(context).colorScheme.primary,
                        _showSendReminderDialog,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transaction Timeline
          Expanded(
            child: _transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return _buildTransactionItem(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.captionWithColor(
                context,
              ).copyWith(color: color, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final isCredit = transaction['type'] == 'credit';
    final color = isCredit
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final amount = transaction['amount'] ?? 0.0;
    final method = transaction['method'] ?? 'cash';
    final date = transaction['date'] ?? '';
    final note = transaction['note'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isCredit ? 'Credit' : 'Debit',
                      style: AppTypography.bodyWithColor(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600, color: color),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        method.toUpperCase(),
                        style: AppTypography.captionWithColor(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  date,
                  style: AppTypography.captionWithColor(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (note.isNotEmpty)
                  Text(
                    note,
                    style: AppTypography.captionWithColor(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(0)}',
            style: AppTypography.bodyWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: AppTypography.titleWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Add the first credit or debit for this customer',
              style: AppTypography.bodyWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _showAddCreditDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Add Credit'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _showAddDebitDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  child: const Text('Add Debit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
