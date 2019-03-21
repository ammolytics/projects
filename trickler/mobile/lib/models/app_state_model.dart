part of 'index.dart';

class AppState {
  Measurement currentMeasurement;
  List<Measurement> measurementHistory;
  String connectionStatus;
  BluetoothDevice device;
  dynamic deviceConnection;
  BluetoothService service;
  List characteristics;

  AppState({
    this.currentMeasurement,
    this.measurementHistory,
    this.connectionStatus,
    this.device,
    this.deviceConnection,
    this.service,
    this.characteristics,
  });

  AppState.initialState()
  : currentMeasurement = Measurement(globals.grams, 0.0, 0.0, false),
    measurementHistory = <Measurement>[],
    connectionStatus = globals.disconnected,
    device = BluetoothDevice(id: DeviceIdentifier('000')),
    deviceConnection = null,
    service = null,
    characteristics = [[], [], []];

  getStatusColor() {
    if (this.connectionStatus == globals.disconnected) {
      return Color.fromARGB(255, 251, 118, 102);
    } else if (this.connectionStatus == globals.connecting) {
      return Color.fromARGB(255, 200, 200, 200);
    } else if (this.connectionStatus == globals.connected) {
      return Color.fromARGB(255, 79, 186, 248);
    }
    return Colors.white;
  }

  getStatusIcon() {
    if (this.connectionStatus == globals.disconnected) {
      return Icons.bluetooth_disabled;
    } else if (this.connectionStatus == globals.connecting) {
      return Icons.bluetooth_searching;
    } else if (this.connectionStatus == globals.connected) {
      return Icons.bluetooth_connected;
    }
    return Icons.bluetooth;
  }
}