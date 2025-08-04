import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/database_helper.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final maps = await _databaseHelper.getAllCategories();
      return maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all categories: $e');
    }
  }

  @override
  Future<List<Category>> getCategoriesByType(TransactionType type) async {
    try {
      final maps = await _databaseHelper.getCategoriesByType(type.value);
      return maps.map((map) => CategoryModel.fromMap(map).toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get categories by type: $e');
    }
  }

  @override
  Future<String> addCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      await _databaseHelper.insertCategory(model.toMap());
      return category.id;
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  @override
  Future<void> updateCategory(Category category) async {
    try {
      final model = CategoryModel.fromEntity(category);
      // Note: You'll need to add updateCategory method to DatabaseHelper
      // await _databaseHelper.updateCategory(category.id, model.toMap());
      throw UnimplementedError('Update category not implemented yet');
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      // Check if category has transactions first
      final hasTransactions = await categoryHasTransactions(id);
      if (hasTransactions) {
        throw Exception('Cannot delete category with existing transactions');
      }
      // Note: You'll need to add deleteCategory method to DatabaseHelper
      // await _databaseHelper.deleteCategory(id);
      throw UnimplementedError('Delete category not implemented yet');
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final categories = await getAllCategories();
      try {
        return categories.firstWhere((category) => category.id == id);
      } catch (e) {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get category by id: $e');
    }
  }

  @override
  Future<bool> categoryHasTransactions(String categoryId) async {
    try {
      final transactions = await _databaseHelper.getTransactionsByCategory(
        categoryId,
      );
      return transactions.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check if category has transactions: $e');
    }
  }
}
