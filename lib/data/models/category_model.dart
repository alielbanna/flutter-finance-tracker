import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String colorHex;
  final String type;
  final bool isDefault;
  final String createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorHex,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  /// Create CategoryModel from database map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      colorHex: map['color_hex'] as String,
      type: map['type'] as String,
      isDefault: (map['is_default'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  /// Convert CategoryModel to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color_hex': colorHex,
      'type': type,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt,
    };
  }

  /// Create CategoryModel from Entity
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      colorHex: category.colorHex,
      type: category.type.value,
      isDefault: category.isDefault,
      createdAt: category.createdAt.toIso8601String(),
    );
  }

  /// Convert CategoryModel to Entity
  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      colorHex: colorHex,
      type: TransactionType.fromString(type),
      isDefault: isDefault,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Create copy with updated values
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    String? colorHex,
    String? type,
    bool? isDefault,
    String? createdAt,
  }) {
    return CategoryModel(
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
  String toString() {
    return 'CategoryModel(id: $id, name: $name, icon: $icon, '
        'colorHex: $colorHex, type: $type, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.colorHex == colorHex &&
        other.type == type &&
        other.isDefault == isDefault &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        colorHex.hashCode ^
        type.hashCode ^
        isDefault.hashCode ^
        createdAt.hashCode;
  }
}
