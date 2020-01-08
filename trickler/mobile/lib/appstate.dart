import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';

class AppState with ChangeNotifier {
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