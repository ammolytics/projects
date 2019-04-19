/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import '../actions.dart';
import '../models/index.dart';

/// A reducer is a function that takes the previous state and an action, and then returns the next state.
/// These reducers create the next state by looking at the action type, which is represented by what object
/// the action is an instance of, and the action data, which is represented by the actions data members.

part 'measurement_reducers.dart';
part 'device_reducers.dart';

/// appStateReducer is a wrapper reducer that creates the global
/// AppState by combining the states of other reducers.

AppState appStateReducer(AppState state, action) {
  return AppState(
    currentMeasurement: currentMeasurementReducer(state.currentMeasurement, action),
    measurementHistory: measuermentsReducer(state.measurementHistory, action),
    deviceState: deviceStateReducer(state.deviceState, action),
  );
}