/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

part of 'index.dart';

/// AppState is the model that represents the entirety of the global state for the application.
/// It contains a currentMeasurement, and a deviceState.

class AppState {
  Measurement currentMeasurement;
  DeviceState deviceState;
  BluetoothState bluetoothState;
  StreamSubscription btStateSubscription;

  AppState({
    this.currentMeasurement,
    this.deviceState,
    this.bluetoothState,
    this.btStateSubscription,
  });

  AppState.initialState()
  : currentMeasurement = Measurement(GRAINS, 0.0, 0.0, false, false),
    deviceState = DeviceState.initialState(),
    bluetoothState = BluetoothState.unknown,
    btStateSubscription = null;

  /// getStatusColor returns a color that reflects the current connectionStatus

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

  /// getStatusIcon returns an icon that reflects the current connectionStatus

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