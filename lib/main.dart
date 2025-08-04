import 'package:flutter/material.dart';

import 'core/constants/app_themes.dart';
import 'data/datasources/local/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize database
    await DatabaseHelper.instance.database;
    print('✅ Database initialized successfully');

    // Test database by getting categories
    final categories = await DatabaseHelper.instance.getAllCategories();
    print('✅ Found ${categories.length} categories in database');
  } catch (e) {
    print('❌ Database initialization failed: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Master',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      home: const TestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Map<String, dynamic>> categories = [];
  Map<String, dynamic>? dbStats;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Load categories
      final cats = await DatabaseHelper.instance.getAllCategories();

      // Load database stats
      final stats = await DatabaseHelper.instance.getDatabaseStats();

      setState(() {
        categories = cats;
        dbStats = stats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Master - Database Test'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Database Stats Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📊 Database Statistics',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          if (dbStats != null) ...[
                            _buildStatRow(
                              'Categories',
                              '${dbStats!['category_count']}',
                            ),
                            _buildStatRow(
                              'Transactions',
                              '${dbStats!['transaction_count']}',
                            ),
                            _buildStatRow(
                              'Total Income',
                              '\$${dbStats!['total_income']}',
                            ),
                            _buildStatRow(
                              'Total Expense',
                              '\$${dbStats!['total_expense']}',
                            ),
                            _buildStatRow(
                              'Net Balance',
                              '\$${dbStats!['net_balance']}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Categories Section
                  Text(
                    '📂 Categories (${categories.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),

                  // Income Categories
                  _buildCategorySection('Income Categories', 'income'),

                  const SizedBox(height: 16),

                  // Expense Categories
                  _buildCategorySection('Expense Categories', 'expense'),

                  const SizedBox(height: 32),

                  // Success Message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '✅ Database Setup Complete!',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your SQLite database is working correctly with default categories loaded.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.green[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, String type) {
    final filteredCategories = categories
        .where((cat) => cat['type'] == type)
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredCategories.map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse('FF${category['color_hex']}', radix: 16),
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Color(
                        int.parse('FF${category['color_hex']}', radix: 16),
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category['icon'],
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category['name'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
