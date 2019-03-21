import 'package:flutter_blue/flutter_blue.dart';
import 'models/index.dart';

class SetCurrentMeasurement {
  final Measurement measurement;
  SetCurrentMeasurement(this.measurement);
}

class SetUnit {
  final String unit;
  SetUnit(this.unit);
}

class SetTargetWeight {
  final double weight;
  SetTargetWeight(this.weight);
}

class SetActualWeight {
  final double weight;
  SetActualWeight(this.weight);
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

class SetStability {
  final int stability;
  SetStability(this.stability);
}

class AddMeasurementToHistory {
  final Measurement measurement;
  AddMeasurementToHistory(this.measurement);
}
