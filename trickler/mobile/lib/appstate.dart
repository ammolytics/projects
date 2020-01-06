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

}