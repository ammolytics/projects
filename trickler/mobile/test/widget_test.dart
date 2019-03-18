
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scale_controller/main.dart';

void main() {
  testWidgets('Units are toggleable', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    final Key cu = Key('CurrentUnit');

    Text t = tester.widget(find.byKey(cu));
    expect(t.data, equals('g'));

    await tester.tap(find.byKey(cu));
    await tester.pump();

    t = tester.widget(find.byKey(cu));
    expect(t.data, equals('gr'));
  });

  testWidgets('Weight input functions', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    final Key w = Key('WeightInput');

    await tester.enterText(find.byKey(w), '123.45');
    TextField f = tester.widget(find.byKey(w));
    expect(f.controller.value.text, equals('123.45'));
  });
}
