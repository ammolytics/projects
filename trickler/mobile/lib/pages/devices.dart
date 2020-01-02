/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/index.dart';
import '../actions.dart';
import '../widgets/header.dart';

/// DevicesPage is responsible for passing the given connectToDevice,
/// and disconnect methods, as well as a title to the _DevicesPageState.

class DevicesPage extends StatefulWidget {
  final Function connectToDevice;
  final Function disconnect;
  DevicesPage({ Key key, this.connectToDevice, this.disconnect }) : super(key: key);

  final String title = 'Bluetooth Devices';

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

/// _DevicesPageState allows the user to attempt to connect and disconnect to a Trickler device.

class _DevicesPageState extends State<DevicesPage> {
  AppState _state;
  Function _dispatch;
  String _btDeviceName = 'Trickler';

  FlutterBlue _flutterBlue = FlutterBlue.instance;

  dynamic _scanSubscription;
  bool _isScanning = false;

  /// _scanDevices is responsible for scanning for near by bluetooth devices, and checking to
  /// see if the device is Trickler. If it finds trickler it will connect to the device and
  /// call _stopScan. If it is unable to find Trickler within 10 seconds it will call _stopScan.

  void _scanDevices() {
    try {
      bool foundPeripheral = false;
      setState(() {
        _isScanning = true;
      });
      // Listen for BT Devices for 10 seconds
      _scanSubscription = _flutterBlue.scan(timeout: const Duration(seconds: 10)).listen((scanResult) {
        if (scanResult.advertisementData.localName.length > 0) {
          print('\n>>> ${scanResult.device.name}, RSSI: ${scanResult.rssi} <<<\n\n');
        }
        // if (scanResult.advertisementData.localName == _btDeviceName && !foundPeripheral) {
        if (!foundPeripheral) {
          // Connect before 10 second timeout
          foundPeripheral = true;
          _dispatch(SetDevice(scanResult.device));
          widget.connectToDevice(scanResult.device);
          setState(() {}); // Get the new global state
          _stopScan();
        }
      }, onDone: () => _stopScan());
    } catch (e) {
      print(e.toString());
    }
  }

  /// _stopScan cancels the _scanSubscription and sets _scanSubscription
  /// and _isScanning back to their initial values.

  void _stopScan() {
    _scanSubscription?.cancel();
    setState(() {
      _scanSubscription = null;
      _isScanning = false;
    });
  }

  /// _getDeviceInfo returns a list of Text Widgets that represent the stability, unit, and weight
  /// characteristics' values, while connected to the device. Otherwise it returns a Text widget
  /// reflecting the current connectionStatus.

  Widget _getDeviceInfo() {
    BluetoothDevice device = _state.deviceState.device;
    BluetoothDeviceState status = _state.deviceState.connectionStatus;
    if (status == BluetoothDeviceState.connected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            child: Text("Connected to: ${device.name}",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding:EdgeInsets.only(bottom: 8.0),
            child: Text("Stability: ${_state.deviceState.getStability()}",
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Padding(
            padding:EdgeInsets.only(bottom: 8.0),
            child: Text("Weight: ${_state.deviceState.getWeight()}",
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Padding(
            padding:EdgeInsets.only(bottom: 8.0),
            child: Text("Unit: ${_state.deviceState.getUnit()}",
              style: TextStyle(
                fontSize: 18.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      );
    } else {
      String text= 'You are not connected to a device!';
      if (status == BluetoothDeviceState.connecting) {
        text = 'Connecting to a Trickler Device...';
      } else if (_isScanning) {
        text = 'Scanning for a Trickler Device...';
      } else if (_state.bluetoothState != BluetoothState.on) {
        text = 'Enable bluetooth to connect to Trickler';
      }
      return Text(text,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  /// _getActionButton returns an action button that corresponds to the current ConnectionStatus.
  /// The button shown when the device is disconnected will call _scanDevices onPressed. The
  /// button shown when the device is connected will call disconnect onPressed. The buttons shown
  /// during the scanning and connecting states are disabled and will not do anything onPressed.

  _getActionButton() {
    BluetoothDeviceState status = _state.deviceState.connectionStatus;
    FloatingActionButton button;

    var actionButtonMap = {
      BluetoothDeviceState.connected: FloatingActionButton(
        heroTag: 'Disconnect',
        onPressed: widget.disconnect,
        tooltip: 'Disconnect',
        backgroundColor: Colors.red,
        child: Icon(Icons.bluetooth_disabled),
      ),

      BluetoothDeviceState.connecting: FloatingActionButton(
        heroTag: 'Connecting',
        onPressed: () {},
        tooltip: 'Connecting...',
        backgroundColor: Colors.grey,
        child: Icon(Icons.bluetooth_connected),
      ),

      'scanning': FloatingActionButton(
        heroTag: 'Scanning',
        onPressed: () {},
        tooltip: 'Scanning...',
        backgroundColor: Colors.grey,
        child: Icon(Icons.bluetooth_searching),
      ),

      'default': FloatingActionButton(
        heroTag: 'ScanBTDevices',
        onPressed: _scanDevices,
        tooltip: 'Scan for Devices',
        backgroundColor: Colors.green,
        child: Icon(Icons.bluetooth_searching),
      ),
    };

    if (_isScanning) {
      button = actionButtonMap['scanning'];
    } else {
      button = actionButtonMap[status];
    }
    if (button == null) {
      button = actionButtonMap['default'];
    }

    return button;
  }

  @override
  Widget build(BuildContext context) {
    _dispatch = (action) => StoreProvider.of<AppState>(context).dispatch(action);
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        _state = state;
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
              child: Header(
              key: Key('Header'),
              title: widget.title,
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _getDeviceInfo(),
              ],
            ),
          ),
          floatingActionButton: _state.bluetoothState == BluetoothState.on ?
            _getActionButton() : null,
        );
      },
    );
  }
}