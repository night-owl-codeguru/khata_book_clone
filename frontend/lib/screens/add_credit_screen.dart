import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/ledger_service.dart';
import '../services/customer_service.dart';

class AddCreditScreen extends StatefulWidget {
  const AddCreditScreen({super.key});

  @override
  State<AddCreditScreen> createState() => _AddCreditScreenState();
}

class _AddCreditScreenState extends State<AddCreditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedMethod = 'cash';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isLoadingCustomers = true;
  List<Map<String, dynamic>> _customers = [];
  int? _selectedCustomerId;
  String _customerName = ''; // Store the customer name separately

  final List<String> _paymentMethods = ['cash', 'upi', 'bank'];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  @override
  void dispose() {
    _customerController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);

    try {
      final result = await CustomerService.getCustomers();
      if (result['success']) {
        setState(() {
          _customers = List<Map<String, dynamic>>.from(result['customers']);
        });
      } else {
        // Fallback to mock data
        setState(() {
          _customers = CustomerService.getMockCustomers();
        });
      }
    } catch (e) {
      // Fallback to mock data
      setState(() {
        _customers = CustomerService.getMockCustomers();
      });
    } finally {
      setState(() => _isLoadingCustomers = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final customerName = _customerController.text.trim();
    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a customer name'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if customer exists, if not create them
      if (_selectedCustomerId == null) {
        final createResult = await CustomerService.createCustomer(
          name: customerName,
        );

        if (!createResult['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  createResult['message'] ?? 'Failed to create customer',
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }

        // Get the created customer ID
        final createdCustomer = createResult['customer'];
        _selectedCustomerId = createdCustomer['id'];
      }

      final amount = double.parse(_amountController.text);
      final note = _noteController.text.isNotEmpty
          ? _noteController.text
          : null;

      final result = await LedgerService.createCreditEntry(
        customerId: _selectedCustomerId!,
        amount: amount,
        method: _selectedMethod,
        note: note,
        date: _selectedDate,
      );

      if (result['success']) {
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Credit saved successfully!'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          // Navigate back to home
          context.go('/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error saving credit'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving credit: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Add Credit',
          style: AppTypography.titleWithColor(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.go('/add'),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recording a Credit',
                            style: AppTypography.bodyWithColor(context)
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          Text(
                            'Money received from customer',
                            style: AppTypography.captionWithColor(context)
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Customer Field
              Text(
                'Customer',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _customers.map(
                      (customer) => customer['name'] as String,
                    );
                  }
                  return _customers
                      .map((customer) => customer['name'] as String)
                      .where(
                        (name) => name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                },
                onSelected: (String selection) {
                  final customer = _customers.firstWhere(
                    (c) => c['name'] == selection,
                    orElse: () => <String, dynamic>{},
                  );
                  if (customer.isNotEmpty) {
                    setState(() {
                      _customerController.text = selection;
                      _selectedCustomerId = customer['id'];
                    });
                  } else {
                    // If customer doesn't exist, we'll create it later
                    setState(() {
                      _customerController.text = selection;
                      _selectedCustomerId = null; // Will be created on submit
                    });
                  }
                },
                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      // Initialize controller text if we have a value
                      if (_customerController.text.isNotEmpty &&
                          textEditingController.text.isEmpty) {
                        textEditingController.text = _customerController.text;
                      }
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: 'Type customer name or select from list',
                          prefixIcon: const Icon(Icons.person),
                          suffixIcon: _isLoadingCustomers
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    textEditingController.clear();
                                    setState(() {
                                      _selectedCustomerId = null;
                                      _customerController.clear();
                                    });
                                  },
                                ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a customer name';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          // Update our controller and reset selected customer ID when user types
                          _customerController.text = value;
                          if (_selectedCustomerId != null) {
                            final customer = _customers.firstWhere(
                              (c) => c['name'] == value,
                              orElse: () => <String, dynamic>{},
                            );
                            if (customer.isEmpty) {
                              setState(() {
                                _selectedCustomerId = null;
                              });
                            }
                          }
                        },
                      );
                    },
                optionsViewBuilder:
                    (
                      BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options,
                    ) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            width:
                                MediaQuery.of(context).size.width -
                                48, // Account for padding
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final String option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
              ),

              const SizedBox(height: 24),

              // Amount Field
              Text(
                'Amount (₹)',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount greater than 0';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Payment Method
              Text(
                'Payment Method',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _paymentMethods.map((method) {
                    final isSelected = _selectedMethod == method;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedMethod = method),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              method == _paymentMethods.first ? 12 : 0,
                            ),
                          ),
                          child: Text(
                            method.toUpperCase(),
                            style: AppTypography.captionWithColor(context)
                                .copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
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

              // Date Field
              Text(
                'Date',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: AppTypography.bodyWithColor(context),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Note Field
              Text(
                'Note (Optional)',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Add a note about this transaction',
                ),
              ),

              const SizedBox(height: 48),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Credit',
                          style: AppTypography.bodyWithColor(
                            context,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
