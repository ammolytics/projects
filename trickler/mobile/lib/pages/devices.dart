/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/index.dart';
import '../actions.dart';
import '../widgets/header.dart';

class DevicesPage extends StatefulWidget {
  final Function connectToDevice;
  final Function disconnect;
  DevicesPage({ Key key, this.connectToDevice, this.disconnect }) : super(key: key);

  final String title = 'Bluetooth Devices';

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  AppState _state;
  Function _dispatch;
  String _btDeviceName = 'Trickler';

  FlutterBlue _flutterBlue = FlutterBlue.instance;

  dynamic _scanSubscription;

  void _scanDevices() {
    try {
      bool foundPeripheral = false;
      // Listen for BT Devices for 5 seconds
      _scanSubscription = _flutterBlue.scan(timeout: const Duration(seconds: 5)).listen((scanResult) {
        if (scanResult.advertisementData.localName == _btDeviceName && !foundPeripheral) {
          // Connect before 5 second timeout
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

  void _stopScan() {
    // Stop scanning...
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  Widget _getDeviceInfo() {
    BluetoothDevice device = _state.deviceState.device;
    if (device.id != DeviceIdentifier('000')) {
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
    }
    return Text('You are not connected to a device!',
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  _getActionButton() {
    BluetoothDevice device = _state.deviceState.device;
    if (device.id != DeviceIdentifier('000')) {
      return FloatingActionButton(
        heroTag: 'Disconnect',
        onPressed: widget.disconnect,
        tooltip: 'Disconnect',
        backgroundColor: Colors.red,
        child: Icon(Icons.bluetooth_disabled),
      );
    }
    return FloatingActionButton(
      heroTag: 'ScanBTDevices',
      onPressed: _scanDevices,
      tooltip: 'Scan for Devices',
      backgroundColor: Colors.green,
      child: Icon(Icons.bluetooth_searching),
    );
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
          floatingActionButton: _getActionButton(),
        );
      },
    );
  }
}