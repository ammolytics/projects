import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:redux/redux.dart';

import 'globals.dart' as globals;
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
        if (service.uuid.toString() == globals.tricklerServiceId) {
          store.dispatch(SetService(service));
          service.characteristics.forEach((char) {
            chars.add(char);
          });
        }
      });
      _readCharacteristics(chars, 0);
    });
  }

  _readCharacteristics(List<BluetoothCharacteristic> chars, int i) {
    BluetoothDevice device = store.state.deviceState.device;
    List characteristics = store.state.deviceState.characteristics;
    // Rucursively read characteristics one at a time
    List<String> charNames = ['STABLITY', 'WEIGHT', 'UNIT'];

    BluetoothCharacteristic char = chars[i];
    if (char.properties.read) {
      print('\n\n\nREADING ${charNames[i]}...\n\n\n');
      device.readCharacteristic(char).then((readChar) {
        print('\n\n${charNames[i]} PROPERTIES');
        print('NOTIFY: ${char.properties.notify}');
        print('READ: ${char.properties.read}');
        print('WRITE: ${char.properties.write}\n\n');
        print('${charNames[i]}: ${char.value}\n\n');
        // Update global state to reflect characteristics
        if (characteristics.length > i) {
          characteristics[i] = readChar;
        } else {
          characteristics.add(readChar);
        }
        store.dispatch(SetCharacteristic(i, characteristics[i]));
        if (i + 1 >= 3) {
          // Only loop through the first 3 characteristics.
          // This prevents index out of range error if
          // additional characteristics are available.
          return [readChar];
        }
        return List.from([readChar])..addAll(_readCharacteristics(chars, i + 1));
      });
    } else {
      print('\n\n\nCAN\'T READ ${charNames[i]}');
      print('\n\n${charNames[i]} PROPERTIES');
      print('NOTIFY: ${char.properties.notify}');
      print('READ: ${char.properties.read}');
      print('WRITE: ${char.properties.write}\n\n');
    }
  }

  _disconnect() {
    store.state.deviceState.deviceConnection?.cancel();
    print('\n\n\nDisconnecting...\n\n\n\n');
    store.dispatch(ResetDeviceState());
  }

  @override
  Widget build(BuildContext context) {
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
