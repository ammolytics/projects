import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:opentrickler/appstate.dart';
import 'package:opentrickler/globals.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:convert' show utf8;

class TrickleTab extends StatelessWidget {

  List<int> getChar(AppState appState, String uuid) => appState.tricklerChars[Guid(uuid)];
  int getInt(List<int> char, int def) => char != null ? char[0] : def;
  double getValue(List<int> char, double def) => char != null ? double.parse(utf8.decode(char)) : def;

  Widget getStatus(AppState appState) {
    double weight = getValue(getChar(appState, WEIGHT_CHAR_UUID), 0.0);
    double target = getValue(getChar(appState, TARGET_WEIGHT_CHAR_UUID), 0.0);
    return weight == target ?
      Text('=', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)) :
      Icon(weight > target ? Icons.arrow_forward_ios : Icons.arrow_back_ios);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) =>
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment:  MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      '${getValue(getChar(appState, WEIGHT_CHAR_UUID), 0.0)} ${UNIT_LIST[getInt(getChar(appState, UNIT_CHAR_UUID), 0)]}',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Text(
                      STABILITY_LIST[getInt(getChar(appState, STABLE_CHAR_UUID), 5)],
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromARGB(150, 0, 0, 0)
                      )
                    ),
                    getStatus(appState)
                  ],
                ),
              )
            ],
          ),
        ),
    );
  }
}