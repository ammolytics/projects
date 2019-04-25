/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

part of 'index.dart';

/// DeviceState is the model that represents all data related to the bluetooth device and connection.
/// It contains a device, deviceConnection, connectionStatus, service, and characteristics.

class DeviceState {
  BluetoothDevice device;
  dynamic deviceConnection;
  BluetoothDeviceState connectionStatus;
  BluetoothService service;
  TricklerChars characteristics;

  DeviceState(
    this.device,
    this.deviceConnection,
    this.connectionStatus,
    this.service,
    this.characteristics
  );

  /// DeviceState.initialState is a method that initalizes a new instance of DeviceState to have default values.

  DeviceState.initialState()
  : device = BluetoothDevice(id: DeviceIdentifier('000')),
    deviceConnection = null,
    connectionStatus = BluetoothDeviceState.disconnected,
    service = null,
    characteristics = TricklerChars.initialState();

  FlutterBlue flutterBlue = FlutterBlue.instance;

  setDevice(BluetoothDevice device) {
    this.device = device;
  }

  setDeviceConnection(dynamic deviceConnection) {
    this.deviceConnection = deviceConnection;
  }

  setConnectionStatus(BluetoothDeviceState connectionStatus) {
    this.connectionStatus = connectionStatus;
  }

  setService(BluetoothService service) {
    this.service = service;
  }

  /// setCharacteristic is a helper method that abstracts the setCharacteristic method into DeviceState.

  setCharacteristic(Guid uuid, List value) => this.characteristics.setCharacteristic(uuid, value);

  /// getStability, getWeight, and getUnit are all helper methods that provide easy access to their respective data memebers.

  String getStability() => this.characteristics.stability;
  double getWeight() => this.characteristics.actualWeight;
  String getUnit() => this.characteristics.unit;

}