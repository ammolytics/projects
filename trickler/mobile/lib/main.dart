/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:redux/redux.dart';

import 'bluetooth.dart';
import 'models/index.dart';
import 'reducers/index.dart';
import 'pages/home.dart';

void main() {
  final store = Store<AppState>(appStateReducer, initialState: AppState.initialState());

  runApp(MyApp(
    store: store,
  ));
}

class MyApp extends BluetoothApp {
  final Store<AppState> store;
  MyApp({ Key key, this.store }) : super(key: key);
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Open Trickler',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: HomePage(
          key: Key('HomePage'),
          connectToDevice: (device) => connectToDevice(device),
          disconnect: () => disconnect(),
        ),
      ),
    );
  }
}
