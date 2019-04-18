/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scale_controller/widgets/weight_buttons.dart';
import 'package:scale_controller/reducers/index.dart';
import 'package:scale_controller/models/index.dart';

/// This is a TestApp. It is set up similar to a real MaterialApp
/// so that the widget we want to test, functions as expected.

class TestApp extends StatelessWidget {
  final store = Store<AppState>(appStateReducer, initialState: AppState.initialState());

  TestApp({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StoreProvider<AppState>(
        store: store,
        child: Scaffold(
          body: StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return Column(
                children: <Widget>[
                  Text(
                    state.currentMeasurement.targetWeight.toString(),
                    key: Key('TargetWeight'),
                  ),
                  WeightButtons(
                    key: Key('TestWeightButtons'),
                    state: state,
                    dispatch: (action) => store.dispatch(action),
                  ),
                ],
              );
            },
          ),
        )
      ),
    );
  }
}

void main() {

  /// This is an example UI/widget test. It renders the TestApp, and
  /// makes sure that the TargetWeight equals 0.0; Then it clicks the
  /// Add Button, and checks that the TargetWeight equals 0.02;
  testWidgets('Increment Button Works', (WidgetTester tester) async {
    await tester.pumpWidget(TestApp(key: Key('TestApp')));

    Text targetWeight = tester.widget(find.byKey(Key('TargetWeight')));
    expect(targetWeight.data, equals('0.0'));

    Finder addButton = find.byIcon(Icons.add);
    await tester.tap(addButton);
    await tester.pump();

    targetWeight = tester.widget(find.byKey(Key('TargetWeight')));
    expect(targetWeight.data, equals('0.02'));
  });
}
