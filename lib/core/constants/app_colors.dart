import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - iOS inspired
  static const Color primary = Color(0xFF007AFF); // iOS Blue
  static const Color primaryDark = Color(0xFF0056CC);
  static const Color secondary = Color(0xFF34C759); // iOS Green
  static const Color accent = Color(0xFFFF9500); // iOS Orange

  // Glassmorphism Colors
  static const Color glass = Color(0x20FFFFFF);
  static const Color glassDark = Color(0x15000000);

  // Gradients
  static const List<Color> primaryGradientColors = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
  ];

  static const List<Color> successGradientColors = [
    Color(0xFF11998e),
    Color(0xFF38ef7d),
  ];

  static const List<Color> warningGradientColors = [
    Color(0xFFf093fb),
    Color(0xFFf5576c),
  ];

  // Transaction Colors - More vibrant
  static const Color income = Color(0xFF34C759); // iOS Green
  static const Color expense = Color(0xFFFF3B30); // iOS Red
  static const Color incomeLight = Color(0xFFE8F5E8);
  static const Color expenseLight = Color(0xFFFFEBEA);

  // Background Colors
  static const Color background = Color(0xFFF2F4F7); // Light grey-blue
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8F9FA);
  static const Color surfaceDark = Color(0xFF1C1C1E); // iOS Dark

  // Text Colors - Enhanced contrast
  static const Color textPrimary = Color(0xFF1D1D1F); // iOS Black
  static const Color textSecondary = Color(0xFF8E8E93); // iOS Grey
  static const Color textHint = Color(0xFFC7C7CC); // iOS Light Grey
  static const Color textWhite = Colors.white;

  // Status Colors - iOS Style
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF007AFF);

  // Chart Colors - Palette
  static const List<Color> chartColors = [
    Color(0xFF007AFF), // Blue
    Color(0xFF34C759), // Green
    Color(0xFFFF9500), // Orange
    Color(0xFFFF3B30), // Red
    Color(0xFFAF52DE), // Purple
    Color(0xFFFF2D92), // Pink
    Color(0xFF5AC8FA), // Light Blue
    Color(0xFFFFCC00), // Yellow
    Color(0xFF8E8E93), // Grey
    Color(0xFF32D74B), // Light Green
  ];

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: primaryGradientColors,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassmorphismGradient = LinearGradient(
    colors: [Color(0x20FFFFFF), Color(0x10FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceContainerDark = Color(0xFF1C1C1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);

  // Card Colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2C2C2E);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);
}
