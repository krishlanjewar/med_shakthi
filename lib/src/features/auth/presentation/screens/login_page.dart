import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:med_shakthi/src/features/dashboard/pharmacy_home_screen.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/supplier_signup_page.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/signup_page.dart';
import 'package:med_shakthi/src/features/dashboard/supplier_dashboard.dart';
import 'package:med_shakthi/src/core/widgets/app_logo.dart';
import '../controllers/auth_controller.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      _handleNavigation();
    } else if (authController.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _onGoogleLoginPressed() async {
    final authController = context.read<AuthController>();
    final success = await authController.loginWithGoogle();

    if (success && mounted) {
      _handleNavigation();
    } else if (authController.errorMessage != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleNavigation() async {
    final authController = context.read<AuthController>();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final supplierData = await authController.checkSupplierStatus(user.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Login successful'),
        backgroundColor: Colors.green,
      ),
    );

    if (supplierData != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const SupplierDashboard()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const PharmacyHomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = const Color(0xFF6AA39B);
    final authController = context.watch<AuthController>();
    final isLoading = authController.isLoading;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        
                        // ─── HEADER SECTION ───
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              const AppLogo(size: 80),
                              const SizedBox(height: 16),
                              Text(
                                'Welcome Back',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Login to your account',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
        
                        const Spacer(flex: 1),
        
                        // ─── FORM SECTION ───
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _m3TextField(
                                controller: _emailController,
                                label: 'Email',
                                hint: 'name@example.com',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => value != null && value.contains('@')
                                    ? null
                                    : 'Enter a valid email',
                              ),
                              const SizedBox(height: 16),
                              _m3TextField(
                                controller: _passwordController,
                                label: 'Password',
                                hint: 'Enter password',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (value) => value != null && value.length >= 6
                                    ? null
                                    : 'Minimum 6 characters',
                              ),
                              
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Sign In Button
                                SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  onPressed: isLoading ? null : _onLoginPressed,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
        
                        const Spacer(flex: 1),
        
                        // ─── SOCIAL SECTION ───
                        Column(
                          children: [
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Or continue with',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.outline,
                                        ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _m3SocialButton(
                                  Icons.facebook,
                                  const Color(0xFF1877F2),
                                  onPressed: () {
                                    // TODO: Implement Facebook Login
                                  },
                                ),
                                const SizedBox(width: 16),
                                _m3SocialButton(
                                  Icons.g_mobiledata,
                                  const Color(0xFFEA4335),
                                  size: 36,
                                  onPressed: isLoading ? null : _onGoogleLoginPressed,
                                ),
                                const SizedBox(width: 16),
                                _m3SocialButton(
                                  Icons.apple,
                                  Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                  onPressed: () {
                                    // TODO: Implement Apple Login
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
        
                        const Spacer(flex: 2),
        
                        // ─── FOOTER SECTION ───
                        Column(
                          children: [
                            _footerLink(
                              text: "Don't have an account? ",
                              linkText: "Sign up",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignupPage()),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _footerLink(
                              text: "Are you a distributor? ",
                              linkText: "Register as Supplier",
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SupplierSignupPage()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _m3TextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _m3SocialButton(IconData icon, Color color, {double size = 24, VoidCallback? onPressed}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: size),
      ),
    );
  }

  Widget _footerLink({
    required String text,
    required String linkText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          children: [
            TextSpan(text: text),
            TextSpan(
              text: linkText,
              style: TextStyle(
                color: const Color(0xFF6AA39B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

