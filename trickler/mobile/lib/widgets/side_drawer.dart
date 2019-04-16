/**
 * Copyright (c) Ammolytics and contributors. All rights reserved.
 * Released under the MIT license. See LICENSE file in the project root for details.
 */
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: 23,
                      height: 16,
                      child: Image.asset('assets/logo.png'),
                    ),
                    Text(
                      'Ammolytics',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                SizedBox( // This centers the text above
                  width: 5,
                  height: 16,
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
