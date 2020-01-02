/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/index.dart';
import '../globals.dart';
import '../helpers.dart';
import '../actions.dart';

import '../widgets/header.dart';
import '../widgets/side_drawer.dart';
import '../widgets/weight_input.dart';
import '../widgets/weight_buttons.dart';
import '../widgets/auto_mode_button.dart';

/// HomePage is responsible for passing the given connectToDevice, and disconnect
/// methods, as well as a title and inputKey to the _HomePageState.

class HomePage extends StatefulWidget {
  final Function connectToDevice;
  final Function disconnect;
  final Function onDispose;

  HomePage({
    Key key,
    this.connectToDevice,
    this.disconnect,
    this.onDispose,
  }) : super(key: key);

  final String title = 'Open Trickler';
  final inputKey = new GlobalKey<WeightInputState>();

  @override
  _HomePageState createState() => _HomePageState();
}

/// _HomePageState is the main interface of the app. It allows the user to control the
/// targetWeight, unit, and autoMode of both the bluetooth device and the AppState.

class _HomePageState extends State<HomePage> {
  AppState _state;
  Function _dispatch;

  double _prevTargetWeight = 0.0;
  bool _prevAutoMode = false;
  String _prevUnit = GRAINS;

  /// _updateTextField updates the textField to reflect the current targetWeight, as long as the user
  /// isn't currently using the textField to update the targetWeight value. It has an optional
  /// override parameter that will update the textField without the weight being changed.

  void _updateTextField({ bool override = false }) {
    double targetWeight = _state.currentMeasurement.getFormattedWeight();
    String unit = _state.currentMeasurement.unit;
    if (_prevTargetWeight != targetWeight || override) {
      String weightString = targetWeight.toStringAsFixed(unit == GRAINS ? 2 : 3);
      TextEditingController controller = widget.inputKey.currentState.controller;
      FocusNode inputFocus = widget.inputKey.currentState.inputFocus;

      double weightFromText = double.parse(controller.text.length > 0 ? controller.text : '0.0');
      weightFromText = capWeight(weightFromText);
      weightFromText = roundWeight(weightFromText, unit);

      if (inputFocus.hasFocus && targetWeight != weightFromText) {
        inputFocus.unfocus();
        controller.text = targetWeight > 0 ? weightString : '';
      } else if (!inputFocus.hasFocus && weightString != controller.text) {
        controller.text = targetWeight > 0 ? weightString : '';
      }
    }
  }

  /// _updatePeripheral is responsible for detecting any changes to the currentMeasurement,
  /// and writing them to their respective peripheral characteristics.

  void _updatePeripheral() async {
    BluetoothService service = _state.deviceState.service;
    double targetWeight = _state.currentMeasurement.getFormattedWeight();
    bool autoMode = _state.currentMeasurement.isMeasuring;
    bool shouldUpdatePeripheral = _state.shouldUpdatePeripheral;
    String unit = _state.currentMeasurement.unit;
    dynamic char;

    char = getCharFromUUID(TARGET_WEIGHT_CHAR_UUID, service);
    if (_prevTargetWeight != targetWeight && char != null && shouldUpdatePeripheral) {
      await char.write(utf8.encode('$targetWeight'),
        type: CharacteristicWriteType.withResponse);
      _prevTargetWeight = targetWeight;
    }
    
    char = getCharFromUUID(UNIT_CHAR_UUID, service);
    if (_prevUnit != unit && char != null) {
      await char.write(unit == GRAINS ? [0x00] : [0x01],
        type: CharacteristicWriteType.withResponse);
      _prevUnit = unit;
    }

    char = getCharFromUUID(AUTO_MODE_CHAR_UUID, service);
    if (_prevAutoMode != autoMode && char != null) {
      await char.write(autoMode ? [0x01] : [0x00],
        type: CharacteristicWriteType.withResponse);
      _prevAutoMode = autoMode;
    }
  }

  /// _updateMeasurement updates any currentMeasurement values that
  /// are supposed to be overriden by the peripheral's state.

  _updateMeasurement() {
    double actualDeviceWeight = _state.deviceState.characteristics.actualWeight;
    double actualMeasurementWeight = _state.currentMeasurement.actualWeight;
    if (!actualDeviceWeight.isNaN && actualDeviceWeight != actualMeasurementWeight) {
      _dispatch(SetActualWeight(actualDeviceWeight));
    }
  }

  /// _getFloatingActionButton provides the keyboard close button when the keyboard
  /// is open, and the Toggle Auto Mode Button when the keyboard is closed.

  Widget _getFloatingActionButton() {
    FocusNode inputFocus = widget.inputKey.currentState?.inputFocus;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: inputFocus != null &&
        inputFocus.hasFocus &&
        MediaQuery.of(context).viewInsets.bottom > 0 ?
          FloatingActionButton(
            heroTag: 'closeKeyboard',
            onPressed: () {
              inputFocus.unfocus();
              _dispatch(SetShouldUpdatePeripheral(true));
              _updateTextField(override: true);
            },
            tooltip: 'Close Keyboard',
            backgroundColor: Colors.grey,
            child: Icon(Icons.keyboard_hide),
            mini: true,
          ) : AutoModeButton(
            key: Key('AutoModeButton'),
            state: _state,
            dispatch: _dispatch,
          ),
    );
  }

  /// _getScaffold returns a Material Scaffold, which contains
  /// all UI elements and widgets for the home page widget.

  Widget _getScaffold() {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Header(
          key: Key('Header'),
          title: widget.title,
        ),
      ),
      drawer: SideDrawer(
        key: Key('SideDrawer'),
        connectToDevice: widget.connectToDevice,
        disconnect: widget.disconnect,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            WeightInput(
              key: widget.inputKey,
              state: _state,
              dispatch: _dispatch,
              syncValue: () => _updateTextField(override: true),
            ),
            WeightButtons(
              key: Key('Weight Buttons'),
              state: _state,
              dispatch: _dispatch,
            ),
          ],
        ),
      ),
      floatingActionButton: _getFloatingActionButton(),
    );
  }

  @override
  Widget build(BuildContext context) {
    _dispatch = (action) => StoreProvider.of<AppState>(context).dispatch(action);

    /// StoreConnector provides the app with the current global AppState.
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        _state = state;
        _updateTextField();
        _updatePeripheral();
        _updateMeasurement();
        return _getScaffold();
      }
    );
  }

  @protected
  @mustCallSuper
  void dispose() {
    widget.onDispose();
    super.dispose();
  }
}