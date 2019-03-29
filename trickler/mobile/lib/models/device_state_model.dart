part of 'index.dart';

class DeviceState {

  BluetoothDevice device;
  dynamic deviceConnection;
  BluetoothDeviceState connectionStatus;
  BluetoothService service;
  List characteristics;

  DeviceState(
    this.device,
    this.deviceConnection,
    this.connectionStatus,
    this.service,
    this.characteristics
  );

  DeviceState.initialState()
  : device = BluetoothDevice(id: DeviceIdentifier('000')),
    deviceConnection = null,
    connectionStatus = BluetoothDeviceState.disconnected,
    service = null,
    characteristics = [[], [], []];

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

  setCharacteristic(int i, List characteristic) {
    if (characteristics.length > i) {
      characteristics[i] = characteristic;
    } else {
      characteristics.add(characteristic);
    }
  }

}