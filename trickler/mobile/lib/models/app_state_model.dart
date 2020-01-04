/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

part of 'index.dart';


const statusColors = {
  BluetoothDeviceState.disconnected: Color.fromARGB(255, 251, 118, 102),
  BluetoothDeviceState.connecting: Color.fromARGB(255, 200, 200, 200),
  BluetoothDeviceState.connected: Color.fromARGB(255, 79, 186, 248),
};

const statusIcons = {
  BluetoothDeviceState.disconnected: Icons.bluetooth_disabled,
  BluetoothDeviceState.connecting: Icons.bluetooth_searching,
  BluetoothDeviceState.connected: Icons.bluetooth_connected,
};


/// AppState is the model that represents the entirety of the global state for the application.
/// It contains a currentMeasurement, and a deviceState.

class AppState {
  Measurement currentMeasurement;
  DeviceState deviceState;
  BluetoothState bluetoothState;
  StreamSubscription btStateSubscription;
  bool shouldUpdatePeripheral;

  AppState({
    this.currentMeasurement,
    this.deviceState,
    this.bluetoothState,
    this.btStateSubscription,
    this.shouldUpdatePeripheral,
  });

  AppState.initialState()
  : currentMeasurement = Measurement(GRAINS, 0.0, 0.0, false, false),
    deviceState = DeviceState.initialState(),
    bluetoothState = BluetoothState.unknown,
    btStateSubscription = null,
    shouldUpdatePeripheral = true;

  /// getStatusColor returns a color that reflects the current connectionStatus
  getStatusColor() {
    var color = statusColors[this.deviceState.connectionStatus];
    if (color == null) {
      color = Colors.white;
    }
    return color;
  }

  /// getStatusIcon returns an icon that reflects the current connectionStatus
  getStatusIcon() {
    var icon = statusIcons[this.deviceState.connectionStatus];
    if (icon == null) {
      icon = Icons.bluetooth;
    }
    return icon;
  }
}