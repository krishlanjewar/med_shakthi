import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isLoading = authController.isLoading;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1A1A1A), const Color(0xFF121212)]
                : [const Color(0xFFEAF4F2), const Color(0xFFF6FBFA)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Center(child: AppLogo(size: 100)),
                  const SizedBox(height: 40),
                  _label('Email'),
                  _textField(
                    controller: _emailController,
                    hint: 'emailaddress@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Enter valid email',
                  ),
                  const SizedBox(height: 20),
                  _label('Password'),
                  _textField(
                    controller: _passwordController,
                    hint: 'Password',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) => value != null && value.length >= 6
                        ? null
                        : 'Minimum 6 characters',
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6AA39B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Social Login',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialIcon(
                        Icons.facebook,
                        const Color(0xFF1877F2),
                        onPressed: () {
                          // TODO: Implement Facebook Login
                        },
                      ),
                      const SizedBox(width: 20),
                      _socialIcon(
                        Icons.g_mobiledata,
                        const Color(0xFFEA4335),
                        size: 40,
                        onPressed: isLoading ? null : _onGoogleLoginPressed,
                      ),
                      const SizedBox(width: 20),
                      _socialIcon(
                        Icons.apple,
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        onPressed: () {
                          // TODO: Implement Apple Login
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'Sign up',
                              style: TextStyle(
                                color: const Color(0xFF6AA39B),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupplierSignupPage(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Are you a distributor? ',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withOpacity(0.7),
                              ),
                            ),
                            TextSpan(
                              text: 'Register as Supplier',
                              style: TextStyle(
                                color: const Color(0xFF6AA39B),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).textTheme.bodySmall?.color?.withOpacity(0.4),
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon, Color color, {double size = 30, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                Theme.of(context).brightness == Brightness.dark
                    ? 0.3
                    : 0.1,
              ),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}
