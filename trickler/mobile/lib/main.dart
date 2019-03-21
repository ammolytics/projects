import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'model.dart';
import 'reducers.dart';
import 'home.dart';

void main() {
  final store = Store<AppState>(appStateReducer, initialState: AppState.initialState());

  runApp(MyApp(
    store: store,
  ));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  MyApp({ Key key, this.store }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Trickler Mobile',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return  HomePage(key: Key('HomePage'));
          },
        ),
      ),
    );
  }
}
