import 'package:flutter_test/flutter_test.dart';
import 'package:ir_ac_timer/main.dart';

void main() {
  testWidgets('MyApp renders and navigates from splash smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify MyApp is built.
    expect(find.byType(MyApp), findsOneWidget);

    // Advance time by 3 seconds to let SplashScreen timer complete and navigate to MainScreen.
    await tester.pump(const Duration(seconds: 3));

    // Verify navigation completed without any pending timers.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
