/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.
part of 'index.dart';

class AppState {
  Measurement currentMeasurement;
  List<Measurement> measurementHistory;
  DeviceState deviceState;

  AppState({
    this.currentMeasurement,
    this.measurementHistory,
    this.deviceState,
  });

  AppState.initialState()
  : currentMeasurement = Measurement(GRAINS, 0.0, 0.0, false),
    measurementHistory = <Measurement>[],
    deviceState = DeviceState.initialState();

  getStatusColor() {
    if (this.deviceState.connectionStatus == BluetoothDeviceState.disconnected) {
      return Color.fromARGB(255, 251, 118, 102);
    } else if (this.deviceState.connectionStatus == BluetoothDeviceState.connecting) {
      return Color.fromARGB(255, 200, 200, 200);
    } else if (this.deviceState.connectionStatus == BluetoothDeviceState.connected) {
      return Color.fromARGB(255, 79, 186, 248);
    }
    return Colors.white;
  }

  getStatusIcon() {
    if (this.deviceState.connectionStatus == BluetoothDeviceState.disconnected) {
      return Icons.bluetooth_disabled;
    } else if (this.deviceState.connectionStatus == BluetoothDeviceState.connecting) {
      return Icons.bluetooth_searching;
    } else if (this.deviceState.connectionStatus == BluetoothDeviceState.connected) {
      return Icons.bluetooth_connected;
    }
    return Icons.bluetooth;
  }
}