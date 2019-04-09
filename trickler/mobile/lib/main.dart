import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:redux/redux.dart';
import 'dart:async';

import 'globals.dart';
import 'actions.dart';
import 'models/index.dart';
import 'reducers/index.dart';
import 'pages/home.dart';

void main() {
  final store = Store<AppState>(appStateReducer, initialState: AppState.initialState());

  runApp(MyApp(
    store: store,
  ));
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;
  MyApp({ Key key, this.store }) : super(key: key);
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  _connectToDevice(BluetoothDevice device) {
    dynamic deviceConnection = flutterBlue
      .connect(device, timeout: Duration(seconds: 4))
      .listen((s) {
        store.dispatch(SetConnectionStatus(s));
        if (s == BluetoothDeviceState.connected) {
          _handleDeviceStateChange();
        } else {
          _disconnect();
        }
      }, onDone: _disconnect);
    store.dispatch(SetDeviceConnection(deviceConnection));
  }

  _handleDeviceStateChange() {
    store.state.deviceState.device.discoverServices().then((services) {
      List<BluetoothCharacteristic> chars = [];
      services.forEach((service) {
        if (service.uuid.toString() == TRICKLER_SERVICE_UUID) {
          store.dispatch(SetService(service));
          chars = service.characteristics;
        }
      });
      _readCharacteristics(chars, 0);
    });
  }
  
  _readCharacteristics(List<BluetoothCharacteristic> chars, int i) {
    BluetoothDevice device = store.state.deviceState.device;
    // Asynchronously read & subscribe to characteristics one at a time

    BluetoothCharacteristic char = chars[i];
    if (char.properties.read && DONT_READ_CHARS.indexOf(char.uuid.toString()) == -1) {
      device.readCharacteristic(char).then((readChar) async {
        store.dispatch(SetCharacteristic(char.uuid, readChar));
        if (char.properties.notify) {
          // Subscribe to chars with notifications
          await device.setNotifyValue(char, true);
          StreamSubscription sub = device.onValueChanged(char).listen((data) {
            store.dispatch(SetCharacteristic(char.uuid, data));
          });
          store.dispatch(AddSubscription(sub));
        }

        if (i + 1 < chars.length) {
          _readCharacteristics(chars, i + 1);
        }
      });
    } else if (DONT_READ_CHARS.indexOf(char.uuid.toString()) == -1) {
      print('\n\n\nCAN\'T READ ${char.uuid.toString()}');
      print('\n\n${char.uuid.toString()} PROPERTIES');
      print('NOTIFY: ${char.properties.notify}');
      print('READ: ${char.properties.read}');
      print('WRITE: ${char.properties.write}\n\n');
    }
  }

  _disconnect() {
    store.state.deviceState.characteristics.subscriptions.forEach((sub) {
      sub.cancel();
    });
    store.dispatch(ClearSubscriptions());
    print('\n\n\nDisconnecting...\n\n\n\n');
    store.state.deviceState.deviceConnection?.cancel();
    store.dispatch(ResetDeviceState());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Trickler Mobile',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: HomePage(
          key: Key('HomePage'),
          connectToDevice: (device) => _connectToDevice(device),
          disconnect: () => _disconnect(),
        ),
      ),
    );
  }
}
