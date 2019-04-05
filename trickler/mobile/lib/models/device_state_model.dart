part of 'index.dart';

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

  setCharacteristic(Guid uuid, List value) => this.characteristics.setCharacteristic(uuid, value);

  String getStability() => this.characteristics.stability;
  double getWeight() => this.characteristics.actualWeight;
  String getUnit() => this.characteristics.unit;

  /*
  String getStability() {
    List stability = this.characteristics.length > 0 ? this.characteristics[0] : [];
    return stability.length > 0 ? STABILITY_LIST[stability[0]] : '';
  }
  String getWeight() {
    List weight = this.characteristics.length > 1 ? this.characteristics[1] : [];
    return weight is List<int> ? utf8.decode(weight) : '';
  }

  String getUnit() {
    List unit = this.characteristics.length > 2 ? this.characteristics[2] : [];
    return unit.length > 0 ? UNIT_LIST[unit[0]] : '';
  }
  */

}