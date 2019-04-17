/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.
import 'package:flutter/material.dart';

import '../pages/devices.dart';
import '../pages/history.dart';

class SideDrawer extends StatelessWidget {
  final Function connectToDevice;
  final Function disconnect;
  SideDrawer({ Key key, this.connectToDevice, this.disconnect }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/logo.png'),
                ),
                Text(
                  'Open Trickler',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 56, 56, 56),
            ),
          ),
          ListTile(
            title: Text(
              'Bluetooth Devices',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DevicesPage(
                    key: Key('DevicesPage'),
                    connectToDevice: this.connectToDevice,
                    disconnect: this.disconnect,
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              'Measurement History',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(key: Key('HistoryPage')),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
