import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_routes.dart';
import '../providers/auth_provider.dart';

/// AuthGuard — OWASP A01 (Broken Access Control).
///
/// Wraps any protected screen. If the user is not authenticated, they are
/// immediately redirected to the login screen.  If they are authenticated but
/// lack the required role, they are sent to their own dashboard instead,
/// preventing horizontal privilege escalation.
///
/// Usage in [onGenerateRoute]:
/// ```dart
/// case AppRoutes.adminDashboard:
///   page = const AuthGuard(allowedRoles: ['admin'], child: AdminDashboard());
/// ```
class AuthGuard extends StatefulWidget {
  const AuthGuard({
    required this.child,
    this.allowedRoles = const [],
    super.key,
  });

  /// The screen to display when access is granted.
  final Widget child;

  /// Roles that are permitted to view [child].
  /// An empty list means any authenticated user is allowed.
  final List<String> allowedRoles;

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  void initState() {
    super.initState();
    // Defer the navigation check to the next frame so the widget tree is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      return;
    }
    if (widget.allowedRoles.isNotEmpty &&
        !widget.allowedRoles.contains(auth.role)) {
      _redirectToOwnDashboard(auth.role);
    }
  }

  void _redirectToOwnDashboard(String role) {
    final target = switch (role) {
      'student' => AppRoutes.studentDashboard,
      'interpreter' => AppRoutes.interpreterDashboard,
      'admin' => AppRoutes.adminDashboard,
      _ => AppRoutes.login,
    };
    Navigator.pushNamedAndRemoveUntil(context, target, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    // While the guard is evaluating, show a neutral loading indicator.
    if (!auth.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.allowedRoles.isNotEmpty &&
        !widget.allowedRoles.contains(auth.role)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _check());
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
