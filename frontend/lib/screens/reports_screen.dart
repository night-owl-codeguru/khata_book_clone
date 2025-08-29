import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/export_service.dart';
import '../services/reports_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {
  String _selectedReportType = 'monthly';
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic> _reportData = {};
  List<Map<String, dynamic>> _monthlyReports = [];
  List<Map<String, dynamic>> _categoryReports = [];
  List<Map<String, dynamic>> _paymentMethodReports = [];

  late TabController _tabController;

  DateTime? _startDate;
  DateTime? _endDate;
  bool _showDateFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedReportType = [
          'monthly',
          'categories',
          'payment-methods',
        ][_tabController.index];
        _loadReports();
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
      _loadReports();
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
      _loadReports();
    }
  }

  void _clearDateFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadReports();
  }

  void _toggleDateFilters() {
    setState(() {
      _showDateFilters = !_showDateFilters;
    });
  }

  Widget _buildDateFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Date Range',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearDateFilters,
                child: Text(
                  'Clear',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.primary500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectStartDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _startDate != null
                                ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                : 'Start Date',
                            style: AppTypography.caption.copyWith(
                              color: _startDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectEndDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _endDate != null
                                ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                : 'End Date',
                            style: AppTypography.caption.copyWith(
                              color: _endDate != null
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> result = {
        'success': false,
        'message': 'Unknown error',
      };

      switch (_selectedReportType) {
        case 'monthly':
          result = await ReportsService.getMonthlyReports(
            year: _startDate?.year,
            month: _startDate?.month,
          );
          if (result['success']) {
            _monthlyReports = List<Map<String, dynamic>>.from(
              result['reports'],
            );
            _updateMonthlySummary();
          }
          break;
        case 'categories':
          result = await ReportsService.getCategoryReports(
            startDate: _startDate,
            endDate: _endDate,
          );
          if (result['success']) {
            _categoryReports = List<Map<String, dynamic>>.from(
              result['reports'],
            );
            _updateCategorySummary();
          }
          break;
        case 'payment-methods':
          result = await ReportsService.getPaymentMethodReports(
            startDate: _startDate,
            endDate: _endDate,
          );
          if (result['success']) {
            _paymentMethodReports = List<Map<String, dynamic>>.from(
              result['reports'],
            );
            _updatePaymentMethodSummary();
          }
          break;
      }

      if (!result['success']) {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reports: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateMonthlySummary() {
    if (_monthlyReports.isNotEmpty) {
      final latest = _monthlyReports.first;
      _reportData = {
        'totalCredit': latest['total_credit'] ?? 0.0,
        'totalDebit': latest['total_debit'] ?? 0.0,
        'balance': latest['balance'] ?? 0.0,
        'transactionCount': _monthlyReports.length,
      };
    }
  }

  void _updateCategorySummary() {
    if (_categoryReports.isNotEmpty) {
      double totalCredit = 0;
      double totalDebit = 0;
      int totalTransactions = 0;

      for (var report in _categoryReports) {
        totalCredit += report['total_credit'] ?? 0.0;
        totalDebit += report['total_debit'] ?? 0.0;
        totalTransactions +=
            (report['transaction_count'] as num?)?.toInt() ?? 0;
      }

      _reportData = {
        'totalCredit': totalCredit,
        'totalDebit': totalDebit,
        'balance': totalCredit - totalDebit,
        'transactionCount': totalTransactions,
        'topCustomers': _categoryReports
            .take(3)
            .map((c) => {'name': c['customer_name'], 'amount': c['balance']})
            .toList(),
      };
    }
  }

  void _updatePaymentMethodSummary() {
    if (_paymentMethodReports.isNotEmpty) {
      double totalAmount = 0;
      int totalTransactions = 0;

      for (var report in _paymentMethodReports) {
        totalAmount += report['total_amount'] ?? 0.0;
        totalTransactions +=
            (report['transaction_count'] as num?)?.toInt() ?? 0;
      }

      _reportData = {
        'totalCredit': totalAmount,
        'totalDebit': 0.0,
        'balance': totalAmount,
        'transactionCount': totalTransactions,
        'paymentMethods': Map.fromEntries(
          _paymentMethodReports.map((r) {
            final percentage = totalAmount > 0
                ? ((r['total_amount'] ?? 0.0) / totalAmount * 100).round()
                : 0;
            return MapEntry(r['method'], percentage);
          }),
        ),
      };
    }
  }

  void _showExportDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Report',
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose export format',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              'CSV Format',
              'Export as spreadsheet',
              Icons.table_chart,
              () => _exportData('csv'),
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              'PDF Report',
              'Export as formatted document',
              Icons.picture_as_pdf,
              () => _exportData('pdf'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary500, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(String format) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generating export...'),
            ],
          ),
        ),
      );

      // Prepare data based on current report type
      Map<String, dynamic> exportData = {
        'reportType': _selectedReportType,
        'generatedAt': DateTime.now().toIso8601String(),
        ..._reportData,
      };

      // Add specific data based on report type
      switch (_selectedReportType) {
        case 'monthly':
          exportData['monthlyReports'] = _monthlyReports;
          break;
        case 'categories':
          exportData['categoryReports'] = _categoryReports;
          break;
        case 'payment-methods':
          exportData['paymentMethodReports'] = _paymentMethodReports;
          break;
      }

      String filePath;
      if (format == 'csv') {
        filePath = await ExportService.exportToCSV(reportData: exportData);
      } else {
        filePath = await ExportService.exportToPDF(reportData: exportData);
      }

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success dialog with share option
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Export Complete'),
            content: Text(
              'File exported successfully to: ${filePath.split('/').last}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await ExportService.shareFile(filePath);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to share: $e')),
                      );
                    }
                  }
                },
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
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
          'Reports',
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _toggleDateFilters,
            icon: Icon(
              _showDateFilters ? Icons.filter_list_off : Icons.filter_list,
              color: AppColors.primary500,
            ),
          ),
          IconButton(
            onPressed: () => _showExportDialog(),
            icon: Icon(Icons.download, color: AppColors.primary500),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Monthly'),
            Tab(text: 'Categories'),
            Tab(text: 'Payment Methods'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorView()
          : Column(
              children: [
                if (_showDateFilters) _buildDateFilters(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMonthlyReportsView(),
                      _buildCategoryReportsView(),
                      _buildPaymentMethodReportsView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'Failed to load reports',
            style: AppTypography.title.copyWith(color: AppColors.danger),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadReports, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildMonthlyReportsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Credit',
                  amount: _reportData['totalCredit'] ?? 0.0,
                  color: AppColors.success,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Debit',
                  amount: _reportData['totalDebit'] ?? 0.0,
                  color: AppColors.danger,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            title: 'Net Balance',
            amount: _reportData['balance'] ?? 0.0,
            color: AppColors.primary500,
            icon: Icons.account_balance_wallet,
            isHighlighted: true,
          ),

          const SizedBox(height: 32),

          // Monthly Breakdown
          Text(
            'Monthly Breakdown',
            style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ..._monthlyReports.map((report) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report['month'] ?? 'Unknown Month',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credit: ₹${(report['total_credit'] ?? 0.0).toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Debit: ₹${(report['total_debit'] ?? 0.0).toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                      Text(
                        'Balance: ₹${(report['balance'] ?? 0.0).toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: (report['balance'] ?? 0.0) >= 0
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryReportsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Credit',
                  amount: _reportData['totalCredit'] ?? 0.0,
                  color: AppColors.success,
                  icon: Icons.arrow_downward,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Debit',
                  amount: _reportData['totalDebit'] ?? 0.0,
                  color: AppColors.danger,
                  icon: Icons.arrow_upward,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildSummaryCard(
            title: 'Net Balance',
            amount: _reportData['balance'] ?? 0.0,
            color: AppColors.primary500,
            icon: Icons.account_balance_wallet,
            isHighlighted: true,
          ),

          const SizedBox(height: 32),

          // Customer Breakdown
          Text(
            'Customer Breakdown',
            style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ..._categoryReports.map((report) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          report['customer_name'] ?? 'Unknown Customer',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${report['transaction_count'] ?? 0} transactions',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credit: ₹${(report['total_credit'] ?? 0.0).toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        'Debit: ₹${(report['total_debit'] ?? 0.0).toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                      Text(
                        'Balance: ₹${(report['balance'] ?? 0.0).toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: (report['balance'] ?? 0.0) >= 0
                              ? AppColors.success
                              : AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodReportsView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildSummaryCard(
            title: 'Total Transaction Amount',
            amount: _reportData['totalCredit'] ?? 0.0,
            color: AppColors.primary500,
            icon: Icons.account_balance_wallet,
            isHighlighted: true,
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primary500),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Transactions',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        (_reportData['transactionCount'] ?? 0).toString(),
                        style: AppTypography.title.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Payment Methods Breakdown
          Text(
            'Payment Methods',
            style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ..._paymentMethodReports.map((report) {
            final method = report['method'] ?? 'Unknown';
            final totalAmount = report['total_amount'] ?? 0.0;
            final transactionCount = report['transaction_count'] ?? 0;
            final averageAmount = report['average_amount'] ?? 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        method.toUpperCase(),
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$transactionCount transactions',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ₹${totalAmount.toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      Text(
                        'Average: ₹${averageAmount.toStringAsFixed(0)}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        (_reportData['paymentMethods']
                                as Map<String, dynamic>?)?[method] !=
                            null
                        ? ((_reportData['paymentMethods']
                                  as Map<String, dynamic>)[method] /
                              100)
                        : 0.0,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? color : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isHighlighted ? color : AppColors.border),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isHighlighted ? Colors.white : color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: isHighlighted ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: AppTypography.title.copyWith(
              fontWeight: FontWeight.w600,
              color: isHighlighted ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
