import '../entities/category.dart';
import '../entities/transaction.dart';

abstract class CategoryRepository {
  /// Get all categories
  Future<List<Category>> getAllCategories();

  /// Get categories by type (income/expense)
  Future<List<Category>> getCategoriesByType(TransactionType type);

  /// Add new category
  Future<String> addCategory(Category category);

  /// Update existing category
  Future<void> updateCategory(Category category);

  /// Delete category (only if no transactions exist)
  Future<void> deleteCategory(String id);

  /// Get category by id
  Future<Category?> getCategoryById(String id);

  /// Check if category has transactions
  Future<bool> categoryHasTransactions(String categoryId);
}
