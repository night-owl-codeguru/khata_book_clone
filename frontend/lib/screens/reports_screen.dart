import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'month';

  // Mock report data
  final Map<String, dynamic> _reportData = {
    'totalCredit': 12500.0,
    'totalDebit': 8750.0,
    'balance': 3750.0,
    'transactionCount': 45,
    'topCustomers': [
      {'name': 'Ramesh Traders', 'amount': 3200.0},
      {'name': 'Sita Textiles', 'amount': 1800.0},
      {'name': 'Vijay Hardware', 'amount': 4200.0},
    ],
    'paymentMethods': {'cash': 60, 'upi': 30, 'bank': 10},
  };

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
            onPressed: () {
              // TODO: Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
            icon: Icon(Icons.download, color: AppColors.primary500),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            Text(
              'Period',
              style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: ['month', 'quarter', 'year'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _selectedPeriod = period),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary500
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            period == 'month' ? 12 : 0,
                          ),
                        ),
                        child: Text(
                          period.toUpperCase(),
                          style: AppTypography.caption.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Credit',
                    amount: _reportData['totalCredit'],
                    color: AppColors.success,
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: 'Total Debit',
                    amount: _reportData['totalDebit'],
                    color: AppColors.danger,
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildSummaryCard(
              title: 'Net Balance',
              amount: _reportData['balance'],
              color: AppColors.primary500,
              icon: Icons.account_balance_wallet,
              isHighlighted: true,
            ),

            const SizedBox(height: 32),

            // Transaction Count
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
                          _reportData['transactionCount'].toString(),
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

            // Top Customers
            Text(
              'Top Customers',
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...(_reportData['topCustomers'] as List).map((customer) {
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
                    Expanded(
                      child: Text(
                        customer['name'],
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '₹${customer['amount'].toStringAsFixed(0)}',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            // Payment Methods Breakdown
            Text(
              'Payment Methods',
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...(_reportData['paymentMethods'] as Map).entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          style: AppTypography.body,
                        ),
                        Text(
                          '${entry.value}%',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary500,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            // Insights
            Text(
              'Insights',
              style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInsightCard(
              'Collections improved 18% compared to last month',
              AppColors.success,
            ),
            const SizedBox(height: 8),
            _buildInsightCard(
              'UPI transactions account for 30% of all payments',
              AppColors.primary500,
            ),
            const SizedBox(height: 8),
            _buildInsightCard(
              'Average transaction value: ₹278',
              AppColors.textSecondary,
            ),

            const SizedBox(height: 32),
          ],
        ),
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

  Widget _buildInsightCard(String insight, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
