part of 'index.dart';

String connectionStatusReducer(String state, dynamic action) {
  if (action is SetConnectionStatus) {
    return action.connectionStatus;
  }
  return state;
}

BluetoothDevice device(BluetoothDevice state, dynamic action) {
  if (action is SetDevice) {
    return action.device;
  }
  return state;
}

dynamic deviceConnection(dynamic state, dynamic action) {
  if (action is SetDeviceConnection) {
    return action.deviceConnection;
  }
  return state;
}

BluetoothService service(BluetoothService state, dynamic action) {
  if (action is SetService) {
    return action.service;
  }
  return state;
}

List characteristics(List state, dynamic action) {
  if (action is UpdateCharacteristic) {
    state[action.index] = action.characteristic;
    return state;
  }
  return state;
}