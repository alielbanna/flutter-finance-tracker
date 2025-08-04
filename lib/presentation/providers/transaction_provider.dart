import 'package:flutter/foundation.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

enum LoadingState { idle, loading, success, error }

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionProvider(this._repository);

  // State variables
  List<Transaction> _transactions = [];
  LoadingState _loadingState = LoadingState.idle;
  String? _error;
  Map<String, dynamic>? _monthlySummary;
  List<Map<String, dynamic>> _categoryExpenseSummary = [];

  // Getters
  List<Transaction> get transactions => _transactions;
  LoadingState get loadingState => _loadingState;
  String? get error => _error;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get hasError => _loadingState == LoadingState.error;
  Map<String, dynamic>? get monthlySummary => _monthlySummary;
  List<Map<String, dynamic>> get categoryExpenseSummary =>
      _categoryExpenseSummary;

  // Computed properties
  double get totalBalance {
    if (_monthlySummary != null) {
      return (_monthlySummary!['balance'] as num?)?.toDouble() ?? 0.0;
    }

    double income = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    double expense = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    return income - expense;
  }

  double get monthlyIncome {
    if (_monthlySummary != null) {
      return (_monthlySummary!['income'] as num?)?.toDouble() ?? 0.0;
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endOfMonth.add(const Duration(days: 1))),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    if (_monthlySummary != null) {
      return (_monthlySummary!['expense'] as num?)?.toDouble() ?? 0.0;
    }

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return _transactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endOfMonth.add(const Duration(days: 1))),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<Transaction> get recentTransactions {
    return _transactions.take(10).toList();
  }

  List<Transaction> get todayTransactions {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _transactions
        .where(
          (t) =>
              t.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(endOfDay),
        )
        .toList();
  }

  // Methods
  Future<void> loadTransactions() async {
    try {
      _setLoadingState(LoadingState.loading);
      _transactions = await _repository.getAllTransactions();
      await _loadMonthlySummary();
      await _loadCategoryExpenseSummary();
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _error = e.toString();
      _setLoadingState(LoadingState.error);
      debugPrint('Error loading transactions: $e');
    }
  }

  Future<void> loadTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _setLoadingState(LoadingState.loading);
      _transactions = await _repository.getTransactionsByDateRange(
        startDate,
        endDate,
      );
      _setLoadingState(LoadingState.success);
    } catch (e) {
      _error = e.toString();
      _setLoadingState(LoadingState.error);
      debugPrint('Error loading transactions by date range: $e');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _repository.addTransaction(transaction);

      // Add to local list for immediate UI update
      _transactions = [transaction, ..._transactions];

      // Refresh data
      await _loadMonthlySummary();
      await _loadCategoryExpenseSummary();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoadingState(LoadingState.error);
      debugPrint('Error adding transaction: $e');
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _repository.updateTransaction(transaction);

      // Update in local list
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }

      // Refresh data
      await _loadMonthlySummary();
      await _loadCategoryExpenseSummary();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoadingState(LoadingState.error);
      debugPrint('Error updating transaction: $e');
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);

      // Remove from local list
      _transactions.removeWhere((t) => t.id == id);

      // Refresh data
      await _loadMonthlySummary();
      await _loadCategoryExpenseSummary();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoadingState(LoadingState.error);
      debugPrint('Error deleting transaction: $e');
    }
  }

  Future<List<Transaction>> searchTransactions(String query) async {
    try {
      if (query.isEmpty) {
        return _transactions;
      }
      return await _repository.searchTransactions(query);
    } catch (e) {
      debugPrint('Error searching transactions: $e');
      return [];
    }
  }

  Future<void> _loadMonthlySummary() async {
    try {
      final now = DateTime.now();
      _monthlySummary = await _repository.getMonthlySummary(now);
    } catch (e) {
      debugPrint('Error loading monthly summary: $e');
    }
  }

  Future<void> _loadCategoryExpenseSummary() async {
    try {
      final now = DateTime.now();
      _categoryExpenseSummary = await _repository.getCategoryExpenseSummary(
        now,
      );
    } catch (e) {
      debugPrint('Error loading category expense summary: $e');
    }
  }

  void _setLoadingState(LoadingState state) {
    _loadingState = state;
    if (state != LoadingState.error) {
      _error = null;
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    if (_loadingState == LoadingState.error) {
      _loadingState = LoadingState.idle;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadTransactions();
  }

  // Filter methods
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  List<Transaction> getTransactionsByCategory(String categoryId) {
    return _transactions.where((t) => t.categoryId == categoryId).toList();
  }

  // Statistics methods
  Map<String, double> getCategoryTotals(TransactionType type) {
    Map<String, double> totals = {};

    for (var transaction in _transactions) {
      if (transaction.type == type) {
        totals[transaction.categoryId] =
            (totals[transaction.categoryId] ?? 0) + transaction.amount;
      }
    }

    return totals;
  }

  Map<DateTime, double> getDailyTotals(TransactionType type, DateTime month) {
    Map<DateTime, double> totals = {};

    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    for (var transaction in _transactions) {
      if (transaction.type == type &&
          transaction.date.isAfter(
            startOfMonth.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        final day = DateTime(
          transaction.date.year,
          transaction.date.month,
          transaction.date.day,
        );

        totals[day] = (totals[day] ?? 0) + transaction.amount;
      }
    }

    return totals;
  }
}
