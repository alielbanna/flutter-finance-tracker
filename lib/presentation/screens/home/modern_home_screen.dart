import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/animated_balance_card.dart';
import '../../widgets/modern_transaction_card.dart';
import '../transactions/add_transaction_screen.dart';
import '../transactions/transaction_list_screen.dart';

class ModernHomeScreen extends StatefulWidget {
  const ModernHomeScreen({super.key});

  @override
  State<ModernHomeScreen> createState() => _ModernHomeScreenState();
}

class _ModernHomeScreenState extends State<ModernHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Load data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
      _fabController.forward();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _fabController.dispose();
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
          _buildModernAppBar(),

          // Balance Card
          SliverToBoxAdapter(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                return AnimatedBalanceCard(
                  balance: provider.totalBalance,
                  monthlyIncome: provider.monthlyIncome,
                  monthlyExpense: provider.monthlyExpense,
                  onTap: () => _showBalanceDetails(context),
                );
              },
            ).animate().slideY(
              begin: -0.5,
              duration: 800.ms,
              curve: Curves.easeOutCubic,
            ).fadeIn(duration: 800.ms),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: _buildQuickActions(),
          ),

          // Recent Transactions Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _navigateToAllTransactions(),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: const Text('View All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ).animate().slideY(
                begin: 0.3,
                delay: 600.ms,
                duration: 600.ms,
                curve: Curves.easeOutCubic,
              ).fadeIn(delay: 600.ms),
            ),
          ),

          // Recent Transactions List
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

              final recentTransactions = provider.recentTransactions;

              if (recentTransactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyState(),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final transaction = recentTransactions[index];
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 600),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: ModernTransactionCard(
                            transaction: transaction,
                            index: index,
                            onTap: () => _showTransactionDetails(transaction),
                            onEdit: () => _editTransaction(transaction),
                            onDelete: () => _deleteTransaction(transaction),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: recentTransactions.length,
                ),
              );
            },
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Modern Floating Action Button
      floatingActionButton: ScaleTransition(
        scale: _fabController,
        child: Container(
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
          child: FloatingActionButton.extended(
            onPressed: () => _navigateToAddTransaction(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Transaction',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good ${_getGreeting()}',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha:0.9),
                            ),
                          ),
                          Text(
                            'Money Master',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          // Search Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _showSearchModal(),
                              icon: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Notifications Button
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              onPressed: () => _showNotifications(),
                              icon: const Icon(
                                Icons.notifications_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              'Send Money',
              Icons.arrow_upward_rounded,
              AppColors.expenseGradient,
                  () => _quickSendMoney(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              'Receive',
              Icons.arrow_downward_rounded,
              AppColors.incomeGradient,
                  () => _quickReceiveMoney(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              'Budget',
              Icons.pie_chart_rounded,
              AppColors.primaryGradient,
                  () => _navigateToBudget(),
            ),
          ),
        ],
      ),
    ).animate().slideY(
      begin: 0.5,
      delay: 400.ms,
      duration: 600.ms,
      curve: Curves.easeOutCubic,
    ).fadeIn(delay: 400.ms);
  }

  Widget _buildQuickActionCard(
      String title,
      IconData icon,
      Gradient gradient,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(5, (index) {
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
                      width: double.infinity,
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No transactions yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your finances by adding your first transaction',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddTransaction(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
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

  void _navigateToAllTransactions() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
        const TransactionListScreen(),
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
  }

  void _showTransactionDetails(transaction) {
    // TODO: Show transaction details modal
    print('Show transaction details: ${transaction.id}');
  }

  void _editTransaction(transaction) {
    // TODO: Navigate to edit transaction screen
    HapticFeedback.lightImpact();
    print('Edit transaction: ${transaction.id}');
  }

  void _deleteTransaction(transaction) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionProvider>().deleteTransaction(transaction.id);
              Navigator.of(context).pop();
              HapticFeedback.heavyImpact();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBalanceDetails(BuildContext context) {
    // TODO: Show balance details modal
    print('Show balance details');
  }

  void _showSearchModal() {
    // TODO: Show search modal
    print('Show search modal');
  }

  void _showNotifications() {
    // TODO: Show notifications
    print('Show notifications');
  }

  void _quickSendMoney() {
    // TODO: Quick send money flow
    HapticFeedback.lightImpact();
    print('Quick send money');
  }

  void _quickReceiveMoney() {
    // TODO: Quick receive money flow
    HapticFeedback.lightImpact();
    print('Quick receive money');
  }

  void _navigateToBudget() {
    // TODO: Navigate to budget screen
    print('Navigate to budget');
  }
}