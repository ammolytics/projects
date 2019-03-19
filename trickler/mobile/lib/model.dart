import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'dart:math';

class Measurement {
  String unit;
  double targetWeight;
  double actualWeight = 0.0;
  bool isComplete = false;
  final time = DateTime.now();

  Measurement(this.unit, this.targetWeight, this.actualWeight, this.isComplete);

  setActualWeight(weight) {
    double w;
    w = this.capWeight(weight);
    w = this.roundWeight(weight);
    this.actualWeight = w;
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
    int decimals = this.unit == globals.grams ? 3 : 2;
    decimals = pow(10, decimals);
    value *= decimals;
    value = value.round() / decimals;
    return value;
  }
}

class AppState {
  Measurement currentMeasurement;
  List<Measurement> measurementHistory;
  String connectionStatus;
  int counter;

  AppState({
    this.currentMeasurement,
    this.measurementHistory,
    this.connectionStatus,
    this.counter
  });

  AppState.initialState()
  : currentMeasurement = Measurement(globals.grams, 0.0, 0.0, false),
    measurementHistory = <Measurement>[],
    connectionStatus = globals.disconnected;

  getStatusColor() {
    if (this.connectionStatus == globals.disconnected) {
      return Color.fromARGB(255, 251, 118, 102);
    } else if (this.connectionStatus == globals.connecting) {
      return Color.fromARGB(255, 200, 200, 200);
    } else if (this.connectionStatus == globals.connected) {
      return Color.fromARGB(255, 79, 186, 248);
    }
    return Colors.white;
  }

  getStatusIcon() {
    if (this.connectionStatus == globals.disconnected) {
      return Icons.bluetooth_disabled;
    } else if (this.connectionStatus == globals.connecting) {
      return Icons.bluetooth_searching;
    } else if (this.connectionStatus == globals.connected) {
      return Icons.bluetooth_connected;
    }
    return Icons.bluetooth;
  }
}