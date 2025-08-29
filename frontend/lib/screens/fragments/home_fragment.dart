import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';

// Home Fragment - Simplified version of home screen without app bar and navigation
class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _latestEntries = [];
  Map<String, double> _summaryData = {
    'totalCredit': 0.0,
    'totalDebit': 0.0,
    'balance': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load user data
      _userData = await AuthService.getUserData();

      // Load dashboard data from API
      final dashboardResult = await DashboardService.getDashboardSummary();

      if (dashboardResult['success']) {
        final data = dashboardResult['data'];
        _summaryData = {
          'totalCredit': data['total_credit'] ?? 0.0,
          'totalDebit': data['total_debit'] ?? 0.0,
          'balance': data['balance'] ?? 0.0,
        };

        // Process latest entries
        final entries = data['latest_entries'] as List<dynamic>? ?? [];
        _latestEntries = entries.map((entry) {
          return {
            'id': entry['id'],
            'customer': entry['customer_name'] ?? 'Unknown Customer',
            'type': entry['type'],
            'amount': entry['amount'] ?? 0.0,
            'date': entry['date'] ?? DateTime.now().toString().split('T')[0],
            'method': entry['method'] ?? 'cash',
          };
        }).toList();
      } else {
        // Fallback to mock data if API fails
        print('API failed: ${dashboardResult['message']}');
        final mockData = DashboardService.getMockDashboardData();
        _summaryData = {
          'totalCredit': mockData['total_credit'],
          'totalDebit': mockData['total_debit'],
          'balance': mockData['balance'],
        };
        _latestEntries = List<Map<String, dynamic>>.from(
          mockData['latest_entries'],
        );
      }
    } catch (e) {
      // Handle error and use mock data as fallback
      print('Error loading data: $e');
      final mockData = DashboardService.getMockDashboardData();
      _summaryData = {
        'totalCredit': mockData['total_credit'],
        'totalDebit': mockData['total_debit'],
        'balance': mockData['balance'],
      };
      _latestEntries = List<Map<String, dynamic>>.from(
        mockData['latest_entries'],
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: AppTypography.captionWithColor(context)
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          Text(
                            _userData?['name'] ?? 'User',
                            style: AppTypography.titleWithColor(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Summary Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Credit',
                                  amount: _summaryData['totalCredit']!,
                                  icon: Icons.arrow_downward,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  title: 'Total Debit',
                                  amount: _summaryData['totalDebit']!,
                                  icon: Icons.arrow_upward,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSummaryCard(
                            title: 'Balance',
                            amount: _summaryData['balance']!,
                            icon: Icons.account_balance_wallet,
                            color: AppColors.primary500,
                            isHighlighted: true,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: AppTypography.titleWithColor(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Add Customer',
                                  icon: Icons.person_add,
                                  onTap: () => context.go('/customers'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Reminders',
                                  icon: Icons.notifications,
                                  onTap: () => context.go('/reminders'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildQuickAction(
                                  title: 'Reports',
                                  icon: Icons.bar_chart,
                                  onTap: () => context.go('/reports'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Latest Entries
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Latest Entries',
                            style: AppTypography.titleWithColor(
                              context,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                  // Entries List
                  _latestEntries.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildEmptyState(),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final entry = _latestEntries[index];
                            return _buildEntryItem(entry);
                          }, childCount: _latestEntries.length),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? color : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? color : Theme.of(context).colorScheme.outline,
          width: isHighlighted ? 0 : 1,
        ),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Colors.white.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isHighlighted ? Colors.white : color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.captionWithColor(context).copyWith(
                    color: isHighlighted
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: AppTypography.titleWithColor(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: isHighlighted
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.captionWithColor(
                context,
              ).copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryItem(Map<String, dynamic> entry) {
    final isCredit = entry['type'] == 'credit';
    final color = isCredit ? AppColors.success : AppColors.danger;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['customer'],
                  style: AppTypography.bodyWithColor(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${entry['date']} • ${entry['method']}',
                  style: AppTypography.captionWithColor(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹${entry['amount'].toStringAsFixed(0)}',
            style: AppTypography.bodyWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
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
            'No entries yet',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first credit or debit to get started',
            style: AppTypography.bodyWithColor(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/add'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Add Entry',
              style: AppTypography.bodyWithColor(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
