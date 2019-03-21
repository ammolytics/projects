import 'package:flutter_blue/flutter_blue.dart';
import 'actions.dart';
import 'model.dart';

Measurement currentMeasurementReducer(Measurement state, dynamic action) {
  if (action is SetCurrentMeasurement) {
    return action.measurement;
  } else if (action is SetUnit) {
    state.setUnit(action.unit);
  } else if (action is SetTargetWeight) {
    state.setTargetWeight(action.weight);
  } else if (action is SetActualWeight) {
    state.setActualWeight(action.weight);
  }
  return state;
}

List<Measurement> measuermentsReducer(List<Measurement> state, dynamic action) {
  if (action is AddMeasurementToHistory) {
    return []
      ..addAll(state)
      ..add(action.measurement);
  }
  return state;
}

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

AppState appStateReducer(AppState state, action) {
  return AppState(
    currentMeasurement: currentMeasurementReducer(state.currentMeasurement, action),
    measurementHistory: measuermentsReducer(state.measurementHistory, action),
    connectionStatus: connectionStatusReducer(state.connectionStatus, action),
    device: device(state.device, action),
    service: service(state.service, action),
  );
}
