import 'package:flutter/material.dart';
import '../theme.dart';
import 'fragments/home_fragment.dart';
import '../screens/customers_screen.dart';
import '../screens/all_entries_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // List of widget fragments for each tab
  final List<Widget> _fragments = [
    const HomeFragment(),
    const AllEntriesFragment(),
    const CustomersFragment(),
    const RemindersFragment(),
    const ReportsFragment(),
    const SettingsFragment(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600; // Tablet/Web breakpoint

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Row(
        children: [
          // Sidebar for large screens
          if (isLargeScreen) _buildSidebar(),

          // Main content area
          Expanded(child: _fragments[_selectedIndex]),
        ],
      ),

      // Bottom navigation for mobile/small screens
      bottomNavigationBar: !isLargeScreen ? _buildBottomNavigationBar() : null,

      // FAB for Add Entry (only on mobile)
      floatingActionButton: !isLargeScreen
          ? _buildFloatingActionButton()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primaryGradientStart,
                        AppColors.primaryGradientEnd,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'LedgerBook',
                  style: AppTypography.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSidebarItem(icon: Icons.home, label: 'Home', index: 0),
                _buildSidebarItem(
                  icon: Icons.list,
                  label: 'All Entries',
                  index: 1,
                ),
                _buildSidebarItem(
                  icon: Icons.people,
                  label: 'Customers',
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.notifications,
                  label: 'Reminders',
                  index: 3,
                ),
                _buildSidebarItem(
                  icon: Icons.bar_chart,
                  label: 'Reports',
                  index: 4,
                ),
                _buildSidebarItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  index: 5,
                ),
              ],
            ),
          ),

          // Add Entry Button
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add entry screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary500.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary500
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: isSelected
                    ? AppColors.primary500
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary500,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.surface,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Entries'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Reminders',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Navigate to add entry screen
      },
      backgroundColor: AppColors.primary500,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

// Fragment Widgets - These are simplified versions of the full screens
// that can be embedded in the navigation container

class AllEntriesFragment extends StatelessWidget {
  const AllEntriesFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return const AllEntriesScreen();
  }
}

class CustomersFragment extends StatelessWidget {
  const CustomersFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomersScreen();
  }
}

class RemindersFragment extends StatelessWidget {
  const RemindersFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return const RemindersScreen();
  }
}

class ReportsFragment extends StatelessWidget {
  const ReportsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReportsScreen();
  }
}

class SettingsFragment extends StatelessWidget {
  const SettingsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen();
  }
}
