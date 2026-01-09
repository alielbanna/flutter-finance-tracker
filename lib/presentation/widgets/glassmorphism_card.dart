import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GlassmorphismCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Border? border;
  final double? width;
  final double? height;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.1,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.onTap,
    this.gradient,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDark : AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: gradient ??
                    (isDark
                        ? LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.05),
                        Colors.white.withValues(alpha: 0.02),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: opacity),
                        Colors.white.withValues(alpha: opacity * 0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )),
                border: border ??
                    Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}