/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import '../models/index.dart';
import '../actions.dart';

/// AutoModeButton creates a FloatingActionButton that allows the user to
/// toggle the auto mode characteristic on the bluetooth device.

class AutoModeButton extends StatelessWidget {
  final AppState state;
  final Function dispatch;

  AutoModeButton({
    Key key,
    this.state,
    this.dispatch,
  }) : super(key: key);

  /// _toggleAutoMode dispatches the opposite of the current isMeasuring value.

  void _toggleAutoMode() {
    bool autoMode = this.state.currentMeasurement.isMeasuring;
    this.dispatch(SetIsMeasuring(!autoMode));
  }

  @override
  Widget build(BuildContext context) {
    return this.state.currentMeasurement.isMeasuring ?
      FloatingActionButton(
        heroTag: 'turnAutoModeOff',
        onPressed: _toggleAutoMode,
        tooltip: 'Turn Off Auto Mode',
        backgroundColor: Colors.red,
        child: Icon(Icons.pause),
      ) : FloatingActionButton(
        heroTag: 'turnAutoModeOn',
        onPressed: _toggleAutoMode,
        tooltip: 'Turn On Auto Mode',
        backgroundColor: Colors.blue,
        child: Icon(Icons.play_arrow),
      );
  }
}