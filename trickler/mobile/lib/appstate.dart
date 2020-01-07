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
  BluetoothDevice _connectedDevice = null;
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

}