import '../entities/transaction.dart';

abstract class TransactionRepository {
  /// Get all transactions
  Future<List<Transaction>> getAllTransactions();

  /// Get transactions by date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get transactions by category
  Future<List<Transaction>> getTransactionsByCategory(String categoryId);

  /// Add new transaction
  Future<String> addTransaction(Transaction transaction);

  /// Update existing transaction
  Future<void> updateTransaction(Transaction transaction);

  /// Delete transaction
  Future<void> deleteTransaction(String id);

  /// Search transactions by description or notes
  Future<List<Transaction>> searchTransactions(String query);

  /// Get monthly summary (income, expense, balance)
  Future<Map<String, dynamic>> getMonthlySummary(DateTime month);

  /// Get category-wise expense summary for a month
  Future<List<Map<String, dynamic>>> getCategoryExpenseSummary(DateTime month);
}
