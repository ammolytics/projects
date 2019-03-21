import 'package:flutter_blue/flutter_blue.dart';
import '../actions.dart';
import '../models/index.dart';

part 'measurement_reducers.dart';
part 'peripheral_reducers.dart';

AppState appStateReducer(AppState state, action) {
  return AppState(
    currentMeasurement: currentMeasurementReducer(state.currentMeasurement, action),
    measurementHistory: measuermentsReducer(state.measurementHistory, action),
    connectionStatus: connectionStatusReducer(state.connectionStatus, action),
    device: device(state.device, action),
    deviceConnection:deviceConnection(state.deviceConnection, action),
    service: service(state.service, action),
    characteristics: characteristics(state.characteristics, action),
  );
}