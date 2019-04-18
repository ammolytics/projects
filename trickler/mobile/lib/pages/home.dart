/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'dart:convert' show utf8;
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/index.dart';
import '../globals.dart';
import '../helpers.dart';

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

  HomePage({
    Key key,
    this.connectToDevice,
    this.disconnect,
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
  String _prevUnit = GRAINS;

  /// _syncTextField updates the textField to reflect the given targetWeight, as long
  /// as the user isn't currently using the textField to update the targetWeight value.

  void _syncTextField(double targetWeight, String unit) {
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

  /// _syncPeripheral updates the Trickler peripheral characteristics with the given targetWeight and unit.

  void _syncPeripheral(double targetWeight, String unit, bool shouldUpdateWeight, bool shouldUpdateUnit) {
    if (shouldUpdateWeight && shouldUpdateUnit) {
      _updatePeripheralChar(
        UNIT_CHAR_UUID,
        unit == GRAINS ? [0x00] : [0x01]
      ).then((_) {
        _updatePeripheralChar(
          TARGET_WEIGHT_CHAR_UUID,
          utf8.encode('$targetWeight')
        );
      });
      _prevUnit = unit;
      _prevTargetWeight = targetWeight;
    } else if (shouldUpdateWeight) {
      _updatePeripheralChar(
        TARGET_WEIGHT_CHAR_UUID,
        utf8.encode('$targetWeight')
      );
      _prevTargetWeight = targetWeight;
    } else if (shouldUpdateUnit) {
      _updatePeripheralChar(
        UNIT_CHAR_UUID,
        unit == GRAINS ? [0x00] : [0x01]
      );
      _prevUnit = unit;
    }
  }

  /// _syncStates calls _syncTextField if needed as well as _syncPeripheral. It has an optional
  /// override parameter that allows the textField to be synced with out the weight being updated.

  void _syncStates({ bool override = false }) {
    double targetWeight = _state.currentMeasurement.targetWeight;
    String unit = _state.currentMeasurement.unit;
    if (_prevTargetWeight != targetWeight || override) {
      _syncTextField(targetWeight, unit);
    }
    _syncPeripheral(targetWeight, unit, _prevTargetWeight != targetWeight, _prevUnit != unit);
  }

  /// _updatePeripheralChar attempts to write to the bluetooth device and update
  /// the characteristic with the given uuid to reflect the given value.

  Future _updatePeripheralChar(String uuid, dynamic value) {
    BluetoothDevice device = _state.deviceState.device;
    BluetoothService service = _state.deviceState.service;
    dynamic characteristic = service?.characteristics != null ?
      service.characteristics.where((char) => char.uuid.toString() == uuid).single : null;

    if (characteristic != null && characteristic.properties.write) {
      return device.writeCharacteristic(characteristic, value,
        type: CharacteristicWriteType.withResponse);
    }
    return Future(() {});
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
              _syncStates(override: true);
            },
            tooltip: 'Close Keyboard',
            backgroundColor: Colors.grey,
            child: Icon(Icons.keyboard_hide),
            mini: true,
          ) : AutoModeButton(
            key: Key('AutoModeButton'),
            state: _state,
            updatePeripheralChar: _updatePeripheralChar,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _dispatch = (action) => StoreProvider.of<AppState>(context).dispatch(action);
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        _state = state;
        _syncStates();
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
                  syncStates: () => _syncStates(override: true),
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
    );
  }
}