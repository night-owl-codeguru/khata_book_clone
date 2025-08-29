import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/add_entry_selector_screen.dart';
import '../screens/add_credit_screen.dart';
import '../screens/add_debit_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/customer_detail_screen.dart';
import '../screens/ledger_summary_screen.dart';
import '../screens/all_entries_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';
import '../services/auth_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated before allowing access to home
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/add',
        builder: (context, state) => const AddEntrySelectorScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/add/credit',
        builder: (context, state) => const AddCreditScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/add/debit',
        builder: (context, state) => const AddDebitScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomersScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/customer/:id',
        builder: (context, state) {
          final customerId =
              int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return CustomerDetailScreen(customerId: customerId);
        },
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/ledger/summary',
        builder: (context, state) => const LedgerSummaryScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/entries',
        builder: (context, state) => const AllEntriesScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/reminders',
        builder: (context, state) => const RemindersScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        redirect: (context, state) async {
          // Check if user is authenticated
          final isLoggedIn = await AuthService.isLoggedIn();
          if (!isLoggedIn) {
            return '/auth/login';
          }
          return null;
        },
      ),
    ],
  );
}
