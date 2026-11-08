import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';

void main() {
  testWidgets('navigator shortcuts', (tester) async {
    late BuildContext homeContext;
    late BuildContext detailContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            homeContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(homeContext.navigator, Navigator.of(homeContext));
    expect(
      homeContext.rootNavigator,
      Navigator.of(homeContext, rootNavigator: true),
    );
    expect(homeContext.canPop, isFalse);

    homeContext.navigator.push(
      MaterialPageRoute<void>(
        builder: (context) {
          detailContext = context;
          return const SizedBox();
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(detailContext.canPop, isTrue);

    detailContext.pop();
    await tester.pumpAndSettle();
    expect(homeContext.canPop, isFalse);
  });

  testWidgets('focusScope and form shortcuts', (tester) async {
    late BuildContext insideForm;
    late BuildContext outsideForm;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (outside) {
            outsideForm = outside;
            return Form(
              child: Builder(
                builder: (inside) {
                  insideForm = inside;
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );

    expect(insideForm.form, isA<FormState>());
    expect(outsideForm.form, isNull);
    expect(insideForm.focusScope, FocusScope.of(insideForm));
  });
}
