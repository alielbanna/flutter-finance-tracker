import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/transaction.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get category color or default
    Color categoryColorParsed = AppColors.primary;
    if (categoryColor != null) {
      try {
        categoryColorParsed = Color(int.parse('FF$categoryColor', radix: 16));
      } catch (e) {
        categoryColorParsed = AppColors.primary;
      }
    }

    // Calculate stagger delay once
    final staggerDelay = Duration(milliseconds: index * 50);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        key: ValueKey(transaction.id),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? AppColors.shadowDark
                      : AppColors.shadowLight,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: categoryColorParsed.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Category Icon with animated background
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        categoryColorParsed.withValues(alpha: 0.2),
                        categoryColorParsed.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: categoryColorParsed.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      categoryIcon ?? '💰',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Transaction Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Description
                      Text(
                        transaction.description,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 2),

                      // Category and Date
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              categoryName ?? 'Unknown',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: categoryColorParsed,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            dateFormat.format(transaction.date),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),

                      // Notes (if any)
                      if (transaction.notes != null &&
                          transaction.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          transaction.notes!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Amount with animated background
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: transaction.isIncome
                            ? AppColors.incomeGradient
                            : AppColors.expenseGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (transaction.isIncome
                                ? AppColors.income
                                : AppColors.expense)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${transaction.isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount).substring(1)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Time
                    Text(
                      DateFormat('HH:mm').format(transaction.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(
      key: ValueKey('transaction_card_${transaction.id}'),
    )
        .slideY(
      begin: 0.3,
      end: 0,
      delay: staggerDelay,
      duration: 500.ms,
      curve: Curves.easeOutCubic,
    )
        .fadeIn(
      delay: staggerDelay,
      duration: 500.ms,
    );
  }
}

// If you need a simpler version without any animations for better performance:
class SimpleTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SimpleTransactionCard({
    super.key,
    required this.transaction,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get category color or default
    Color categoryColorParsed = AppColors.primary;
    if (categoryColor != null) {
      try {
        categoryColorParsed = Color(int.parse('FF$categoryColor', radix: 16));
      } catch (e) {
        categoryColorParsed = AppColors.primary;
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Slidable(
        key: ValueKey(transaction.id),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              icon: Icons.edit_rounded,
              label: 'Edit',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.shadowDark
                        : AppColors.shadowLight,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: categoryColorParsed.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Category Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColorParsed.withValues(alpha: 0.2),
                          categoryColorParsed.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: categoryColorParsed.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        categoryIcon ?? '💰',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Transaction Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          transaction.description,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                categoryName ?? 'Unknown',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: categoryColorParsed,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              ' • ${dateFormat.format(transaction.date)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (transaction.notes != null &&
                            transaction.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            transaction.notes!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: transaction.isIncome
                              ? AppColors.incomeGradient
                              : AppColors.expenseGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: (transaction.isIncome
                                  ? AppColors.income
                                  : AppColors.expense)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${transaction.isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount).substring(1)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(transaction.date),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}