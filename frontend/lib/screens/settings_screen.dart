import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../services/backup_service.dart';
import '../services/security_service.dart';
import '../widgets/pin_dialog.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Settings',
          style: AppTypography.titleWithColor(
            context,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
            subtitle: Provider.of<LanguageProvider>(context).getLanguageName(),
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
            subtitle: Provider.of<ThemeProvider>(context).getThemeModeName(),
            icon: Icons.palette,
            onTap: () => _showThemeDialog(),
          ),

          const SizedBox(height: 24),

          // Security Section
          _buildSectionHeader('Security'),
          FutureBuilder<Map<String, dynamic>>(
            future: SecurityService.getSecurityStatus(),
            builder: (context, snapshot) {
              final hasPin = snapshot.data?['hasPin'] ?? false;
              final biometricEnabled =
                  snapshot.data?['biometricEnabled'] ?? false;
              final biometricAvailable =
                  snapshot.data?['biometricAvailable'] ?? false;

              return Column(
                children: [
                  _buildSettingItem(
                    title: 'App PIN',
                    subtitle: hasPin ? 'Change PIN' : 'Set PIN',
                    icon: Icons.lock,
                    onTap: () => _showPinDialog(hasPin: hasPin),
                  ),
                  if (biometricAvailable)
                    _buildSettingItem(
                      title: 'Biometric Unlock',
                      subtitle: biometricEnabled ? 'Enabled' : 'Disabled',
                      icon: Icons.fingerprint,
                      onTap: () {}, // Empty onTap since it has a switch
                      trailing: Switch(
                        value: biometricEnabled,
                        onChanged: (value) => _toggleBiometric(value),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader('Data'),
          _buildSettingItem(
            title: 'Backup Data',
            subtitle: 'Create data backup',
            icon: Icons.backup,
            onTap: () => _createBackup(),
          ),
          _buildSettingItem(
            title: 'Restore Data',
            subtitle: 'Import from backup',
            icon: Icons.restore,
            onTap: () => _restoreFromBackup(),
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
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Logout',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
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
        style: AppTypography.titleWithColor(context).copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyWithColor(
                      context,
                    ).copyWith(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.captionWithColor(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          title: Text(
            'Edit $title',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter $title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.bodyWithColor(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Update user data
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title updated successfully')),
                );
              },
              child: Text(
                'Save',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageDialog() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final availableLanguages = languageProvider.getAvailableLanguages();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Select Language',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          children: availableLanguages.map((language) {
            final isSelected =
                languageProvider.locale.languageCode == language['code'];
            return SimpleDialogOption(
              onPressed: () async {
                Navigator.of(context).pop();
                await languageProvider.setLanguage(language['code']!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${language['name']}'),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Text(
                    language['name']!,
                    style: AppTypography.bodyWithColor(context),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ],
              ),
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
          title: Text(
            'Select Currency',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          children: currencies.map((currency) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Currency changed to $currency')),
                );
              },
              child: Text(
                currency,
                style: AppTypography.bodyWithColor(context),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final themes = ['Light', 'Dark', 'System'];
    final themeModes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            'Select Theme',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          children: List.generate(themes.length, (index) {
            final theme = themes[index];
            final mode = themeModes[index];
            final isSelected = themeProvider.themeMode == mode;

            return SimpleDialogOption(
              onPressed: () async {
                Navigator.of(context).pop();
                await themeProvider.setThemeMode(mode);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Theme changed to $theme')),
                  );
                }
              },
              child: Row(
                children: [
                  Text(theme, style: AppTypography.bodyWithColor(context)),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.check,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ],
                ],
              ),
            );
          }),
        );
      },
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatFileSize(String sizeString) {
    try {
      final size = int.parse(sizeString);
      if (size < 1024) {
        return '$size B';
      } else if (size < 1024 * 1024) {
        return '${(size / 1024).toStringAsFixed(1)} KB';
      } else {
        return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (e) {
      return sizeString;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTypography.bodyWithColor(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTypography.bodyWithColor(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logout functionality coming soon!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(
                'Logout',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPinDialog({bool hasPin = false}) async {
    if (hasPin) {
      // Change PIN - first verify current PIN
      final currentPin = await PinDialog.show(
        context,
        title: 'Enter Current PIN',
        subtitle: 'Enter your current PIN to proceed',
      );

      if (currentPin != null) {
        // Now set new PIN
        final newPin = await PinDialog.show(
          context,
          title: 'Set New PIN',
          subtitle: 'Enter your new PIN',
          isSettingPin: true,
        );

        if (newPin != null) {
          try {
            await SecurityService.changePin(currentPin, newPin);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN changed successfully')),
              );
              setState(() {}); // Refresh the UI
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to change PIN: $e')),
              );
            }
          }
        }
      }
    } else {
      // Set new PIN
      final pin = await PinDialog.show(
        context,
        title: 'Set PIN',
        subtitle: 'Create a 4-6 digit PIN to secure your app',
        isSettingPin: true,
      );

      if (pin != null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('PIN set successfully')));
          setState(() {}); // Refresh the UI
        }
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'LedgerBook',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 LedgerBook',
    );
  }

  void _createBackup() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Creating backup...'),
            ],
          ),
        ),
      );

      final filePath = await BackupService.createBackup();

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success dialog with options
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup Complete'),
            content: Text(
              'Backup created successfully: ${filePath.split('/').last}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await BackupService.shareBackup(filePath);
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to share backup: $e')),
                      );
                    }
                  }
                },
                child: const Text('Share'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Backup failed: $e')));
      }
    }
  }

  void _restoreFromBackup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restore from Backup',
              style: AppTypography.titleWithColor(
                context,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a backup file to restore',
              style: AppTypography.bodyWithColor(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: BackupService.getBackupHistory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading backups: ${snapshot.error}',
                        style: AppTypography.bodyWithColor(
                          context,
                        ).copyWith(color: Theme.of(context).colorScheme.error),
                      ),
                    );
                  }

                  final backups = snapshot.data ?? [];

                  if (backups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.backup,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No backups found',
                            style: AppTypography.titleWithColor(context)
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a backup first to see it here',
                            style: AppTypography.bodyWithColor(context)
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: backups.length,
                    itemBuilder: (context, index) {
                      final backup = backups[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.backup,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    backup['fileName'],
                                    style: AppTypography.bodyWithColor(
                                      context,
                                    ).copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Created: ${_formatDate(backup['timestamp'])}',
                                    style:
                                        AppTypography.captionWithColor(
                                          context,
                                        ).copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    'Size: ${_formatFileSize(backup['size'])}',
                                    style:
                                        AppTypography.captionWithColor(
                                          context,
                                        ).copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'restore') {
                                  await _performRestore(backup['filePath']);
                                } else if (value == 'share') {
                                  try {
                                    await BackupService.shareBackup(
                                      backup['filePath'],
                                    );
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to share: $e'),
                                        ),
                                      );
                                    }
                                  }
                                } else if (value == 'delete') {
                                  await _deleteBackup(backup['filePath']);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'restore',
                                  child: Text('Restore'),
                                ),
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Text('Share'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performRestore(String filePath) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Confirm Restore',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'This will replace all current data with the backup. This action cannot be undone. Continue?',
            style: AppTypography.bodyWithColor(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTypography.bodyWithColor(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(
                'Restore',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Restoring backup...'),
            ],
          ),
        ),
      );

      await BackupService.restoreFromBackup(filePath);

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup restored successfully')),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      }
    }
  }

  Future<void> _deleteBackup(String filePath) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Delete Backup',
            style: AppTypography.titleWithColor(
              context,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Are you sure you want to delete this backup file?',
            style: AppTypography.bodyWithColor(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTypography.bodyWithColor(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(
                'Delete',
                style: AppTypography.bodyWithColor(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await BackupService.deleteBackup(filePath);
        setState(() {}); // Refresh the backup list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Backup deleted successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete backup: $e')));
      }
    }
  }

  void _toggleBiometric(bool enabled) async {
    try {
      if (enabled) {
        // Check if biometric is available
        final available = await SecurityService.isBiometricAvailable();
        if (!available) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Biometric authentication not available on this device',
                ),
              ),
            );
          }
          return;
        }

        // Try to authenticate before enabling
        final authenticated = await SecurityService.authenticateWithBiometrics(
          reason: 'Authenticate to enable biometric unlock',
        );

        if (authenticated) {
          await SecurityService.setBiometricEnabled(true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometric unlock enabled')),
            );
            setState(() {}); // Refresh the UI
          }
        }
      } else {
        await SecurityService.setBiometricEnabled(false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biometric unlock disabled')),
          );
          setState(() {}); // Refresh the UI
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update biometric setting: $e')),
        );
      }
    }
  }
}
