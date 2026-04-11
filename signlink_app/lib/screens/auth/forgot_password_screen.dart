import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.forgotPassword(_emailCtrl.text.trim());
    if (mounted) setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: _sent ? _SuccessView(email: _emailCtrl.text) : _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            isLoading: auth.isLoading,
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _FormView({required this.formKey, required this.emailCtrl, required this.isLoading, required this.onSubmit});

  @override
  Widget build(BuildContext context) => Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset_rounded, size: 40, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 28),
            Text('Forgot Password?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text(
              'Enter your registered email address and we\'ll send you a link to reset your password.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: emailCtrl,
              validator: Validators.email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 28),
            PrimaryButton(label: 'Send Reset Link', onPressed: onSubmit, isLoading: isLoading),
          ],
        ),
      );
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_read_rounded, size: 72, color: AppColors.success),
          const SizedBox(height: 24),
          Text('Check your email', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'We\'ve sent a password reset link to\n$email',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          PrimaryButton(label: 'Back to Login', onPressed: () => Navigator.pushReplacementNamed(context, '/login')),
        ],
      );
}
