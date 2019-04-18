/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../models/index.dart';

/// Header is meant to be used as a Material appBar for every Scaffold. It will reflect
/// the given title, and the current connectionStatus of the global DeviceState.

class Header extends StatelessWidget {
  final String title;

  Header({ Key key, this.title }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(this.title),
      backgroundColor: Color.fromARGB(255, 56, 56, 56),
      actions: <Widget>[
        StoreConnector<AppState, List>(
          converter: (store) => [store.state.getStatusIcon(), store.state.getStatusColor()],
          builder: (context, status) {
            return SizedBox(
              width: 80.0,
              height: 60.0,
              child: Icon(status[0], color: status[1]),
            );
          }
        ),
      ],
    );
  }
}