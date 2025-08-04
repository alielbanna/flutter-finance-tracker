import '../../domain/entities/transaction.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String description;
  final String categoryId;
  final String type;
  final String date;
  final String createdAt;
  final String? notes;

  // Additional fields from JOIN queries
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  const TransactionModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.type,
    required this.date,
    required this.createdAt,
    this.notes,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  /// Create TransactionModel from database map
  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String,
      categoryId: map['category_id'] as String,
      type: map['type'] as String,
      date: map['date'] as String,
      createdAt: map['created_at'] as String,
      notes: map['notes'] as String?,
      categoryName: map['category_name'] as String?,
      categoryIcon: map['category_icon'] as String?,
      categoryColor: map['category_color'] as String?,
    );
  }

  /// Convert TransactionModel to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'category_id': categoryId,
      'type': type,
      'date': date,
      'created_at': createdAt,
      'notes': notes,
    };
  }

  /// Create TransactionModel from Entity
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      description: transaction.description,
      categoryId: transaction.categoryId,
      type: transaction.type.value,
      date: transaction.date.toIso8601String(),
      createdAt: transaction.createdAt.toIso8601String(),
      notes: transaction.notes,
    );
  }

  /// Convert TransactionModel to Entity
  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      description: description,
      categoryId: categoryId,
      type: TransactionType.fromString(type),
      date: DateTime.parse(date),
      createdAt: DateTime.parse(createdAt),
      notes: notes,
    );
  }

  /// Create copy with updated values
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? description,
    String? categoryId,
    String? type,
    String? date,
    String? createdAt,
    String? notes,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, description: $description, '
        'categoryId: $categoryId, type: $type, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransactionModel &&
        other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.categoryId == categoryId &&
        other.type == type &&
        other.date == date &&
        other.createdAt == createdAt &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        categoryId.hashCode ^
        type.hashCode ^
        date.hashCode ^
        createdAt.hashCode ^
        notes.hashCode;
  }
}
