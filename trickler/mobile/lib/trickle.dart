import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:opentrickler/appstate.dart';
import 'package:opentrickler/globals.dart';
import 'package:flutter_blue/flutter_blue.dart';

class TrickleTab extends StatelessWidget {

  List<int> getChar(AppState appState, String uuid) => appState.tricklerChars[Guid(uuid)];
  
  String getStability(List<int> char) => char != null ? STABILITY_LIST[char[0]] : 'DISCONNECTED';

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) =>
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Trickle Tab...'),
              Text(getStability(getChar(appState, STABLE_CHAR_UUID))),
            ],
          ),
        ),
    );
  }
}