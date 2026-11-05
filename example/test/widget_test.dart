import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  setUp(() async {
    PlayxPrefs.setMockInitialValues({});
    await PlayxPrefs.create();
    // Loads the real .env asset and the generated secure env.
    await PlayxEnv.load(envSettings);
  });

  tearDown(PlayxEnv.dispose);

  testWidgets('counter increments', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('uses env values and shows the environment page', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Playx Core'), findsOneWidget);
    expect(find.text('API: https://dev.example.com/api'), findsOneWidget);

    await tester.tap(find.byTooltip('Environment'));
    await tester.pumpAndSettle();

    expect(find.text('https://dev.example.com/api'), findsOneWidget);
    expect(find.text('30s'), findsOneWidget);
    expect(find.text('en | ar'), findsOneWidget);
    // Secure values are masked and never shown in full.
    await tester.dragUntilVisible(
      find.text('pk_t••••'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('pk_t••••'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
    expect(find.textContaining('pk_test_demo'), findsNothing);
  });
}
