import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import '../../config/app_routes.dart';
import '../../utils/constants.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardPage(
      icon: Icons.sign_language_rounded,
      title: 'Connect with Interpreters',
      subtitle: 'Request certified sign language interpreters for your classes, events, and meetings at Ashesi.',
    ),
    _OnboardPage(
      icon: Icons.calendar_month_rounded,
      title: 'Manage Your Schedule',
      subtitle: 'View your timetable, track interpreter assignments, and stay on top of your academic calendar.',
    ),
    _OnboardPage(
      icon: Icons.people_rounded,
      title: 'Inclusive Community',
      subtitle: 'Join a supportive environment where every student has equal access to academic resources.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (_, i) => _pages[i],
                ),
              ),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLG),
                child: PrimaryButton(
                  label: _page == _pages.length - 1 ? 'Get Started' : 'Next',
                  onPressed: _next,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
}

class _OnboardPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(icon, size: 56, color: AppColors.primary),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), duration: 400.ms),
            const SizedBox(height: 40),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 150.ms, duration: 300.ms).slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 300.ms),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 250.ms, duration: 300.ms).slideY(begin: 0.2, end: 0, delay: 250.ms, duration: 300.ms),
          ],
        ),
      );
}
