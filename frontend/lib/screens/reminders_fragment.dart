import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../providers/reminder_provider.dart';

class RemindersFragment extends StatefulWidget {
  const RemindersFragment({super.key});

  @override
  State<RemindersFragment> createState() => _RemindersFragmentState();
}

class _RemindersFragmentState extends State<RemindersFragment>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load reminders when the fragment is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReminderProvider>().loadReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Reload reminders with the new status filter
      final statuses = ['pending', 'sent', 'paid'];
      final selectedStatus = statuses[_tabController.index];
      context.read<ReminderProvider>().loadReminders(status: selectedStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReminderProvider>(
      builder: (context, reminderProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: Text(
              'Reminders',
              style: AppTypography.titleWithColor(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Sent'),
                Tab(text: 'Paid'),
              ],
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          body: reminderProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : reminderProvider.error != null
              ? _buildErrorState(reminderProvider.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRemindersList('pending', reminderProvider),
                    _buildRemindersList('sent', reminderProvider),
                    _buildRemindersList('paid', reminderProvider),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildRemindersList(String status, ReminderProvider reminderProvider) {
    final reminders = reminderProvider.getRemindersByStatus(status);

    if (reminders.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        return _buildReminderCard(reminder, status);
      },
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder['customer_name'] ??
                          reminder['customer'] ??
                          'Unknown Customer',
                      style: AppTypography.bodyWithColor(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '₹${reminder['due_amount']?.toStringAsFixed(0) ?? reminder['amount']?.toStringAsFixed(0) ?? '0'} due on ${reminder['due_date'] ?? reminder['dueDate'] ?? 'Unknown'}',
                      style: AppTypography.captionWithColor(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTypography.captionWithColor(context).copyWith(
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _getChannelIcon(reminder['channel'] ?? 'unknown'),
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                (reminder['channel'] ?? 'unknown').toString().toUpperCase(),
                style: AppTypography.captionWithColor(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (reminder['last_reminder'] != null ||
                  reminder['lastReminder'] != null) ...[
                const SizedBox(width: 12),
                Text(
                  'Last sent: ${reminder['last_reminder'] ?? reminder['lastReminder']}',
                  style: AppTypography.captionWithColor(context).copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (status == 'paid' &&
                  (reminder['paid_date'] != null ||
                      reminder['paidDate'] != null)) ...[
                const SizedBox(width: 12),
                Text(
                  'Paid: ${reminder['paid_date'] ?? reminder['paidDate']}',
                  style: AppTypography.captionWithColor(
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ],
          ),
          if (status == 'pending') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _sendReminder(reminder),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Send Reminder',
                      style: AppTypography.captionWithColor(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _markAsPaid(reminder),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Mark Paid',
                      style: AppTypography.captionWithColor(
                        context,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    final title = status == 'pending'
        ? 'No pending reminders'
        : status == 'sent'
        ? 'No sent reminders'
        : 'No paid reminders';
    final subtitle = status == 'pending'
        ? 'Reminders you\'ve scheduled will appear here'
        : status == 'sent'
        ? 'Sent reminders will appear here'
        : 'Paid reminders will appear here';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.bodyWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
              'Failed to load reminders',
              style: AppTypography.titleWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTypography.bodyWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<ReminderProvider>().loadReminders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Theme.of(context).colorScheme.error;
      case 'sent':
        return Theme.of(context).colorScheme.primary;
      case 'paid':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  IconData _getChannelIcon(String channel) {
    switch (channel) {
      case 'whatsapp':
        return Icons.chat;
      case 'sms':
        return Icons.sms;
      case 'email':
        return Icons.email;
      default:
        return Icons.notifications;
    }
  }

  void _sendReminder(Map<String, dynamic> reminder) {
    // TODO: Implement send reminder functionality with real API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder sent to ${reminder['customer_name'] ?? reminder['customer']} via ${reminder['channel']}',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _markAsPaid(Map<String, dynamic> reminder) {
    // TODO: Implement mark as paid functionality with real API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${reminder['customer_name'] ?? reminder['customer']} marked as paid',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
