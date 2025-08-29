import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class AddEntrySelectorScreen extends StatelessWidget {
  const AddEntrySelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Add Entry',
          style: AppTypography.titleWithColor(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What would you like to add?',
              style: AppTypography.headlineWithColor(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose between a credit or debit entry',
              style: AppTypography.bodyWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 48),

            // Credit Option
            _buildEntryOption(
              context: context,
              title: 'Add Credit',
              subtitle: 'Record money received from a customer',
              icon: Icons.arrow_downward,
              color: Theme.of(context).colorScheme.primary,
              onTap: () => context.go('/add/credit'),
            ),

            const SizedBox(height: 24),

            // Debit Option
            _buildEntryOption(
              context: context,
              title: 'Add Debit',
              subtitle: 'Record money paid to a customer',
              icon: Icons.arrow_upward,
              color: Theme.of(context).colorScheme.error,
              onTap: () => context.go('/add/debit'),
            ),

            const SizedBox(height: 48),

            // Recent Entries Section
            Text(
              'Recent Entries',
              style: AppTypography.titleWithColor(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Recent entries list (mock data for now)
            _buildRecentEntry(
              context: context,
              customer: 'Ramesh Traders',
              type: 'credit',
              amount: 2500.0,
              date: '2 hours ago',
            ),
            const SizedBox(height: 12),
            _buildRecentEntry(
              context: context,
              customer: 'Mohan Kirana',
              type: 'debit',
              amount: 1200.0,
              date: '5 hours ago',
            ),
            const SizedBox(height: 12),
            _buildRecentEntry(
              context: context,
              customer: 'Sita Textiles',
              type: 'credit',
              amount: 1800.0,
              date: '1 day ago',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleWithColor(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.bodyWithColor(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildRecentEntry({
    required BuildContext context,
    required String customer,
    required String type,
    required double amount,
    required String date,
  }) {
    final isCredit = type == 'credit';
    final color = isCredit
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;
    final prefix = isCredit ? '+' : '-';

    return Container(
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
              color: color.withOpacity(0.1),
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
                  customer,
                  style: AppTypography.bodyWithColor(
                    context,
                  ).copyWith(fontWeight: FontWeight.w500),
                ),
                Text(
                  date,
                  style: AppTypography.captionWithColor(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$prefix₹${amount.toStringAsFixed(0)}',
            style: AppTypography.bodyWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
