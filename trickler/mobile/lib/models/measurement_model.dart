part of 'index.dart';

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
    weight = this.capWeight(weight);
    weight = this.roundWeight(weight);
    this.targetWeight = weight;
  }

  setActualWeight(weight) {
    weight = this.capWeight(weight);
    weight = this.roundWeight(weight);
    this.actualWeight = weight;
    if (this.actualWeight >= this.targetWeight) {
      this.isComplete = true;
      this.endTime =DateTime.now();
    }
  }

  capWeight(weight) {
    if (weight >= 1000.0) {
      weight = 999.99;
    } else if (weight < 0.0) {
      weight = 0.0;
    }
    return weight;
  }

  roundWeight(weight) {
    double value = double.parse(weight.toStringAsFixed(4));
    int decimals = this.unit == GRAMS ? 3 : 2;
    decimals = pow(10, decimals);
    value *= decimals;
    value = value.round() / decimals;
    return value;
  }
}