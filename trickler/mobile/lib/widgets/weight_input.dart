/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import '../models/index.dart';
import '../actions.dart';
import '../globals.dart';

import '../widgets/toggle_unit_button.dart';

/// WeightInput is a StatefulWidget responsible for passing
/// the given AppState and dispatch Function to it's state.

class WeightInput extends StatefulWidget {
  final AppState state;
  final Function dispatch;
  final Function syncValue;

  WeightInput({
    Key key,
    this.state,
    this.dispatch,
    this.syncValue,
  }) : super(key: key);

  WeightInputState createState() => WeightInputState();
}

/// WeightInputState creates a TextField that allows the user to update the targetWeight value in the
/// AppState. It also provides a button allowing the user to toggle the current unit in the AppState.

class WeightInputState extends State<WeightInput> {
  TextEditingController controller = TextEditingController(text: '');
  FocusNode inputFocus = FocusNode();

  /// _setWeightFromText converts the given text into a valid
  /// double value, and dispatches it to the AppState.

  void _setWeightFromText(String text) {
    double newWeight = text.length > 0 ?
      double.parse(text) : 0.0;
    widget.dispatch(SetTargetWeight(newWeight));
  }

  /// _toggleUnit converts the targetWeight to it's corresponding value in the new unit. It then decides
  /// what the new unit should be and dispatches both the unit and targetWeight to the AppState.

  void _toggleUnit() {
    double weight = widget.state.currentMeasurement.targetWeight;
    String unit = widget.state.currentMeasurement.unit;
    weight = unit == GRAMS ? weight * 15.4324 : weight / 15.4324;
    unit = unit == GRAMS ? GRAINS : GRAMS;
    widget.dispatch(SetUnit(unit));
    widget.dispatch(SetTargetWeight(weight));
  }

  /// _handleFocus is a callback function intended to be used by a
  /// listener. It moves the users cursor to the end of the textField.

  void _handleFocus() {
    setState(() {
      controller.selection = TextSelection(
        baseOffset: controller.text.length,
        extentOffset: controller.text.length,
      );
    });
  }

  /// _getFocusNodeWithListener returns a FocusNode with a
  /// listener that calls _handleFocus on focus change.

  FocusNode _getFocusNodeWithListener() {
    inputFocus.addListener(_handleFocus);
    return inputFocus;
  }

  /// _getAbbrFromUnit selects and returns a String from the
  /// given abbr List based on the index of the current Unit.

  String _getAbbrFromUnit(List<String> abbr) {
    String unit = widget.state.currentMeasurement.unit;
    int i = UNIT_LIST.indexOf(unit);
    return abbr[i];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 20.0),
      child: TextField(
        key: Key('WeightInput'),
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: false
        ),
        controller: controller,
        /// TODO(cleanup): Is this necessary?
        focusNode: _getFocusNodeWithListener(),
        /// TODO(ux): This causes issues because it sends partial values. Use onSubmit instead.
        onChanged: _setWeightFromText,
        /// TODO(ux): Use onSubmitted instead?
        onEditingComplete: () {
          inputFocus.unfocus();
          widget.syncValue();
        },
        textAlign: TextAlign.center,
        textInputAction: TextInputAction.done,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        /// TODO(ux): Use inputFormatters to format and validate.
        decoration: ToggleUnitButton(
          hintText: _getAbbrFromUnit(['0.00', '0.000']),
          unitAbbr: _getAbbrFromUnit(['gr', 'g']),
          toggleUnit: _toggleUnit,
        ),
      ),
    );
  }

  /// deactivate is called before the widget is disposed.
  /// It is responsible for removing the input focus listener.

  @protected
  @mustCallSuper
  void deactivate() {
    inputFocus.removeListener(_handleFocus);
    super.deactivate();
  }
}