import '../datasources/local/database_helper.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final maps = await _databaseHelper.getAllTransactions();
      return maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get all transactions: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final maps = await _databaseHelper.getTransactionsByDateRange(
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      );
      return maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions by date range: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    try {
      final maps = await _databaseHelper.getTransactionsByCategory(categoryId);
      return maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to get transactions by category: $e');
    }
  }

  @override
  Future<String> addTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _databaseHelper.insertTransaction(model.toMap());
      return transaction.id;
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _databaseHelper.updateTransaction(transaction.id, model.toMap());
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _databaseHelper.deleteTransaction(id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Future<List<Transaction>> searchTransactions(String query) async {
    try {
      final maps = await _databaseHelper.searchTransactions(query);
      return maps
          .map((map) => TransactionModel.fromMap(map).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Failed to search transactions: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getMonthlySummary(DateTime month) async {
    try {
      final monthString =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      return await _databaseHelper.getMonthlySummary(monthString);
    } catch (e) {
      throw Exception('Failed to get monthly summary: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoryExpenseSummary(
    DateTime month,
  ) async {
    try {
      final monthString =
          '${month.year}-${month.month.toString().padLeft(2, '0')}';
      return await _databaseHelper.getCategoryExpenseSummary(monthString);
    } catch (e) {
      throw Exception('Failed to get category expense summary: $e');
    }
  }
}
