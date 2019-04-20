/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

part of 'index.dart';

/// currentMeasurementReducer is the reducer that handles all actions related to the global currentMeasurement data.

Measurement currentMeasurementReducer(Measurement state, dynamic action) {
  if (action is SetCurrentMeasurement) {
    return action.measurement;
  } else if (action is SetUnit) {
    state.setUnit(action.unit);
  } else if (action is SetTargetWeight) {
    state.setTargetWeight(action.weight);
  } else if (action is SetActualWeight) {
    state.setActualWeight(action.weight);
  } else if (action is SetIsMeasuring) {
    state.isMeasuring = action.isMeasuring;
  }
  return state;
}