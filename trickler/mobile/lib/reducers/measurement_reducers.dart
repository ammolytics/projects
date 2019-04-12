/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
part of 'index.dart';

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