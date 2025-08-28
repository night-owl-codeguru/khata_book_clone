import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Reminders',
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Sent'),
            Tab(text: 'Paid'),
          ],
          labelColor: AppColors.primary500,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary500,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersList('pending'),
          _buildRemindersList('sent'),
          _buildRemindersList('paid'),
        ],
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Reminders tab
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/add');
              break;
            case 2:
              // Already on reminders
              break;
            case 3:
              context.go('/customers');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
        ],
      ),
    );
  }

  Widget _buildRemindersList(String status) {
    // Mock data based on status
    final mockReminders = _getMockReminders(status);

    if (mockReminders.isEmpty) {
      return _buildEmptyState(status);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: mockReminders.length,
      itemBuilder: (context, index) {
        final reminder = mockReminders[index];
        return _buildReminderCard(reminder, status);
      },
    );
  }

  List<Map<String, dynamic>> _getMockReminders(String status) {
    switch (status) {
      case 'pending':
        return [
          {
            'id': '1',
            'customer': 'Mohan Kirana',
            'amount': 500.0,
            'dueDate': '2024-08-30',
            'channel': 'whatsapp',
            'lastReminder': null,
          },
          {
            'id': '2',
            'customer': 'Anand Dairy',
            'amount': 1200.0,
            'dueDate': '2024-09-05',
            'channel': 'sms',
            'lastReminder': '2024-08-20',
          },
        ];
      case 'sent':
        return [
          {
            'id': '3',
            'customer': 'Ramesh Traders',
            'amount': 800.0,
            'dueDate': '2024-08-25',
            'channel': 'whatsapp',
            'lastReminder': '2024-08-20',
          },
        ];
      case 'paid':
        return [
          {
            'id': '4',
            'customer': 'Sita Textiles',
            'amount': 1500.0,
            'dueDate': '2024-08-15',
            'channel': 'sms',
            'lastReminder': '2024-08-10',
            'paidDate': '2024-08-14',
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
                      reminder['customer'],
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${reminder['amount'].toStringAsFixed(0)} due on ${reminder['dueDate']}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: AppTypography.caption.copyWith(
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
                _getChannelIcon(reminder['channel']),
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                reminder['channel'].toString().toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (reminder['lastReminder'] != null) ...[
                const SizedBox(width: 12),
                Text(
                  'Last sent: ${reminder['lastReminder']}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (status == 'paid' && reminder['paidDate'] != null) ...[
                const SizedBox(width: 12),
                Text(
                  'Paid: ${reminder['paidDate']}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                  ),
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
                      side: const BorderSide(color: AppColors.primary500),
                      foregroundColor: AppColors.primary500,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Send Reminder',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _markAsPaid(reminder),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.success),
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      'Mark Paid',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.title.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.danger;
      case 'sent':
        return AppColors.primary500;
      case 'paid':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
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
    // TODO: Implement send reminder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder sent to ${reminder['customer']} via ${reminder['channel']}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _markAsPaid(Map<String, dynamic> reminder) {
    // TODO: Implement mark as paid functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reminder['customer']} marked as paid'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
