/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';

/// ToggleUnitButton is a custom InputDecoration. It creates a button that allows
/// the user to call the given toggleUnit callback, and display the given unitAbbr.

class ToggleUnitButton extends InputDecoration {
  ToggleUnitButton({
    String hintText,
    String unitAbbr,
    Function toggleUnit,
  }) : super(
    hintText: hintText,
    border: InputBorder.none,
    // Prefix centers the textField's Value
    prefix: SizedBox(
      width: 57.0,
      height: 40.0,
      child: Text(''),
    ),
    suffix: SizedBox(
      width: 57.0,
      height: 40.0,
      child: OutlineButton(
        onPressed: toggleUnit,
        child: Text(
          unitAbbr,
          key: Key('CurrentUnit'),
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        splashColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
      ),
    ),
  );
}
