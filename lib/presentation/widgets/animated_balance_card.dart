import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import 'glassmorphism_card.dart';

class AnimatedBalanceCard extends StatefulWidget {
  final double balance;
  final double monthlyIncome;
  final double monthlyExpense;
  final VoidCallback? onTap;

  const AnimatedBalanceCard({
    super.key,
    required this.balance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    this.onTap,
  });

  @override
  State<AnimatedBalanceCard> createState() => _AnimatedBalanceCardState();
}

class _AnimatedBalanceCardState extends State<AnimatedBalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _balanceAnimation;
  double _currentBalance = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _balanceAnimation = Tween<double>(
      begin: _currentBalance,
      end: widget.balance,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedBalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation when balance changes
    if (oldWidget.balance != widget.balance) {
      _currentBalance = _balanceAnimation.value;
      _controller.reset();

      _balanceAnimation = Tween<double>(
        begin: _currentBalance,
        end: widget.balance,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
        ),
      );

      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 220,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGradientColors[0].withValues(
                    alpha: 0.3,
                  ),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),

          // Floating particles effect (clipped to card bounds)
          ...List.generate(6, (index) {
            return Positioned(
              left: 20.0 + (index * 50),
              top: 30.0 + (index % 3 * 20),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .moveY(
                begin: 0,
                end: -10,
                duration: Duration(milliseconds: 2000 + (index * 200)),
                curve: Curves.easeInOut,
              )
                  .then()
                  .moveY(
                begin: -10,
                end: 0,
                duration: Duration(milliseconds: 2000 + (index * 200)),
                curve: Curves.easeInOut,
              ),
            );
          }),

          // Main content
          GlassmorphismCard(
            margin: EdgeInsets.zero,
            borderRadius: 24,
            blur: 15,
            opacity: 0.1,
            padding: const EdgeInsets.all(20),
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total Balance',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          AnimatedBuilder(
                            animation: _balanceAnimation,
                            builder: (context, child) {
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  currencyFormat.format(_balanceAnimation.value),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Balance trend icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.balance >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: Colors.white,
                        size: 24,
                      ),
                    )
                        .animate()
                        .scale(delay: 800.ms, duration: 400.ms)
                        .fade(delay: 800.ms),
                  ],
                ),

                const Spacer(),

                // Stats Row
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: _buildStatItem(
                          'Income',
                          currencyFormat.format(widget.monthlyIncome),
                          Icons.arrow_upward,
                          AppColors.success,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          width: 1,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: _buildStatItem(
                          'Expense',
                          currencyFormat.format(widget.monthlyExpense),
                          Icons.arrow_downward,
                          AppColors.error,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(
                  delay: 600.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                )
                    .fade(delay: 600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}