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
    if (this.characteristics.length > i) {
      this.characteristics[i] = characteristic;
    } else {
      this.characteristics.add(characteristic);
    }
  }

  String getStability() {
    List stability = this.characteristics[0];
    return stability.length > 0 ? globals.stabilityList[stability[0]] : '';
  }
  String getWeight() {
    List weight = this.characteristics[1];
    return weight is List<int> ? utf8.decode(weight) : '';
  }

  String getUnit() {
    List unit = this.characteristics[2];
    return unit.length > 0 ? globals.unitsList[unit[0]] : '';
  }

}