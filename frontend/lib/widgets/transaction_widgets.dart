import 'package:flutter/material.dart';
import '../models/transaction.dart' as app_models;
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'common_widgets.dart';

class TransactionCard extends StatelessWidget {
  final app_models.Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool showCustomer;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    this.showCustomer = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == app_models.TransactionType.credit;
    final transactionColor =
        isCredit ? AppConstants.successColor : AppConstants.errorColor;
    final sign = isCredit ? '+' : '-';

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Transaction Type Icon
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: transactionColor.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Icon(
                  isCredit ? Icons.trending_up : Icons.trending_down,
                  color: transactionColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),

              // Transaction Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showCustomer) ...[
                      Text(
                        transaction.customerName,
                        style: AppConstants.subHeadingStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      transaction.description,
                      style: AppConstants.bodyStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (transaction.category != null) ...[
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          transaction.category!,
                          style: AppConstants.captionStyle.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Amount and Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$sign${AppHelpers.formatCurrency(transaction.amount)}',
                    style: AppConstants.subHeadingStyle.copyWith(
                      color: transactionColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AppHelpers.formatDate(transaction.date),
                    style: AppConstants.captionStyle,
                  ),
                  if (AppHelpers.isToday(transaction.date))
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Today',
                        style: AppConstants.captionStyle.copyWith(
                          color: AppConstants.primaryColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),

              // Actions
              if (showActions)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete,
                              size: 16, color: AppConstants.errorColor),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(color: AppConstants.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Time
          if (!AppHelpers.isToday(transaction.date)) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              AppHelpers.timeAgo(transaction.createdAt),
              style: AppConstants.captionStyle.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  final app_models.Transaction transaction;
  final VoidCallback? onTap;
  final bool showCustomer;

  const TransactionListTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.showCustomer = true,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == app_models.TransactionType.credit;
    final transactionColor =
        isCredit ? AppConstants.successColor : AppConstants.errorColor;
    final sign = isCredit ? '+' : '-';

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: transactionColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isCredit ? Icons.trending_up : Icons.trending_down,
          color: transactionColor,
          size: 20,
        ),
      ),
      title: Text(
        showCustomer ? transaction.customerName : transaction.description,
        style: AppConstants.bodyStyle.copyWith(
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        showCustomer
            ? transaction.description
            : AppHelpers.formatDate(transaction.date),
        style: AppConstants.captionStyle,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$sign${AppHelpers.formatCurrency(transaction.amount)}',
            style: AppConstants.bodyStyle.copyWith(
              color: transactionColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showCustomer)
            Text(
              AppHelpers.formatDate(transaction.date),
              style: AppConstants.captionStyle,
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class TransactionSummaryCard extends StatelessWidget {
  final double totalCredit;
  final double totalDebit;
  final double netAmount;
  final int transactionCount;
  final String period;

  const TransactionSummaryCard({
    super.key,
    required this.totalCredit,
    required this.totalDebit,
    required this.netAmount,
    required this.transactionCount,
    this.period = 'All Time',
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Summary',
                style: AppConstants.subHeadingStyle,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  style: AppConstants.captionStyle.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Total Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Transactions',
                style: AppConstants.bodyStyle,
              ),
              Text(
                transactionCount.toString(),
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(height: AppConstants.paddingMedium),

          // Credit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppConstants.successColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Credit (Money Given)',
                    style: AppConstants.bodyStyle.copyWith(
                      color: AppConstants.successColor,
                    ),
                  ),
                ],
              ),
              Text(
                AppHelpers.formatCurrency(totalCredit),
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // Debit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_down,
                    size: 16,
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Debit (Money Received)',
                    style: AppConstants.bodyStyle.copyWith(
                      color: AppConstants.errorColor,
                    ),
                  ),
                ],
              ),
              Text(
                AppHelpers.formatCurrency(totalDebit),
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(height: AppConstants.paddingMedium),

          // Net Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Amount',
                style: AppConstants.subHeadingStyle,
              ),
              Text(
                AppHelpers.formatCurrency(netAmount),
                style: AppConstants.subHeadingStyle.copyWith(
                  color: netAmount >= 0
                      ? AppConstants.successColor
                      : AppConstants.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              title,
              style: AppConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
