import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../domain/entities/category.dart';

class DatabaseHelper {
  static const String _databaseName = 'money_master.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String transactionsTable = 'transactions';
  static const String categoriesTable = 'categories';
  static const String budgetsTable = 'budgets';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Get database instance (create if doesn't exist)
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e) {
      throw DatabaseException('Failed to initialize database: $e');
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      // Create categories table
      await db.execute('''
        CREATE TABLE $categoriesTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          icon TEXT NOT NULL,
          color_hex TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
          is_default INTEGER DEFAULT 0 CHECK (is_default IN (0, 1)),
          created_at TEXT NOT NULL
        )
      ''');

      // Create transactions table
      await db.execute('''
        CREATE TABLE $transactionsTable (
          id TEXT PRIMARY KEY,
          amount REAL NOT NULL CHECK (amount > 0),
          description TEXT NOT NULL,
          category_id TEXT NOT NULL,
          type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
          date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          notes TEXT,
          FOREIGN KEY (category_id) REFERENCES $categoriesTable (id) ON DELETE RESTRICT
        )
      ''');

      // Create budgets table
      await db.execute('''
        CREATE TABLE $budgetsTable (
          id TEXT PRIMARY KEY,
          category_id TEXT NOT NULL,
          amount REAL NOT NULL CHECK (amount > 0),
          period TEXT NOT NULL CHECK (period IN ('weekly', 'monthly', 'yearly')),
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES $categoriesTable (id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for better performance
      await db.execute('''
        CREATE INDEX idx_transactions_date ON $transactionsTable (date)
      ''');

      await db.execute('''
        CREATE INDEX idx_transactions_category ON $transactionsTable (category_id)
      ''');

      await db.execute('''
        CREATE INDEX idx_transactions_type ON $transactionsTable (type)
      ''');

      // Insert default categories
      await _insertDefaultCategories(db);

      print('Database created successfully with version $version');
    } catch (e) {
      throw DatabaseException('Failed to create database tables: $e');
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      print('Upgrading database from version $oldVersion to $newVersion');

      // Handle future database migrations here
      if (oldVersion < 2) {
        // Example migration for version 2
        // await db.execute('ALTER TABLE $transactionsTable ADD COLUMN notes TEXT');
      }
    } catch (e) {
      throw DatabaseException('Failed to upgrade database: $e');
    }
  }

  /// Handle database open
  Future<void> _onOpen(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    print('Database opened successfully');
  }

  /// Insert default categories
  Future<void> _insertDefaultCategories(Database db) async {
    try {
      final defaultCategories = DefaultCategories.allCategories;

      for (var category in defaultCategories) {
        await db.insert(categoriesTable, {
          'id': category.id,
          'name': category.name,
          'icon': category.icon,
          'color_hex': category.colorHex,
          'type': category.type.value,
          'is_default': category.isDefault ? 1 : 0,
          'created_at': category.createdAt.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      print('Default categories inserted successfully');
    } catch (e) {
      throw DatabaseException('Failed to insert default categories: $e');
    }
  }

  /// Get all categories
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final db = await database;
      return await db.query(categoriesTable, orderBy: 'type DESC, name ASC');
    } catch (e) {
      throw DatabaseException('Failed to get categories: $e');
    }
  }

  /// Get categories by type
  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    try {
      final db = await database;
      return await db.query(
        categoriesTable,
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'name ASC',
      );
    } catch (e) {
      throw DatabaseException('Failed to get categories by type: $e');
    }
  }

  /// Insert category
  Future<void> insertCategory(Map<String, dynamic> category) async {
    try {
      final db = await database;
      await db.insert(
        categoriesTable,
        category,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert category: $e');
    }
  }

  /// Get all transactions
  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT 
          t.*,
          c.name as category_name,
          c.icon as category_icon,
          c.color_hex as category_color
        FROM $transactionsTable t
        LEFT JOIN $categoriesTable c ON t.category_id = c.id
        ORDER BY t.date DESC, t.created_at DESC
      ''');
    } catch (e) {
      throw DatabaseException('Failed to get transactions: $e');
    }
  }

  /// Get transactions by date range
  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
    String startDate,
    String endDate,
  ) async {
    try {
      final db = await database;
      return await db.rawQuery(
        '''
        SELECT 
          t.*,
          c.name as category_name,
          c.icon as category_icon,
          c.color_hex as category_color
        FROM $transactionsTable t
        LEFT JOIN $categoriesTable c ON t.category_id = c.id
        WHERE t.date BETWEEN ? AND ?
        ORDER BY t.date DESC, t.created_at DESC
      ''',
        [startDate, endDate],
      );
    } catch (e) {
      throw DatabaseException('Failed to get transactions by date range: $e');
    }
  }

  /// Get transactions by category
  Future<List<Map<String, dynamic>>> getTransactionsByCategory(
    String categoryId,
  ) async {
    try {
      final db = await database;
      return await db.rawQuery(
        '''
        SELECT 
          t.*,
          c.name as category_name,
          c.icon as category_icon,
          c.color_hex as category_color
        FROM $transactionsTable t
        LEFT JOIN $categoriesTable c ON t.category_id = c.id
        WHERE t.category_id = ?
        ORDER BY t.date DESC, t.created_at DESC
      ''',
        [categoryId],
      );
    } catch (e) {
      throw DatabaseException('Failed to get transactions by category: $e');
    }
  }

  /// Insert transaction
  Future<void> insertTransaction(Map<String, dynamic> transaction) async {
    try {
      final db = await database;
      await db.insert(
        transactionsTable,
        transaction,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert transaction: $e');
    }
  }

  /// Update transaction
  Future<void> updateTransaction(
    String id,
    Map<String, dynamic> transaction,
  ) async {
    try {
      final db = await database;
      await db.update(
        transactionsTable,
        transaction,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update transaction: $e');
    }
  }

  /// Delete transaction
  Future<void> deleteTransaction(String id) async {
    try {
      final db = await database;
      await db.delete(transactionsTable, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw DatabaseException('Failed to delete transaction: $e');
    }
  }

  /// Get monthly summary
  Future<Map<String, dynamic>> getMonthlySummary(String month) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
        SELECT 
          type,
          SUM(amount) as total,
          COUNT(*) as count
        FROM $transactionsTable
        WHERE strftime('%Y-%m', date) = ?
        GROUP BY type
      ''',
        [month],
      );

      double income = 0.0;
      double expense = 0.0;
      int incomeCount = 0;
      int expenseCount = 0;

      for (var row in result) {
        if (row['type'] == 'income') {
          income = (row['total'] as num).toDouble();
          incomeCount = row['count'] as int;
        } else if (row['type'] == 'expense') {
          expense = (row['total'] as num).toDouble();
          expenseCount = row['count'] as int;
        }
      }

      return {
        'income': income,
        'expense': expense,
        'balance': income - expense,
        'income_count': incomeCount,
        'expense_count': expenseCount,
        'total_transactions': incomeCount + expenseCount,
      };
    } catch (e) {
      throw DatabaseException('Failed to get monthly summary: $e');
    }
  }

  /// Get category-wise expense summary
  Future<List<Map<String, dynamic>>> getCategoryExpenseSummary(
    String month,
  ) async {
    try {
      final db = await database;
      return await db.rawQuery(
        '''
        SELECT 
          c.id,
          c.name,
          c.icon,
          c.color_hex,
          SUM(t.amount) as total,
          COUNT(t.id) as count,
          (SUM(t.amount) * 100.0 / (
            SELECT SUM(amount) 
            FROM $transactionsTable 
            WHERE type = 'expense' AND strftime('%Y-%m', date) = ?
          )) as percentage
        FROM $transactionsTable t
        JOIN $categoriesTable c ON t.category_id = c.id
        WHERE t.type = 'expense' AND strftime('%Y-%m', t.date) = ?
        GROUP BY c.id, c.name, c.icon, c.color_hex
        HAVING total > 0
        ORDER BY total DESC
      ''',
        [month, month],
      );
    } catch (e) {
      throw DatabaseException('Failed to get category expense summary: $e');
    }
  }

  /// Search transactions
  Future<List<Map<String, dynamic>>> searchTransactions(String query) async {
    try {
      final db = await database;
      return await db.rawQuery(
        '''
        SELECT 
          t.*,
          c.name as category_name,
          c.icon as category_icon,
          c.color_hex as category_color
        FROM $transactionsTable t
        LEFT JOIN $categoriesTable c ON t.category_id = c.id
        WHERE t.description LIKE ? OR t.notes LIKE ?
        ORDER BY t.date DESC, t.created_at DESC
        LIMIT 50
      ''',
        ['%$query%', '%$query%'],
      );
    } catch (e) {
      throw DatabaseException('Failed to search transactions: $e');
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final db = await database;

      final transactionCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $transactionsTable'),
          ) ??
          0;

      final categoryCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $categoriesTable'),
          ) ??
          0;

      final totalIncome =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT SUM(amount) FROM $transactionsTable WHERE type = ?',
              ['income'],
            ),
          ) ??
          0;

      final totalExpense =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT SUM(amount) FROM $transactionsTable WHERE type = ?',
              ['expense'],
            ),
          ) ??
          0;

      return {
        'transaction_count': transactionCount,
        'category_count': categoryCount,
        'total_income': totalIncome,
        'total_expense': totalExpense,
        'net_balance': totalIncome - totalExpense,
      };
    } catch (e) {
      throw DatabaseException('Failed to get database stats: $e');
    }
  }

  /// Close database connection
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete database (for testing purposes)
  Future<void> deleteDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
      print('Database deleted successfully');
    } catch (e) {
      throw DatabaseException('Failed to delete database: $e');
    }
  }
}

/// Custom exception for database operations
class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
