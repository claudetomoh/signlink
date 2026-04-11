import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_routes.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

class SignUpSuccessScreen extends StatelessWidget {
  const SignUpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, size: 60, color: AppColors.success),
                ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ).fadeIn(duration: 300.ms),
                const SizedBox(height: 32),
                Text(
                  'Account Created!',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 300.ms).slideY(begin: 0.15, end: 0, delay: 300.ms, duration: 300.ms),
                const SizedBox(height: 12),
                Text(
                  'Your ${AppStrings.appName} account has been created successfully. Welcome to the DASS community!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary, height: 1.6),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms, duration: 300.ms).slideY(begin: 0.15, end: 0, delay: 400.ms, duration: 300.ms),
                const SizedBox(height: 48),
                PrimaryButton(
                  label: 'Go to Login',
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (r) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
