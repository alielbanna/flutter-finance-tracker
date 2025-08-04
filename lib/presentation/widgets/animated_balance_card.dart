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
    with TickerProviderStateMixin {
  late AnimationController _balanceController;
  late AnimationController _statsController;
  late Animation<double> _balanceAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();

    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _statsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _balanceAnimation = Tween<double>(begin: 0, end: widget.balance).animate(
      CurvedAnimation(parent: _balanceController, curve: Curves.easeOutCubic),
    );

    _statsAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.easeOutBack),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 300), () {
      _balanceController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _statsController.forward();
    });
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 200,
      child: Stack(
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

          // Glassmorphism overlay
          GlassmorphismCard(
            margin: EdgeInsets.zero,
            borderRadius: 24,
            blur: 15,
            opacity: 0.1,
            padding: const EdgeInsets.all(24),
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Balance',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedBuilder(
                          animation: _balanceAnimation,
                          builder: (context, child) {
                            return Text(
                              currencyFormat.format(_balanceAnimation.value),
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                            );
                          },
                        ),
                      ],
                    ),

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

                // Stats Row
                AnimatedBuilder(
                  animation: _statsAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _statsAnimation.value,
                      child: Opacity(
                        opacity: _statsAnimation.value,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              'Income',
                              currencyFormat.format(widget.monthlyIncome),
                              Icons.arrow_upward,
                              AppColors.success,
                            ),

                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withValues(alpha: 0.3),
                            ),

                            _buildStatItem(
                              'Expense',
                              currencyFormat.format(widget.monthlyExpense),
                              Icons.arrow_downward,
                              AppColors.error,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Floating particles effect
          ...List.generate(6, (index) {
            return Positioned(
              left: 20.0 + (index * 50),
              top: 30.0 + (index % 3 * 20),
              child:
                  Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
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
    return Expanded(
      child: Column(
        children: [
          Row(
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
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
