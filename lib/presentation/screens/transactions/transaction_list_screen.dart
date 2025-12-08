import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/modern_transaction_card.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with TickerProviderStateMixin {

  // Animation Controllers
  late AnimationController _searchAnimController;
  late AnimationController _filterAnimController;

  // Text and Scroll Controllers
  final _searchTextController = TextEditingController();
  final _scrollController = ScrollController();

  // State variables
  bool _isSearchActive = false;
  TransactionType? _selectedTypeFilter;
  String? _selectedCategoryFilter;
  DateTimeRange? _selectedDateRange;

  List<Transaction> _filteredTransactions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _filterAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchAnimController.dispose();
    _filterAnimController.dispose();
    _searchTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFilteredTransactions(List<Transaction> allTransactions) {
    setState(() {
      _filteredTransactions = allTransactions.where((transaction) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          if (!transaction.description.toLowerCase().contains(query) &&
              !(transaction.notes?.toLowerCase().contains(query) ?? false)) {
            return false;
          }
        }

        // Type filter
        if (_selectedTypeFilter != null && transaction.type != _selectedTypeFilter) {
          return false;
        }

        // Category filter
        if (_selectedCategoryFilter != null &&
            transaction.categoryId != _selectedCategoryFilter) {
          return false;
        }

        // Date range filter
        if (_selectedDateRange != null) {
          final transactionDate = DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          );
          if (transactionDate.isBefore(_selectedDateRange!.start) ||
              transactionDate.isAfter(_selectedDateRange!.end)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar with Search
          _buildModernSliverAppBar(),

          // Filter Bar
          SliverToBoxAdapter(
            child: _buildFilterBar(),
          ),

          // Transaction List
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return SliverToBoxAdapter(
                  child: _buildLoadingShimmer(),
                );
              }

              if (provider.hasError) {
                return SliverToBoxAdapter(
                  child: _buildErrorWidget(provider.error!, () {
                    provider.refresh();
                  }),
                );
              }

              _updateFilteredTransactions(provider.transactions);

              if (_filteredTransactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState(),
                );
              }

              return _buildTransactionList();
            },
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildModernSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _isSearchActive ? 140 : 120,
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
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearchActive ? Icons.close_rounded : Icons.search_rounded,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
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
                  if (!_isSearchActive) ...[
                    Text(
                      'All Transactions',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Consumer<TransactionProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          '${_filteredTransactions.length} transactions',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha:0.9),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    // Search Field
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha:0.3)),
                      ),
                      child: TextField(
                        controller: _searchTextController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search transactions...',
                          hintStyle: TextStyle(color: Colors.white.withValues(alpha:0.7)),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: Colors.white.withValues(alpha:0.7),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    )
                        .animate(controller: _searchAnimController)
                        .slideY(begin: -0.5, end: 0)
                        .fadeIn(),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final hasActiveFilters = _selectedTypeFilter != null ||
        _selectedCategoryFilter != null ||
        _selectedDateRange != null;

    if (!hasActiveFilters) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (_selectedTypeFilter != null)
              _buildFilterChip(
                label: _selectedTypeFilter!.name.toUpperCase(),
                color: _selectedTypeFilter == TransactionType.income
                    ? AppColors.income
                    : AppColors.expense,
                onDeleted: () {
                  setState(() {
                    _selectedTypeFilter = null;
                  });
                },
              ),

            if (_selectedCategoryFilter != null)
              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, child) {
                  final category = categoryProvider.getCategoryById(_selectedCategoryFilter!);
                  return _buildFilterChip(
                    label: category?.name ?? 'Unknown Category',
                    color: AppColors.primary,
                    onDeleted: () {
                      setState(() {
                        _selectedCategoryFilter = null;
                      });
                    },
                  );
                },
              ),

            if (_selectedDateRange != null)
              _buildFilterChip(
                label: '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}',
                color: AppColors.info,
                onDeleted: () {
                  setState(() {
                    _selectedDateRange = null;
                  });
                },
              ),
          ],
        ),
      ),
    ).animate().slideY(begin: -0.3, duration: 300.ms).fadeIn();
  }

  Widget _buildFilterChip({
    required String label,
    required Color color,
    required VoidCallback onDeleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        deleteIcon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
        onDeleted: onDeleted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final transaction = _filteredTransactions[index];

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child) {
                    final category = categoryProvider.getCategoryById(transaction.categoryId);

                    return ModernTransactionCard(
                      transaction: transaction,
                      categoryName: category?.name,
                      categoryIcon: category?.icon,
                      categoryColor: category?.colorHex,
                      index: index,
                      onTap: () => _showTransactionDetails(transaction),
                      onEdit: () => _editTransaction(transaction),
                      onDelete: () => _deleteTransaction(transaction),
                    );
                  },
                ),
              ),
            ),
          );
        },
        childCount: _filteredTransactions.length,
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(8, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon shimmer
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),

              // Content shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Amount shimmer
              Container(
                height: 20,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha:0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _selectedTypeFilter != null ||
        _selectedCategoryFilter != null ||
        _selectedDateRange != null ||
        _searchQuery.isNotEmpty;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: hasFilters
                  ? LinearGradient(
                colors: [AppColors.info.withValues(alpha:0.8), AppColors.info],
              )
                  : AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.search_off_rounded : Icons.receipt_long_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            hasFilters ? 'No matching transactions' : 'No transactions yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters or search criteria'
                : 'Start tracking your finances by adding your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (hasFilters)
            OutlinedButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all_rounded),
              label: const Text('Clear Filters'),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _navigateToAddTransaction(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Transaction'),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToAddTransaction(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  // Helper methods
  void _toggleSearch() {
    setState(() {
      _isSearchActive = !_isSearchActive;
    });

    if (_isSearchActive) {
      _searchAnimController.forward();
    } else {
      _searchAnimController.reverse();
      _searchTextController.clear();
      setState(() {
        _searchQuery = '';
      });
    }

    HapticFeedback.lightImpact();
  }

  void _showFilterDialog() {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Transactions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          const Divider(),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Type Filter
                  _buildFilterSection(
                    title: 'Transaction Type',
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTypeFilterOption(TransactionType.income),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeFilterOption(TransactionType.expense),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTypeFilterOption(null, label: 'All'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Category Filter
                  Consumer<CategoryProvider>(
                    builder: (context, provider, child) {
                      if (provider.categories.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return _buildFilterSection(
                        title: 'Category',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildCategoryFilterChip(null, 'All Categories'),
                            ...provider.categories.map((category) {
                              return _buildCategoryFilterChip(category.id, category.name);
                            }),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Date Range Filter
                  _buildFilterSection(
                    title: 'Date Range',
                    child: Column(
                      children: [
                        _buildDateRangeOption('Today', _getTodayRange()),
                        _buildDateRangeOption('This Week', _getThisWeekRange()),
                        _buildDateRangeOption('This Month', _getThisMonthRange()),
                        _buildDateRangeOption('Last 30 Days', _getLast30DaysRange()),
                        _buildDateRangeOption('Custom Range', null, isCustom: true),
                        if (_selectedDateRange != null)
                          _buildDateRangeOption('Clear', null, isClear: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildTypeFilterOption(TransactionType? type, {String? label}) {
    final isSelected = _selectedTypeFilter == type;
    final displayLabel = label ?? type!.name.toUpperCase();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTypeFilter = type;
        });
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (type == TransactionType.income
              ? AppColors.income.withValues(alpha:0.1)
              : type == TransactionType.expense
              ? AppColors.expense.withValues(alpha:0.1)
              : AppColors.primary.withValues(alpha:0.1))
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (type == TransactionType.income
                ? AppColors.income
                : type == TransactionType.expense
                ? AppColors.expense
                : AppColors.primary)
                : AppColors.textHint.withValues(alpha:0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          displayLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (type == TransactionType.income
                ? AppColors.income
                : type == TransactionType.expense
                ? AppColors.expense
                : AppColors.primary)
                : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCategoryFilterChip(String? categoryId, String name) {
    final isSelected = _selectedCategoryFilter == categoryId;

    return FilterChip(
      label: Text(name),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategoryFilter = selected ? categoryId : null;
        });
        HapticFeedback.lightImpact();
      },
      selectedColor: AppColors.primary.withValues(alpha:0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildDateRangeOption(String label, DateTimeRange? range, {
    bool isCustom = false,
    bool isClear = false,
  }) {
    final isSelected = !isClear && _selectedDateRange == range;

    return ListTile(
      title: Text(label),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      selected: isSelected,
      onTap: () async {
        if (isClear) {
          setState(() {
            _selectedDateRange = null;
          });
        } else if (isCustom) {
          final pickedRange = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            initialDateRange: _selectedDateRange,
          );
          if (pickedRange != null) {
            setState(() {
              _selectedDateRange = pickedRange;
            });
          }
        } else {
          setState(() {
            _selectedDateRange = range;
          });
        }
        HapticFeedback.lightImpact();
      },
    );
  }

  // Date range helpers
  DateTimeRange _getTodayRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTimeRange(start: today, end: today);
  }

  DateTimeRange _getThisWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endDate = startDate.add(const Duration(days: 6));
    return DateTimeRange(start: startDate, end: endDate);
  }

  DateTimeRange _getThisMonthRange() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);
    return DateTimeRange(start: startDate, end: endDate);
  }

  DateTimeRange _getLast30DaysRange() {
    final now = DateTime.now();
    final endDate = DateTime(now.year, now.month, now.day);
    final startDate = endDate.subtract(const Duration(days: 30));
    return DateTimeRange(start: startDate, end: endDate);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTypeFilter = null;
      _selectedCategoryFilter = null;
      _selectedDateRange = null;
      _searchQuery = '';
      _searchTextController.clear();
    });
    Navigator.of(context).pop();
    HapticFeedback.lightImpact();
  }

  // Navigation methods
  void _navigateToAddTransaction() async {
    HapticFeedback.mediumImpact();

    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const AddTransactionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    // Refresh data if transaction was added
    if (result != null) {
      context.read<TransactionProvider>().refresh();
    }
  }

  void _editTransaction(Transaction transaction) async {
    HapticFeedback.lightImpact();

    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionScreen(transactionToEdit: transaction),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    // Refresh data if transaction was updated
    if (result != null) {
      context.read<TransactionProvider>().refresh();
    }
  }

  void _deleteTransaction(Transaction transaction) {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Delete Transaction'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this transaction?',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha:0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.isIncome ? '+' : '-'}\${transaction.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: transaction.isIncome ? AppColors.income : AppColors.expense,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionProvider>().deleteTransaction(transaction.id);
              Navigator.of(context).pop();

              // Show success snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(
                        Icons.delete_rounded,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Text('Transaction deleted'),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Implement undo functionality
                    },
                  ),
                ),
              );

              HapticFeedback.heavyImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsSheet(transaction),
    );
  }

  Widget _buildTransactionDetailsSheet(Transaction transaction) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final category = categoryProvider.getCategoryById(transaction.categoryId);

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Details',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _editTransaction(transaction);
                          },
                          icon: const Icon(Icons.edit_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.info.withValues(alpha:0.1),
                            foregroundColor: AppColors.info,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteTransaction(transaction);
                          },
                          icon: const Icon(Icons.delete_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.error.withValues(alpha:0.1),
                            foregroundColor: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Amount Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: transaction.isIncome
                              ? AppColors.incomeGradient
                              : AppColors.expenseGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (transaction.isIncome ? AppColors.income : AppColors.expense)
                                  .withValues(alpha:0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              transaction.isIncome
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${transaction.isIncome ? '+' : '-'}\${transaction.amount.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              transaction.isIncome ? 'Income' : 'Expense',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha:0.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Details
                      _buildDetailRow('Description', transaction.description),
                      _buildDetailRow('Category', '${category?.icon ?? '📦'} ${category?.name ?? 'Unknown'}'),
                      _buildDetailRow('Date', DateFormat('EEEE, MMMM dd, yyyy').format(transaction.date)),
                      _buildDetailRow('Time', DateFormat('hh:mm a').format(transaction.date)),

                      if (transaction.notes != null && transaction.notes!.isNotEmpty)
                        _buildDetailRow('Notes', transaction.notes!),

                      _buildDetailRow('Created', DateFormat('MMM dd, yyyy at hh:mm a').format(transaction.createdAt)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }}