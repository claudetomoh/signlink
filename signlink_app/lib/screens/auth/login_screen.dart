import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (success) {
      _routeByRole(auth.role);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Login failed'), backgroundColor: AppColors.error),
      );
    }
  }

  void _routeByRole(String role) {
    context.read<NotificationProvider>().startPolling();
    switch (role) {
      case 'student':
        Navigator.pushReplacementNamed(context, AppRoutes.studentDashboard);
      case 'interpreter':
        Navigator.pushReplacementNamed(context, AppRoutes.interpreterDashboard);
      case 'admin':
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.sign_language_rounded, size: 38, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Welcome Back', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your ${AppStrings.appName} account',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),
                TextFormField(
                  controller: _emailCtrl,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'you@ashesi.edu.gh',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  validator: Validators.password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                    child: const Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: AppStrings.login, onPressed: _login, isLoading: auth.isLoading),
                const SizedBox(height: 20),
                // Hint for demo
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Demo accounts', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                      const SizedBox(height: 4),
                      _demoHint('Student', 'alex.johnson@ashesi.edu.gh'),
                      _demoHint('Interpreter', 'kofi.mensah@ashesi.edu.gh'),
                      _demoHint('Admin', 'sarah.asante@ashesi.edu.gh'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.signUp),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _demoHint(String role, String email) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: GestureDetector(
          onTap: () {
            _emailCtrl.text = email;
            _passwordCtrl.text = 'Password1!';
          },
          child: Text(
            '$role: $email',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
      );
}
