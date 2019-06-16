/// Copyright (c) Ammolytics and contributors. All rights reserved.
/// Released under the MIT license. See LICENSE file in the project root for details.

import 'package:flutter/material.dart';
import '../pages/devices.dart';
import '../pages/about.dart';

/// SideDrawer is meant to be used as a Material sideDrawer for any Scaffold that
/// requires Navigation functionallity. It is responsible for passing the given
/// connectToDevice, and disconnect methods to any page that requires them. As well
/// as providing the user the ability to navigate between pages.

class SideDrawer extends StatelessWidget {
  final Function connectToDevice;
  final Function disconnect;
  SideDrawer({ Key key, this.connectToDevice, this.disconnect }) : super(key: key);

  /// _getDrawerHeader creates a custom DrawerHeader to be used at the top of the SideDrawer.

  Widget _getDrawerHeader() {
    return DrawerHeader(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          _getDrawerHeader(),
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
              'About Open Trickler',
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
                  builder: (context) => AboutPage(
                    key: Key('AboutPage'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
