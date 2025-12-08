import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_themes.dart';
import 'data/datasources/local/database_helper.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/category_repository_impl.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    return MultiProvider(
      providers: [
        // Transaction Provider
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(
            TransactionRepositoryImpl(DatabaseHelper.instance),
          ),
        ),

        // Category Provider
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(
            CategoryRepositoryImpl(DatabaseHelper.instance),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Money Master',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainNavigationScreen(),
        debugShowCheckedModeBanner: false,

        // Enhanced visual density for better touch targets
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0), // Prevent text scaling issues
            ),
            child: child!,
          );
        },
      ),
    );
  }
}