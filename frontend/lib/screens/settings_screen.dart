import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    if (mounted) {
      setState(() {
        _userData = userData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildSectionHeader('Profile'),
          _buildSettingItem(
            title: 'Business Name',
            subtitle: _userData?['businessName'] ?? 'LedgerBook Store',
            icon: Icons.business,
            onTap: () => _showEditDialog('Business Name', 'businessName'),
          ),
          _buildSettingItem(
            title: 'Owner Name',
            subtitle: _userData?['name'] ?? 'John Doe',
            icon: Icons.person,
            onTap: () => _showEditDialog('Owner Name', 'name'),
          ),
          _buildSettingItem(
            title: 'Phone',
            subtitle: _userData?['phone'] ?? '+91 9876543210',
            icon: Icons.phone,
            onTap: () => _showEditDialog('Phone', 'phone'),
          ),
          _buildSettingItem(
            title: 'Email',
            subtitle: _userData?['email'] ?? 'john@example.com',
            icon: Icons.email,
            onTap: () => _showEditDialog('Email', 'email'),
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildSettingItem(
            title: 'Language',
            subtitle: 'English (India)',
            icon: Icons.language,
            onTap: () => _showLanguageDialog(),
          ),
          _buildSettingItem(
            title: 'Currency',
            subtitle: 'Indian Rupee (INR)',
            icon: Icons.currency_rupee,
            onTap: () => _showCurrencyDialog(),
          ),
          _buildSettingItem(
            title: 'Theme',
            subtitle: 'Light',
            icon: Icons.palette,
            onTap: () => _showThemeDialog(),
          ),

          const SizedBox(height: 24),

          // Security Section
          _buildSectionHeader('Security'),
          _buildSettingItem(
            title: 'App PIN',
            subtitle: 'Set',
            icon: Icons.lock,
            onTap: () => _showPinDialog(),
          ),
          _buildSettingItem(
            title: 'Biometric Unlock',
            subtitle: 'Enabled',
            icon: Icons.fingerprint,
            onTap: () {}, // Empty onTap since it has a switch
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement biometric toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Biometric setting updated')),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader('Data'),
          _buildSettingItem(
            title: 'Backup Data',
            subtitle: 'Last backup: Never',
            icon: Icons.backup,
            onTap: () {
              // TODO: Implement backup functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup feature coming soon!')),
              );
            },
          ),
          _buildSettingItem(
            title: 'Restore Data',
            subtitle: 'Import from backup',
            icon: Icons.restore,
            onTap: () {
              // TODO: Implement restore functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore feature coming soon!')),
              );
            },
          ),
          _buildSettingItem(
            title: 'Export Data',
            subtitle: 'Export as CSV/PDF',
            icon: Icons.download,
            onTap: () {
              // TODO: Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          _buildSettingItem(
            title: 'Version',
            subtitle: '1.0.0',
            icon: Icons.info,
            onTap: () => _showAboutDialog(),
          ),
          _buildSettingItem(
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            icon: Icons.description,
            onTap: () {
              // TODO: Navigate to terms page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Terms page coming soon!')),
              );
            },
          ),
          _buildSettingItem(
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            icon: Icons.privacy_tip,
            onTap: () {
              // TODO: Navigate to privacy page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy page coming soon!')),
              );
            },
          ),

          const SizedBox(height: 24),

          // Logout Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => _showLogoutDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Logout',
                style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: Text(
        title,
        style: AppTypography.title.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary500,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary500, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(String title, String field) {
    final controller = TextEditingController(text: _userData?[field] ?? '');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter $title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Update user data
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title updated successfully')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    final languages = ['English (India)', 'Hindi', 'Gujarati', 'Marathi'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Language'),
          children: languages.map((language) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Language changed to $language')),
                );
              },
              child: Text(language),
            );
          }).toList(),
        );
      },
    );
  }

  void _showCurrencyDialog() {
    final currencies = ['Indian Rupee (INR)', 'US Dollar (USD)', 'Euro (EUR)'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Currency'),
          children: currencies.map((currency) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Currency changed to $currency')),
                );
              },
              child: Text(currency),
            );
          }).toList(),
        );
      },
    );
  }

  void _showThemeDialog() {
    final themes = ['Light', 'Dark', 'System'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Theme'),
          children: themes.map((theme) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Theme changed to $theme')),
                );
              },
              child: Text(theme),
            );
          }).toList(),
        );
      },
    );
  }

  void _showPinDialog() {
    // TODO: Implement PIN setting dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('PIN setting coming soon!')));
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'LedgerBook',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 LedgerBook',
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.logout();
                if (mounted) {
                  context.go('/splash');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
