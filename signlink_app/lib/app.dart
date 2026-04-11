import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'providers/accessibility_provider.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/sign_up_success_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/student_timetable.dart';
import 'screens/student/student_profile.dart';
import 'screens/student/events_list_screen.dart';
import 'screens/student/event_detail_screen.dart';
import 'screens/student/request_interpreter_flow.dart';
import 'screens/student/upload_timetable_screen.dart';
import 'screens/interpreter/interpreter_dashboard.dart';
import 'screens/interpreter/interpreter_schedule.dart';
import 'screens/interpreter/event_requests_screen.dart';
import 'screens/interpreter/confirm_availability_screen.dart';
import 'screens/interpreter/interpreter_profile.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/assign_interpreter_screen.dart';
import 'screens/admin/create_event_screen.dart';
import 'screens/shared/messages_list_screen.dart';
import 'screens/shared/chat_screen.dart';
import 'screens/shared/video_call_screen.dart';
import 'screens/shared/notifications_screen.dart';
import 'screens/shared/accessibility_settings_screen.dart';
import 'screens/shared/help_support_screen.dart';
import 'widgets/auth_guard.dart';

class SignLinkApp extends StatelessWidget {
  const SignLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSize = context.watch<AccessibilityProvider>().fontSize;
    return MaterialApp(
      title: 'SignLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _generateRoute,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(
          textScaler: TextScaler.linear(fontSize),
        ),
        child: child!,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      // ── Public / auth routes (no guard needed) ──────────────────────────
      case AppRoutes.splash:            page = const SplashScreen(); break;
      case AppRoutes.onboarding:        page = const OnboardingScreen(); break;
      case AppRoutes.login:             page = const LoginScreen(); break;
      case AppRoutes.signUp:            page = const SignUpScreen(); break;
      case AppRoutes.signUpSuccess:     page = const SignUpSuccessScreen(); break;
      case AppRoutes.forgotPassword:    page = const ForgotPasswordScreen(); break;

      // ── Student routes (OWASP A01 – role-restricted) ────────────────────
      case AppRoutes.studentDashboard:
        page = const AuthGuard(allowedRoles: ['student'], child: StudentDashboard()); break;
      case AppRoutes.studentTimetable:
        page = const AuthGuard(allowedRoles: ['student'], child: StudentTimetable()); break;
      case AppRoutes.studentProfile:
        page = const AuthGuard(allowedRoles: ['student'], child: StudentProfile()); break;
      case AppRoutes.eventsList:
        page = const AuthGuard(allowedRoles: ['student', 'admin'], child: EventsListScreen()); break;
      case AppRoutes.eventDetail:
        page = AuthGuard(
          allowedRoles: const ['student', 'admin'],
          child: EventDetailScreen(eventId: settings.arguments as String? ?? ''),
        ); break;
      case AppRoutes.requestStep1:
      case AppRoutes.requestStep2:
      case AppRoutes.requestStep3:
      case AppRoutes.requestEventType:
      case AppRoutes.requestDateTime:
      case AppRoutes.requestReview:
      case AppRoutes.requestSuccess:
        page = AuthGuard(
          allowedRoles: const ['student'],
          child: RequestInterpreterFlow(initialStep: _requestStep(settings.name!)),
        ); break;
      case AppRoutes.uploadTimetable:
        page = const AuthGuard(allowedRoles: ['student'], child: UploadTimetableScreen()); break;

      // ── Interpreter routes (OWASP A01 – role-restricted) ────────────────
      case AppRoutes.interpreterDashboard:
        page = const AuthGuard(allowedRoles: ['interpreter'], child: InterpreterDashboard()); break;
      case AppRoutes.interpreterSchedule:
        page = const AuthGuard(allowedRoles: ['interpreter'], child: InterpreterSchedule()); break;
      case AppRoutes.interpreterRequests:
        page = const AuthGuard(allowedRoles: ['interpreter'], child: EventRequestsScreen()); break;
      case AppRoutes.confirmAvailability:
        page = const AuthGuard(allowedRoles: ['interpreter'], child: ConfirmAvailabilityScreen()); break;
      case AppRoutes.interpreterProfile:
        page = const AuthGuard(allowedRoles: ['interpreter'], child: InterpreterProfile()); break;

      // ── Admin routes (OWASP A01 – role-restricted) ──────────────────────
      case AppRoutes.adminDashboard:
        page = const AuthGuard(allowedRoles: ['admin'], child: AdminDashboard()); break;
      case AppRoutes.manageUsers:
        page = const AuthGuard(allowedRoles: ['admin'], child: ManageUsersScreen()); break;
      case AppRoutes.assignInterpreter:
        page = AuthGuard(
          allowedRoles: const ['admin'],
          child: AssignInterpreterScreen(requestId: settings.arguments as String? ?? ''),
        ); break;
      case AppRoutes.createEvent:
        page = const AuthGuard(allowedRoles: ['admin'], child: CreateEventScreen()); break;

      // ── Shared authenticated routes (any logged-in role) ────────────────
      case AppRoutes.messages:
        page = const AuthGuard(child: MessagesListScreen()); break;
      case AppRoutes.chat:
        page = AuthGuard(
          child: ChatScreen(conversationId: settings.arguments as String? ?? ''),
        ); break;
      case AppRoutes.videoCall:
        page = const AuthGuard(child: VideoCallScreen()); break;
      case AppRoutes.notifications:
        page = const AuthGuard(child: NotificationsScreen()); break;
      case AppRoutes.accessibility:
        page = const AuthGuard(child: AccessibilitySettingsScreen()); break;
      case AppRoutes.help:
        page = const AuthGuard(child: HelpSupportScreen()); break;

      default:
        page = const SplashScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  int _requestStep(String route) {
    switch (route) {
      case AppRoutes.requestStep2:    return 1;
      case AppRoutes.requestStep3:    return 2;
      case AppRoutes.requestReview:   return 3;
      case AppRoutes.requestSuccess:  return 4;
      default:                        return 0;
    }
  }
}
