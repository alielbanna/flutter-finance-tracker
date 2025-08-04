import 'package:equatable/equatable.dart';

enum TransactionType {
  income('income'),
  expense('expense');

  const TransactionType(this.value);
  final String value;

  static TransactionType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        throw ArgumentError('Invalid transaction type: $value');
    }
  }
}

class Transaction extends Equatable {
  final String id;
  final double amount;
  final String description;
  final String categoryId;
  final TransactionType type;
  final DateTime date;
  final DateTime createdAt;
  final String? notes;

  const Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.type,
    required this.date,
    required this.createdAt,
    this.notes,
  });

  // Helper methods
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  String get formattedAmount {
    final prefix = isIncome ? '+' : '-';
    return '$prefix\$${amount.toStringAsFixed(2)}';
  }

  // Copy with method
  Transaction copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    TransactionType? type,
    DateTime? date,
    DateTime? createdAt,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    amount,
    description,
    categoryId,
    type,
    date,
    createdAt,
    notes,
  ];

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, description: $description, '
        'categoryId: $categoryId, type: $type, date: $date)';
  }
}
