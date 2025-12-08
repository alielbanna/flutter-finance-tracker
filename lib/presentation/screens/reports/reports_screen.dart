import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/glassmorphism_card.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with TickerProviderStateMixin {

  late AnimationController _chartController;
  late TabController _tabController;

  final DateTime _selectedMonth = DateTime.now();
  int _selectedPeriod = 0; // 0: Month, 1: Year, 2: All Time

  @override
  void initState() {
    super.initState();

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _tabController = TabController(length: 3, vsync: this);

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _chartController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar
          _buildModernSliverAppBar(),

          // Period Selector
          SliverToBoxAdapter(
            child: _buildPeriodSelector(),
          ),

          // Summary Cards
          SliverToBoxAdapter(
            child: _buildSummaryCards(),
          ),

          // Charts Section
          SliverToBoxAdapter(
            child: _buildChartsSection(),
          ),

          // Category Breakdown
          SliverToBoxAdapter(
            child: _buildCategoryBreakdown(),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.file_download_rounded, color: Colors.white),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Financial Reports',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getPeriodTitle(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha:0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: -1, duration: 800.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildPeriodOption('Month', 0),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPeriodOption('Year', 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPeriodOption('All Time', 2),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 200.ms, duration: 600.ms).fadeIn();
  }

  Widget _buildPeriodOption(String label, int index) {
    final isSelected = _selectedPeriod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = index;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : AppColors.surfaceVariant.withValues(alpha:0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.textHint.withValues(alpha:0.3),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha:0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildSummaryCardsSkeleton();
        }

        final income = provider.monthlyIncome;
        final expense = provider.monthlyExpense;
        final balance = income - expense;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Income',
                  income,
                  Icons.arrow_upward_rounded,
                  AppColors.incomeGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Expense',
                  expense,
                  Icons.arrow_downward_rounded,
                  AppColors.expenseGradient,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Balance',
                  balance,
                  balance >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  balance >= 0 ? AppColors.incomeGradient : AppColors.expenseGradient,
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 600.ms).fadeIn();
      },
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Gradient gradient) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha:0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha:0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(amount),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardsSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha:0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Categories'),
                  Tab(text: 'Trends'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tab Views
            SizedBox(
              height: 300,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewChart(),
                  _buildCategoryChart(),
                  _buildTrendsChart(),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.3, delay: 600.ms, duration: 600.ms).fadeIn();
  }

  Widget _buildOverviewChart() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildChartSkeleton();
        }

        final income = provider.monthlyIncome;
        final expense = provider.monthlyExpense;

        if (income == 0 && expense == 0) {
          return _buildNoDataChart();
        }

        return GlassmorphismCard(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(
                  color: AppColors.income,
                  value: income,
                  title: 'Income\n\$${income.toStringAsFixed(0)}',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: AppColors.expense,
                  value: expense,
                  title: 'Expense\n\$${expense.toStringAsFixed(0)}',
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (event is FlTapUpEvent) {
                    HapticFeedback.lightImpact();
                  }
                },
              ),
            ),
          ),
        ).animate(controller: _chartController)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
            .fadeIn();
      },
    );
  }

  Widget _buildCategoryChart() {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, transactionProvider, categoryProvider, child) {
        if (transactionProvider.isLoading || categoryProvider.isLoading) {
          return _buildChartSkeleton();
        }

        final expenseTransactions = transactionProvider.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();

        if (expenseTransactions.isEmpty) {
          return _buildNoDataChart();
        }

        // Group by category
        Map<String, double> categoryTotals = {};
        for (var transaction in expenseTransactions) {
          categoryTotals[transaction.categoryId] =
              (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
        }

        // Get top 6 categories
        var sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        if (sortedCategories.length > 6) {
          sortedCategories = sortedCategories.take(6).toList();
        }

        return GlassmorphismCard(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: sortedCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final categoryEntry = entry.value;
                final category = categoryProvider.getCategoryById(categoryEntry.key);
                final color = AppColors.chartColors[index % AppColors.chartColors.length];

                return PieChartSectionData(
                  color: color,
                  value: categoryEntry.value,
                  title: '${category?.icon ?? '📦'}\n\$${categoryEntry.value.toStringAsFixed(0)}',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  if (event is FlTapUpEvent) {
                    HapticFeedback.lightImpact();
                  }
                },
              ),
            ),
          ),
        ).animate(controller: _chartController)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
            .fadeIn(delay: 200.ms);
      },
    );
  }

  Widget _buildTrendsChart() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildChartSkeleton();
        }

        final transactions = provider.transactions;
        if (transactions.isEmpty) {
          return _buildNoDataChart();
        }

        // Get daily totals for the last 30 days
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));

        Map<DateTime, double> dailyIncome = {};
        Map<DateTime, double> dailyExpense = {};

        for (var transaction in transactions) {
          if (transaction.date.isAfter(thirtyDaysAgo)) {
            final day = DateTime(
              transaction.date.year,
              transaction.date.month,
              transaction.date.day,
            );

            if (transaction.type == TransactionType.income) {
              dailyIncome[day] = (dailyIncome[day] ?? 0) + transaction.amount;
            } else {
              dailyExpense[day] = (dailyExpense[day] ?? 0) + transaction.amount;
            }
          }
        }

        // Create spots for line chart
        List<FlSpot> incomeSpots = [];
        List<FlSpot> expenseSpots = [];

        for (int i = 0; i < 30; i++) {
          final day = thirtyDaysAgo.add(Duration(days: i));
          final dayKey = DateTime(day.year, day.month, day.day);

          incomeSpots.add(FlSpot(i.toDouble(), dailyIncome[dayKey] ?? 0));
          expenseSpots.add(FlSpot(i.toDouble(), dailyExpense[dayKey] ?? 0));
        }

        return GlassmorphismCard(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 100,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.textHint.withValues(alpha:0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 7,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final day = thirtyDaysAgo.add(Duration(days: value.toInt()));
                      return Text(
                        DateFormat('M/d').format(day),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 500,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '\$${value.toInt()}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: AppColors.textHint.withValues(alpha:0.2)),
              ),
              minX: 0,
              maxX: 29,
              minY: 0,
              maxY: _getMaxValue([...incomeSpots, ...expenseSpots]) * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: incomeSpots,
                  isCurved: true,
                  gradient: AppColors.incomeGradient,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.income.withValues(alpha:0.3),
                        AppColors.income.withValues(alpha:0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: expenseSpots,
                  isCurved: true,
                  gradient: AppColors.expenseGradient,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.expense.withValues(alpha:0.3),
                        AppColors.expense.withValues(alpha:0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent) {
                    HapticFeedback.lightImpact();
                  }
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final isIncome = barSpot.barIndex == 0;
                      return LineTooltipItem(
                        '${isIncome ? "Income" : "Expense"}\n\${barSpot.y.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                  getTooltipColor: (g)=>AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ).animate(controller: _chartController)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
            .fadeIn(delay: 400.ms);
      },
    );
  }

  Widget _buildCategoryBreakdown() {
    return Consumer2<TransactionProvider, CategoryProvider>(
      builder: (context, transactionProvider, categoryProvider, child) {
        if (transactionProvider.isLoading || categoryProvider.isLoading) {
          return const SizedBox.shrink();
        }

        final expenseTransactions = transactionProvider.transactions
            .where((t) => t.type == TransactionType.expense)
            .toList();

        if (expenseTransactions.isEmpty) {
          return const SizedBox.shrink();
        }

        // Group by category
        Map<String, double> categoryTotals = {};
        for (var transaction in expenseTransactions) {
          categoryTotals[transaction.categoryId] =
              (categoryTotals[transaction.categoryId] ?? 0) + transaction.amount;
        }

        final totalExpense = categoryTotals.values.fold(0.0, (a, b) => a + b);
        var sortedCategories = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          margin: const EdgeInsets.all(16),
          child: GlassmorphismCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                ...sortedCategories.take(8).map((entry) {
                  final category = categoryProvider.getCategoryById(entry.key);
                  final percentage = (entry.value / totalExpense * 100);
                  final colorIndex = sortedCategories.indexOf(entry) % AppColors.chartColors.length;
                  final color = AppColors.chartColors[colorIndex];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    category?.icon ?? '📦',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      category?.name ?? 'Unknown',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${entry.value.toStringAsFixed(0)}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: AppColors.textHint.withValues(alpha:0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ).animate().slideY(begin: 0.3, delay: 800.ms, duration: 600.ms).fadeIn();
      },
    );
  }

  Widget _buildChartSkeleton() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildNoDataChart() {
    return GlassmorphismCard(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                size: 48,
                color: AppColors.textHint,
              ),
              const SizedBox(height: 16),
              Text(
                'No data available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add some transactions to see charts',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  double _getMaxValue(List<FlSpot> spots) {
    if (spots.isEmpty) return 100;
    return spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
  }

  String _getPeriodTitle() {
    switch (_selectedPeriod) {
      case 0:
        return DateFormat('MMMM yyyy').format(_selectedMonth);
      case 1:
        return DateFormat('yyyy').format(_selectedMonth);
      case 2:
        return 'All Time';
      default:
        return '';
    }
  }

  void _exportReport() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Report',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement PDF export
              },
            ),

            ListTile(
              leading: const Icon(Icons.table_chart_rounded, color: AppColors.success),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement CSV export
              },
            ),

            ListTile(
              leading: const Icon(Icons.share_rounded, color: AppColors.info),
              title: const Text('Share Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}