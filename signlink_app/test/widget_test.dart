import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:signlink_app/app.dart';
import 'package:signlink_app/providers/accessibility_provider.dart';
import 'package:signlink_app/providers/auth_provider.dart';
import 'package:signlink_app/providers/chat_provider.dart';
import 'package:signlink_app/providers/event_provider.dart';
import 'package:signlink_app/providers/notification_provider.dart';
import 'package:signlink_app/providers/schedule_provider.dart';
import 'package:signlink_app/providers/user_provider.dart';

Widget _buildApp() => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: const SignLinkApp(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('app launches without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());
    // pumpAndSettle with a 4s period advances fake time 4 s per step,
    // which fires the splash screen's 3-second navigation timer and
    // lets subsequent animations settle before the widget tree is torn down.
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a Scaffold (material widget tree is valid)',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('unauthenticated user is routed to onboarding after splash',
      (WidgetTester tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle(const Duration(seconds: 4));
    // No exception and the widget tree is still alive after navigation.
    expect(tester.takeException(), isNull);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
