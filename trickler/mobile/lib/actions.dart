import 'model.dart';
import 'package:flutter_blue/flutter_blue.dart';

class SetCurrentMeasurement {
  final Measurement measurement;
  SetCurrentMeasurement(this.measurement);
}

class SetCurrentActualWeight {
  final double weight;
  SetCurrentActualWeight(this.weight);
}

class SetConnectionStatus {
  final String connectionStatus;
  SetConnectionStatus(this.connectionStatus);
}

class SetDevice {
  final BluetoothDevice device;
  SetDevice(this.device);
}

class SetService {
  final BluetoothService service;
  SetService(this.service);
}

class AddMeasurementToHistory {
  final Measurement measurement;
  AddMeasurementToHistory(this.measurement);
}
