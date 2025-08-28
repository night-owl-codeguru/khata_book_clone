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
  String _loadingMessage = 'Initializing...';
  int _retryCount = 0;
  static const int _maxRetries = 5;
  String? _debugInfo;

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
    try {
      // Check internet connectivity first
      final hasInternet = await ConnectivityService.hasInternetConnection();

      if (!hasInternet) {
        setState(() {
          _loadingMessage = 'No internet connection...';
          _debugInfo = 'Connectivity check: No internet connection detected';
        });

        // Listen for connectivity changes with a timeout
        final subscription = ConnectivityService.onConnectivityChanged.listen((
          List<ConnectivityResult> result,
        ) {
          if (result.isNotEmpty &&
              result[0] != ConnectivityResult.none &&
              mounted) {
            setState(() {
              _loadingMessage = 'Internet restored! Connecting to server...';
              _debugInfo = 'Connectivity restored: ${result[0]}';
            });
            // Internet restored - check server readiness
            _checkServerReadiness();
          }
        });

        // Set a timeout for connectivity check
        Future.delayed(const Duration(seconds: 30), () {
          if (mounted && _loadingMessage.contains('No internet connection')) {
            setState(() {
              _loadingMessage = 'Connection timeout. Tap to retry.';
              _retryCount = _maxRetries; // Allow manual retry
              _debugInfo = 'Connectivity timeout after 30 seconds';
            });
          }
          subscription.cancel();
        });

        return;
      }

      setState(() {
        _loadingMessage = 'Internet connected! Checking server...';
        _debugInfo = 'Connectivity check: Internet available';
      });

      // Internet available - check server readiness
      _checkServerReadiness();
    } catch (e) {
      setState(() {
        _loadingMessage = 'Connectivity check failed. Tap to retry.';
        _retryCount = _maxRetries; // Allow manual retry
        _debugInfo = 'Connectivity check error: ${e.toString()}';
      });
    }
  }

  Future<void> _checkServerReadiness() async {
    try {
      setState(() {
        _loadingMessage = 'Waking up server...';
        _debugInfo = null;
      });

      // Call wake-up route to ensure server is ready
      final wakeUpResult = await AuthService.wakeUpServer();

      if (wakeUpResult['success'] == true) {
        setState(() {
          _loadingMessage = 'Server ready! Checking status...';
          _retryCount = 0; // Reset retry count on success
          _debugInfo = wakeUpResult['debug'];
        });
        // Server is ready - proceed with auth status check
        _checkAuthStatus();
      } else {
        // Server not ready - retry with exponential backoff
        if (_retryCount < _maxRetries) {
          _retryCount++;
          final delaySeconds = _retryCount * 2; // 2s, 4s, 6s, 8s, 10s
          setState(() {
            _loadingMessage =
                'Server not ready, retrying in ${delaySeconds}s... (${_retryCount}/${_maxRetries})';
            _debugInfo = wakeUpResult['debug'] ?? wakeUpResult['message'];
          });

          if (mounted) {
            Future.delayed(Duration(seconds: delaySeconds), () {
              if (mounted) {
                _checkServerReadiness();
              }
            });
          }
        } else {
          // Max retries reached - show error and allow manual retry
          setState(() {
            _loadingMessage = 'Unable to connect to server. Tap to retry.';
            _debugInfo = wakeUpResult['debug'] ?? wakeUpResult['message'];
          });
        }
      }
    } catch (e) {
      // Network error - retry with exponential backoff
      if (_retryCount < _maxRetries) {
        _retryCount++;
        final delaySeconds = _retryCount * 2;
        setState(() {
          _loadingMessage =
              'Connection failed, retrying in ${delaySeconds}s... (${_retryCount}/${_maxRetries})';
          _debugInfo = 'Error: ${e.toString()}';
        });

        if (mounted) {
          Future.delayed(Duration(seconds: delaySeconds), () {
            if (mounted) {
              _checkServerReadiness();
            }
          });
        }
      } else {
        // Max retries reached
        setState(() {
          _loadingMessage = 'Connection failed. Tap to retry.';
          _debugInfo = 'Error: ${e.toString()}';
        });
      }
    }
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
        // Validate token and refresh user data before proceeding to home
        final isValid = await AuthService.validateAndRefreshSession();
        if (isValid && mounted) {
          context.go('/home');
        } else if (mounted) {
          // Token invalid, go to login
          context.go('/auth/login');
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
      body: GestureDetector(
        onTap: _retryCount >= _maxRetries ? _resetAndRetry : null,
        child: Center(
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
                      // Loading indicator or retry icon
                      _retryCount >= _maxRetries
                          ? Icon(
                              Icons.refresh,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 48,
                            )
                          : CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                      const SizedBox(height: 16),
                      // Loading message
                      Text(
                        _loadingMessage,
                        style: AppTypography.body.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_retryCount >= _maxRetries)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Tap anywhere to retry',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      if (_debugInfo != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _debugInfo!,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _resetAndRetry() {
    setState(() {
      _retryCount = 0;
      _loadingMessage = 'Retrying connection...';
      _debugInfo = null; // Clear debug info on retry
    });

    // Start the process from the beginning
    _checkOnboardingStatus();
  }
}
