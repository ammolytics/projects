import 'model.dart';

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

class AddMeasurementToHistory {
  final Measurement measurement;
  AddMeasurementToHistory(this.measurement);
}
