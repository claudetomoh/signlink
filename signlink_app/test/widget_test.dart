import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:signlink_app/app.dart';
import 'package:signlink_app/providers/auth_provider.dart';
import 'package:signlink_app/providers/schedule_provider.dart';
import 'package:signlink_app/providers/event_provider.dart';
import 'package:signlink_app/providers/chat_provider.dart';

void main() {
  testWidgets('SignLink app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ScheduleProvider()),
          ChangeNotifierProvider(create: (_) => EventProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const SignLinkApp(),
      ),
    );
    await tester.pump();
    // App should launch without throwing
    expect(tester.takeException(), isNull);
  });
}
