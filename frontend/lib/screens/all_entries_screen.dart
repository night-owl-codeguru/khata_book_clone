import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/ledger_service.dart';

class AllEntriesScreen extends StatefulWidget {
  const AllEntriesScreen({super.key});

  @override
  State<AllEntriesScreen> createState() => _AllEntriesScreenState();
}

class _AllEntriesScreenState extends State<AllEntriesScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _allEntries = [];
  List<Map<String, dynamic>> _filteredEntries = [];
  String? _error;

  // Filter states
  String _selectedType = 'all'; // 'all', 'credit', 'debit'
  String _selectedMethod = 'all'; // 'all', 'cash', 'upi', 'bank'
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _entryTypes = ['all', 'credit', 'debit'];
  final List<String> _paymentMethods = ['all', 'cash', 'upi', 'bank'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadEntries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);

    try {
      final result = await LedgerService.getLedgerEntries(limit: 1000);

      if (result['success']) {
        setState(() {
          _allEntries = List<Map<String, dynamic>>.from(result['entries']);
          _filteredEntries = _allEntries;
        });
      } else {
        // Use mock data if API fails
        _loadMockData();
      }
    } catch (e) {
      setState(() => _error = 'Failed to load entries: $e');
      _loadMockData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadMockData() {
    _allEntries = [
      {
        'id': 1,
        'customer_name': 'Ramesh Traders',
        'type': 'credit',
        'amount': 2500.0,
        'method': 'cash',
        'date': '2024-08-29',
        'note': 'Payment for goods',
      },
      {
        'id': 2,
        'customer_name': 'Mohan Kirana',
        'type': 'debit',
        'amount': 500.0,
        'method': 'upi',
        'date': '2024-08-28',
        'note': 'Partial payment',
      },
      {
        'id': 3,
        'customer_name': 'Sita Textiles',
        'type': 'credit',
        'amount': 1200.0,
        'method': 'bank',
        'date': '2024-08-27',
        'note': '',
      },
      {
        'id': 4,
        'customer_name': 'Anand Dairy',
        'type': 'credit',
        'amount': 800.0,
        'method': 'upi',
        'date': '2024-08-25',
        'note': 'Milk supply',
      },
      {
        'id': 5,
        'customer_name': 'Vijay Hardware',
        'type': 'debit',
        'amount': 300.0,
        'method': 'cash',
        'date': '2024-08-24',
        'note': 'Tools purchase',
      },
    ];
    _filteredEntries = _allEntries;
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredEntries = _allEntries.where((entry) {
        // Search filter
        final searchQuery = _searchController.text.toLowerCase();
        if (searchQuery.isNotEmpty) {
          final customerName = (entry['customer_name'] ?? '')
              .toString()
              .toLowerCase();
          final note = (entry['note'] ?? '').toString().toLowerCase();
          if (!customerName.contains(searchQuery) &&
              !note.contains(searchQuery)) {
            return false;
          }
        }

        // Type filter
        if (_selectedType != 'all' && entry['type'] != _selectedType) {
          return false;
        }

        // Method filter
        if (_selectedMethod != 'all' && entry['method'] != _selectedMethod) {
          return false;
        }

        // Date range filter
        if (_startDate != null || _endDate != null) {
          final entryDate = DateTime.parse(entry['date']);
          if (_startDate != null && entryDate.isBefore(_startDate!)) {
            return false;
          }
          if (_endDate != null && entryDate.isAfter(_endDate!)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _showFiltersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Filters',
                    style: AppTypography.titleWithColor(
                      context,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = 'all';
                        _selectedMethod = 'all';
                        _startDate = null;
                        _endDate = null;
                      });
                      this.setState(() {});
                      _applyFilters();
                    },
                    child: Text(
                      'Clear All',
                      style: AppTypography.bodyWithColor(
                        context,
                      ).copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Entry Type Filter
              Text(
                'Entry Type',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _entryTypes.map((type) {
                  final isSelected = _selectedType == type;
                  return FilterChip(
                    label: Text(type.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedType = type);
                      this.setState(() {});
                      _applyFilters();
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Payment Method Filter
              Text(
                'Payment Method',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _paymentMethods.map((method) {
                  final isSelected = _selectedMethod == method;
                  return FilterChip(
                    label: Text(method.toUpperCase()),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedMethod = method);
                      this.setState(() {});
                      _applyFilters();
                    },
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Date Range Filter
              Text(
                'Date Range',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                          this.setState(() {});
                          _applyFilters();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _startDate != null
                              ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                              : 'Start Date',
                          style: AppTypography.captionWithColor(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _endDate = picked);
                          this.setState(() {});
                          _applyFilters();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _endDate != null
                              ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                              : 'End Date',
                          style: AppTypography.captionWithColor(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'All Entries',
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
        actions: [
          IconButton(
            onPressed: _showFiltersDialog,
            icon: Icon(
              Icons.filter_list,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by customer name or notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Active Filters Indicator
          if (_selectedType != 'all' ||
              _selectedMethod != 'all' ||
              _startDate != null ||
              _endDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filters applied',
                    style: AppTypography.captionWithColor(context).copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedType = 'all';
                        _selectedMethod = 'all';
                        _startDate = null;
                        _endDate = null;
                        _searchController.clear();
                      });
                      _applyFilters();
                    },
                    child: Text(
                      'Clear',
                      style: AppTypography.captionWithColor(context).copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${_filteredEntries.length} entries found',
              style: AppTypography.captionWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),

          // Entries List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorState()
                : _filteredEntries.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadEntries,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredEntries.length,
                      itemBuilder: (context, index) {
                        final entry = _filteredEntries[index];
                        return _buildEntryItem(entry);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryItem(Map<String, dynamic> entry) {
    final isCredit = entry['type'] == 'credit';
    final color = isCredit
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final icon = isCredit ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['customer_name'] ?? 'Unknown Customer',
                  style: AppTypography.bodyWithColor(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      '${entry['date']} • ${entry['method']?.toString().toUpperCase()}',
                      style: AppTypography.captionWithColor(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isCredit
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1)
                            : Theme.of(
                                context,
                              ).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isCredit ? 'CREDIT' : 'DEBIT',
                        style: AppTypography.captionWithColor(context).copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                if (entry['note'] != null &&
                    entry['note'].toString().isNotEmpty)
                  Text(
                    entry['note'],
                    style: AppTypography.captionWithColor(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}₹${entry['amount']?.toStringAsFixed(0) ?? '0'}',
            style: AppTypography.bodyWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No entries found',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTypography.bodyWithColor(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedType = 'all';
                _selectedMethod = 'all';
                _startDate = null;
                _endDate = null;
                _searchController.clear();
              });
              _applyFilters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
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
            'Error loading entries',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: AppTypography.bodyWithColor(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadEntries,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
