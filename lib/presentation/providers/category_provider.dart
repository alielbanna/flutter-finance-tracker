import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repository;

  CategoryProvider(this._repository);

  // State variables
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  // Filtered categories
  List<Category> get incomeCategories =>
      _categories.where((cat) => cat.type == TransactionType.income).toList();

  List<Category> get expenseCategories =>
      _categories.where((cat) => cat.type == TransactionType.expense).toList();

  List<Category> getCategoriesByType(TransactionType type) {
    return _categories.where((cat) => cat.type == type).toList();
  }

  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  // Methods
  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      _categories = await _repository.getAllCategories();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> addCategory(Category category) async {
    try {
      await _repository.addCategory(category);

      // Add to local list for immediate UI update
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error adding category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _repository.updateCategory(category);

      // Update in local list
      final index = _categories.indexWhere((cat) => cat.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repository.deleteCategory(id);

      // Remove from local list
      _categories.removeWhere((cat) => cat.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      debugPrint('Error deleting category: $e');
    }
  }

  Future<bool> categoryHasTransactions(String categoryId) async {
    try {
      return await _repository.categoryHasTransactions(categoryId);
    } catch (e) {
      debugPrint('Error checking category transactions: $e');
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) {
      _error = null;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadCategories();
  }
}