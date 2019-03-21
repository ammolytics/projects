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

BluetoothService service(BluetoothService state, dynamic action) {
  if (action is SetService) {
    return action.service;
  }
  return state;
}

int stability(int state, dynamic action) {
  if (action is SetStability) {
    return action.stability;
  }
  return state;
}