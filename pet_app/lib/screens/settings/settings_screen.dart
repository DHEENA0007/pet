/// Settings Screen
/// App preferences and configuration

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryGreen.withOpacity(0.05), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildModernSettingItem(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive alerts for adoption updates',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _saveSetting('notifications_enabled', value);
                },
                activeColor: AppColors.primaryGreen,
              ),
            ),

            // Appearance Section
            const SizedBox(height: 32),
            _buildSectionHeader('Appearance'),
            _buildModernSettingItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: 'Switch to dark theme',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  _saveSetting('dark_mode_enabled', value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Theme settings saved')),
                  );
                },
                activeColor: AppColors.primaryGreen,
              ),
            ),

            // Language Section
            const SizedBox(height: 32),
            _buildSectionHeader('Language & Region'),
            _buildModernSettingItem(
              icon: Icons.language,
              title: 'Language',
              subtitle: _language,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showLanguageDialog();
              },
            ),

            // Account Section
            const SizedBox(height: 32),
            _buildSectionHeader('Account'),
            _buildModernSettingItem(
              icon: Icons.security,
              title: 'Privacy & Security',
              subtitle: 'Manage your privacy settings',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showPrivacyDialog();
              },
            ),
            _buildModernSettingItem(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              color: AppColors.criticalRed,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),

            // About Section
            const SizedBox(height: 32),
            _buildSectionHeader('About'),
            _buildModernSettingItem(
              icon: Icons.info_outline,
              title: 'App Version',
              subtitle: '1.0.0',
            ),
            _buildModernSettingItem(
              icon: Icons.star_outline,
              title: 'Rate App',
              subtitle: 'Leave a review on app store',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening app store...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildModernSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primaryGreen).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? AppColors.primaryGreen, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _language = value);
                  _saveSetting('language', value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Share usage data'),
              subtitle: const Text('Help us improve the app'),
              value: true,
              onChanged: (v) {},
            ),
            SwitchListTile(
              title: const Text('Profile visibility'),
              subtitle: const Text('Allow others to see your profile'),
              value: true,
              onChanged: (v) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Account scheduled for deletion. Please contact support.',
                    ),
                  ),
                );
                context.go('/login');
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.criticalRed),
            ),
          ),
        ],
      ),
    );
  }
}
