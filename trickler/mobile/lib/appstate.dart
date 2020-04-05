import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

class AppState with ChangeNotifier {
  // Bluetooth State
  BluetoothState _btState = BluetoothState.unknown;
  BluetoothState get btState => _btState;
  set btState(BluetoothState state) {
    _btState = state;
    notifyListeners();
  }

  // Bluetooth State Subscription
  StreamSubscription _btStateSub;
  StreamSubscription get btStateSub => _btStateSub;
  set btStateSub(StreamSubscription sub) {
    _btStateSub = sub;
    notifyListeners();
  }

  // Devices State
  List<BluetoothDevice> _devices = [];
  List<BluetoothDevice> get devices => _devices;
  set devices(List<BluetoothDevice> devices) {
    _devices = devices;
    notifyListeners();
  }

  // Connected Device State
  BluetoothDevice _connectedDevice;
  get connectedDevice => _connectedDevice;
  set connectedDevice(BluetoothDevice device) {
    _connectedDevice = device;
    notifyListeners();
  }

  // Is Connecting
  bool _isConnecting = false;
  get isConnecting => _isConnecting;
  set isConnecting(bool isConnecting) {
    _isConnecting = isConnecting;
    notifyListeners();
  }

  // Auto Connect Device
  BluetoothDevice _autoConnectDevice;
  get autoConnectDevice => _autoConnectDevice;
  set autoConnectDevice(BluetoothDevice autoConnectDevice) {
    _autoConnectDevice = autoConnectDevice;
    notifyListeners();
  }

  // Trickler Service
  BluetoothService _tricklerService;
  get tricklerService => _tricklerService;
  set tricklerService(BluetoothService service) {
    _tricklerService = service;
    notifyListeners();
  }

  // Trickler Characteristics
  Map<Guid, List<int>> _tricklerChars = {};
  get tricklerChars => _tricklerChars;
  set tricklerChars(Map<Guid, List<int>> tricklerChars) {
    _tricklerChars = tricklerChars;
    notifyListeners();
  }

  // Characteristic Subscriptions
  List<StreamSubscription> _subs = [];
  get subs  => _subs;
  set subs(List<StreamSubscription> subs) {
    _subs = subs;
    notifyListeners();
  }

}