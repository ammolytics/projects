/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

part of 'index.dart';

/// Measurement is the model that is the base representation of the data used in each measurement.

class Measurement {
  String unit;
  double targetWeight;
  double actualWeight = 0.0;
  bool isComplete = false;
  final startTime = DateTime.now();
  DateTime endTime;

  Measurement(this.unit, this.targetWeight, this.actualWeight, this.isComplete);

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

  /// setActualWeight is meant to be used in conjunction with the bluetooth weight characteristic
  /// subscription. It is supposed to set the end time stamp once the measurement is complete.

  setActualWeight(weight) {
    weight = capWeight(weight);
    weight = roundWeight(weight, this.unit);
    this.actualWeight = weight;
    if (this.actualWeight >= this.targetWeight) {
      this.isComplete = true;
      this.endTime = DateTime.now();
    }
  }
}