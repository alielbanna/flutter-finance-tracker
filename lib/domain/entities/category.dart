import 'package:equatable/equatable.dart';
import 'transaction.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final TransactionType type;
  final bool isDefault;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.type,
    this.isDefault = false,
    required this.createdAt,
  });

  // Helper methods
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;

  String get displayName => name;
  String get displayIcon => icon;

  // Copy with method
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? colorHex,
    TransactionType? type,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorHex: colorHex ?? this.colorHex,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    colorHex,
    type,
    isDefault,
    createdAt,
  ];

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, '
        'colorHex: $colorHex, type: $type, isDefault: $isDefault)';
  }
}

// Default categories for initial setup
class DefaultCategories {
  static List<Category> get expenseCategories => [
    Category(
      id: 'exp_food',
      name: 'Food & Dining',
      icon: '🍕',
      colorHex: 'FF5722',
      type: TransactionType.expense,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'exp_transport',
      name: 'Transportation',
      icon: '🚗',
      colorHex: '2196F3',
      type: TransactionType.expense,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'exp_shopping',
      name: 'Shopping',
      icon: '🛒',
      colorHex: '9C27B0',
      type: TransactionType.expense,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'exp_entertainment',
      name: 'Entertainment',
      icon: '🎬',
      colorHex: 'E91E63',
      type: TransactionType.expense,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'exp_bills',
      name: 'Bills & Utilities',
      icon: '💡',
      colorHex: 'FF9800',
      type: TransactionType.expense,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'exp_health',
      name: 'Healthcare',
      icon: '🏥',
      colorHex: '4CAF50',
      type: TransactionType.expense,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'exp_education',
      name: 'Education',
      icon: '📚',
      colorHex: '00BCD4',
      type: TransactionType.expense,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'exp_other',
      name: 'Other',
      icon: '📦',
      colorHex: '607D8B',
      type: TransactionType.expense,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
  ];

  static List<Category> get incomeCategories => [
    Category(
      id: 'inc_salary',
      name: 'Salary',
      icon: '💰',
      colorHex: '4CAF50',
      type: TransactionType.income,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'inc_freelance',
      name: 'Freelance',
      icon: '💻',
      colorHex: '2196F3',
      type: TransactionType.income,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'inc_business',
      name: 'Business',
      icon: '🏢',
      colorHex: '9C27B0',
      type: TransactionType.income,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'inc_investment',
      name: 'Investment',
      icon: '📈',
      colorHex: 'FF9800',
      type: TransactionType.income,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'inc_gift',
      name: 'Gift',
      icon: '🎁',
      colorHex: 'E91E63',
      type: TransactionType.income,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
    Category(
      id: 'inc_other',
      name: 'Other Income',
      icon: '💵',
      colorHex: '607D8B',
      type: TransactionType.income,
      isDefault: true,
      createdAt: DateTime.now(),
    ),
  ];

  static List<Category> get allCategories => [
    ...expenseCategories,
    ...incomeCategories,
  ];
}
