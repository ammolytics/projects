/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

part of 'index.dart';

/// Measurement is the model that is the base representation of the data used in each measurement.

class Measurement {
  String unit;
  double targetWeight;
  double actualWeight;
  bool isMeasuring;
  bool isComplete;

  Measurement(
    this.unit,
    this.targetWeight,
    this.actualWeight,
    this.isMeasuring,
    this.isComplete,
  );

  final startTime = DateTime.now();
  DateTime endTime;

  setUnit(unit) {
    if (UNIT_LIST.indexOf(unit) != -1) {
      this.unit = unit;
    }
  }

  setTargetWeight(weight) {
    weight = capWeight(weight);
    weight = roundWeight(weight, this.unit);
    this.targetWeight = weight;
  }

  /// setActualWeight is a setter method responsible for updating
  /// the actualWeight, as well as isComplete, and endTime.

  setActualWeight(weight) {
    weight = capWeight(weight);
    weight = roundWeight(weight, this.unit);
    this.actualWeight = weight;
    if (this.actualWeight >= this.targetWeight && this.targetWeight != 0.0) {
      this.isComplete = true;
      this.endTime = DateTime.now();
    } else {
      this.isComplete = false;
      this.endTime = null;
    }
  }
}