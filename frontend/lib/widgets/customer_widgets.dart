import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'common_widgets.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    final balanceColor = customer.balance > 0
        ? AppConstants.successColor
        : customer.balance < 0
            ? AppConstants.errorColor
            : Colors.grey;

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Customer Avatar
              CircleAvatar(
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                child: Text(
                  AppHelpers.getInitials(customer.name),
                  style: const TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.paddingMedium),

              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: AppConstants.subHeadingStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (customer.phone != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        AppHelpers.formatPhoneNumber(customer.phone!),
                        style: AppConstants.captionStyle,
                      ),
                    ],
                  ],
                ),
              ),

              // Balance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppHelpers.formatCurrency(customer.balance.abs()),
                    style: AppConstants.subHeadingStyle.copyWith(
                      color: balanceColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    customer.balance > 0
                        ? 'To Receive'
                        : customer.balance < 0
                            ? 'To Pay'
                            : 'Settled',
                    style: AppConstants.captionStyle.copyWith(
                      color: balanceColor,
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

          // Address
          if (customer.address != null && customer.address!.isNotEmpty) ...[
            const SizedBox(height: AppConstants.paddingSmall),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customer.address!,
                    style: AppConstants.captionStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class CustomerListTile extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;
  final bool selected;

  const CustomerListTile({
    super.key,
    required this.customer,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final balanceColor = customer.balance > 0
        ? AppConstants.successColor
        : customer.balance < 0
            ? AppConstants.errorColor
            : Colors.grey;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: selected
            ? AppConstants.primaryColor
            : AppConstants.primaryColor.withOpacity(0.1),
        child: Text(
          AppHelpers.getInitials(customer.name),
          style: TextStyle(
            color: selected ? Colors.white : AppConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        customer.name,
        style: AppConstants.bodyStyle.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: customer.phone != null
          ? Text(
              AppHelpers.formatPhoneNumber(customer.phone!),
              style: AppConstants.captionStyle,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppHelpers.formatCurrency(customer.balance.abs()),
            style: AppConstants.bodyStyle.copyWith(
              color: balanceColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            customer.balance > 0
                ? 'To Receive'
                : customer.balance < 0
                    ? 'To Pay'
                    : 'Settled',
            style: AppConstants.captionStyle.copyWith(
              color: balanceColor,
            ),
          ),
        ],
      ),
      onTap: onTap,
      selected: selected,
      selectedTileColor: AppConstants.primaryColor.withOpacity(0.1),
    );
  }
}

class CustomerSummaryCard extends StatelessWidget {
  final int totalCustomers;
  final double totalToReceive;
  final double totalToPay;
  final double netBalance;

  const CustomerSummaryCard({
    super.key,
    required this.totalCustomers,
    required this.totalToReceive,
    required this.totalToPay,
    required this.netBalance,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Summary',
            style: AppConstants.subHeadingStyle,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          // Total Customers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Customers',
                style: AppConstants.bodyStyle,
              ),
              Text(
                totalCustomers.toString(),
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(height: AppConstants.paddingMedium),

          // To Receive
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To Receive',
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.successColor,
                ),
              ),
              Text(
                AppHelpers.formatCurrency(totalToReceive),
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.paddingSmall),

          // To Pay
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'To Pay',
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.errorColor,
                ),
              ),
              Text(
                AppHelpers.formatCurrency(totalToPay),
                style: AppConstants.bodyStyle.copyWith(
                  color: AppConstants.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Divider(height: AppConstants.paddingMedium),

          // Net Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Balance',
                style: AppConstants.subHeadingStyle,
              ),
              Text(
                AppHelpers.formatCurrency(netBalance),
                style: AppConstants.subHeadingStyle.copyWith(
                  color: netBalance >= 0
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
