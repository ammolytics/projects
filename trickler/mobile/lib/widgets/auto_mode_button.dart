/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import '../models/index.dart';
import '../globals.dart';

/// AutoModeButton creates a FloatingActionButton that allows the user to
/// toggle the auto mode characteristic on the bluetooth device.

class AutoModeButton extends StatelessWidget {
  final AppState state;
  final Function updatePeripheralChar;

  AutoModeButton({
    Key key,
    this.state,
    this.updatePeripheralChar,
  }) : super(key: key);

  /// _toggleAutoMode is responsible for updating the AutoMode char to be the opposite of its current value.

  void _toggleAutoMode() {
    bool autoMode = this.state.deviceState.characteristics.autoMode;
    this.updatePeripheralChar(AUTO_MODE_CHAR_UUID, autoMode ? [0x00] : [0x01]);
  }

  @override
  Widget build(BuildContext context) {
    return this.state.deviceState.characteristics.autoMode ?
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