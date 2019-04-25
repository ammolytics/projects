/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import '../models/index.dart';
import '../actions.dart';
import '../globals.dart';

/// WeightButtons creates a pair of FloatingActionButtons that allow the user
/// to make small adjustments to the targetWeight for the currentMeasurement.

class WeightButtons extends StatelessWidget {
  final AppState state;
  final Function dispatch;

  WeightButtons({
    Key key,
    this.state,
    this.dispatch,
  }) : super(key: key);

  /// _handleIncrement decides whether to increment or decrement based on the given shouldIncrement bool.
  /// It will change the weight by 0.001 GRAMS or 0.02 GRAINS, and dispatch the new value to the AppState.

  void _handleIncrement(bool shouldIncrement) {
    double weight = this.state.currentMeasurement.targetWeight;
    double diff = this.state.currentMeasurement.unit == GRAMS ? 0.001 : 0.02;
    weight = shouldIncrement ? weight + diff : weight - diff;
    this.dispatch(SetTargetWeight(weight));
  }

  /// _getTooltip returns a tooltip notifying the user of how much the target weight will be changed by.

  String _getTooltip(String prefix) {
    String value = this.state.currentMeasurement.unit == GRAMS ? '0.001g' : '0.02gr';
    return "$prefix $value";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.0,
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'RemoveBtn',
            onPressed: () => _handleIncrement(false),
            tooltip: _getTooltip('Remove'),
            child: Icon(Icons.remove),
            backgroundColor: Colors.redAccent,
          ),
          FloatingActionButton(
            heroTag: 'AddBtn',
            onPressed: () => _handleIncrement(true),
            tooltip: _getTooltip('Add'),
            child: Icon(Icons.add),
            backgroundColor: Colors.blueAccent,
          ),
        ],
      ),
    );
  }
}