import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/common_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (mounted && success) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo and Title
                Icon(
                  Icons.account_balance_wallet,
                  size: 80,
                  color: AppConstants.primaryColor,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Text(
                  AppConstants.appName,
                  style: AppConstants.headingStyle.copyWith(
                    fontSize: 28,
                    color: AppConstants.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Digital Ledger for Your Business',
                  style: AppConstants.bodyStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: Validators.validateEmail,
                ),

                const SizedBox(height: AppConstants.paddingMedium),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: Validators.validatePassword,
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      children: [
                        CustomButton(
                          text: 'Login',
                          onPressed: _login,
                          isLoading: authProvider.isLoading,
                          width: double.infinity,
                          height: 50,
                        ),
                        if (authProvider.error != null) ...[
                          const SizedBox(height: AppConstants.paddingMedium),
                          Container(
                            padding: const EdgeInsets.all(
                                AppConstants.paddingMedium),
                            decoration: BoxDecoration(
                              color: AppConstants.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusMedium),
                              border: Border.all(
                                  color:
                                      AppConstants.errorColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppConstants.errorColor,
                                  size: 20,
                                ),
                                const SizedBox(
                                    width: AppConstants.paddingSmall),
                                Expanded(
                                  child: Text(
                                    authProvider.error!,
                                    style: AppConstants.bodyStyle.copyWith(
                                      color: AppConstants.errorColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                const SizedBox(height: AppConstants.paddingLarge),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppConstants.bodyStyle,
                    ),
                    GestureDetector(
                      onTap: _goToRegister,
                      child: Text(
                        'Register',
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // Features
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadiusMedium),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Key Features',
                        style: AppConstants.subHeadingStyle.copyWith(
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingSmall),
                      const _FeatureItem(
                        icon: Icons.people,
                        text: 'Manage Customers',
                      ),
                      const _FeatureItem(
                        icon: Icons.receipt,
                        text: 'Track Transactions',
                      ),
                      const _FeatureItem(
                        icon: Icons.analytics,
                        text: 'Generate Reports',
                      ),
                      const _FeatureItem(
                        icon: Icons.offline_bolt,
                        text: 'Works Offline',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: AppConstants.paddingSmall),
          Text(
            text,
            style: AppConstants.captionStyle.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
