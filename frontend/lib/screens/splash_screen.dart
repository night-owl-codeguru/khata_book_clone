import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../services/connectivity_service.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Navigate to onboarding after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Check if onboarding is completed
        _checkOnboardingStatus();
      }
    });
  }

  Future<void> _checkOnboardingStatus() async {
    // Check internet connectivity first
    final hasInternet = await ConnectivityService.hasInternetConnection();

    if (!hasInternet) {
      // No internet - stay on splash screen with loading
      // Listen for connectivity changes
      ConnectivityService.onConnectivityChanged.listen((
        List<ConnectivityResult> result,
      ) {
        if (result.isNotEmpty &&
            result[0] != ConnectivityResult.none &&
            mounted) {
          // Internet restored - check auth status
          _checkAuthStatus();
        }
      });
      return;
    }

    // Internet available - check auth status
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final authStatus = await AuthService.getAuthStatus();

    if (!mounted) return;

    switch (authStatus) {
      case AuthStatus.needsOnboarding:
        if (mounted) {
          context.go('/onboarding');
        }
        break;
      case AuthStatus.needsSignup:
      case AuthStatus.needsLogin:
        // First complete onboarding if not done, then go to auth
        final onboardingCompleted = await AuthService.isOnboardingCompleted();
        if (!onboardingCompleted) {
          if (mounted) {
            context.go('/onboarding');
          }
        } else {
          if (mounted) {
            context.go('/auth/login');
          }
        }
        break;
      case AuthStatus.authenticated:
        // User is authenticated - navigate to home
        // For now, navigate to a placeholder home screen
        if (mounted) {
          context.go('/home');
        }
        break;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary500,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo/Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryGradientStart,
                            AppColors.primaryGradientEnd,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App Name
                    Text(
                      'LedgerBook',
                      style: AppTypography.headline.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tagline
                    Text(
                      'Digital Ledger Made Simple',
                      style: AppTypography.body.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Loading indicator
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
