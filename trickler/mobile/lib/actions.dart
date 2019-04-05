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

class ResetDeviceState {
  ResetDeviceState();
}

class SetDevice {
  final BluetoothDevice device;
  SetDevice(this.device);
}

class SetDeviceConnection {
  final dynamic deviceConnection;
  SetDeviceConnection(this.deviceConnection);
}

class SetConnectionStatus {
  final BluetoothDeviceState connectionStatus;
  SetConnectionStatus(this.connectionStatus);
}

class SetService {
  final BluetoothService service;
  SetService(this.service);
}

class SetCharacteristic {
  final Guid uuid;
  final List characteristic;
  SetCharacteristic(this.uuid, this.characteristic);
}

class AddMeasurementToHistory {
  final Measurement measurement;
  AddMeasurementToHistory(this.measurement);
}
