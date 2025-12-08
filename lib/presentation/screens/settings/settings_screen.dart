import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/glassmorphism_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _selectedCurrency = 'USD';
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
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
                          'Settings',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Customize your app experience',
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
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // App Settings
                  _buildSettingsSection(
                    title: 'App Settings',
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_rounded,
                        title: 'Notifications',
                        subtitle: 'Receive transaction reminders',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                      _buildSwitchTile(
                        icon: Icons.fingerprint_rounded,
                        title: 'Biometric Authentication',
                        subtitle: 'Use fingerprint or face ID',
                        value: _biometricEnabled,
                        onChanged: (value) {
                          setState(() {
                            _biometricEnabled = value;
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                      _buildDropdownTile(
                        icon: Icons.attach_money_rounded,
                        title: 'Currency',
                        subtitle: 'Default currency for transactions',
                        value: _selectedCurrency,
                        items: ['USD', 'EUR', 'GBP', 'EGP'],
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                      _buildDropdownTile(
                        icon: Icons.palette_rounded,
                        title: 'Theme',
                        subtitle: 'App appearance',
                        value: _selectedTheme,
                        items: ['Light', 'Dark', 'System'],
                        onChanged: (value) {
                          setState(() {
                            _selectedTheme = value!;
                          });
                          HapticFeedback.lightImpact();
                        },
                      ),
                    ],
                  ).animate().slideY(begin: 0.3, delay: 200.ms, duration: 600.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // Data Management
                  _buildSettingsSection(
                    title: 'Data Management',
                    children: [
                      _buildActionTile(
                        icon: Icons.backup_rounded,
                        title: 'Backup Data',
                        subtitle: 'Save your data to cloud',
                        onTap: _showBackupDialog,
                      ),
                      _buildActionTile(
                        icon: Icons.restore_rounded,
                        title: 'Restore Data',
                        subtitle: 'Restore from backup',
                        onTap: _showRestoreDialog,
                      ),
                      _buildActionTile(
                        icon: Icons.file_download_rounded,
                        title: 'Export Data',
                        subtitle: 'Download as CSV or PDF',
                        onTap: _showExportDialog,
                      ),
                    ],
                  ).animate().slideY(begin: 0.3, delay: 400.ms, duration: 600.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // About & Support
                  _buildSettingsSection(
                    title: 'About & Support',
                    children: [
                      _buildActionTile(
                        icon: Icons.help_rounded,
                        title: 'Help & Support',
                        subtitle: 'Get help with the app',
                        onTap: _showHelpDialog,
                      ),
                      _buildActionTile(
                        icon: Icons.info_rounded,
                        title: 'About Money Master',
                        subtitle: 'Version 1.0.0',
                        onTap: _showAboutDialog,
                      ),
                      _buildActionTile(
                        icon: Icons.star_rounded,
                        title: 'Rate App',
                        subtitle: 'Rate us on the App Store',
                        onTap: _rateApp,
                      ),
                    ],
                  ).animate().slideY(begin: 0.3, delay: 600.ms, duration: 600.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // Danger Zone
                  _buildSettingsSection(
                    title: 'Danger Zone',
                    children: [
                      _buildActionTile(
                        icon: Icons.delete_forever_rounded,
                        title: 'Clear All Data',
                        subtitle: 'Delete all transactions and settings',
                        textColor: AppColors.error,
                        onTap: _showClearDataDialog,
                      ),
                    ],
                  ).animate().slideY(begin: 0.3, delay: 800.ms, duration: 600.ms).fadeIn(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return GlassmorphismCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          underline: const SizedBox.shrink(),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: textColor != null
                ? LinearGradient(colors: [textColor, textColor])
                : AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  // Dialog methods
  void _showBackupDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Backup Data'),
        content: const Text('This will backup your transactions and settings to the cloud.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement backup functionality
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restore Data'),
        content: const Text('This will restore your data from the most recent backup.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement restore functionality
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
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
              'Export Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.table_chart_rounded, color: AppColors.success),
              title: const Text('Export as CSV'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement CSV export
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement PDF export
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Help & Support'),
        content: const Text('For support, please contact us at support@moneymaster.com'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open email app
            },
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    HapticFeedback.lightImpact();
    showAboutDialog(
      context: context,
      applicationName: 'Money Master',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
      ),
      children: [
        const Text('A modern personal finance tracker built with Flutter.'),
      ],
    );
  }

  void _rateApp() {
    HapticFeedback.lightImpact();
    // TODO: Implement app rating
  }

  void _showClearDataDialog() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your transactions, categories, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement clear data functionality
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }
}