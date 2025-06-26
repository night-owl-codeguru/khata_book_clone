import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/customer_provider.dart';
import '../../models/transaction.dart' as app_models;
import '../../models/customer.dart';
import '../../utils/constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final Customer? selectedCustomer;
  final app_models.Transaction? transaction;

  const AddTransactionScreen({
    super.key,
    this.selectedCustomer,
    this.transaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  Customer? _selectedCustomer;
  app_models.TransactionType _transactionType =
      app_models.TransactionType.credit;
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.selectedCustomer;

    if (isEditing) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description;
      _transactionType = widget.transaction!.type;
      _selectedDate = widget.transaction!.date;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Selection
              Consumer<CustomerProvider>(
                builder: (context, customerProvider, child) {
                  return DropdownButtonFormField<Customer>(
                    value: _selectedCustomer,
                    decoration: const InputDecoration(
                      labelText: 'Select Customer *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: customerProvider.customers.map((customer) {
                      return DropdownMenuItem<Customer>(
                        value: customer,
                        child: Text(customer.name),
                      );
                    }).toList(),
                    onChanged: (customer) {
                      setState(() {
                        _selectedCustomer = customer;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a customer';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Transaction Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<app_models.TransactionType>(
                              title: const Text('Credit'),
                              subtitle: const Text('Money given'),
                              value: app_models.TransactionType.credit,
                              groupValue: _transactionType,
                              onChanged: (value) {
                                setState(() {
                                  _transactionType = value!;
                                });
                              },
                              activeColor: AppColors.warning,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<app_models.TransactionType>(
                              title: const Text('Debit'),
                              subtitle: const Text('Money received'),
                              value: app_models.TransactionType.debit,
                              groupValue: _transactionType,
                              onChanged: (value) {
                                setState(() {
                                  _transactionType = value!;
                                });
                              },
                              activeColor: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Date Selection
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              Consumer<TransactionProvider>(
                builder: (context, transactionProvider, child) {
                  return ElevatedButton(
                    onPressed:
                        transactionProvider.isLoading ? null : _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _transactionType == app_models.TransactionType.credit
                              ? AppColors.warning
                              : AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: transactionProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEditing
                                ? 'Update Transaction'
                                : 'Add ${_transactionType == app_models.TransactionType.credit ? 'Credit' : 'Debit'}',
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final transactionProvider = context.read<TransactionProvider>();
    final customerProvider = context.read<CustomerProvider>();

    final transaction = app_models.Transaction(
      id: isEditing ? widget.transaction!.id : null,
      customerId: _selectedCustomer!.id!,
      customerName: _selectedCustomer!.name,
      type: _transactionType,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    bool success;
    if (isEditing) {
      success = await transactionProvider.updateTransaction(transaction);
    } else {
      success = await transactionProvider.addTransaction(transaction);
    }

    if (success && mounted) {
      // Update customer balance
      customerProvider.loadCustomers();

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Transaction updated successfully'
                : 'Transaction added successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            transactionProvider.error ?? 'Failed to save transaction',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTransaction();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction() async {
    final transactionProvider = context.read<TransactionProvider>();
    final customerProvider = context.read<CustomerProvider>();

    final success =
        await transactionProvider.deleteTransaction(widget.transaction!.id!);

    if (success && mounted) {
      // Update customer balance
      customerProvider.loadCustomers();

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            transactionProvider.error ?? 'Failed to delete transaction',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
