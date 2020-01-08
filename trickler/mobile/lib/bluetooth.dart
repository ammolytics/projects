import 'dart:async';
import 'package:opentrickler/appstate.dart';
import 'package:opentrickler/globals.dart';
import 'package:flutter_blue/flutter_blue.dart';


void connectToDevice(BluetoothDevice device, AppState appState, Function callback) async {
    print('Connecting to ${device.name}...');
    // Note: Devices fails to connect twice in a row.
    // Possible solution is re-scan and add the same devices on disconnect.
    appState.connectedDevice = device;
    bool errored = false;
    try {
      appState.isConnecting = true;
      await device.connect(autoConnect: false).timeout(Duration(seconds: 5));
      appState.isConnecting = false;
      print('Connected to ${device.name}');
    } on TimeoutException {
      print('Timed out while attempting to connect to ${device.name}');
      disconnectFromDevice(appState);
      errored = true;
    } catch (err) {
      print('Failed to connect to ${device.name}');
      print(err.toString());
      disconnectFromDevice(appState);
      errored = true;
    }
    if (!errored) {
      discoverTricklerService(appState, callback);
    }
  }

  void discoverTricklerService(AppState appState, Function callback) async {
    print('Discovering services on ${appState.connectedDevice.name}...');
    bool errored = false;
    try {
      List<BluetoothService> services = await appState.connectedDevice.discoverServices();
      BluetoothService tricklerService = services.singleWhere((s) => s.uuid.toString() == TRICKLER_SERVICE_UUID, orElse: () => null);
      if (tricklerService != null) {
        print('Found Trickler Service!');
        appState.tricklerService = tricklerService;
      } else {
        print('Unable to find Trickler Service.');
        disconnectFromDevice(appState);
        errored = true;
      }
    } catch (err) {
      print(err.toString());
      errored = true;
    }
    if (!errored) {
      readCharacteristics(appState, callback);
    }
  }

  void readCharacteristics(AppState appState, Function callback) async {
    print('Reading trickler characteristics...');
    List<BluetoothCharacteristic> chars = appState.tricklerService.characteristics;
    for (BluetoothCharacteristic char in chars) {
      if (char.properties.read && DONT_READ_CHARS.indexOf(char.uuid.toString()) == -1) {
        List<int> value = await char.read();
        appState.tricklerChars[char.uuid] = value;
        print('Read char: ${char.uuid}');
        if (char.properties.notify) {
          await char.setNotifyValue(true);
          StreamSubscription sub = char.value.listen((data) {
            appState.tricklerChars[char.uuid] = data;
          });
          print('Sub to char: ${char.uuid}');
          appState.subs.add(sub);
        }
      } else if (DONT_READ_CHARS.indexOf(char.uuid.toString()) == -1) {
        print('\n\n\nCAN\'T READ ${char.uuid.toString()}');
        print('\n\n${char.uuid.toString()} PROPERTIES');
        print('NOTIFY: ${char.properties.notify}');
        print('READ: ${char.properties.read}');
        print('WRITE: ${char.properties.write}\n\n');
      }
    }
    callback();
  }

  void disconnectFromDevice(AppState appState) {
    appState.subs.forEach((s) => s.cancel());
    appState.subs = [];
    print('Disconnecting from ${appState.connectedDevice.name}...');
    appState.connectedDevice.disconnect();
    appState.connectedDevice = null;
  }
