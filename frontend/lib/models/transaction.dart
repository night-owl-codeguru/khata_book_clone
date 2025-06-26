enum TransactionType { credit, debit }

class Transaction {
  final int? id;
  final int customerId;
  final String customerName;
  final TransactionType type;
  final double amount;
  final String description;
  final String? category;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.customerId,
    required this.customerName,
    required this.type,
    required this.amount,
    required this.description,
    this.category,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : date = date ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? '',
      type: json['type'] == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      description: json['description'] ?? '',
      category: json['category'],
      date: DateTime.parse(json['date']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'customer_name': customerName,
      'type': type == TransactionType.credit ? 'credit' : 'debit',
      'amount': amount,
      'description': description,
      'category': category,
      'date': date.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isCredit => type == TransactionType.credit;
  bool get isDebit => type == TransactionType.debit;

  Transaction copyWith({
    int? id,
    int? customerId,
    String? customerName,
    TransactionType? type,
    double? amount,
    String? description,
    String? category,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
