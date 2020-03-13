import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:opentrickler/appstate.dart';
import 'package:opentrickler/globals.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert' show utf8;

class TrickleTab extends StatelessWidget {

  List<int> getChar(AppState appState, String uuid) => appState.tricklerChars[Guid(uuid)];
  int getInt(List<int> char, int def) => char != null ? char[0] : def;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) =>
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Trickle Tab...'),
              Text(STABILITY_LIST[getInt(getChar(appState, STABLE_CHAR_UUID), 1)]),
              Text(UNIT_LIST[getInt(getChar(appState, UNIT_CHAR_UUID), 0)]),
              Text('Auto: ${getInt(getChar(appState, AUTO_MODE_CHAR_UUID), 0) != 0 ? 'On' : 'Off'}'),
              Text('Weight: ${double.parse(utf8.decode(getChar(appState, WEIGHT_CHAR_UUID)))}'),
              Text('Target: ${double.parse(utf8.decode(getChar(appState, TARGET_WEIGHT_CHAR_UUID)))}'),
            ],
          ),
        ),
    );
  }
}