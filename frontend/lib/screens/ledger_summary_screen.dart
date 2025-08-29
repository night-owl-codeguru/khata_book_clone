import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/ledger_service.dart';

class LedgerSummaryScreen extends StatefulWidget {
  const LedgerSummaryScreen({super.key});

  @override
  State<LedgerSummaryScreen> createState() => _LedgerSummaryScreenState();
}

class _LedgerSummaryScreenState extends State<LedgerSummaryScreen> {
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();
  Map<String, dynamic> _summaryData = {};
  List<Map<String, dynamic>> _creditEntries = [];
  List<Map<String, dynamic>> _debitEntries = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load ledger entries for the selected month
      final result = await LedgerService.getLedgerEntries(
        limit: 1000, // Load more entries for summary
      );

      if (result['success']) {
        final entries = List<Map<String, dynamic>>.from(result['entries']);

        // Filter entries for the selected month
        final monthEntries = entries.where((entry) {
          final entryDate = DateTime.parse(entry['date']);
          return entryDate.year == _selectedMonth.year &&
              entryDate.month == _selectedMonth.month;
        }).toList();

        // Separate credits and debits
        _creditEntries = monthEntries
            .where((entry) => entry['type'] == 'credit')
            .toList();
        _debitEntries = monthEntries
            .where((entry) => entry['type'] == 'debit')
            .toList();

        // Calculate summary
        final totalCredits = _creditEntries.fold<double>(
          0,
          (sum, entry) => sum + (entry['amount'] ?? 0),
        );
        final totalDebits = _debitEntries.fold<double>(
          0,
          (sum, entry) => sum + (entry['amount'] ?? 0),
        );
        final balance = totalCredits - totalDebits;

        setState(() {
          _summaryData = {
            'totalCredits': totalCredits,
            'totalDebits': totalDebits,
            'balance': balance,
            'creditCount': _creditEntries.length,
            'debitCount': _debitEntries.length,
          };
        });
      } else {
        // Use mock data if API fails
        _loadMockData();
      }
    } catch (e) {
      setState(() => _error = 'Failed to load data: $e');
      _loadMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadMockData() {
    _creditEntries = [
      {
        'customer_name': 'Ramesh Traders',
        'date': '2024-08-29',
        'amount': 2500.0,
        'method': 'cash',
      },
      {
        'customer_name': 'Sita Textiles',
        'date': '2024-08-27',
        'amount': 1200.0,
        'method': 'bank',
      },
      {
        'customer_name': 'Anand Dairy',
        'date': '2024-08-25',
        'amount': 800.0,
        'method': 'upi',
      },
    ];

    _debitEntries = [
      {
        'customer_name': 'Mohan Kirana',
        'date': '2024-08-28',
        'amount': 500.0,
        'method': 'upi',
      },
      {
        'customer_name': 'Vijay Hardware',
        'date': '2024-08-26',
        'amount': 300.0,
        'method': 'cash',
      },
    ];

    final totalCredits = _creditEntries.fold<double>(
      0,
      (sum, entry) => sum + (entry['amount'] ?? 0),
    );
    final totalDebits = _debitEntries.fold<double>(
      0,
      (sum, entry) => sum + (entry['amount'] ?? 0),
    );
    final balance = totalCredits - totalDebits;

    setState(() {
      _summaryData = {
        'totalCredits': totalCredits,
        'totalDebits': totalDebits,
        'balance': balance,
        'creditCount': _creditEntries.length,
        'debitCount': _debitEntries.length,
      };
    });
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Select month',
      fieldLabelText: 'Month',
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Ledger Summary',
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // Month Picker
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: InkWell(
                        onTap: () => _selectMonth(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Text(
                                '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                                style: AppTypography.title.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Big Balance Circle
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryGradientStart,
                              AppColors.primaryGradientEnd,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary500.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Month Balance',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${_summaryData['balance']?.toStringAsFixed(0) ?? '0'}',
                              style: AppTypography.headline.copyWith(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Summary Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Credits',
                              _summaryData['totalCredits'] ?? 0,
                              _summaryData['creditCount'] ?? 0,
                              AppColors.success,
                              Icons.arrow_downward,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Debits',
                              _summaryData['totalDebits'] ?? 0,
                              _summaryData['debitCount'] ?? 0,
                              AppColors.danger,
                              Icons.arrow_upward,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Tabs for Credits/Debits
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            TabBar(
                              tabs: const [
                                Tab(text: 'Credits'),
                                Tab(text: 'Debits'),
                              ],
                              labelColor: AppColors.primary500,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary500,
                              indicatorSize: TabBarIndicatorSize.tab,
                            ),
                            Container(
                              height: 400, // Fixed height for tab content
                              child: TabBarView(
                                children: [
                                  _buildEntriesList(_creditEntries, true),
                                  _buildEntriesList(_debitEntries, false),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Footer Action
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () => context.go('/reports'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary500,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'View Full Reports',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            '$count transactions',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(List<Map<String, dynamic>> entries, bool isCredit) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${isCredit ? 'credits' : 'debits'} this month',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildEntryItem(entry, isCredit);
      },
    );
  }

  Widget _buildEntryItem(Map<String, dynamic> entry, bool isCredit) {
    final color = isCredit ? AppColors.success : AppColors.danger;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['customer_name'] ?? 'Unknown Customer',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  entry['date'] ?? '',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${entry['amount']?.toStringAsFixed(0) ?? '0'}',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Error loading data',
            style: AppTypography.title.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
